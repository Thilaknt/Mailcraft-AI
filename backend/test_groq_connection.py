import os
import sys
import asyncio
import httpx
from dotenv import load_dotenv

load_dotenv()

def check_env():
    api_key = os.getenv("GROQ_API_KEY", "").strip()
    model = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant").strip()

    is_configured = bool(api_key and api_key not in ["your_key_here", "your_groq_api_key_here", "your_api_key_here"])
    print(f"GROQ_API_KEY loaded: {is_configured}")
    print(f"[Groq Test] Model: {model}")
    return is_configured, api_key, model

async def test_direct_groq():
    is_configured, api_key, model = check_env()

    if not is_configured:
        print("[Groq Test] FAIL: GROQ_API_KEY is not configured or is set to placeholder.")
        return

    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": model,
        "messages": [
            {"role": "user", "content": "Reply with exactly GROQ_OK"}
        ],
        "temperature": 0.2,
        "max_completion_tokens": 20,
    }

    print("[Groq Test] Request started")
    print(f"[Groq Test] Endpoint: {url}")

    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            response = await client.post(url, headers=headers, json=payload)
            print(f"[Groq Test] HTTP status: {response.status_code}")
            if response.status_code == 200:
                data = response.json()
                content = data["choices"][0]["message"]["content"].strip()
                print(f"[Groq Test] Response received: {content}")
                if "GROQ_OK" in content:
                    print("[Groq Test] PASS")
                else:
                    print(f"[Groq Test] Content received: {content}")
            else:
                print(f"[Groq Test] Error response body: {response.text}")
        except httpx.HTTPStatusError as http_err:
            print(f"[Groq Test] HTTPStatusError status: {http_err.response.status_code}")
            print(f"[Groq Test] HTTPStatusError body: {http_err.response.text}")
        except httpx.RequestError as req_err:
            print(f"[Groq Test] RequestError: {type(req_err).__name__} - {req_err}")
        except Exception as err:
            print(f"[Groq Test] Unexpected Exception: {type(err).__name__} - {err}")

if __name__ == "__main__":
    asyncio.run(test_direct_groq())
