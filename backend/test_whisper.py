import os
import asyncio
from dotenv import load_dotenv

from backend.services.groq_service import GroqService

load_dotenv()

async def test_whisper():
    service = GroqService()
    
    # Create minimal silence header WAV bytes for diagnostic test
    # 44 bytes WAV header + 8000 bytes 0.5s silence
    wav_header = bytes([
        0x52, 0x49, 0x46, 0x46,  # RIFF
        0x24, 0x1F, 0x00, 0x00,  # size
        0x57, 0x41, 0x56, 0x45,  # WAVE
        0x66, 0x6D, 0x74, 0x20,  # fmt 
        0x10, 0x00, 0x00, 0x00,  # subchunk1size (16)
        0x01, 0x00, 0x01, 0x00,  # PCM, Mono
        0x40, 0x1F, 0x00, 0x00,  # 8000 sample rate
        0x80, 0x3E, 0x00, 0x00,  # byte rate
        0x02, 0x00, 0x10, 0x00,  # block align
        0x64, 0x61, 0x74, 0x61,  # data
        0x00, 0x1F, 0x00, 0x00,  # subchunk2size
    ]) + (b'\x00' * 8000)

    print("[Whisper Diagnostic] Testing Groq Whisper transcription endpoint...")
    try:
        text = await service.transcribe_audio(wav_header, "test.wav")
        print(f"[Whisper Diagnostic] SUCCESS! Result: '{text}'")
    except Exception as e:
        print(f"[Whisper Diagnostic] Exception (expected if silent/invalid audio): {e}")

if __name__ == "__main__":
    asyncio.run(test_whisper())
