// ==========================================
// Job Tracker Chrome Extension — Popup JS
// ==========================================

const API_BASE_DEFAULT = 'http://localhost:8000/api';

// ---- Helpers ----

function $(id) { return document.getElementById(id); }

function showState(stateName) {
  const states = ['login', 'loading', 'applied', 'capture', 'success'];
  states.forEach(s => $(`state-${s}`).classList.add('hidden'));
  $(`state-${stateName}`).classList.remove('hidden');
}

function showError(elementId, msg) {
  const el = $(elementId);
  el.textContent = msg;
  el.classList.remove('hidden');
}

function hideError(elementId) {
  $(elementId).classList.add('hidden');
}

function setLoading(buttonId, spinnerId, textId, loading, text = null) {
  const btn = $(buttonId);
  const spinner = $(spinnerId);
  const label = $(textId);
  btn.disabled = loading;
  if (text && label) label.textContent = text;
  spinner.classList.toggle('hidden', !loading);
}

async function getStorage(keys) {
  return new Promise(resolve => chrome.storage.local.get(keys, resolve));
}

async function setStorage(obj) {
  return new Promise(resolve => chrome.storage.local.set(obj, resolve));
}

// ---- API calls ----

async function apiRequest(path, method, body, token, apiBase) {
  const resp = await fetch(`${apiBase}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await resp.json();
  if (!resp.ok) throw new Error(data.detail || `HTTP ${resp.status}`);
  return data;
}

// ---- Get active tab info ----

async function getActiveTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  return tab;
}

async function getPageContent(tabId) {
  try {
    const results = await chrome.scripting.executeScript({
      target: { tabId },
      func: () => ({
        html: document.documentElement.outerHTML.slice(0, 200000),
        title: document.title,
        url: window.location.href,
      }),
    });
    return results?.[0]?.result || null;
  } catch {
    return null;
  }
}

// ---- Domain helpers ----

function extractDomain(url) {
  try {
    return new URL(url).hostname.replace(/^www\./, '');
  } catch {
    return '';
  }
}

// ---- Render skills chips ----

function renderSkills(skills) {
  const container = $('skills-container');
  container.innerHTML = '';
  if (!skills || skills.length === 0) {
    container.innerHTML = '<span style="color:rgba(255,255,255,0.25);font-size:11px">None detected</span>';
    return;
  }
  skills.forEach(skill => {
    const chip = document.createElement('span');
    chip.className = 'skill-chip';
    chip.textContent = skill;
    chip.title = 'Click to remove';
    chip.addEventListener('click', () => chip.classList.toggle('removed'));
    container.appendChild(chip);
  });
}

function getActiveSkills() {
  return Array.from($('skills-container').querySelectorAll('.skill-chip:not(.removed)'))
    .map(c => c.textContent);
}

// ---- Render applied jobs ----

function renderAppliedJobs(jobs) {
  const container = $('applied-jobs-list');
  container.innerHTML = '';
  jobs.slice(0, 3).forEach(job => {
    const card = document.createElement('div');
    card.className = 'applied-job-card';
    card.innerHTML = `
      <div class="applied-job-info">
        <div class="applied-job-company">${job.company || '—'}</div>
        <div class="applied-job-role">${job.role || '—'}</div>
      </div>
      <span class="applied-job-status">${job.status || 'Applied'}</span>
    `;
    container.appendChild(card);
  });
}

// ---- Main popup flow ----

let _currentExtractedData = null;
let _currentTab = null;
let _apiBase = API_BASE_DEFAULT;
let _token = null;

async function init() {
  const storage = await getStorage(['token', 'email', 'apiBase']);
  _apiBase = storage.apiBase || API_BASE_DEFAULT;
  _token = storage.token;

  if (!_token) {
    showState('login');
    return;
  }

  // Token exists — check if we're on a job page and start extraction
  await runExtractionFlow();
}

async function runExtractionFlow() {
  _currentTab = await getActiveTab();
  if (!_currentTab) { showState('capture'); return; }

  const domain = extractDomain(_currentTab.url);

  // Update site bar
  $('site-domain').textContent = domain || _currentTab.url;
  $('site-title').textContent = _currentTab.title || '';
  const favicon = $('site-favicon');
  favicon.innerHTML = domain ? domain[0].toUpperCase() : '?';

  // Show loading
  showState('loading');
  $('loading-text').textContent = 'Checking your history…';

  try {
    // 1. Check if domain already applied
    if (domain) {
      const checkResult = await apiRequest('/extension/check', 'POST', { domain }, _token, _apiBase);
      if (checkResult.applied && checkResult.jobs.length > 0) {
        renderAppliedJobs(checkResult.jobs);
        showState('applied');
        return;
      }
    }

    // 2. Extract job data
    $('loading-text').textContent = 'AI extracting job details…';
    const pageContent = await getPageContent(_currentTab.id);
    const extractPayload = {
      url: _currentTab.url,
      title: _currentTab.title || '',
      html: pageContent?.html || null,
    };

    const extracted = await apiRequest('/extension/scrape', 'POST', extractPayload, _token, _apiBase);
    _currentExtractedData = extracted;

    // 3. Populate capture form
    $('field-company').value = extracted.company || '';
    $('field-role').value = extracted.role || '';
    $('field-location').value = extracted.location || '';
    $('field-notes').value = extracted.notes || '';
    renderSkills(extracted.skills || []);

    showState('capture');

  } catch (err) {
    // If auth error — clear token and go to login
    if (err.message.includes('401') || err.message.toLowerCase().includes('unauthorized') || err.message.toLowerCase().includes('token')) {
      await setStorage({ token: null });
      _token = null;
      showState('login');
      return;
    }
    // Otherwise show capture form with empty fields so user can still manually fill
    renderSkills([]);
    showState('capture');
    showError('capture-error', `AI extraction failed — please fill manually. (${err.message})`);
  }
}

// ---- Login ----

async function handleLogin() {
  const email = $('input-email').value.trim();
  const password = $('input-password').value;
  hideError('login-error');

  if (!email || !password) {
    showError('login-error', 'Please enter your email and password.');
    return;
  }

  setLoading('btn-login', 'login-spinner', 'login-text', true, 'Signing in…');

  try {
    const result = await apiRequest('/auth/login', 'POST', { email, password }, null, _apiBase);
    await setStorage({ token: result.token, email: result.email });
    _token = result.token;
    setLoading('btn-login', 'login-spinner', 'login-text', false, 'Sign In');
    await runExtractionFlow();
  } catch (err) {
    setLoading('btn-login', 'login-spinner', 'login-text', false, 'Sign In');
    showError('login-error', err.message || 'Login failed. Check your credentials.');
  }
}

// ---- Capture / Save ----

async function handleCapture() {
  hideError('capture-error');
  const company = $('field-company').value.trim();
  const role = $('field-role').value.trim();

  if (!company || !role) {
    showError('capture-error', 'Company and Role are required.');
    return;
  }

  setLoading('btn-capture', 'capture-spinner', 'capture-text', true, 'Saving…');

  try {
    const domain = _currentTab ? extractDomain(_currentTab.url) : '';
    const payload = {
      company,
      role,
      location: $('field-location').value.trim() || null,
      status: $('field-status').value,
      notes: $('field-notes').value.trim() || null,
      skills: getActiveSkills(),
      application_link: _currentTab?.url || null,
      domain: domain || null,
    };

    const saved = await apiRequest('/extension/capture', 'POST', payload, _token, _apiBase);

    // Show success
    $('success-summary').textContent = `${saved.company} — ${saved.role} saved as "${saved.status}"`;
    setLoading('btn-capture', 'capture-spinner', 'capture-text', false, 'Save to Tracker');
    showState('success');

  } catch (err) {
    setLoading('btn-capture', 'capture-spinner', 'capture-text', false, 'Save to Tracker');
    if (err.message.includes('401') || err.message.toLowerCase().includes('token')) {
      await setStorage({ token: null });
      _token = null;
      showState('login');
      return;
    }
    showError('capture-error', err.message || 'Failed to save. Try again.');
  }
}

// ---- Open dashboard ----

function openDashboard() {
  getStorage(['apiBase']).then(({ apiBase }) => {
    // Try to open the Flutter web app; fallback to backend
    const base = apiBase || API_BASE_DEFAULT;
    // Strip /api path to get the base URL of the web app
    const appUrl = base.replace('/api', '');
    chrome.tabs.create({ url: appUrl });
  });
}

// ---- Event Listeners ----

document.addEventListener('DOMContentLoaded', () => {
  init();

  // Login
  $('btn-login').addEventListener('click', handleLogin);
  $('input-email').addEventListener('keydown', e => { if (e.key === 'Enter') $('input-password').focus(); });
  $('input-password').addEventListener('keydown', e => { if (e.key === 'Enter') handleLogin(); });
  $('link-open-app').addEventListener('click', e => { e.preventDefault(); openDashboard(); });

  // Options
  $('btn-options').addEventListener('click', () => chrome.runtime.openOptionsPage());

  // Applied state actions
  $('btn-add-anyway').addEventListener('click', async () => {
    showState('loading');
    $('loading-text').textContent = 'AI extracting job details…';
    try {
      const pageContent = await getPageContent(_currentTab?.id);
      const extracted = await apiRequest('/extension/scrape', 'POST', {
        url: _currentTab?.url || '',
        title: _currentTab?.title || '',
        html: pageContent?.html || null,
      }, _token, _apiBase);
      _currentExtractedData = extracted;
      $('field-company').value = extracted.company || '';
      $('field-role').value = extracted.role || '';
      $('field-location').value = extracted.location || '';
      renderSkills(extracted.skills || []);
      showState('capture');
    } catch {
      showState('capture');
    }
  });
  $('btn-open-dashboard').addEventListener('click', openDashboard);

  // Capture actions
  $('btn-capture').addEventListener('click', handleCapture);
  $('btn-re-extract').addEventListener('click', async () => {
    showState('loading');
    $('loading-text').textContent = 'Re-scanning page…';
    try {
      const pageContent = await getPageContent(_currentTab?.id);
      const extracted = await apiRequest('/extension/scrape', 'POST', {
        url: _currentTab?.url || '',
        title: _currentTab?.title || '',
        html: pageContent?.html || null,
      }, _token, _apiBase);
      $('field-company').value = extracted.company || '';
      $('field-role').value = extracted.role || '';
      $('field-location').value = extracted.location || '';
      renderSkills(extracted.skills || []);
      showState('capture');
    } catch (err) {
      showState('capture');
      showError('capture-error', `Re-scan failed: ${err.message}`);
    }
  });

  // Success actions
  $('btn-view-dashboard').addEventListener('click', openDashboard);
});
