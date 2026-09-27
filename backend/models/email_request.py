from pydantic import BaseModel, Field


class EmailGenerationRequest(BaseModel):
    sender_name: str = Field(..., min_length=1, description="Name of the person sending the email")
    sender_role: str | None = Field(default="", description="Role or relationship of the sender")
    recipient_type: str = Field(..., min_length=1, description="Category of recipient e.g. Friend, Professor")
    recipient_name: str | None = Field(default="", description="Name of the recipient")
    purpose: str = Field(..., min_length=1, description="Core objective or prompt for the email")
    tone: str = Field(..., min_length=1, description="Desired communication tone e.g. Formal, Friendly")
    language: str = Field(..., min_length=1, description="Target language for the generated email")
    additional_context: str | None = Field(default="", description="Optional supporting instructions")
    source_email: str | None = Field(default=None, description="Source email text for rewrite/refinement operations")


# Backward compatibility alias
EmailRequest = EmailGenerationRequest
