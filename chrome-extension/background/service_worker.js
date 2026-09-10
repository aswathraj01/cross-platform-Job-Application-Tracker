// ======================================================
// Job Tracker Chrome Extension — Background Service Worker
// ======================================================
// Handles: auth token management, badge updates

const API_BASE_DEFAULT = 'https://job-tracker-api-i9hd.onrender.com/api';

// Update extension badge when tab changes
chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  try {
    const tab = await chrome.tabs.get(tabId);
    await updateBadgeForTab(tab);
  } catch (e) {
    // Tab may have been closed
  }
});

chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tab.url) {
    await updateBadgeForTab(tab);
  }
});

async function updateBadgeForTab(tab) {
  if (!tab.url || tab.url.startsWith('chrome://') || tab.url.startsWith('chrome-extension://')) {
    chrome.action.setBadgeText({ text: '', tabId: tab.id });
    return;
  }

  const storage = await chrome.storage.local.get(['token', 'apiBase']);
  const token = storage.token;
  const apiBase = storage.apiBase || API_BASE_DEFAULT;

  if (!token) {
    chrome.action.setBadgeText({ text: '', tabId: tab.id });
    return;
  }

  try {
    const domain = extractDomain(tab.url);
    if (!domain) return;

    const resp = await fetch(`${apiBase}/extension/check`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({ domain }),
    });

    if (resp.ok) {
      const data = await resp.json();
      if (data.applied) {
        // Green badge: user has applied to this domain before
        chrome.action.setBadgeText({ text: '✓', tabId: tab.id });
        chrome.action.setBadgeBackgroundColor({ color: '#10B981', tabId: tab.id });
      } else {
        chrome.action.setBadgeText({ text: '', tabId: tab.id });
      }
    }
  } catch (e) {
    // Network error or backend not running — clear badge silently
    chrome.action.setBadgeText({ text: '', tabId: tab.id });
  }
}

function extractDomain(url) {
  try {
    return new URL(url).hostname.replace(/^www\./, '');
  } catch {
    return '';
  }
}

// Clear stale tokens on install/update
chrome.runtime.onInstalled.addListener(() => {
  console.log('Job Tracker Extension installed/updated.');
});
