const MAX_LENGTHS = {
  name: 100,
  email: 254,
  topic: 80,
  message: 180,
};

const WORDPRESS_CONTACT_PAGE = 'https://amybanksmd.com/contact/';
const WORDPRESS_AJAX_URL = 'https://amybanksmd.com/wp-admin/admin-ajax.php';
const WORDPRESS_FORM_ID = '3385';

function clean(value, maxLength) {
  return typeof value === 'string' ? value.trim().slice(0, maxLength) : '';
}

function json(response, status, body) {
  response.status(status).setHeader('Content-Type', 'application/json; charset=utf-8').send(JSON.stringify(body));
}

module.exports = async function handler(request, response) {
  if (request.method !== 'POST') {
    response.setHeader('Allow', 'POST');
    return json(response, 405, { error: 'Method not allowed.' });
  }

  const body = request.body || {};
  if (clean(body.website, 200)) return json(response, 200, { ok: true });

  const startedAt = Number(body.startedAt);
  if (!Number.isFinite(startedAt) || Date.now() - startedAt < 2500) {
    return json(response, 400, { error: 'Please wait a moment and try again.' });
  }

  const submission = Object.fromEntries(
    Object.entries(MAX_LENGTHS).map(([key, maxLength]) => [key, clean(body[key], maxLength)])
  );
  if (!submission.name || !submission.email || !submission.topic || !submission.message) {
    return json(response, 400, { error: 'Please complete all required fields.' });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(submission.email)) {
    return json(response, 400, { error: 'Please enter a valid email address.' });
  }

  const nonceResponse = await fetch(WORDPRESS_AJAX_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ action: 'forminator_get_nonce', form_id: WORDPRESS_FORM_ID }),
  });
  const nonceResult = await nonceResponse.json().catch(() => null);
  const nonce = nonceResult && nonceResult.success ? nonceResult.data : '';
  if (!nonce) return json(response, 502, { error: 'We could not send your request. Please try again.' });

  const contactName = `RCT CARE · ${submission.topic} · ${submission.name}`.slice(0, 100);
  const formData = new URLSearchParams({
    'name-1': contactName,
    'email-1': submission.email,
    'textarea-1': submission.message,
    forminator_nonce: nonce,
    _wp_http_referer: '/contact/',
    form_id: WORDPRESS_FORM_ID,
    page_id: '21',
    form_type: 'default',
    current_url: WORDPRESS_CONTACT_PAGE,
    render_id: '0',
    action: 'forminator_submit_form_custom-forms',
    input_5: '',
  });
  const forwarded = await fetch(WORDPRESS_AJAX_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: formData,
  });

  const result = await forwarded.json().catch(() => null);
  if (!forwarded.ok || !result || !result.success || !result.data || !result.data.success) {
    return json(response, 502, { error: 'We could not send your request. Please try again.' });
  }

  return json(response, 200, { ok: true });
};
