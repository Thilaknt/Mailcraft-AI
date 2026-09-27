from __future__ import annotations


class PromptBuilder:
    def build_system_message(self) -> str:
        return (
            "You are MailCraft AI, an expert email writing assistant.\n\n"
            "CORE PRINCIPLE:\n"
            "Write an email that a real person would actually send. Prioritize clarity and natural communication over verbosity.\n"
            "Never turn a simple email into an essay or a wall of text.\n\n"
            "PARAGRAPH & FORMATTING RULES:\n"
            "- Use short paragraphs (1 to 3 sentences per paragraph).\n"
            "- Separate logical thoughts with double line breaks (blank lines) between paragraphs.\n"
            "- Use bullet points ONLY when listing multiple deliverables, completed tasks, meeting agendas, or requirements. Do NOT use bullets for simple leave requests, personal messages, or short inquiries.\n"
            "- Never invent personal details like phone numbers, email addresses, dates, or company names unless provided.\n"
            "- Never produce generic bracket placeholders such as [Phone Number], [Email Address], or [Position] unless explicitly instructed.\n"
            "- The sign-off MUST strictly use the provided SENDER NAME. Never invent sender names like 'John', 'Sarah', or 'Alex'.\n\n"
            "BANNED GENERIC AI FILLER & CLICHÉS:\n"
            "Do NOT use these overused phrases as default templates:\n"
            "x 'I hope this email finds you well.'\n"
            "x 'I am writing this email to...'\n"
            "x 'I would like to take this opportunity to...'\n"
            "x 'Following up on our previous discussion...'\n"
            "x 'Please do not hesitate to contact me.'\n"
            "x 'I look forward to hearing from you.'\n"
            "Choose greetings, sentence structures, and sign-offs naturally based on the purpose and recipient.\n\n"
            "PURPOSE-DRIVEN EMAIL STRUCTURES:\n"
            "- LEAVE / SICK / PERMISSION REQUEST (40–80 words):\n"
            "  Greeting -> Direct reason for leave -> Specific request -> Catch-up commitment -> Respectful closing.\n"
            "- APPLICATION / FOLLOW-UP (70–120 words):\n"
            "  Greeting -> Direct reason for contacting -> Relevant qualification / inquiry -> Call to action / next step -> Professional closing.\n"
            "- PROJECT / STATUS UPDATE (80–160 words):\n"
            "  Greeting -> Brief introduction -> Completed items (bullet list if multiple) -> Next steps / deadline -> Closing.\n"
            "- FRIEND / PERSONAL EMAIL (40–120 words):\n"
            "  Greeting -> Warm conversational message -> Event or trip details -> Casual response request -> Friendly sign-off ('Cheers,', 'See you,', 'Take care,'). No corporate language.\n\n"
            "RECIPIENT & TONE ADAPTATION:\n"
            "- FRIEND: Natural, warm, relaxed greeting, short paragraphs, casual sign-off. No corporate jargon.\n"
            "- PROFESSOR: Respectful academic etiquette, concise, clear request, no excessive emotional language ('Sincerely,', 'Thank you for your understanding.').\n"
            "- HR MANAGER / RECRUITER: Professional corporate tone, structured, clearly states purpose and next actions.\n"
            "- CLIENT / BUSINESS PARTNER: Professional business tone, focused on status, deliverables, decisions, and deadlines ('Best regards,', 'Kind regards,').\n"
            "- MANAGER / TEAM LEAD: Direct, action-oriented, highlighting status, blockers, and next steps.\n\n"
            "LANGUAGE ENFORCEMENT:\n"
            "- The target language applies to the ENTIRE email (both Subject line AND Body).\n"
            "- If Hindi: Write 100% in natural Hindi (Devanagari script).\n"
            "- If Kannada: Write 100% in natural Kannada script.\n"
            "- If Spanish, French, German, Italian, Portuguese, Japanese, Chinese, Arabic, Tamil, Telugu, Malayalam, Marathi, Bengali: Write natively in that language.\n"
            "- Proper nouns (names, company names, URLs) may remain in their original form."
        )

    def build_user_message(
        self,
        sender_name: str,
        sender_role: str | None,
        recipient_type: str,
        recipient_name: str | None,
        purpose: str,
        tone: str,
        language: str,
        additional_context: str | None,
        operation: str = "create",
        source_email: str | None = None,
    ) -> str:
        s_name = sender_name.strip() if sender_name else "Sender"
        s_role = f" ({sender_role.strip()})" if sender_role and sender_role.strip() else ""
        r_type = recipient_type.strip() if recipient_type else "Recipient"
        r_name = f" ({recipient_name.strip()})" if recipient_name and recipient_name.strip() else ""

        instructions = [
            f"SENDER NAME: {s_name}",
            f"SENDER ROLE / CONTEXT: {s_role if s_role else 'Unspecified'}",
            f"RECIPIENT TYPE: {r_type}",
            f"RECIPIENT NAME: {r_name if r_name else 'Unspecified'}",
            f"PURPOSE / INSTRUCTION: {purpose.strip()}",
            f"TONE: {tone.strip()}",
            f"TARGET LANGUAGE: {language.strip()}",
        ]

        if additional_context and additional_context.strip():
            instructions.append(f"ADDITIONAL CONTEXT: {additional_context.strip()}")

        if operation == "rewrite" and source_email:
            instructions.append(f"ORIGINAL EMAIL:\n{source_email}")
            instructions.append("TASK: Rewrite this email with short scannable paragraphs and fresh phrasing while preserving core intent.")
        elif operation == "grammar" and source_email:
            instructions.append(f"ORIGINAL EMAIL:\n{source_email}")
            instructions.append("TASK: Fix grammar, spelling, and flow while keeping short scannable paragraphs.")
        elif operation == "shorten" and source_email:
            instructions.append(f"ORIGINAL EMAIL:\n{source_email}")
            instructions.append("TASK: Shorten the email to the core message, eliminating unnecessary words.")
        elif operation == "expand" and source_email:
            instructions.append(f"ORIGINAL EMAIL:\n{source_email}")
            instructions.append("TASK: Add thoughtful details and structure using short paragraphs.")
        elif operation == "translate" and source_email:
            instructions.append(f"ORIGINAL EMAIL:\n{source_email}")
            instructions.append(f"TASK: Translate both subject line and body natively into {language.strip()}.")
        elif operation == "regenerate" and source_email:
            instructions.append(f"PREVIOUS EMAIL:\n{source_email}")
            instructions.append("TASK: Provide a fresh alternative version with a completely different structure.")
        else:
            instructions.append(f"TASK: Write a natural, scannable, real-world email from {s_name} to {r_type} matching the purpose, tone, and language.")

        instructions.append(
            "\nReturn ONLY valid JSON with schema:\n"
            "{\n"
            '  "subject": "<Realistic, specific subject line in target language>",\n'
            '  "body": "<Complete email body in target language, with 1-3 sentences per paragraph separated by blank lines (\\n\\n) and closing signed off by ' + s_name + '>"\n'
            "}"
        )

        return "\n".join(instructions)

    def build_payload(
        self,
        sender_name: str,
        sender_role: str | None,
        recipient_type: str,
        recipient_name: str | None,
        purpose: str,
        tone: str,
        language: str,
        additional_context: str | None,
        operation: str = "create",
        source_email: str | None = None,
    ) -> list[dict[str, str]]:
        return [
            {
                "role": "system",
                "content": self.build_system_message(),
            },
            {
                "role": "user",
                "content": self.build_user_message(
                    sender_name=sender_name,
                    sender_role=sender_role,
                    recipient_type=recipient_type,
                    recipient_name=recipient_name,
                    purpose=purpose,
                    tone=tone,
                    language=language,
                    additional_context=additional_context,
                    operation=operation,
                    source_email=source_email,
                ),
            },
        ]
