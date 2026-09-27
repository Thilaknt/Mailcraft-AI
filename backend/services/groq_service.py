from __future__ import annotations

import json
import logging
import os
import re
import time
import uuid

import httpx
from dotenv import load_dotenv

from backend.models.email_request import EmailGenerationRequest
from backend.models.email_response import EmailResponse
from backend.services.prompt_builder import PromptBuilder

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("MailCraftBackend")

GROQ_BASE_URL = "https://api.groq.com/openai/v1"
TIMEOUT_SECONDS = 30.0


class GroqService:
    def __init__(self) -> None:
        self.prompt_builder = PromptBuilder()

    def is_api_key_configured(self) -> bool:
        api_key = os.getenv("GROQ_API_KEY", "").strip()
        if not api_key:
            return False
        if api_key in ["your_key_here", "your_groq_api_key_here", "your_api_key_here"]:
            return False
        return True

    def _get_config(self) -> tuple[str, str]:
        api_key = os.getenv("GROQ_API_KEY", "").strip()
        is_valid = self.is_api_key_configured()
        logger.info(f"GROQ_API_KEY loaded: {is_valid}")

        if not is_valid:
            raise ValueError(
                "Groq API key is not configured. Please set a valid GROQ_API_KEY in the backend .env file."
            )

        model = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile").strip()
        return api_key, model

    async def transcribe_audio(self, file_bytes: bytes, filename: str, language: str | None = None) -> str:
        api_key, _ = self._get_config()
        req_id = f"stt-{uuid.uuid4().hex[:6]}"
        logger.info(f"[Voice] Upload started [req_id: {req_id}, filename: {filename}, size: {len(file_bytes)} bytes]")

        headers = {
            "Authorization": f"Bearer {api_key}",
        }

        data = {
            "model": "whisper-large-v3-turbo",
            "response_format": "json",
            "temperature": "0",
        }
        if language and language.strip():
            data["language"] = language.strip()

        files = {
            "file": (filename, file_bytes, "audio/m4a"),
        }

        logger.info(f"[Voice] Transcription request started [req_id: {req_id}, model: whisper-large-v3-turbo]")
        start_time = time.time()

        async with httpx.AsyncClient(timeout=45.0) as client:
            try:
                response = await client.post(
                    f"{GROQ_BASE_URL}/audio/transcriptions",
                    headers=headers,
                    data=data,
                    files=files,
                )
                elapsed = time.time() - start_time
                logger.info(f"[Voice] Groq transcription status: {response.status_code} in {elapsed:.2f}s")
                response.raise_for_status()

                res_json = response.json()
                transcribed_text = str(res_json.get("text", "")).strip()
                logger.info(f"[Voice] Transcription received: '{transcribed_text}'")
                return transcribed_text
            except httpx.HTTPStatusError as http_err:
                logger.error(f"[Voice] Groq Whisper HTTP error {http_err.response.status_code}: {http_err.response.text}")
                raise ValueError(f"Groq Whisper error (HTTP {http_err.response.status_code}).") from http_err
            except Exception as err:
                logger.error(f"[Voice] Transcription failed: {err}")
                raise ConnectionError("Voice transcription failed. Check network connection.") from err

    async def _send_request(self, payload: dict, req_id: str) -> dict:
        api_key, _ = self._get_config()
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        }

        start_time = time.time()
        logger.info(f"[Request {req_id}] Groq request started [model: {payload.get('model')}]")

        async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS) as client:
            try:
                response = await client.post(
                    f"{GROQ_BASE_URL}/chat/completions",
                    headers=headers,
                    json=payload,
                )
                elapsed = time.time() - start_time
                logger.info(f"[Request {req_id}] Groq HTTP {response.status_code} in {elapsed:.2f}s")
                response.raise_for_status()
                return response.json()
            except httpx.ConnectTimeout as err:
                logger.error(f"[Request {req_id}] Groq ConnectTimeout: unable to establish connection to Groq API")
                raise ConnectionError("Timeout connecting to Groq AI service. Check internet connection.") from err
            except httpx.ReadTimeout as err:
                logger.error(f"[Request {req_id}] Groq ReadTimeout: Groq API took longer than {TIMEOUT_SECONDS}s to respond")
                raise TimeoutError(f"Groq API completion timed out after {TIMEOUT_SECONDS} seconds.") from err
            except httpx.HTTPStatusError as http_err:
                status_code = http_err.response.status_code
                logger.error(f"[Request {req_id}] Groq HTTP error {status_code}: {http_err.response.text}")
                if status_code == 401:
                    raise ValueError("AI authentication failed (HTTP 401). Check GROQ_API_KEY in backend .env file.")
                if status_code == 403:
                    raise ValueError("Access forbidden (HTTP 403). Check Groq account permissions.")
                if status_code == 404:
                    raise ValueError(f"Model or endpoint not found (HTTP 404): {payload.get('model')}")
                if status_code == 429:
                    raise ValueError("Groq API rate limit reached (HTTP 429). Please try again in a few moments.")
                if status_code >= 500:
                    raise ValueError(f"Groq server error (HTTP {status_code}). Check backend logs.")
                raise ValueError(f"Groq API error (HTTP {status_code}).") from http_err
            except httpx.RequestError as req_err:
                logger.error(f"[Request {req_id}] Groq Network Error: {req_err}")
                raise ConnectionError("Unable to reach Groq API. Please check network connection.") from req_err

    async def test_groq_connection(self) -> dict:
        req_id = f"test-{uuid.uuid4().hex[:6]}"
        is_key_valid = self.is_api_key_configured()
        logger.info(f"[Request {req_id}] Testing Groq connectivity (API Key configured: {is_key_valid})")

        if not is_key_valid:
            return {
                "status": "error",
                "api_key_configured": False,
                "message": "GROQ_API_KEY in .env is missing or set to placeholder.",
            }

        payload = {
            "model": "llama-3.1-8b-instant",
            "messages": [
                {"role": "system", "content": "You are a test assistant."},
                {"role": "user", "content": "Reply with exactly GROQ_OK"},
            ],
            "max_completion_tokens": 20,
        }

        try:
            res_data = await self._send_request(payload, req_id)
            choices = res_data.get("choices", [])
            reply = choices[0].get("message", {}).get("content", "").strip() if choices else ""
            logger.info(f"[Request {req_id}] Groq test response received: {reply}")
            return {
                "status": "ok",
                "api_key_configured": True,
                "response": reply,
            }
        except Exception as e:
            logger.error(f"[Request {req_id}] Groq test failed: {e}")
            return {
                "status": "error",
                "api_key_configured": True,
                "message": str(e),
            }

    def _extract_text(self, response: dict) -> str:
        choices = response.get("choices")
        if not choices or not isinstance(choices, list):
            raise ValueError("Unexpected API response structure: missing choices")

        message = choices[0].get("message")
        if not message or not isinstance(message, dict):
            raise ValueError("Unexpected API response structure: missing message")

        content = message.get("content")
        if not content or not isinstance(content, str):
            raise ValueError("Unexpected API response structure: missing content")

        return content.strip()

    def _parse_response_json(self, raw_text: str) -> tuple[str, str]:
        cleaned = raw_text.strip()
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
            cleaned = re.sub(r"\s*```$", "", cleaned)

        subject = ""
        body = ""

        try:
            payload = json.loads(cleaned)
            if isinstance(payload, dict):
                subject = str(payload.get("subject", "")).strip()
                body = str(payload.get("body", "")).strip()
        except json.JSONDecodeError:
            subj_match = re.search(r'"subject"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"', cleaned)
            body_match = re.search(r'"body"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"', cleaned)

            if subj_match:
                subject = subj_match.group(1).replace('\\"', '"').replace("\\n", "\n").strip()
            if body_match:
                body = body_match.group(1).replace('\\"', '"').replace("\\n", "\n").strip()

        if not subject and not body:
            lines = [line.strip() for line in cleaned.splitlines() if line.strip()]
            if lines:
                subject = lines[0].replace("Subject:", "").replace('"subject":', "").strip(' "',)
                body = "\n".join(lines[1:]) if len(lines) > 1 else lines[0]

        if not subject:
            subject = "Email Subject"
        if not body:
            body = cleaned

        return subject, body

    def _calculate_quality_score(self, body: str, request: EmailGenerationRequest) -> int:
        words = len(body.split())
        score = 85

        if 40 <= words <= 250:
            score += 6
        elif 25 <= words <= 400:
            score += 4

        lower_body = body.lower()
        if request.recipient_type.lower() in ["professor", "doctor", "government official"]:
            if any(term in lower_body for term in ["dear", "respectfully", "sincerely", "thank you"]):
                score += 3
        elif request.recipient_type.lower() in ["friend", "classmate", "family member"]:
            if any(term in lower_body for term in ["hi", "hey", "hello", "cheers", "best"]):
                score += 3

        return min(98, max(75, score))

    def _build_response_object(self, raw_text: str, request: EmailGenerationRequest, req_id: str) -> EmailResponse:
        subject, body = self._parse_response_json(raw_text)

        word_count = len(body.split()) if body else 0
        character_count = len(body)
        reading_time_seconds = max(5, round((word_count / 200) * 60)) if word_count > 0 else 5
        quality_score = self._calculate_quality_score(body, request)

        logger.info(
            f"[Request {req_id}] Parsed completion -> subject: '{subject[:30]}...', words: {word_count}, score: {quality_score}"
        )

        return EmailResponse(
            subject=subject,
            body=body,
            quality_score=quality_score,
            word_count=word_count,
            character_count=character_count,
            reading_time_seconds=reading_time_seconds,
        )

    async def generate_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "create")

    async def rewrite_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "rewrite")

    async def improve_grammar(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "grammar")

    async def shorten_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "shorten")

    async def expand_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "expand")

    async def translate_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "translate")

    async def regenerate_email(self, request: EmailGenerationRequest) -> EmailResponse:
        return await self._run_operation(request, "regenerate")

    async def _run_operation(self, request: EmailGenerationRequest, operation: str) -> EmailResponse:
        req_id = uuid.uuid4().hex[:6]
        _, model = self._get_config()

        logger.info(
            f"[Request {req_id}] Processing email request [sender: '{request.sender_name}', recipient: '{request.recipient_type}', "
            f"tone: '{request.tone}', lang: '{request.language}']"
        )

        payload = {
            "model": model,
            "messages": self.prompt_builder.build_payload(
                sender_name=request.sender_name,
                sender_role=request.sender_role,
                recipient_type=request.recipient_type,
                recipient_name=request.recipient_name,
                purpose=request.purpose,
                tone=request.tone,
                language=request.language,
                additional_context=request.additional_context,
                operation=operation,
                source_email=request.source_email,
            ),
            "temperature": 0.7,
            "max_completion_tokens": 1200,
            "response_format": {"type": "json_object"},
        }

        response_json = await self._send_request(payload, req_id)
        raw_text = self._extract_text(response_json)
        return self._build_response_object(raw_text, request, req_id)
