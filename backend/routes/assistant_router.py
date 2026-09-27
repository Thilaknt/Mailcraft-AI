from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from backend.services.assistant_service import AssistantService, ChatRequest, ChatResponse
from backend.services.groq_service import GroqService

router = APIRouter(prefix="/api/assistant", tags=["assistant"])
assistant_service = AssistantService()
groq_service = GroqService()


@router.post("/chat", response_model=ChatResponse)
async def chat_with_assistant(request: ChatRequest):
    try:
        response = await assistant_service.process_chat(request)
        return response
    except Exception as error:
        err_msg = str(error)
        if "HTTP 401" in err_msg or "unauthorized" in err_msg.lower() or "not configured" in err_msg.lower():
            raise HTTPException(status_code=401, detail=err_msg)
        if "HTTP 429" in err_msg or "rate limit" in err_msg.lower():
            raise HTTPException(status_code=429, detail=err_msg)
        if isinstance(error, ConnectionError):
            raise HTTPException(status_code=503, detail=err_msg)
        raise HTTPException(status_code=500, detail=err_msg)


@router.post("/transcribe")
async def transcribe_audio(
    file: UploadFile = File(...),
    language: str | None = Form(None),
):
    try:
        content = await file.read()
        if not content or len(content) == 0:
            return {"text": "", "error": "No speech detected"}

        filename = file.filename or "recording.m4a"
        transcribed_text = await groq_service.transcribe_audio(content, filename, language)

        if not transcribed_text:
            return {"text": "", "error": "No speech detected"}

        return {"text": transcribed_text}
    except Exception as error:
        err_msg = str(error)
        if "HTTP 401" in err_msg or "unauthorized" in err_msg.lower():
            raise HTTPException(status_code=401, detail=err_msg)
        if "HTTP 429" in err_msg:
            raise HTTPException(status_code=429, detail=err_msg)
        raise HTTPException(status_code=500, detail=err_msg)
