import os
import asyncio
import httpx
from dotenv import load_dotenv

from backend.models.email_request import EmailGenerationRequest
from backend.services.prompt_builder import PromptBuilder

load_dotenv()

async def test_full_request():
    api_key = os.getenv("GROQ_API_KEY", "").strip()
    model = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile").strip()

    builder = PromptBuilder()

    messages = builder.build_payload(
        sender_name="Tiger",
        sender_role="Engineering Student",
        recipient_type="HR Manager",
        recipient_name="Priya Sharma",
        purpose="Apply for software engineering internship",
        tone="Professional",
        language="English",
        additional_context="",
        operation="create",
    )

    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
        "max_completion_tokens": 1200,
        "response_format": {"type": "json_object"},
    }

    print(f"[Full Prompt Test] Sending full email generation request to model: {model}...")

    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            res = await client.post(url, headers=headers, json=payload)
            print(f"[Full Prompt Test] HTTP status: {res.status_code}")
            if res.status_code == 200:
                data = res.json()
                content = data["choices"][0]["message"]["content"]
                print(f"[Full Prompt Test] SUCCESS! Content received:\n{content[:200]}...")
            else:
                print(f"[Full Prompt Test] ERROR Body: {res.text}")
        except Exception as e:
            print(f"[Full Prompt Test] Exception: {type(e).__name__} - {e}")

if __name__ == "__main__":
    asyncio.run(test_full_request())
