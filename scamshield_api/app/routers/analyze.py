from fastapi import APIRouter, HTTPException
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


def _build_content(text: str, image_base64: str | None) -> list[dict]:
    content: list[dict] = [{"type": "text", "text": text}]
    if image_base64:
        content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{image_base64}"},
        })
    return content


async def _call_model(messages: list[dict]) -> AnalysisResponse:
    try:
        resp = await client.chat.completions.create(
            model="gemma-4-31b-it",
            response_format={"type": "json_object"},
            messages=messages,
            max_tokens=4096,
            temperature=0.1,
        )
        raw = resp.choices[0].message.content
        logger.info("Gemini raw response: %s", raw)
        data = json.loads(raw)
        return AnalysisResponse(**data)
    except json.JSONDecodeError as e:
        logger.error("JSON decode error: %s", e)
        raise HTTPException(status_code=502, detail=f"Model returned invalid JSON: {e}")
    except Exception as e:
        logger.exception("Gemini API call failed: %s", e)
        raise HTTPException(status_code=502, detail=str(e))


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze(req: AnalyzeRequest):
    messages = [{"role": "system", "content": SCAMSHIELD_SYSTEM_PROMPT}]
    messages.extend(req.history)
    messages.append({
        "role": "user",
        "content": _build_content(req.text, req.image_base64),
    })
    return await _call_model(messages)


@router.post("/chat", response_model=AnalysisResponse)
async def chat(req: ChatRequest):
    messages = [{"role": "system", "content": SCAMSHIELD_SYSTEM_PROMPT}]
    messages.extend(req.history)
    messages.append({"role": "user", "content": req.text})
    return await _call_model(messages)


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
