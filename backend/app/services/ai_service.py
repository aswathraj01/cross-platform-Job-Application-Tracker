import json
import re
from openai import OpenAI
from app.config import get_settings

settings = get_settings()

# Extraction prompt template
EXTRACTION_PROMPT = """You are an intelligent job data extraction system.

STRICT RULES:
- Return ONLY valid JSON
- No explanations
- If missing, return null
- Do NOT guess

FORMAT:
{{
  "company": string | null,
  "role": string | null,
  "location": string | null,
  "skills": string[],
  "application_link": string | null,
  "notes": string | null
}}

JOB DESCRIPTION:
\"\"\"
{content}
\"\"\""""


def get_llm_client() -> OpenAI:
    """
    Get an OpenAI-compatible LLM client.
    Works with both OpenAI API and local LLaMA (via Ollama, llama.cpp server, etc.).
    """
    return OpenAI(
        api_key=settings.OPENAI_API_KEY,
        base_url=settings.LLM_BASE_URL,
    )


def extract_job_data(content: str) -> dict:
    """
    Send job description content to the LLM and extract structured job data.
    Returns a validated dictionary with job fields.
    """
    if not content or not content.strip():
        raise ValueError("No content provided for extraction")

    client = get_llm_client()
    prompt = EXTRACTION_PROMPT.format(content=content)

    try:
        response = client.chat.completions.create(
            model=settings.LLM_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": "You are a precise data extraction assistant. Always respond with valid JSON only.",
                },
                {"role": "user", "content": prompt},
            ],
            temperature=0.1,
            max_tokens=500,
        )

        raw_response = response.choices[0].message.content.strip()
        return parse_ai_response(raw_response)

    except Exception as e:
        raise ValueError(f"AI extraction failed: {str(e)}")


def parse_ai_response(raw: str) -> dict:
    """
    Parse and validate the AI response.
    Handles cases where the AI wraps JSON in markdown code blocks.
    """
    # Strip markdown code block wrappers if present
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        # Remove ```json or ``` at start and ``` at end
        cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)

    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError:
        # Try to find JSON object in the response
        match = re.search(r"\{[\s\S]*\}", cleaned)
        if match:
            try:
                data = json.loads(match.group())
            except json.JSONDecodeError:
                raise ValueError(f"Failed to parse AI response as JSON: {raw[:200]}")
        else:
            raise ValueError(f"No JSON found in AI response: {raw[:200]}")

    # Validate and sanitize the response
    validated = {
        "company": _safe_string(data.get("company")),
        "role": _safe_string(data.get("role")),
        "location": _safe_string(data.get("location")),
        "skills": _safe_string_list(data.get("skills", [])),
        "application_link": _safe_string(data.get("application_link")),
        "notes": _safe_string(data.get("notes")),
    }

    return validated


def _safe_string(value) -> str | None:
    """Safely convert a value to string or None."""
    if value is None:
        return None
    if isinstance(value, str):
        return value.strip() if value.strip() else None
    return str(value)


def _safe_string_list(value) -> list[str]:
    """Safely convert a value to a list of strings."""
    if not isinstance(value, list):
        return []
    return [str(item).strip() for item in value if item and str(item).strip()]
