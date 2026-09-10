import json
import re
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

from google import genai
from google.genai import types


def _get_client():
    """Get the Gemini client instance."""
    return genai.Client(api_key=settings.GEMINI_API_KEY)


def extract_job_data(content: str) -> dict:
    """
    Send job description content to Gemini and extract structured job data.
    Returns a validated dictionary with job fields.
    """
    if not content or not content.strip():
        raise ValueError("No content provided for extraction")

    prompt = EXTRACTION_PROMPT.format(content=content)

    try:
        client = _get_client()
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.1,
                response_mime_type="application/json",
            )
        )
        
        raw_response = response.text.strip()
        return parse_ai_response(raw_response)

    except Exception as e:
        raise ValueError(f"AI extraction failed: {str(e)}")


def chat_with_ai(message: str, history: list, job_context: str = None) -> dict:
    """
    Conversational AI job coach.
    Returns a reply and quick-reply suggestions.
    """
    system_prompt = """You are an expert AI Job Search Coach named JobBot. 
You help users with:
- Interview preparation and tips
- Resume and cover letter advice  
- Salary negotiation strategies
- Job search tactics
- Career advice and planning

Be concise, practical, and encouraging. Format responses in clear bullet points when listing multiple items.
Always end with 1-3 short follow-up question suggestions for the user."""

    # Build conversation context
    context_parts = [system_prompt]
    if job_context:
        context_parts.append(f"\nCurrent job context: {job_context}")
    
    # Build history string
    history_str = ""
    for msg in history[-6:]:  # Last 6 messages for context
        role = "User" if msg["role"] == "user" else "JobBot"
        history_str += f"\n{role}: {msg['content']}"
    
    if history_str:
        context_parts.append(f"\nConversation history:{history_str}")
    
    context_parts.append(f"\nUser: {message}")
    context_parts.append("\nJobBot:")
    
    full_prompt = "\n".join(context_parts)

    try:
        client = _get_client()
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=full_prompt,
            config=types.GenerateContentConfig(
                temperature=0.7,
                max_output_tokens=800,
            )
        )
        
        reply = response.text.strip()
        
        # Generate follow-up suggestions
        suggestions_prompt = f"""Based on this job coaching conversation, suggest 3 SHORT follow-up questions the user might ask next.
Return ONLY a JSON array of strings. Example: ["Question 1?", "Question 2?", "Question 3?"]

Last user message: {message}
Assistant reply: {reply[:200]}"""
        
        try:
            sugg_response = client.models.generate_content(
                model='gemini-1.5-flash',
                contents=suggestions_prompt,
                config=types.GenerateContentConfig(
                    temperature=0.5,
                    response_mime_type="application/json",
                )
            )
            suggestions = json.loads(sugg_response.text.strip())
            if not isinstance(suggestions, list):
                suggestions = []
            suggestions = suggestions[:3]
        except Exception:
            suggestions = []
        
        return {"reply": reply, "suggestions": suggestions}

    except Exception as e:
        raise ValueError(f"AI chat failed: {str(e)}")


def analyze_applications(jobs_summary: str) -> dict:
    """
    Analyze user's overall job applications and provide strategic insights.
    """
    prompt = f"""You are a career analytics expert. Analyze these job application statistics and provide insights.

Job applications data:
{jobs_summary}

Provide a JSON response with:
{{
  "insights": "2-3 sentence overall assessment",
  "tips": ["tip1", "tip2", "tip3"],
  "strengths": ["strength1", "strength2"],
  "areas_to_improve": ["area1", "area2"]
}}

Be specific, practical, and data-driven. Return ONLY valid JSON."""

    try:
        client = _get_client()
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.4,
                response_mime_type="application/json",
            )
        )
        
        data = json.loads(response.text.strip())
        return {
            "insights": data.get("insights", ""),
            "tips": data.get("tips", [])[:5],
            "strengths": data.get("strengths", [])[:3],
            "areas_to_improve": data.get("areas_to_improve", [])[:3],
        }

    except Exception as e:
        raise ValueError(f"AI analysis failed: {str(e)}")


def get_job_advice(company: str, role: str, status: str, skills: list, notes: str = None) -> dict:
    """
    Get AI advice and next steps for a specific job application.
    """
    skills_str = ", ".join(skills) if skills else "not specified"
    notes_str = f"\nNotes: {notes}" if notes else ""
    
    prompt = f"""You are an expert career coach. Provide specific advice for this job application:

Company: {company}
Role: {role}
Current Status: {status}
Skills: {skills_str}{notes_str}

Return a JSON response:
{{
  "advice": "Personalized 2-3 sentence advice for this specific application and status",
  "next_steps": ["step1", "step2", "step3"],
  "interview_tips": ["tip1", "tip2", "tip3"]
}}

Make advice specific to the status ({status}). Return ONLY valid JSON."""

    try:
        client = _get_client()
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.5,
                response_mime_type="application/json",
            )
        )
        
        data = json.loads(response.text.strip())
        return {
            "advice": data.get("advice", ""),
            "next_steps": data.get("next_steps", [])[:5],
            "interview_tips": data.get("interview_tips", [])[:5],
        }

    except Exception as e:
        raise ValueError(f"AI advice failed: {str(e)}")


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

