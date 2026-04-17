import requests
from bs4 import BeautifulSoup
import re


def scrape_job_page(url: str) -> str:
    """
    Scrape a job posting page and extract meaningful text content.
    Strips navigation, footer, scripts, and other non-content elements.
    """
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
    }

    try:
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        raise ValueError(f"Failed to fetch URL: {str(e)}")

    soup = BeautifulSoup(response.text, "html.parser")

    # Remove unwanted elements
    for tag in soup.find_all(["script", "style", "nav", "footer", "header", "iframe", "noscript"]):
        tag.decompose()

    # Try to find the main content area
    main_content = (
        soup.find("main")
        or soup.find("article")
        or soup.find("div", {"class": re.compile(r"job|posting|description|content", re.I)})
        or soup.find("div", {"id": re.compile(r"job|posting|description|content", re.I)})
        or soup.body
    )

    if main_content is None:
        main_content = soup

    # Extract text
    text = main_content.get_text(separator="\n", strip=True)

    # Clean up excessive whitespace
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    cleaned_text = "\n".join(lines)

    # Truncate if too long (LLM context limits)
    max_chars = 8000
    if len(cleaned_text) > max_chars:
        cleaned_text = cleaned_text[:max_chars] + "\n... [truncated]"

    return cleaned_text
