const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'rsg-banking';
const $ = id => document.getElementById(id);
let state = null, busy = false, page = 'deposit', pendingTransfer = null;
let gameHour = 12, typing = null;
// account just opened: the form stays on screen (stamp + receipt) until "go to my account"
let entering = false;

const fmt = n => '$' + Number(n || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const round2 = n => Math.round(n * 100) / 100;
let L = {};
// translate: t('key', a, b) replaces each %s in order
const t = (k, ...a) => { let i = 0; return String(L[k] ?? k).replace(/%s/g, () => a[i++] ?? ''); };
function applyI18n() {
  document.querySelectorAll('[data-i18n]').forEach(el => el.textContent = t(el.dataset.i18n));
}

function post(name, body = {}) {
  return fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).catch(() => {});
}

function applyScale() {
  const fit = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
  document.documentElement.style.setProperty('--ui-scale', Math.max(0.55, Math.min(2.5, fit)).toFixed(3));
}
window.addEventListener('resize', applyScale);
applyScale();

// bank / cash: what happens to the bank balance and to cash on hand
const PAGES = {
  deposit:  { title: 'ui_tab_deposit',  desc: 'ui_deposit_desc',  button: 'ui_deposit',  bank: 1,  cash: -1, all: () => state.cash },
  withdraw: { title: 'ui_tab_withdraw', desc: 'ui_withdraw_desc', button: 'ui_withdraw', bank: -1, cash: 1,  all: () => state.balance },
  transfer: { title: 'ui_tab_transfer', desc: 'ui_transfer_desc', button: 'ui_transfer', bank: -1, cash: 0,  all: () => state.balance },
};

const maintText = d => d.maintFee > 0 ? t('ui_maint_every', fmt(d.maintFee), d.maintDays) : t('ui_free');

/* ------------------------------------------------------------------ entrada (sem conta) */
function updateOpenButton() {
  if (!state) return;
  const signed = $('w-terms').checked;
  $('w-signature').classList.toggle('signed', signed);
  $('open-btn').disabled = busy || !signed || state.cash < state.openFee;
}

// greeting follows the in-game clock
function greeting(name) {
  const key = gameHour >= 5 && gameHour < 12 ? 'ui_greet_morning' : gameHour >= 12 && gameHour < 18 ? 'ui_greet_afternoon' : 'ui_greet_evening';
  return t(key, name || '—');
}

// types the greeting letter by letter after the seal lands
function typeGreeting(text) {
  clearInterval(typing);
  const el = $('w-greet'), box = el.parentElement;
  el.textContent = '';
  box.classList.remove('done');
  let i = 0;
  setTimeout(() => {
    typing = setInterval(() => {
      el.textContent = text.slice(0, ++i);
      if (i >= text.length) { clearInterval(typing); box.classList.add('done'); }
    }, 38);
  }, 650);
}

function renderWelcome(d, fresh) {
  $('w-monogram').textContent = d.monogram || d.label[0];
  $('w-label').textContent = d.label;
  $('w-founded').textContent = d.founded ? t('ui_founded', d.founded) : '';
  $('w-motto').textContent = d.motto ? `“${d.motto}”` : '';
  $('w-teller').textContent = d.teller ? t('ui_teller', d.teller) : '';
  $('w-desc').textContent = t('ui_open_desc', d.label);
  $('w-name').textContent = d.name || '—';
  $('w-cid').textContent = d.citizenid || '—';
  $('w-branch').textContent = d.code || '—';
  $('w-fee').textContent = d.openFee > 0 ? fmt(d.openFee) : t('ui_free');
  $('w-maint').textContent = maintText(d);
  $('w-cash').textContent = fmt(d.cash);
  $('w-cash').classList.toggle('over', d.cash < d.openFee);
  const missing = round2(d.openFee - d.cash);
  $('w-missing-row').classList.toggle('hidden', missing <= 0);
  $('w-missing-row').firstElementChild.textContent = t('ui_missing', '');
  $('w-missing').textContent = fmt(missing);
  $('w-terms-text').textContent = t('ui_terms', maintText(d));
  $('w-sign').textContent = d.name || '';
  $('w-approved-bank').textContent = d.label;
  if (fresh) {
    $('w-sheet-no').textContent = t('ui_sheet_no', `${d.code || '0000'}-${String(Math.floor(Math.random() * 100000)).padStart(5, '0')}`);
    $('w-date').textContent = new Date().toLocaleDateString();
    typeGreeting(greeting(d.name));
  }
  updateOpenButton();
}

/* ------------------------------------------------------------------ banco completo */
function setPage(name) {
  page = name;
  const p = PAGES[name];
  document.querySelectorAll('.nav-item[data-page]').forEach(n => n.classList.toggle('active', n.dataset.page === name));
  $('page-title').textContent = t(p.title);
  $('desc').textContent = t(p.desc);
  $('submit').textContent = t(p.button);
  $('target-field').classList.toggle('hidden', name !== 'transfer');
  $('sum-cash-row').classList.toggle('hidden', !p.cash);
  $('amount').value = '';
  updateSummary();
  if (state && state.hasAccount) (name === 'transfer' ? $('target') : $('amount')).focus();
}

function amountValue() {
  const v = parseFloat($('amount').value);
  return v > 0 ? round2(v) : 0;
}

function updateSummary() {
  if (!state || !state.hasAccount) return;
  const p = PAGES[page];
  const a = amountValue();
  const after = round2(state.balance + p.bank * a);
  const cashAfter = round2(state.cash + p.cash * a);
  $('sum-balance').textContent = fmt(state.balance);
  $('sum-amount').textContent = (a ? (p.bank < 0 ? '- ' : '+ ') : '') + fmt(a);
  $('sum-after').textContent = fmt(after);
  $('sum-cash').textContent = fmt(cashAfter);
  $('sum-after').classList.toggle('over', after < 0);
  $('sum-cash').classList.toggle('over', cashAfter < 0);
  const source = p.bank < 0 ? state.balance : state.cash;
  $('submit').disabled = busy || !a || a > source || a > state.max || (page === 'transfer' && !$('target').value.trim());
}

function renderBank(d) {
  $('monogram').textContent = d.monogram || d.label[0];
  $('bank-label').textContent = d.label;
  $('founded').textContent = d.founded ? t('ui_founded', d.founded) : '';
  $('motto').textContent = d.motto ? `“${d.motto}”` : '';
  $('customer').textContent = d.name || '—';
  $('cid').textContent = d.citizenid || '—';
  $('branch').textContent = d.code || '—';
  $('maint').textContent = maintText(d);
  $('page-title').textContent = t(PAGES[page].title);
  $('page-sub').textContent = d.nextFee && d.maintFee > 0
    ? t('ui_maint_next', fmt(d.maintFee), new Date(d.nextFee * 1000).toLocaleDateString())
    : '';
  $('balance').textContent = fmt(d.balance);
  $('cash').textContent = fmt(d.cash);
  $('max').textContent = t('ui_max_tx', fmt(d.max));
  updateSummary();
}

// sem conta -> ficha de entrada; com conta -> banco completo
function render(d, fresh) {
  state = d;
  $('welcome').classList.remove('approved', 'leaving');
  $('welcome').classList.toggle('hidden', d.hasAccount);
  $('bank').classList.toggle('hidden', !d.hasAccount);
  if (d.hasAccount) renderBank(d); else renderWelcome(d, fresh);
}

// account approved: stamp the form, then show the receipt over it
function approve(d) {
  entering = true;
  state = d;
  $('welcome').classList.add('approved');
  setTimeout(() => showReceipt(d.receipt), 1000);
}

// "go to my account": the form leaves and the full bank comes in
function enterBank() {
  $('welcome').classList.add('leaving');
  setTimeout(() => {
    entering = false;
    setPage('deposit');
    render(state);
    $('amount').focus();
  }, 380);
}

/* ------------------------------------------------------------------ actions */
async function send(name, body) {
  busy = true;
  updateSummary();
  $('open-btn').disabled = true;
  await post(name, body);
  busy = false;
  if (state) {
    updateSummary();
    updateOpenButton();
  }
}

function submit() {
  if (!state || !state.hasAccount || busy || $('submit').disabled) return;
  const amount = amountValue();
  if (page === 'transfer') {
    pendingTransfer = { target: $('target').value.trim().toUpperCase(), amount };
    $('cf-from').textContent = state.label;
    $('cf-to').textContent = pendingTransfer.target;
    $('cf-amount').textContent = fmt(amount);
    $('confirm-modal').classList.remove('hidden');
    return;
  }
  send(page, { amount });
}

function openAccount() {
  if (!state || state.hasAccount || busy || $('open-btn').disabled) return;
  send('openAccount');
}

function closeConfirm() { $('confirm-modal').classList.add('hidden'); pendingTransfer = null; }
function confirmTransfer() {
  if (!pendingTransfer) return;
  const body = pendingTransfer;
  closeConfirm();
  send('transfer', body);
}

function showReceipt(r) {
  $('rc-type').textContent = t('ui_receipt_' + r.type);
  $('rc-amount').textContent = fmt(r.amount);
  $('rc-bank').textContent = `${state.label} · ${t('ui_branch', state.code || '—')}`;
  $('rc-to-row').classList.toggle('hidden', r.type !== 'transfer');
  if (r.type === 'transfer') $('rc-to').textContent = `${r.toName || '—'} (${r.toCid})`;
  $('rc-date').textContent = new Date((r.time || Date.now() / 1000) * 1000).toLocaleString();
  $('rc-id').textContent = r.id || '—';
  // after opening the account the button leads into the full bank
  $('rc-ok').textContent = t(r.type === 'opened' ? 'ui_continue' : 'ui_ok');
  receiptType = r.type;
  $('receipt-modal').classList.remove('hidden');
}
// receipts that end the visit: the whole menu closes after "Done"
const CLOSE_AFTER = { deposit: true, withdraw: true };
let receiptType = null;

function closeReceipt() {
  $('receipt-modal').classList.add('hidden');
  if (entering) return enterBank();
  if (CLOSE_AFTER[receiptType]) return close();
  $('amount').value = '';
  if (page === 'transfer') $('target').value = '';
  updateSummary();
  if (state && state.hasAccount) $('amount').focus();
}

function hideAll() {
  clearInterval(typing);
  entering = false;
  closeConfirm();
  $('receipt-modal').classList.add('hidden');
  $('app').classList.add('hidden');
  state = null;
}
function close() { hideAll(); post('close'); }

document.querySelectorAll('.nav-item[data-page]').forEach(n => n.addEventListener('click', () => setPage(n.dataset.page)));
document.querySelectorAll('#quick .chip').forEach(b => b.addEventListener('click', () => {
  if (!state) return;
  let v;
  if (b.dataset.add === 'all') v = Math.floor(Math.min(Number(PAGES[page].all()) || 0, state.max) * 100) / 100;
  else v = Math.min(amountValue() + Number(b.dataset.add), state.max);
  $('amount').value = v > 0 ? v.toFixed(2) : '';
  updateSummary();
}));
$('amount').addEventListener('input', updateSummary);
$('target').addEventListener('input', updateSummary);
$('submit').addEventListener('click', submit);
$('w-terms').addEventListener('change', updateOpenButton);
$('open-btn').addEventListener('click', openAccount);
$('w-cancel').addEventListener('click', close);
$('close').addEventListener('click', close);
$('cf-cancel').addEventListener('click', closeConfirm);
$('cf-ok').addEventListener('click', confirmTransfer);
$('rc-ok').addEventListener('click', closeReceipt);

document.addEventListener('keyup', e => {
  if (!state) return;
  if (!$('receipt-modal').classList.contains('hidden')) {
    if (e.key === 'Escape' || e.key === 'Enter') closeReceipt();
    return;
  }
  if (!$('confirm-modal').classList.contains('hidden')) {
    if (e.key === 'Escape') closeConfirm();
    else if (e.key === 'Enter') confirmTransfer();
    return;
  }
  if (entering) return; // stamp animation running
  if (e.key === 'Escape') close();
  else if (e.key === 'Enter') state.hasAccount ? submit() : openAccount();
});

window.addEventListener('message', e => {
  const msg = e.data || {};
  if (msg.action === 'open') {
    if (msg.locales) { L = msg.locales; applyI18n(); }
    if (typeof msg.hour === 'number') gameHour = msg.hour;
    $('target').value = '';
    $('w-terms').checked = false;
    entering = false;
    state = msg.data;
    setPage('deposit');
    render(msg.data, true);
    $('app').classList.remove('hidden');
  } else if (msg.action === 'update') {
    if (!state || entering) return;
    const r = msg.data.receipt;
    if (r && r.type === 'opened') return approve(msg.data);
    render(msg.data);
    if (r) showReceipt(r);
  } else if (msg.action === 'close') {
    hideAll();
  }
});
