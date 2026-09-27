import asyncio
from dotenv import load_dotenv

from backend.models.email_request import EmailGenerationRequest
from backend.services.groq_service import GroqService

load_dotenv()

async def run_test_cases():
    service = GroqService()

    tests = [
        {
            "name": "TEST 1: Professor Sick Leave Request (Formal)",
            "request": EmailGenerationRequest(
                sender_name="Tiger",
                sender_role="Engineering Student",
                recipient_type="Professor",
                recipient_name="Dr. Sharma",
                purpose="Request leave because I am sick and cannot attend today's class.",
                tone="Formal",
                language="English",
            )
        },
        {
            "name": "TEST 2: HR Internship Application Follow-Up (Professional)",
            "request": EmailGenerationRequest(
                sender_name="Tiger",
                sender_role="",
                recipient_type="HR Manager",
                recipient_name="Priya Sharma",
                purpose="Ask for an update on my software engineering internship application.",
                tone="Professional",
                language="English",
            )
        },
        {
            "name": "TEST 3: Friend Goa Trip Invitation (Friendly)",
            "request": EmailGenerationRequest(
                sender_name="Tiger",
                sender_role="",
                recipient_type="Friend",
                recipient_name="Rahul",
                purpose="Invite Rahul to join me for a weekend trip to Goa.",
                tone="Friendly",
                language="English",
            )
        },
        {
            "name": "TEST 4: Client Website Features Update (Professional)",
            "request": EmailGenerationRequest(
                sender_name="Tiger",
                sender_role="Software Developer",
                recipient_type="Client",
                recipient_name="ABC Technologies",
                purpose="Give an update about completed website features and ask them to review the work.",
                tone="Professional",
                language="English",
            )
        },
    ]

    for test in tests:
        print("=" * 60)
        print(f"Executing {test['name']}...")
        print("=" * 60)
        res = await service.generate_email(test["request"])
        print(f"Subject: {res.subject}")
        print(f"Score: {res.quality_score} | Words: {res.word_count} | Chars: {res.character_count} | ReadTime: {res.reading_time_seconds}s")
        print("-" * 60)
        print(res.body)
        print("\n")

if __name__ == "__main__":
    asyncio.run(run_test_cases())
