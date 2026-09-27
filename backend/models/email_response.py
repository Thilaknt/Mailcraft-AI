from pydantic import BaseModel, Field


class EmailResponse(BaseModel):
    subject: str = Field(..., min_length=1)
    body: str = Field(..., min_length=1)
    quality_score: int = Field(..., ge=0, le=100)
    word_count: int = Field(..., ge=0)
    character_count: int = Field(..., ge=0)
    reading_time_seconds: int = Field(..., ge=0)
