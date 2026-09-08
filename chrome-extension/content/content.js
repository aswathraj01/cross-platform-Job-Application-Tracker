// =============================================
// Job Tracker Chrome Extension — Content Script
// =============================================
// This script runs in the context of every web page.
// It listens for messages from the popup/service worker
// and returns the page's content for AI extraction.

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'GET_PAGE_CONTENT') {
    try {
      const html = document.documentElement.outerHTML.slice(0, 200000);
      const title = document.title;
      const url = window.location.href;
      
      // Also try to extract visible text for a quick summary
      const bodyText = document.body?.innerText?.slice(0, 5000) || '';

      sendResponse({ html, title, url, bodyText, success: true });
    } catch (e) {
      sendResponse({ success: false, error: e.message });
    }
  }
  return true; // Keep channel open for async
});

// Show a subtle indicator when the extension is active on a job page
(function injectJobTrackerHint() {
  // Only run on pages that look like job postings
  const pageText = document.body?.innerText?.toLowerCase() || '';
  const jobKeywords = ['apply now', 'job description', 'requirements', 'responsibilities', 'qualifications', 'we are hiring', 'position', 'salary', 'benefits'];
  const isJobPage = jobKeywords.some(kw => pageText.includes(kw));

  if (isJobPage) {
    // Set a data attribute so the popup JS knows it's likely a job page
    document.documentElement.setAttribute('data-job-tracker-page', 'true');
  }
})();
