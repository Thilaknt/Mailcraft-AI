from backend.models.email_request import EmailGenerationRequest
from backend.models.email_response import EmailResponse
from backend.services.prompt_builder import PromptBuilder

def test_prompt_builder():
    builder = PromptBuilder()

    # Case 1: Tiger, Student -> Professor Dr. Sharma, Formal, Extension request
    p1 = builder.build_user_message(
        sender_name="Tiger",
        sender_role="Engineering Student",
        recipient_type="Professor",
        recipient_name="Dr. Sharma",
        purpose="Request a two-day extension for my project submission because I need additional time to complete testing.",
        tone="Formal",
        language="English",
        additional_context="",
        operation="create",
    )
    assert "Tiger" in p1
    assert "Engineering Student" in p1
    assert "Professor" in p1
    assert "Dr. Sharma" in p1

    # Case 2: Tiger, Student -> Friend Rahul, Friendly, Goa Trip
    p2 = builder.build_user_message(
        sender_name="Tiger",
        sender_role="Student",
        recipient_type="Friend",
        recipient_name="Rahul",
        purpose="Invite Rahul to join me for a weekend trip to Goa.",
        tone="Friendly",
        language="English",
        additional_context="",
        operation="create",
    )
    assert "Rahul" in p2
    assert "Goa" in p2

    # Case 3: Friend, Birthday, Hindi
    p3 = builder.build_user_message(
        sender_name="Tiger",
        sender_role="",
        recipient_type="Friend",
        recipient_name="Rahul",
        purpose="Invite Rahul to my birthday party.",
        tone="Friendly",
        language="Hindi",
        additional_context="",
        operation="create",
    )
    assert "Hindi" in p3

    print("Prompt builder unit tests passed successfully!")

def test_models():
    req = EmailGenerationRequest(
        sender_name="Tiger",
        sender_role="Engineering Student",
        recipient_type="Professor",
        recipient_name="Dr. Sharma",
        purpose="Extension request",
        tone="Formal",
        language="English",
    )
    assert req.sender_name == "Tiger"
    assert req.sender_role == "Engineering Student"

    res = EmailResponse(
        subject="Test Extension Request",
        body="Dear Dr. Sharma...",
        quality_score=96,
        word_count=50,
        character_count=300,
        reading_time_seconds=15,
    )
    assert res.quality_score == 96
    assert res.word_count == 50
    assert res.character_count == 300
    assert res.reading_time_seconds == 15

    print("Model unit tests passed successfully!")

if __name__ == "__main__":
    test_prompt_builder()
    test_models()
