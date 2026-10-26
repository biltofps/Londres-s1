const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'rsg-inventory';
const $ = (id) => document.getElementById(id);

let labels = {};
const L = (key, fallback) => labels[key] || fallback;

function applyLabels() {
    document.querySelectorAll('[data-l]').forEach((el) => {
        if (labels[el.dataset.l]) el.textContent = labels[el.dataset.l];
    });
    document.querySelectorAll('[data-l-title]').forEach((el) => {
        if (labels[el.dataset.lTitle]) el.title = labels[el.dataset.lTitle];
    });
}

const state = {
    open: false,
    imagePath: '',
    hotbarSlots: 5,
    player: null,
    other: null,
    drag: null,
    hideGround: false, // opened with nothing nearby: no ground panel, drop via the bottom bar
};

/* ------------------------------------------------------------------ responsive scale */
// sizes in style.css are for 1920x1080; scale everything to the real screen
let uiScaleMul = 1; // Config.UiScale
function applyScale() {
    const fit = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
    const s = Math.max(0.55, Math.min(2.5, fit * uiScaleMul));
    document.documentElement.style.setProperty('--ui-scale', s.toFixed(3));
}
window.addEventListener('resize', applyScale);
applyScale();

function post(name, data = {}) {
    return fetch(`https://${RES}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data),
    }).catch(() => {});
}

// Lua tables may arrive as arrays (with nulls) or objects keyed by slot
function bySlot(items) {
    const map = {};
    if (!items) return map;
    Object.values(items).forEach((it) => { if (it && it.slot) map[it.slot] = it; });
    return map;
}

function totalWeight(map) {
    return Object.values(map).reduce((w, it) => w + (it.weight || 0) * (it.amount || 0), 0);
}

const kg = (g) => (g / 1000).toFixed(1);
const imgSrc = (it) => state.imagePath + (it.image || `${it.name}.png`);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// shop open: what the shop pays per unit for an item in the player's inventory
function sellPrice(invKey, item) {
    const shop = state.other;
    if (invKey !== 'player' || !shop || shop.type !== 'shop') return undefined;
    if (shop.buys && shop.buys[item.name]) return shop.buys[item.name].buyPrice;
    const entry = Object.values(shop.map).find((it) => it.name === item.name && it.buyPrice !== undefined);
    return entry ? entry.buyPrice : undefined;
}

/* ------------------------------------------------------------------ render */
function setWeight(prefix, inv) {
    const used = totalWeight(inv.map);
    const pct = inv.maxWeight > 0 ? Math.min(100, (used / inv.maxWeight) * 100) : 0;
    $(`${prefix}-weight`).textContent = kg(used);
    $(`${prefix}-max`).textContent = kg(inv.maxWeight || 0);
    setFill($(`${prefix}-bar`), pct);

    // slots in use (a stack counts as one slot)
    const filled = Object.keys(inv.map).length, total = inv.slots || 0;
    $(`${prefix}-used`).textContent = filled;
    $(`${prefix}-slots`).textContent = total;
    setFill($(`${prefix}-slotbar`), total > 0 ? Math.min(100, (filled / total) * 100) : 0);
}

function setFill(bar, pct) {
    bar.style.width = pct + '%';
    bar.className = 'fill ' + (pct < 70 ? 'stat-good' : pct < 90 ? 'stat-warn' : 'stat-bad');
}

function slotEl(invKey, slot, item, showKey) {
    const el = document.createElement('div');
    el.className = 'slot' + (item ? ' filled' : '') + (showKey ? ' hot' : '');
    el.dataset.inv = invKey;
    el.dataset.slot = slot;
    let html = showKey ? `<div class="key">${slot}</div>` : '';
    if (item) {
        html += `<img src="${esc(imgSrc(item))}" onerror="this.style.visibility='hidden'">`;
        html += `<div class="qty">${item.amount > 1 ? 'x' + item.amount : ''}</div>`;
        if (item.price !== undefined && invKey === 'other') html += `<div class="price">$${Number(item.price).toFixed(2)}</div>`;
        const sp = sellPrice(invKey, item);
        if (sp !== undefined) html += `<div class="price">$${Number(sp).toFixed(2)}</div>`;
        const q = item.info && typeof item.info.quality === 'number' ? item.info.quality : null;
        if (q !== null) {
            const cls = q > 60 ? 'stat-good' : q > 25 ? 'stat-warn' : 'stat-bad';
            html += `<div class="quality ${cls}" style="width:calc((100% - 8px) * ${Math.max(0, Math.min(100, q)) / 100})"></div>`;
        }
        html += `<div class="name">${esc(item.label)}</div>`;
    }
    el.innerHTML = html;
    return el;
}

/* ------------------------------------------------------------------ category filter */
const filters = { player: 'all', other: 'all' };
let categoryLabels = {};

const categoryOf = (item) => item.category || 'misc';

// shop tab listing what the shop buys from players (display only, not part of the grid's items)
const BUYS = '__buys';
const shopBuys = (inv) => (inv && inv.type === 'shop' && inv.buys ? Object.values(inv.buys) : [])
    .sort((a, b) => String(a.label).localeCompare(String(b.label)));

function categoryLabel(cat, inv) {
    if (cat === 'all') return L('ui_all', 'All');
    if (cat === BUYS) return (inv && inv.buysLabel) || L('ui_we_buy', 'We buy');
    const own = inv && inv.categoryLabels; // shops name their own categories
    if (own && own[cat]) return own[cat];
    if (cat === 'misc') return L('ui_misc', 'Misc');
    return categoryLabels[cat] || String(cat).replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function renderFilters(invKey) {
    const inv = state[invKey];
    const bar = $(`filter-${invKey}`);
    let cats = [...new Set(Object.values(inv.map).sort((a, b) => a.slot - b.slot).map(categoryOf))];
    if (!inv.categoryLabels) cats.sort(); // shops keep their configured order
    if (shopBuys(inv).length) {
        if (!cats.length && filters[invKey] === 'all') filters[invKey] = BUYS; // buy-only shop
        cats.push(BUYS);
    }
    // reset a filter whose category no longer exists in this inventory
    if (filters[invKey] !== 'all' && !cats.includes(filters[invKey])) filters[invKey] = 'all';
    bar.classList.toggle('empty', cats.length < 2); // keeps its space so the panel size never changes
    bar.innerHTML = ['all', ...cats].map((c) =>
        `<button class="chip${filters[invKey] === c ? ' active' : ''}" data-filter="${esc(c)}" data-inv="${invKey}">${esc(categoryLabel(c, inv))}</button>`
    ).join('');
}

function renderGrid(invKey) {
    const inv = state[invKey];
    const grid = $(`grid-${invKey}`);
    grid.innerHTML = '';
    if (!inv) return;
    renderFilters(invKey);
    const f = filters[invKey];
    if (f === BUYS) {
        state.buyList = shopBuys(inv);
        state.buyList.forEach((b, i) => {
            const el = slotEl('buys', i + 1, b, false);
            el.classList.add('buy-only');
            el.insertAdjacentHTML('beforeend', `<div class="price">$${Number(b.buyPrice).toFixed(2)}</div>`);
            grid.appendChild(el);
        });
        return;
    }
    let shown = 0;
    for (let s = 1; s <= inv.slots; s++) {
        const item = inv.map[s];
        // filtered view: only matching items (empty slots hidden)
        if (f !== 'all' && (!item || categoryOf(item) !== f)) continue;
        grid.appendChild(slotEl(invKey, s, item, invKey === 'player' && s <= state.hotbarSlots));
        shown++;
    }
    if (f !== 'all' && shown === 0) {
        grid.innerHTML = `<div class="grid-empty">${esc(L('ui_no_matches', 'No items in this category'))}</div>`;
    }
}

// category row has no scrollbar: mouse wheel scrolls it sideways
document.addEventListener('wheel', (e) => {
    const bar = e.target.closest('.filters');
    if (!bar || bar.scrollWidth <= bar.clientWidth) return;
    bar.scrollLeft += e.deltaY || e.deltaX;
    e.preventDefault();
}, { passive: false });

document.addEventListener('click', (e) => {
    const chip = e.target.closest('.chip[data-filter]');
    if (!chip) return;
    filters[chip.dataset.inv] = chip.dataset.filter;
    renderGrid(chip.dataset.inv);
    $(`grid-${chip.dataset.inv}`).scrollTop = 0;
});

function render() {
    if (state.player) {
        setWeight('player', state.player);
        renderGrid('player');
    }
    const other = state.other;
    $('panel-other').classList.toggle('hidden', !other);
    $('app').classList.toggle('shop-mode', !!(other && other.type === 'shop'));
    if (other) {
        $('other-label').textContent = other.label || L('ui_ground', 'Ground');
        const subs = {
            stash: L('ui_storage', 'Storage'),
            shop: L('ui_shop_hint', 'Drag to buy · drop here to sell'),
            player: L('ui_searching', 'Searching'),
        };
        $('other-sub').textContent = other.subtitle || subs[other.type] || L('ui_drop_here', 'Drop items here');
        $('panel-other').querySelector('.weight').classList.toggle('hidden', other.type === 'shop');
        if (other.type !== 'shop') setWeight('other', other);
        renderGrid('other');
    }
}

function setInv(key, data) {
    if (data === false) { state[key] = null; return; }
    if (!data) return; // undefined/null = unchanged
    if (key === 'other' && state.hideGround && data.type === 'drop') { state.other = null; return; }
    state[key] = { ...data, map: bySlot(data.items) };
}

/* ------------------------------------------------------------------ player info */
const money = (n) => '$' + (Number(n) || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

function renderPlayerInfo(p) {
    if (!p) return;
    state.info = p; // balances for the money transfer
    const first = p.firstname || '', last = p.lastname || '';
    $('pi-first').textContent = first || '—';
    $('pi-last').textContent = last || '—';
    $('pi-id').textContent = p.id ?? '—';
    $('pi-cid').textContent = p.citizenid || '—';
    $('pi-job').textContent = p.job || '—';
    $('pi-cash').textContent = money(p.cash);
    $('pi-blood').textContent = money(p.bloodmoney);
    $('pi-gold').textContent = (Number(p.gold) || 0).toLocaleString('en-US', { maximumFractionDigits: 2 });
}

/* ------------------------------------------------------------------ info */
function showInfo(item, invKey) {
    if (!item) return;
    $('info-title').textContent = item.label;
    $('info-desc').textContent = item.description || '';
    const rows = [`<div><span>${L('ui_weight', 'Weight')}</span>${kg((item.weight || 0) * (item.amount || 1))} ${esc(L('ui_kg', 'kg'))}</div>`];
    if (item.price !== undefined) rows.push(`<div><span>${L('ui_price', 'Price')}</span>$${Number(item.price).toFixed(2)}</div>`);
    const sells = item.buyPrice !== undefined ? item.buyPrice : sellPrice(invKey, item);
    if (sells !== undefined) rows.push(`<div><span>${L('ui_sells_for', 'Sells for')}</span>$${Number(sells).toFixed(2)}</div>`);
    const info = item.info || {};
    Object.keys(info).forEach((k) => {
        const v = info[k];
        if (v === null || typeof v === 'object') return;
        rows.push(`<div><span>${esc(L('info_' + k, k))}</span>${esc(v)}</div>`);
    });
    $('info-meta').innerHTML = rows.join('');
    $('info-desc').classList.toggle('hidden', !item.description);
    $('tip').classList.remove('hidden');
}

function hideInfo() { $('tip').classList.add('hidden'); }

// keep the tooltip next to the cursor without leaving the screen
function placeInfo(x, y) {
    const tip = $('tip');
    if (tip.classList.contains('hidden')) return;
    const { width: w, height: h } = tip.getBoundingClientRect(); // includes --ui-scale
    tip.style.left = (x + 18 + w > window.innerWidth ? x - w - 18 : x + 18) + 'px';
    tip.style.top = Math.max(8, Math.min(y + 18, window.innerHeight - h - 8)) + 'px';
}

/* ------------------------------------------------------------------ drag */
function invId(key) {
    if (key === 'player') return 'player';
    return state.other ? state.other.id : null;
}

function getItem(key, slot) {
    if (key === 'buys') return (state.buyList || [])[slot - 1]; // tooltip only
    const inv = state[key];
    return inv ? inv.map[slot] : null;
}

function requestedAmount(item, half, key) {
    const isShop = key === 'other' && state.other && state.other.type === 'shop';
    if (isShop) return 1; // more than one: right-click > Buy
    if (half) return Math.max(1, Math.floor(item.amount / 2));
    return item.amount;
}

function firstFreeSlot(key, name) {
    const inv = state[key];
    if (!inv) return null;
    for (let s = 1; s <= inv.slots; s++) {
        const it = inv.map[s];
        if (it && it.name === name && !it.unique) return s;
    }
    for (let s = 1; s <= inv.slots; s++) if (!inv.map[s]) return s;
    return null;
}

function move(fromKey, fromSlot, toKey, toSlot, amount) {
    const from = invId(fromKey), to = invId(toKey);
    if (!from || !to) return;
    post('move', { from, to, fromSlot, toSlot, amount });
}

document.addEventListener('mousedown', (e) => {
    const el = e.target.closest('.slot.filled');
    if (!el || !state.open || el.closest('#hotbar') || el.dataset.inv === 'buys') return; // "we buy" tab: display only
    const key = el.dataset.inv, slot = +el.dataset.slot;
    const item = getItem(key, slot);
    if (!item) return;

    if (e.button === 2) {
        const isShop = state.other && state.other.type === 'shop';
        if (state.other && !isShop) {
            // two inventories: right = 1 · shift + right = all · ctrl + right = type the amount
            const target = key === 'player' ? 'other' : 'player';
            const to = firstFreeSlot(target, item.name);
            if (!to) return;
            const send = (n) => move(key, slot, target, to, n);
            if (e.ctrlKey) return openTransferModal(item, send, target);
            return send(e.shiftKey ? item.amount : 1);
        }
        if (e.ctrlKey) { // alone: ctrl + right = split with typed amount
            if (!isShop || key === 'player') openSplitModal(key, slot, item);
            return;
        }
        openMenu(e.clientX, e.clientY, key, slot, item); // alone / shop: context menu
        return;
    }
    if (e.button !== 0) return;

    if (e.ctrlKey) { // quick move
        const target = key === 'player' ? 'other' : 'player';
        if (!state[target]) return;
        if (state.other.type === 'shop') { // shop: same amount box as dragging
            if (key === 'other') buyPrompt(slot, item, null);
            else sellPrompt(slot, item);
            return;
        }
        const to = state[target].type === 'shop' ? 1 : firstFreeSlot(target, item.name);
        if (to) move(key, slot, target, to, requestedAmount(item, e.shiftKey, key));
        return;
    }

    state.drag = { key, slot, item, amount: requestedAmount(item, e.shiftKey, key), el, startX: e.clientX, startY: e.clientY, active: false };
});

document.addEventListener('mousemove', (e) => {
    const d = state.drag;
    if (!d) return;
    if (!d.active) {
        if (Math.abs(e.clientX - d.startX) + Math.abs(e.clientY - d.startY) < 5) return;
        d.active = true;
        hideInfo();
        d.el.classList.add('dragging');
        if (d.key === 'player') $('app').classList.add('drag-player');
        const g = $('ghost');
        const fromShop = state.other && state.other.type === 'shop'; // buy / sell: amount asked on drop
        g.innerHTML = `<img src="${esc(imgSrc(d.item))}"><div class="qty">${fromShop ? '' : 'x' + d.amount}</div>`;
        g.classList.remove('hidden');
    }
    const g = $('ghost'); // centred on the cursor by CSS transform
    g.style.left = e.clientX + 'px';
    g.style.top = e.clientY + 'px';
    document.querySelectorAll('.drag-over').forEach((n) => n.classList.remove('drag-over'));
    const over = document.elementFromPoint(e.clientX, e.clientY);
    const target = over && (over.closest('#app .slot') || over.closest('.drop-zone'));
    if (target) target.classList.add('drag-over');
});

document.addEventListener('mouseup', (e) => {
    const d = state.drag;
    state.drag = null;
    if (!d) return;
    $('ghost').classList.add('hidden');
    $('app').classList.remove('drag-player');
    d.el.classList.remove('dragging');
    document.querySelectorAll('.drag-over').forEach((n) => n.classList.remove('drag-over'));
    if (!d.active) return;

    const over = document.elementFromPoint(e.clientX, e.clientY);
    if (!over) return;

    // shop open: drop anywhere on the other panel, ask the amount, then buy / sell
    if (state.other && state.other.type === 'shop') {
        if (d.key === 'other' && over.closest('#panel-player')) return buyPrompt(d.slot, d.item, over.closest('#app .slot'));
        if (d.key === 'player' && over.closest('#panel-other')) return sellPrompt(d.slot, d.item);
        if (d.key === 'other') return;
    }

    const zone = over.closest('.drop-zone');
    if (zone) {
        if (d.key !== 'player') return;
        if (zone.dataset.zone === 'drop') confirmDrop(d.slot, d.item, d.amount);
        return;
    }

    const slotEl = over.closest('#app .slot');
    if (!slotEl) return;
    const toKey = slotEl.dataset.inv, toSlot = +slotEl.dataset.slot;
    if (toKey === d.key && toSlot === d.slot) return;
    move(d.key, d.slot, toKey, toSlot, d.amount);
});

document.addEventListener('contextmenu', (e) => e.preventDefault());

document.addEventListener('dblclick', (e) => {
    const el = e.target.closest('#grid-player .slot.filled');
    if (el) post('use', { slot: +el.dataset.slot });
});

document.addEventListener('mouseover', (e) => {
    const el = e.target.closest('#app .slot.filled');
    if (!el || !state.open || state.drag || !$('ctx').classList.contains('hidden')) return hideInfo();
    showInfo(getItem(el.dataset.inv, +el.dataset.slot), el.dataset.inv);
    placeInfo(e.clientX, e.clientY);
});

document.addEventListener('mousemove', (e) => { if (!state.drag) placeInfo(e.clientX, e.clientY); });
document.addEventListener('mousedown', hideInfo);

document.addEventListener('click', (e) => {
    if (e.target.closest('[data-action="close"]')) post('close');
});

document.addEventListener('keyup', (e) => {
    if (!state.open) return;
    if (giveCtx) {
        if (e.key === 'Escape') closeGivePicker();
        return;
    }
    if (!$('amount-modal').classList.contains('hidden')) {
        if (e.key === 'Escape') closeAmountModal();
        if (e.key === 'Enter') confirmAmountModal();
        return;
    }
    if (!$('ctx').classList.contains('hidden') && e.key === 'Escape') return closeMenu();
    if (e.key === 'Escape' || e.key === 'Tab' || e.key.toLowerCase() === 'i') post('close');
});

/* ------------------------------------------------------------------ right-click menu */
function firstEmptySlot(key) {
    const inv = state[key];
    if (!inv) return null;
    for (let s = 1; s <= inv.slots; s++) if (!inv.map[s]) return s;
    return null;
}

const half = (n) => Math.max(1, Math.floor(n / 2));

// amount picker: n | 'half' | 'all' | 'ask'
function withAmount(item, choice, fn, max) {
    max = max || item.amount || 1;
    if (choice === 'ask') return openAmountModal(item, max, fn);
    const n = choice === 'all' ? max : choice === 'half' ? half(max) : choice;
    fn(Math.min(Math.max(1, n), max));
}

function amountSub(item, fn, opts = {}) {
    const max = opts.max || item.amount || 1;
    const subs = [{ label: L('ui_one', 'One'), run: () => withAmount(item, 1, fn, max) }];
    if (!opts.noHalf && max > 1) subs.push({ label: L('ui_half', 'Half'), run: () => withAmount(item, 'half', fn, max) });
    if (!opts.noAll && max > 1) subs.push({ label: L('ui_all_amount', 'All'), run: () => withAmount(item, 'all', fn, max) });
    subs.push({ label: L('ui_enter_amount', 'Amount…'), run: () => withAmount(item, 'ask', fn, max) });
    return subs;
}

function buildMenu(key, slot, item) {
    const other = state.other;
    const otherKey = key === 'player' ? 'other' : 'player';
    const entries = [];
    const isShop = key === 'other' && other && other.type === 'shop';

    if (isShop) return entries; // buying is done by dragging (amount box on drop)

    if (key === 'player') {
        if (item.useable || item.type === 'weapon' || item.type === 'weapon_thrown' || item.type === 'equipment') {
            entries.push({ label: L('ui_use', 'Use'), run: () => post('use', { slot }) });
        }
        entries.push({ label: L('ui_give', 'Give'), run: () => openGivePicker(slot, item) });
    }

    // taking from the ground / stash is done by dragging (amount from the centre box), no "Take" entry
    if (other && other.type !== 'shop' && key === 'player') {
        entries.push({ label: L('ui_move_to', 'Move to') + ' ' + (other.label || L('ui_ground', 'Ground')), sub: amountSub(item, (n) => {
            const to = firstFreeSlot(otherKey, item.name);
            if (to) move(key, slot, otherKey, to, n);
        }) });
    } // selling to a shop is done by dragging (amount box on drop)

    if (item.info && item.info.serie) {
        entries.push({ label: L('ui_copy_serial', 'Copy serial'), run: () => copyText(item.info.serie) });
    }
    return entries;
}

function copyText(text) {
    const t = document.createElement('textarea');
    t.value = text;
    document.body.appendChild(t);
    t.select();
    try { document.execCommand('copy'); } catch (err) { /* ignore */ }
    t.remove();
}

function renderMenuList(list, entries) {
    list.innerHTML = '';
    entries.forEach((en) => {
        const li = document.createElement('li');
        li.textContent = en.label;
        if (en.sub) {
            li.classList.add('has-sub');
            const sub = document.createElement('ul');
            sub.className = 'ctx-sub';
            renderMenuList(sub, en.sub);
            li.appendChild(sub);
        } else {
            li.addEventListener('click', (ev) => { ev.stopPropagation(); closeMenu(); en.run(); });
        }
        list.appendChild(li);
    });
}

function openMenu(x, y, key, slot, item) {
    showMenu(x, y, item.label, buildMenu(key, slot, item));
}

function showMenu(x, y, title, entries) {
    if (!entries.length) return;
    const menu = $('ctx');
    $('ctx-title').textContent = title;
    renderMenuList($('ctx-list'), entries);
    menu.classList.remove('hidden', 'flip');
    const { width: w, height: h } = menu.getBoundingClientRect(); // includes --ui-scale
    const left = Math.min(x, window.innerWidth - w - 8);
    menu.style.left = left + 'px';
    menu.style.top = Math.min(y, window.innerHeight - h - 8) + 'px';
    // open submenus to the left when there is no room on the right
    if (left + w * 2 > window.innerWidth) menu.classList.add('flip');
}

function closeMenu() { $('ctx').classList.add('hidden'); }

document.addEventListener('mousedown', (e) => {
    if (!e.target.closest('#ctx')) closeMenu();
}, true);

// right-click on Cash / Blood money: Transfer
document.addEventListener('mousedown', (e) => {
    if (e.button !== 2 || !state.open) return;
    const tile = e.target.closest('.pi-tile[data-money]');
    if (!tile) return;
    const type = tile.dataset.money;
    const label = tile.querySelector('span').textContent;
    showMenu(e.clientX, e.clientY, label, [
        { label: L('ui_transfer', 'Transfer'), run: () => openGivePicker(null, null, { type, label }) },
    ]);
});

/* ------------------------------------------------------------------ amount modal */
let amountCb = null, amountMax = 1, amountDecimal = false;
// shop buy / sell: { unit, weight } — total price and (buying) total weight under the input
let amountTotal = null;

function updateAmountTotal() {
    $('amount-modal-summary').classList.toggle('hidden', !amountTotal);
    if (!amountTotal) return;
    const n = Math.min(parseInt($('amount-modal-input').value, 10) || 0, amountMax);
    $('amount-modal-total').textContent = money(n * amountTotal.unit);
    const showWeight = amountTotal.weight !== undefined;
    $('amount-modal-weight-row').classList.toggle('hidden', !showWeight);
    if (!showWeight) return;
    const p = state.player;
    const free = p ? Math.max(0, p.maxWeight - totalWeight(p.map)) : 0;
    const w = $('amount-modal-weight');
    w.innerHTML = `${kg(n * amountTotal.weight)} ${esc(L('ui_kg', 'kg'))}<small>(${esc(L('ui_free', 'free'))} ${kg(free)} ${esc(L('ui_kg', 'kg'))})</small>`;
    w.classList.toggle('over', n * amountTotal.weight > free);
}
$('amount-modal-input').addEventListener('input', updateAmountTotal);

// opts: { title, desc, value, image, decimal, unitPrice, unitWeight } — decimal: money (cents allowed)
function openAmountModal(item, max, cb, opts = {}) {
    amountCb = cb; amountMax = max; amountDecimal = !!opts.decimal;
    amountTotal = opts.unitPrice !== undefined ? { unit: opts.unitPrice, weight: opts.unitWeight } : null;
    $('amount-modal-title').textContent = opts.title || item.label;
    $('amount-modal-desc').textContent = opts.desc || '';
    $('amount-modal-desc').classList.toggle('hidden', !opts.desc);
    $('amount-modal-stamp').classList.toggle('hidden', !opts.image);
    if (opts.image) {
        $('amount-modal-img').style.visibility = '';
        $('amount-modal-img').src = imgSrc(item);
    }
    $('amount-modal-max').textContent = `${L('ui_max', 'Max')}: ${amountDecimal ? money(max) : max}`;
    const input = $('amount-modal-input');
    input.step = amountDecimal ? '0.01' : '1';
    input.min = amountDecimal ? '0.01' : '1';
    input.max = max; input.value = opts.value || 1;
    updateAmountTotal();
    $('amount-modal').classList.remove('hidden');
    setTimeout(() => { input.focus(); input.select(); }, 0);
}

/* ------------------------------------------------------------------ give: player picker */
let giveCtx = null;

// item give: (slot, item) · money transfer: (null, null, { type, label })
async function openGivePicker(slot, item, moneyCtx) {
    let players = [];
    try {
        const res = await post('nearbyPlayers');
        players = (res && await res.json()) || [];
    } catch (err) { players = []; }
    // nobody nearby: the client shows a notification, no picker
    if (!players.length || !state.open) return;

    giveCtx = { slot, item, money: moneyCtx || null };
    $('give-stamp').classList.toggle('hidden', !item);
    if (item) {
        $('give-img').style.visibility = '';
        $('give-img').src = imgSrc(item);
    }
    $('give-item').textContent = item ? item.label : moneyCtx.label;
    $('give-list').innerHTML = players.map((p) => `<li class="give-player" data-id="${esc(p.id)}">
            <span class="gp-id">${esc(L('ui_person', 'Person'))} <b>#${esc(p.id)}</b></span>
            <span class="gp-dist">${esc(Number(p.dist).toFixed(1))} m</span>
        </li>`).join('');
    $('give-modal').classList.remove('hidden');
}

function closeGivePicker() {
    if (!giveCtx) return;
    giveCtx = null;
    giveHoverId = null;
    $('give-modal').classList.add('hidden');
    post('giveHover', {});
}

function choosePlayer(target) {
    const { slot, item, money: m } = giveCtx;
    closeGivePicker();
    if (m) {
        const balance = Number(state.info && state.info[m.type]) || 0;
        if (balance <= 0) return post('notifyNoMoney');
        return openAmountModal({ label: m.label }, balance, (n) => post('giveMoney', { type: m.type, amount: n, target }), {
            title: L('ui_transfer', 'Transfer'),
            desc: `${m.label} → ${L('ui_person', 'Person')} #${target}`,
            value: Math.min(1, balance),
            decimal: true,
        });
    }
    const give = (n) => post('give', { slot, amount: n, target });
    // weapons / unique items / single items: no amount step
    if (item.type === 'weapon' || item.type === 'weapon_thrown' || item.unique || (item.amount || 1) <= 1) return give(1);
    openAmountModal(item, item.amount, give, {
        title: L('ui_give', 'Give'),
        desc: `${item.label} → ${L('ui_person', 'Person')} #${target}`,
        value: 1,
        image: true,
    });
}

document.addEventListener('click', (e) => {
    if (e.target.closest('[data-give="cancel"]')) return closeGivePicker();
    const li = e.target.closest('.give-player');
    if (li && giveCtx) choosePlayer(+li.dataset.id);
});

// highlight the hovered player in the world
let giveHoverId = null;
document.addEventListener('mouseover', (e) => {
    if (!giveCtx) return;
    const li = e.target.closest('.give-player');
    const id = li ? +li.dataset.id : null;
    if (id === giveHoverId) return;
    giveHoverId = id;
    post('giveHover', { id });
});

// ctrl + right click with two inventories open: type how many to move to the other side
function openTransferModal(item, send, target) {
    const max = item.amount || 1;
    if (max <= 1) return send(1);
    const dest = target === 'player'
        ? L('ui_satchel', 'Satchel')
        : ((state.other && state.other.label) || L('ui_ground', 'Ground'));
    openAmountModal(item, max, send, {
        title: L('ui_move_to', 'Move to') + ' ' + dest,
        desc: item.label,
        value: 1,
        image: true,
    });
}

// ctrl + right click: split part of a stack into the first empty slot of the same inventory
function openSplitModal(key, slot, item) {
    if (item.unique || (item.amount || 1) < 2) return;
    openAmountModal(item, item.amount - 1, (n) => {
        const to = firstEmptySlot(key);
        if (to) move(key, slot, key, to, n);
    }, {
        title: L('ui_split', 'Split'),
        desc: item.label,
        value: Math.floor(item.amount / 2),
        image: true,
    });
}

function confirmDrop(slot, item, amount) {
    const max = item.amount || 1;
    openAmountModal(item, max, (n) => post('drop', { slot, amount: n }), {
        title: L('ui_drop_item', 'Drop item'),
        desc: L('ui_drop_confirm', 'Drop %s on the ground?').replace('%s', item.label),
        value: Math.min(Math.max(1, amount || max), max),
        image: true,
    });
}
// buy into the slot under the cursor when it can take the item, otherwise the first free one
function buyPrompt(shopSlot, item, targetEl) {
    const at = targetEl && targetEl.dataset.inv === 'player' ? +targetEl.dataset.slot : null;
    const held = at && getItem('player', at);
    const to = at && (!held || (held.name === item.name && !held.unique)) ? at : firstFreeSlot('player', item.name);
    if (!to) return;
    const buy = (n) => move('other', shopSlot, 'player', to, n);
    const unit = Number(item.price) || 0;
    // unique items (weapons) are bought one at a time by the server
    openAmountModal(item, item.unique ? 1 : (item.amount || 1000), buy, {
        title: L('ui_buy', 'Buy'),
        desc: `${item.label} · ${money(unit)} ${L('ui_each', 'each')}`,
        value: 1,
        image: true,
        unitPrice: unit,
        unitWeight: item.weight || 0,
    });
}

// player -> shop; the shop pays less for worn items, same rule as the server
function sellPrompt(slot, item) {
    const sell = (n) => move('player', slot, 'other', 1, n);
    const base = sellPrice('player', item);
    if (base === undefined) return sell(item.amount); // the server answers "won't buy"
    const q = item.info && typeof item.info.quality === 'number' ? item.info.quality : 100;
    const unit = Math.floor(base * (q / 100) * 100 + 0.5) / 100;
    openAmountModal(item, item.amount || 1, sell, {
        title: L('ui_sell', 'Sell'),
        desc: `${item.label} · ${money(unit)} ${L('ui_each', 'each')}`,
        value: item.amount,
        image: true,
        unitPrice: unit,
    });
}

function closeAmountModal() { $('amount-modal').classList.add('hidden'); amountCb = null; amountTotal = null; }
function confirmAmountModal() {
    const raw = $('amount-modal-input').value;
    const n = amountDecimal ? Math.floor(parseFloat(raw) * 100 + 1e-6) / 100 : parseInt(raw, 10);
    const cb = amountCb;
    closeAmountModal();
    if (cb && n > 0) cb(Math.min(n, amountMax));
}
document.addEventListener('click', (e) => {
    if (e.target.closest('[data-modal="confirm"]')) confirmAmountModal();
    if (e.target.closest('[data-modal="cancel"]')) closeAmountModal();
});

/* ------------------------------------------------------------------ hotbar */
let hotbarTimer = null;
function showHotbar(items) {
    const bar = $('hotbar');
    bar.innerHTML = '';
    const map = bySlot(items);
    for (let s = 1; s <= state.hotbarSlots; s++) bar.appendChild(slotEl('hotbar', s, map[s], true));
    bar.classList.remove('hidden');
    clearTimeout(hotbarTimer);
    hotbarTimer = setTimeout(() => bar.classList.add('hidden'), 3000);
}

/* ------------------------------------------------------------------ item box */
const itemBoxRecent = {};
function showItemBox(d) {
    if (!d || !d.item) return;
    // de-dupe: scripts often call RemoveItem AND trigger their own ItemBox, and the
    // inventory also sends a 'use' box — show one box per item/action burst
    const now = Date.now(), name = d.item.name;
    const seen = (k) => now - (itemBoxRecent[name + ':' + k] || 0) < 1000;
    if (seen(d.kind)) return;
    if (d.kind === 'use' && seen('remove')) return;
    if (d.kind === 'remove' && seen('use')) return;
    itemBoxRecent[name + ':' + d.kind] = now;
    if (d.imagePath) state.imagePath = d.imagePath;
    const box = document.createElement('div');
    box.className = `itembox itembox-${d.kind}`;
    const qty = d.kind === 'use' ? '' : `${d.amount}x `;
    box.innerHTML = `<div class="itembox-action">${esc(d.text || d.kind)}</div>
        <img src="${esc(imgSrc(d.item))}" onerror="this.style.visibility='hidden'">
        <div class="itembox-label">${esc(qty + (d.item.label || d.item.name))}</div>`;
    const c = $('itembox-container');
    c.className = 'pos-' + (d.position || 'bottom');
    c.appendChild(box);
    while (c.children.length > 5) c.firstChild.remove();
    setTimeout(() => box.classList.add('out'), 4600); // visible for 5s, last 0.4s fades out
    setTimeout(() => box.remove(), 5000);
}

/* ------------------------------------------------------------------ messages */
window.addEventListener('message', ({ data: msg }) => {
    const d = msg.data || {};
    switch (msg.action) {
        case 'open':
            state.open = true;
            state.imagePath = d.imagePath || state.imagePath;
            state.hotbarSlots = d.hotbarSlots || 5;
            if (d.uiScale) { uiScaleMul = Number(d.uiScale) || 1; applyScale(); }
            state.other = null;
            state.hideGround = !!(d.other && d.other.type === 'drop' && d.other.id === 'newdrop');
            if (d.labels) labels = d.labels;
            categoryLabels = d.categoryLabels || {};
            filters.other = 'all';
            applyLabels();
            hideInfo();
            setInv('player', d.player);
            setInv('other', d.other);
            renderPlayerInfo(d.info);
            $('hotbar').classList.add('hidden');
            $('app').classList.remove('hidden');
            render();
            break;
        case 'refresh':
            setInv('player', d.player);
            setInv('other', d.other);
            renderPlayerInfo(d.info);
            render();
            break;
        case 'playerInfo':
            renderPlayerInfo(d);
            break;
        case 'close': // close everything the inventory had on screen
            closeMenu();
            closeAmountModal();
            closeGivePicker();
            hideInfo();
            state.open = false;
            state.drag = null;
            $('app').classList.remove('drag-player');
            $('ghost').classList.add('hidden');
            $('app').classList.add('hidden');
            break;
        case 'hotbar':
            state.imagePath = d.imagePath || state.imagePath;
            showHotbar(d.items);
            break;
        case 'itembox':
            showItemBox(d);
            break;
    }
});
