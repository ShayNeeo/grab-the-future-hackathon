import asyncio
import json
import logging
import base64

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from google import genai
from google.genai import types

from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter()

MODEL = "models/gemini-3-flash-live"

SYSTEM_PROMPT = """Bạn là Justful, AI bảo vệ người cao tuổi Việt Nam khỏi lừa đảo.
Bạn đang nghe trực tiếp một cuộc điện thoại. Nhiệm vụ: phân tích real-time và cảnh báo nếu phát hiện dấu hiệu lừa đảo.

Khi nghe thấy nội dung đáng ngờ, hãy trả lời JSON hợp lệ:
{
  "type": "analysis",
  "risk_level": "critical | high | medium | low",
  "explanation": "lời giải thích ngắn gọn bằng tiếng Việt",
  "red_flags": [{"type": "tên_loại", "detail": "mô tả cụ thể"}],
  "suggested_action": "hành động nên làm"
}

Khi nghe nội dung bình thường, trả về:
{"type": "analysis", "risk_level": "low", "explanation": "Nội dung bình thường", "red_flags": [], "suggested_action": ""}

Luôn trả về JSON hợp lệ, KHÔNG có text bên ngoài JSON."""


@router.websocket("/live-monitor")
async def live_monitor(ws: WebSocket):
    await ws.accept()
    logger.info("Live monitor client connected")

    client = genai.Client(
        http_options={"api_version": "v1beta"},
        api_key=settings.gemma_api_key,
    )

    config = types.LiveConnectConfig(
        response_modalities=["TEXT"],
        media_resolution="MEDIA_RESOLUTION_MEDIUM",
        context_window_compression=types.ContextWindowCompressionConfig(
            trigger_tokens=104857,
            sliding_window=types.SlidingWindow(target_tokens=52428),
        ),
        system_instruction=types.Content(
            parts=[types.Part(text=SYSTEM_PROMPT)]
        ),
    )

    try:
        async with client.aio.live.connect(model=MODEL, config=config) as session:
            logger.info("Gemini Live session established")

            async def forward_to_gemini():
                """Read from Flutter WebSocket, send audio to Gemini."""
                try:
                    while True:
                        data = await ws.receive_json()
                        msg_type = data.get("type", "")

                        if msg_type == "audio":
                            audio_b64 = data.get("data", "")
                            if audio_b64:
                                audio_bytes = base64.b64decode(audio_b64)
                                await session.send(
                                    input={"data": audio_bytes, "mime_type": "audio/pcm"}
                                )
                        elif msg_type == "text":
                            text = data.get("text", "")
                            if text:
                                await session.send(input=text, end_of_turn=True)
                        elif msg_type == "stop":
                            break
                except WebSocketDisconnect:
                    logger.info("Flutter client disconnected")
                except Exception as e:
                    logger.error(f"forward_to_gemini error: {e}")

            async def forward_to_flutter():
                """Read from Gemini, send analysis back to Flutter."""
                try:
                    while True:
                        turn = session.receive()
                        async for response in turn:
                            if response.text:
                                try:
                                    # Try to parse as JSON analysis
                                    analysis = json.loads(response.text)
                                    await ws.send_json(analysis)
                                except json.JSONDecodeError:
                                    # Send as raw transcript
                                    await ws.send_json({
                                        "type": "transcript",
                                        "text": response.text,
                                    })
                except Exception as e:
                    logger.error(f"forward_to_flutter error: {e}")

            await asyncio.gather(
                forward_to_gemini(),
                forward_to_flutter(),
            )

    except Exception as e:
        logger.error(f"Gemini Live session error: {e}")
        try:
            await ws.send_json({
                "type": "error",
                "message": f"Không thể kết nối Gemini: {e}",
            })
        except Exception:
            pass
    finally:
        logger.info("Live monitor session ended")
        try:
            await ws.close()
        except Exception:
            pass
