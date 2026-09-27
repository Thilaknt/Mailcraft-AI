import os
import sys
import asyncio
from dotenv import load_dotenv

load_dotenv()

def check_env():
    api_key = os.getenv("GROQ_API_KEY")
    model = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")

    is_loaded = bool(api_key and api_key != "your_key_here" and api_key != "your_groq_api_key_here")
    print(f"GROQ_API_KEY loaded: {is_loaded}")
    print(f"[Groq] Model: {model}")
    return is_loaded

async def run_diagnostic():
    is_key_valid = check_env()

    from backend.models.email_request import EmailGenerationRequest
    from backend.services.groq_service import GroqService

    req = EmailGenerationRequest(
        sender_name="Tiger",
        sender_role="Engineering Student",
        recipient_type="Friend",
        recipient_name="Rahul",
        purpose="Invite Rahul to join me for a weekend trip to Goa.",
        tone="Friendly",
        language="English",
        additional_context="",
    )

    service = GroqService()

    print("[Groq] Request started")
    if not is_key_valid:
        print("[Groq] WARNING: GROQ_API_KEY in .env is unconfigured/placeholder ('your_key_here' or 'your_groq_api_key_here').")
        print("[Groq] Please set a valid GROQ_API_KEY in .env to perform live Groq API completions.")
        return

    try:
        response = await service.generate_email(req)
        print("[Groq] Response received")
        print("[Groq] Parsing response: SUCCESS")
        print(f"Subject: {response.subject}")
        print(f"Body snippet: {response.body[:100]}...")
        print(f"Quality Score: {response.quality_score}, Words: {response.word_count}, Chars: {response.character_count}")
    except Exception as e:
        print(f"[Groq] Error during diagnostic request: {e}")

if __name__ == "__main__":
    asyncio.run(run_diagnostic())
