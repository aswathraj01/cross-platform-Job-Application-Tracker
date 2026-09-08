const DEFAULT_API_BASE = 'http://localhost:8000/api';

async function getStorage(keys) {
  return new Promise(resolve => chrome.storage.local.get(keys, resolve));
}

async function setStorage(obj) {
  return new Promise(resolve => chrome.storage.local.set(obj, resolve));
}

function showStatus(msg, type) {
  const el = document.getElementById('status-msg');
  el.textContent = msg;
  el.className = `status-msg ${type}`;
  setTimeout(() => { el.className = 'status-msg'; }, 3000);
}

document.addEventListener('DOMContentLoaded', async () => {
  const storage = await getStorage(['token', 'email', 'apiBase']);

  // Populate fields
  document.getElementById('api-base').value = storage.apiBase || DEFAULT_API_BASE;

  if (storage.email) {
    document.getElementById('account-email').textContent = storage.email;
    document.getElementById('account-status').style.display = 'block';
  }

  // Save settings
  document.getElementById('btn-save').addEventListener('click', async () => {
    const apiBase = document.getElementById('api-base').value.trim() || DEFAULT_API_BASE;
    await setStorage({ apiBase });
    showStatus('Settings saved!', 'success');
  });

  // Sign out
  document.getElementById('btn-logout').addEventListener('click', async () => {
    await setStorage({ token: null, email: null });
    document.getElementById('account-email').textContent = 'Not connected';
    document.getElementById('account-status').style.display = 'none';
    showStatus('Signed out successfully.', 'success');
  });
});
