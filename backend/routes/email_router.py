from fastapi import APIRouter, HTTPException

from backend.models.email_request import EmailGenerationRequest
from backend.services.groq_service import GroqService

router = APIRouter(prefix="/api/email", tags=["email"])
service = GroqService()


def _handle_exception(error: Exception):
    err_msg = str(error)
    if "HTTP 401" in err_msg or "unauthorized" in err_msg.lower() or "not configured" in err_msg.lower():
        raise HTTPException(status_code=401, detail=err_msg)
    if "HTTP 429" in err_msg or "rate limit" in err_msg.lower():
        raise HTTPException(status_code=429, detail=err_msg)
    if isinstance(error, ConnectionError):
        raise HTTPException(status_code=503, detail=err_msg)
    if isinstance(error, TimeoutError):
        raise HTTPException(status_code=504, detail=err_msg)
    raise HTTPException(status_code=500, detail=err_msg)


@router.post("/generate")
async def generate_email(request: EmailGenerationRequest):
    try:
        response = await service.generate_email(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/rewrite")
async def rewrite_email(request: EmailGenerationRequest):
    try:
        response = await service.rewrite_email(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/grammar")
async def grammar_email(request: EmailGenerationRequest):
    try:
        response = await service.improve_grammar(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/shorten")
async def shorten_email(request: EmailGenerationRequest):
    try:
        response = await service.shorten_email(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/expand")
async def expand_email(request: EmailGenerationRequest):
    try:
        response = await service.expand_email(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/translate")
async def translate_email(request: EmailGenerationRequest):
    try:
        response = await service.translate_email(request)
        return response
    except Exception as error:
        _handle_exception(error)


@router.post("/regenerate")
async def regenerate_email(request: EmailGenerationRequest):
    try:
        response = await service.regenerate_email(request)
        return response
    except Exception as error:
        _handle_exception(error)
