import sys
import asyncio
from dotenv import load_dotenv

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

from backend.services.assistant_service import AssistantService, ChatMessageItem, ChatRequest

load_dotenv()

async def run_assistant_tests():
    service = AssistantService()
    conv_id = "test-session-101"

    print("=" * 60)
    print("TEST 1: Professor Sick Leave Request")
    print("=" * 60)
    history = []
    msg1 = "Write an email to my professor asking for two days leave because I am sick."
    req1 = ChatRequest(message=msg1, conversation_id=conv_id, messages=history)
    res1 = await service.process_chat(req1)
    print(f"Assistant Type: {res1.type}")
    print(f"Subject: {res1.subject}")
    print(f"Body:\n{res1.body}\n")

    history.append(ChatMessageItem(role="user", content=msg1))
    history.append(ChatMessageItem(role="assistant", content=res1.message))

    print("=" * 60)
    print("TEST 2: Follow-Up - Make it shorter")
    print("=" * 60)
    msg2 = "Make it shorter."
    req2 = ChatRequest(message=msg2, conversation_id=conv_id, messages=history)
    res2 = await service.process_chat(req2)
    print(f"Assistant Type: {res2.type}")
    print(f"Subject: {res2.subject}")
    print(f"Body:\n{res2.body}\n")

    history.append(ChatMessageItem(role="user", content=msg2))
    history.append(ChatMessageItem(role="assistant", content=res2.message))

    print("=" * 60)
    print("TEST 3: Follow-Up - Translate it to Kannada")
    print("=" * 60)
    msg3 = "Translate it to Kannada."
    req3 = ChatRequest(message=msg3, conversation_id=conv_id, messages=history)
    res3 = await service.process_chat(req3)
    print(f"Assistant Type: {res3.type}")
    print(f"Subject: {res3.subject}")
    print(f"Body:\n{res3.body}\n")

    history.append(ChatMessageItem(role="user", content=msg3))
    history.append(ChatMessageItem(role="assistant", content=res3.message))

    print("=" * 60)
    print("TEST 4: Follow-Up - Now make it more respectful")
    print("=" * 60)
    msg4 = "Now make it more respectful."
    req4 = ChatRequest(message=msg4, conversation_id=conv_id, messages=history)
    res4 = await service.process_chat(req4)
    print(f"Assistant Type: {res4.type}")
    print(f"Subject: {res4.subject}")
    print(f"Body:\n{res4.body}\n")

    print("=" * 60)
    print("TEST 5: Fresh Request - Friendly email to Rahul for Goa trip")
    print("=" * 60)
    msg5 = "Write a friendly email to Rahul inviting him to Goa this weekend."
    req5 = ChatRequest(message=msg5, conversation_id="test-session-102", messages=[])
    res5 = await service.process_chat(req5)
    print(f"Assistant Type: {res5.type}")
    print(f"Subject: {res5.subject}")
    print(f"Body:\n{res5.body}\n")

if __name__ == "__main__":
    asyncio.run(run_assistant_tests())
