from fastapi import APIRouter, HTTPException
from openai import AsyncOpenAI
import json
import logging

from ..models.schemas import AnalyzeRequest, ContractRequest, ChatRequest, AnalysisResponse, FamilyAlertRequest, FamilyAlertResponse
from ..agents.prompts import SCAMSHIELD_SYSTEM_PROMPT, FAMILY_ALERT_PROMPT
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


@router.post("/family-alert", response_model=FamilyAlertResponse)
async def family_alert(req: FamilyAlertRequest):
    red_flags_text = "\n".join(
        f"  - {f.type}: {f.detail}" for f in req.red_flags
    )
    user_content = f"""Dữ liệu phân tích scam:
- Mức rủi ro: {req.risk_level}
- Loại lừa đảo: {req.case_type}
- Giai đoạn: {req.stage}
- Dấu hiệu nguy hiểm:
{red_flags_text}
- Chiến thuật thao túng: {", ".join(req.manipulation_tactics)}
- Hành động đề xuất: {", ".join(req.next_actions)}

Hãy tạo cảnh báo gia đình theo đúng schema JSON yêu cầu."""

    messages = [
        {"role": "system", "content": FAMILY_ALERT_PROMPT},
        {"role": "user", "content": user_content},
    ]
    try:
        resp = await client.chat.completions.create(
            model="gemma-4-31b-it",
            response_format={"type": "json_object"},
            messages=messages,
            max_tokens=1024,
            temperature=0.2,
        )
        raw = resp.choices[0].message.content
        logger.info("Family alert raw response: %s", raw)
        data = json.loads(raw)
        return FamilyAlertResponse(**data)
    except json.JSONDecodeError as e:
        logger.error("JSON decode error (family-alert): %s", e)
        raise HTTPException(status_code=502, detail=f"Model returned invalid JSON: {e}")
    except Exception as e:
        logger.exception("Family alert API call failed: %s", e)
        raise HTTPException(status_code=502, detail=str(e))
