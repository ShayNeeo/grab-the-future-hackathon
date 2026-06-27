from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from openai import AsyncOpenAI
import json
import logging

from ..models.schemas import AnalyzeRequest, ContractRequest, ChatRequest, AnalysisResponse
from ..agents.prompts import SCAMSHIELD_SYSTEM_PROMPT
from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter()

client = AsyncOpenAI(
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
    api_key=settings.gemma_api_key,
)


def _repair_json(json_str: str) -> str:
    json_str = json_str.strip()
    if not json_str:
        return "{}"
    stack = []
    in_quote = False
    escaped = False
    repaired = []
    
    for char in json_str:
        if in_quote:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                in_quote = False
            repaired.append(char)
        else:
            if char == '"':
                in_quote = True
            elif char in ('{', '['):
                stack.append(char)
            elif char in ('}', ']'):
                if stack:
                    stack.pop()
            repaired.append(char)
            
    if in_quote:
        repaired.append('"')
        
    repaired_str = "".join(repaired).strip()
    while repaired_str.endswith(','):
        repaired_str = repaired_str[:-1].strip()
        
    while stack:
        opener = stack.pop()
        if opener == '{':
            repaired_str += '}'
        elif opener == '[':
            repaired_str += ']'
            
    return repaired_str


def _build_content(text: str, image_base64: str | None) -> list[dict]:
    # Sanitize delimiter tokens from user input to prevent injection
    sanitized = text.replace("[USER SUBMITTED CONTENT END]", "[USER CONTENT END - SANITIZED]")
    delimited_text = (
        "[USER SUBMITTED CONTENT START]\n"
        f"{sanitized}\n"
        "[USER SUBMITTED CONTENT END]"
    )
    content: list[dict] = [{"type": "text", "text": delimited_text}]
    if image_base64:
        content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{image_base64}"},
        })
    return content


async def _call_model(messages: list[dict]) -> AnalysisResponse:
    try:
        resp = await client.chat.completions.create(
            model="gemini-2.5-flash",
            response_format={"type": "json_object"},
            messages=messages,
            max_tokens=4096,
            temperature=0.1,
        )
        raw = resp.choices[0].message.content
        logger.info("Gemini raw response: %s", raw)
        
        clean_raw = raw.strip()
        if "</thought>" in clean_raw:
            clean_raw = clean_raw.split("</thought>")[-1].strip()
            
        try:
            data = json.loads(clean_raw)
        except json.JSONDecodeError:
            start = clean_raw.find('{')
            end = clean_raw.rfind('}')
            if start == -1 or end == -1 or end < start:
                raise
            repaired = _repair_json(clean_raw[start:end+1])
            data = json.loads(repaired)
        return AnalysisResponse(**data)
    except json.JSONDecodeError as e:
        logger.error("JSON decode error: %s", e)
        raise HTTPException(status_code=502, detail=f"Model returned invalid JSON: {e}")
    except Exception as e:
        logger.exception("Gemini API call failed: %s", e)
        raise HTTPException(status_code=502, detail=str(e))


async def _stream_model(messages: list[dict]):
    try:
        resp = await client.chat.completions.create(
            model="gemini-2.5-flash",
            response_format={"type": "json_object"},
            messages=messages,
            max_tokens=4096,
            temperature=0.1,
            stream=True,
        )
        async for chunk in resp:
            content = chunk.choices[0].delta.content
            if content:
                yield content
    except Exception as e:
        logger.exception("Gemini API call failed during streaming: %s", e)
        # Yield a safe JSON sentinel — never expose internal exception details
        yield '{"__error__":true}'


@router.post("/analyze")
async def analyze(req: AnalyzeRequest):
    messages = [{"role": "system", "content": SCAMSHIELD_SYSTEM_PROMPT}]
    messages.extend(req.history)
    messages.append({
        "role": "user",
        "content": _build_content(req.text, req.image_base64),
    })
    return StreamingResponse(_stream_model(messages), media_type="text/plain")


@router.post("/chat")
async def chat(req: ChatRequest):
    messages = [{"role": "system", "content": SCAMSHIELD_SYSTEM_PROMPT}]
    messages.extend(req.history)
    sanitized_text = req.text.replace("[USER SUBMITTED CONTENT END]", "[USER CONTENT END - SANITIZED]")
    delimited_text = (
        "[USER SUBMITTED CONTENT START]\n"
        f"{sanitized_text}\n"
        "[USER SUBMITTED CONTENT END]"
    )
    messages.append({"role": "user", "content": delimited_text})
    return StreamingResponse(_stream_model(messages), media_type="text/plain")


@router.post("/contract", response_model=AnalysisResponse)
async def contract(req: ContractRequest):
    messages = [
        {"role": "system", "content": SCAMSHIELD_SYSTEM_PROMPT},
        {
            "role": "user",
            "content": _build_content(
                "Đây là ảnh hợp đồng hoặc tài liệu. Hãy phân tích các điều khoản rủi ro.",
                req.image_base64,
            ),
        },
    ]
    return await _call_model(messages)
