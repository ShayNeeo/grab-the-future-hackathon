from pydantic import BaseModel
from typing import Literal


class AnalyzeRequest(BaseModel):
    text: str
    image_base64: str | None = None
    history: list[dict] = []


class ContractRequest(BaseModel):
    image_base64: str


class ChatRequest(BaseModel):
    text: str
    history: list[dict] = []


class RedFlag(BaseModel):
    type: str
    detail: str


class AnalysisResponse(BaseModel):
    risk_level: Literal["critical", "high", "medium", "low"]
    case_type: str
    stage: str
    red_flags: list[RedFlag]
    manipulation_tactics: list[str]
    next_actions: list[str]
    cooling_off: bool
    cooling_off_hours: int = 48
    suggested_reply: str
    follow_up_questions: list[str] = []
