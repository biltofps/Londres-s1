(() => {
    'use strict';

    const IN_GAME = typeof GetParentResourceName === 'function';
    const RESOURCE = IN_GAME ? GetParentResourceName() : 'bilto_hud';

    const hud = document.getElementById('hud');
    const grid = document.getElementById('grid');
    const panel = document.getElementById('panel');
    const panelBody = document.getElementById('panel-body');
    const toolbar = document.getElementById('toolbar');
    const guideV = document.getElementById('guide-v');
    const guideH = document.getElementById('guide-h');

    const clamp = (v, min, max) => Math.min(max, Math.max(min, v));
    const round3 = (v) => Math.round(v * 1000) / 1000;
    const clone = (o) => JSON.parse(JSON.stringify(o));
    const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

    // Formas das molduras (viewBox 100x100). Todas comecam no topo para o preenchimento girar no sentido horario.
    const SHAPES = {
        ring: 'M50 8a42 42 0 1 1 0 84a42 42 0 1 1 0-84',
        diamond: 'M50 6L94 50L50 94L6 50Z',
        hex: 'M50 6L88 28L88 72L50 94L12 72L12 28Z',
        square: 'M50 8H80Q92 8 92 20V80Q92 92 80 92H20Q8 92 8 80V20Q8 8 20 8Z',
        octagon: 'M50 6H68L94 32V68L68 94H32L6 68V32L32 6Z',
        shield: 'M50 6L88 18V48C88 72 70 88 50 95C30 88 12 72 12 48V18Z',
        star: 'M50 7L64.1 33.6L93.7 38.8L72.8 60.4L77 90.2L50 77L23 90.2L27.2 60.4L6.3 38.8L35.9 33.6Z',
        arc: 'M20.3 79.7A42 42 0 1 1 79.7 79.7', // medidor: 3/4 de circulo aberto embaixo
    };
    const SHAPE_BG = { arc: SHAPES.ring };

    // molduras abertas: o fundo escuro atras nao faz sentido, ficam so com sombra de contorno
    const NO_BG = new Set(['star', 'arc', 'dots', 'segring', 'sunburst', 'corners', 'blades', 'compass']);

    // cristal: retangulo arredondado da borda (comeca no topo para preencher no sentido horario)
    const CRYSTAL_EDGE = 'M50 3H81Q97 3 97 19V81Q97 97 81 97H19Q3 97 3 81V19Q3 3 19 3Z';
    // onda periodica (periodo 100 em 200 de largura) para animar sem emenda
    const WAVE = 'M0 10Q25 2 50 10T100 10T150 10T200 10V20H0Z';

    // alertas nao tem "nivel": nesses estilos aparecem so como icone
    const FLAG_ICON_ONLY = ['bar', 'vbar', 'pips', 'dotrow', 'squares', 'battery'];
    const SEGMENTS = 5;
    const segs = (n) => '<i class="seg"></i>'.repeat(n);

    // =========================================================
    // ESTILOS SEGMENTADOS: moldura de pecas em volta do icone centralizado.
    // Cada peca tem class "seg" e elas acendem na ordem do array (sentido horario, a partir do topo).
    // "sk" = peca desenhada com traco (stroke) em vez de preenchimento.
    // =========================================================
    const fx = (n) => n.toFixed(1);
    const P = (r, deg) => {
        const a = deg * Math.PI / 180;
        return [fx(50 + r * Math.cos(a)), fx(50 + r * Math.sin(a))];
    };
    const around = (n, fn) => Array.from({ length: n }, (_, i) => fn(i, -90 + i * 360 / n));
    const polyPath = (r, n, start) => 'M' + around(n, (i) => P(r, start + i * 360 / n).join(' ')).join('L') + 'Z';

    // n arcos com folga entre eles
    function arcs(n, r, gap, width) {
        return around(n, (i, a) => {
            const [x1, y1] = P(r, a + gap / 2);
            const [x2, y2] = P(r, a + 360 / n - gap / 2);
            return `<path class="seg sk" d="M${x1} ${y1}A${r} ${r} 0 0 1 ${x2} ${y2}" stroke-width="${width}"/>`;
        });
    }

    // lados de um poligono divididos em k pedacos com folga
    function polySegs(verts, k, gap, width) {
        const out = [];
        verts.forEach(([ax, ay], v) => {
            const [bx, by] = verts[(v + 1) % verts.length];
            for (let j = 0; j < k; j++) {
                const t0 = (j + gap / 2) / k, t1 = (j + 1 - gap / 2) / k;
                out.push(`<path class="seg sk" d="M${fx(ax + (bx - ax) * t0)} ${fx(ay + (by - ay) * t0)}L${fx(ax + (bx - ax) * t1)} ${fx(ay + (by - ay) * t1)}" stroke-width="${width}" stroke-linecap="round"/>`);
            }
        });
        return out;
    }

    const BG_CIRCLE = '<circle class="bg" cx="50" cy="50" r="49"/>';
    const BG_SQUARE = '<rect class="bg" width="100" height="100" rx="14"/>';
    const vertsOf = (r, n, start) => around(n, (i) => P(r, start + i * 360 / n).map(Number));

    const SEG_STYLES = {
        // anel de 12 pontinhos
        dots: { bg: BG_CIRCLE, segs: around(12, (i, a) => { const [x, y] = P(40, a); return `<circle class="seg" cx="${x}" cy="${y}" r="6.5"/>`; }) },
        // anel cortado em 10 gomos
        segring: { bg: BG_CIRCLE, segs: arcs(10, 40, 9, 7) },
        // 16 tracinhos radiais (mostrador)
        sunburst: {
            bg: BG_CIRCLE,
            segs: around(16, (i, a) => {
                const [x1, y1] = P(31, a), [x2, y2] = P(44, a);
                return `<path class="seg sk" d="M${x1} ${y1}L${x2} ${y2}" stroke-width="5" stroke-linecap="round"/>`;
            }),
        },
        // hexagono com 12 segmentos
        hexseg: { bg: `<path class="bg" d="${polyPath(50, 6, -90)}"/>`, segs: polySegs(vertsOf(42, 6, -90), 2, 0.2, 7) },
        // losango com 12 segmentos
        diamondseg: { bg: `<path class="bg" d="${polyPath(50, 4, -90)}"/>`, segs: polySegs(vertsOf(43, 4, -90), 3, 0.18, 7) },
        // 8 cantoneiras de mira
        corners: {
            bg: BG_SQUARE,
            segs: ['M14 8H36', 'M64 8H86', 'M92 14V36', 'M92 64V86', 'M86 92H64', 'M36 92H14', 'M8 86V64', 'M8 36V14']
                .map((d) => `<path class="seg sk" d="${d}" stroke-width="7" stroke-linecap="round"/>`),
        },
        // 10 laminas inclinadas
        blades: {
            bg: BG_CIRCLE,
            segs: around(10, (i) => `<path class="seg" d="M46 7L60 8.5L55.5 24L43.5 22Z" transform="rotate(${i * 36} 50 50)"/>`),
        },
        // 8 setas apontando para fora
        compass: {
            bg: BG_CIRCLE + '<circle cx="50" cy="50" r="30" fill="none" stroke="rgba(255,255,255,.12)" stroke-width="2"/>',
            segs: around(8, (i) => `<path class="seg" d="M50 5L58.5 18.5H41.5Z" transform="rotate(${i * 45} 50 50)"/>`),
        },
    };

    function segShape(style) {
        const def = SEG_STYLES[style];
        return `<svg viewBox="0 0 100 100">${def.bg}${def.segs.join('')}</svg>`;
    }

    const iconsFor = (key) => (ELEMENTS[key].icons || [ELEMENTS[key].icon]).filter((name) => ICONS[name]);

    // Icones apenas da interface do editor
    const UI = {
        undo: '<path d="M3 7v6h6"/><path d="M21 17a9 9 0 0 0-15-6.7L3 13"/>',
        redo: '<path d="M21 7v6h-6"/><path d="M3 17a9 9 0 0 1 15-6.7L21 13"/>',
        grid: '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/>',
        magnet: '<path d="m6 15-4-4 6.75-6.77a7.79 7.79 0 0 1 11 11L13 22l-4-4 6.39-6.36a2.14 2.14 0 0 0-3-3L6 15"/><path d="m5 8 4 4"/><path d="m12 15 4 4"/>',
        reset: '<path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/>',
        x: '<path d="M18 6 6 18M6 6l12 12"/>',
        check: '<path d="M20 6 9 17l-5-5"/>',
        back: '<path d="m15 18-6-6 6-6"/>',
        chev: '<path d="m9 18 6-6-6-6"/>',
        minus: '<path d="M5 12h14"/>',
        plus: '<path d="M12 5v14M5 12h14"/>',
        layout: '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
        layers: '<path d="m12 2 10 5-10 5L2 7Z"/><path d="m2 17 10 5 10-5"/><path d="m2 12 10 5 10-5"/>',
        sliders: '<path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6"/>',
        bookmark: '<path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/>',
        grip: '<circle cx="9" cy="6" r="1"/><circle cx="15" cy="6" r="1"/><circle cx="9" cy="12" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="9" cy="18" r="1"/><circle cx="15" cy="18" r="1"/>',
        arrange: '<rect x="3" y="14" width="5" height="7" rx="1"/><rect x="9.5" y="14" width="5" height="7" rx="1"/><rect x="16" y="14" width="5" height="7" rx="1"/><path d="M12 3v7M9 7l3 3 3-3"/>',
        eye: '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
        eyeoff: '<path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.53 13.53 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><path d="M2 2l20 20"/>',
    };
    const ui = (name) => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + UI[name] + '</svg>';

    const SAMPLE_DATA = {
        health: 100, stamina: 82, hunger: 64, thirst: 48, cleanliness: 90, stress: 18,
        onHorse: true, horse_health: 95, horse_stamina: 70, horse_clean: 55,
        talking: false, voiceIndex: 2, temp: 22,
        cash: 125.5, gold: 3, bank: 1500, bloodmoney: 0,
        id: 1, hour: 12, minute: 0, mail: true, outlaw: 1,
    };

    const state = {
        config: { lowThreshold: 25, voiceModes: 3, tempUnit: 'C', defaultPreset: 'classico', maxPresets: 12 },
        layout: null,
        data: { ...SAMPLE_DATA, onHorse: false, mail: false, outlaw: 0 },
        show: false,
        editing: false,
        selected: null,
        tab: 'presets',
        snapshot: null,
        undo: [],
        redo: [],
        flashing: new Map(),
        sliding: false,
        myPresets: [],
        confirmDelete: null,
    };

    const nodes = {};

    // =========================================================
    // NUI
    // =========================================================
    function post(name, data) {
        if (!IN_GAME) return Promise.resolve();
        return fetch(`https://${RESOURCE}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data || {}),
        }).catch(() => {});
    }

    // =========================================================
    // LAYOUT
    // =========================================================
    const LOGO_STYLES = { plain: 'Logo' };

    function stylesFor(key) {
        const kind = ELEMENTS[key].kind;
        if (kind === 'logo') return LOGO_STYLES;
        return kind === 'info' ? INFO_STYLES : STAT_STYLES;
    }

    // elementos que usam os estilos de status (barra, circulo, cristal...)
    const isStatLike = (key) => !['info', 'logo'].includes(ELEMENTS[key].kind);

    function defaultGlobal() {
        return { scale: 1, opacity: 1, bgOpacity: 0.55, lowAlert: true, showGrid: true, snap: true, grid: 2 };
    }

    function defaultElement(key, presetKey) {
        const def = ELEMENTS[key];
        const preset = PRESETS[presetKey] || PRESETS.classico;
        return {
            visible: !def.hidden,
            // logo nasce no topo central; os outros sao posicionados pelo modelo
            x: def.kind === 'logo' ? LOGO_POSITIONS.center.x : null,
            y: def.kind === 'logo' ? 0 : null,
            style: def.kind === 'logo' ? 'plain' : def.kind === 'info' ? preset.info : preset.stat,
            size: 1,
            color: (preset.palette && preset.palette[key]) || def.color,
            // informacoes usam a cor do elemento no icone por padrao; status usam branco
            iconColor: preset.iconColor || (def.kind === 'info' ? (preset.palette && preset.palette[key]) || def.color : '#ffffff'),
            icon: def.icon,
            showValue: !!preset.showValue,
            autoHide: def.kind === 'stat' ? !!preset.autoHide : false,
        };
    }

    // Junta o layout salvo com os padroes (elementos novos ganham valores padrao, campos invalidos sao corrigidos)
    function sanitizeLayout(raw) {
        raw = raw && typeof raw === 'object' ? raw : {};
        const presetKey = PRESETS[raw.preset] ? raw.preset : state.config.defaultPreset;
        const layout = {
            version: 1,
            preset: presetKey,
            global: { ...defaultGlobal(), ...(raw.global || {}) },
            elements: {},
        };

        const g = layout.global;
        g.scale = clamp(+g.scale || 1, 0.6, 1.6);
        g.opacity = clamp(+g.opacity || 1, 0.3, 1);
        g.bgOpacity = clamp(isFinite(+g.bgOpacity) ? +g.bgOpacity : 0.55, 0, 1);
        g.grid = clamp(+g.grid || 2, 1, 5);

        for (const key of Object.keys(ELEMENTS)) {
            const base = defaultElement(key, presetKey);
            const saved = raw.elements && raw.elements[key];
            const el = saved && typeof saved === 'object' ? { ...base, ...saved } : base;

            if (!stylesFor(key)[el.style]) el.style = base.style;
            if (!iconsFor(key).includes(el.icon)) el.icon = base.icon;
            if (!/^#[0-9a-f]{6}$/i.test(el.color)) el.color = base.color;
            if (!/^#[0-9a-f]{6}$/i.test(el.iconColor)) el.iconColor = base.iconColor;
            if (typeof el.x !== 'number' || typeof el.y !== 'number') { el.x = null; el.y = null; }
            el.size = clamp(+el.size || 1, 0.5, 2);
            el.visible = !!el.visible;
            el.showValue = !!el.showValue;
            el.autoHide = !!el.autoHide;

            layout.elements[key] = el;
        }
        return layout;
    }

    function remPx() {
        return parseFloat(getComputedStyle(document.documentElement).fontSize) || 16;
    }

    // Converte a caixa (px) em posicao percentual. A ancora acompanha a posicao
    // (0% = borda esquerda, 50% = centro, 100% = borda direita), entao o icone nunca sai da tela
    // em nenhuma resolucao.
    function setFromBox(el, left, top, w, h) {
        const W = window.innerWidth, H = window.innerHeight;
        el.x = W > w ? round3(clamp(left / (W - w), 0, 1) * 100) : 50;
        el.y = H > h ? round3(clamp(top / (H - h), 0, 1) * 100) : 50;
    }

    function boxOf(key) {
        const r = nodes[key].getBoundingClientRect();
        return { left: r.left, top: r.top, w: r.width, h: r.height };
    }

    // coloca a logo no topo (left/center/right) e reorganiza informacoes e alertas em volta dela, na ordem e alinhados
    function setLogoPosition(pos) {
        const p = LOGO_POSITIONS[pos];
        if (!p) return;
        state.layout.elements.logo.x = p.x;
        state.layout.elements.logo.y = 0;
        position('logo');
        placePreset(state.layout.preset, false, {
            avoid: logoBox(),
            only: (g) => g.keys.some((k) => ELEMENTS[k] && ['info', 'flag'].includes(ELEMENTS[k].kind)),
        });
        positionAll();
        resolveOverlaps();
    }

    // caixa da logo na tela (se visivel), para os grupos desviarem dela
    function logoBox() {
        const el = state.layout.elements.logo;
        if (!el || !el.visible || !nodes.logo || nodes.logo.classList.contains('logo-missing')) return null;
        return boxOf('logo');
    }

    // Monta as posicoes de um modelo medindo os elementos reais na tela do jogador.
    // opts.only(group): so reposiciona os grupos aceitos
    // opts.avoid: caixa (ex.: a logo) que os grupos nao podem cobrir; o grupo inteiro desce/sobe para fora dela
    function placePreset(presetKey, onlyMissing, opts) {
        opts = opts || {};
        const preset = PRESETS[presetKey] || PRESETS.classico;
        const W = window.innerWidth, H = window.innerHeight, R = remPx();
        const els = state.layout.elements;
        const avoidGap = R * 0.6;

        for (const group of preset.groups) {
            if (opts.only && !opts.only(group)) continue;
            const keys = group.keys.filter((k) => ELEMENTS[k]);
            const row = group.dir === 'row';
            const gap = (group.gap || 0) * R;
            const items = keys.map((k) => ({ k, ...boxOf(k) }));
            const shown = items.filter((i) => els[i.k].visible);
            const hidden = items.filter((i) => !els[i.k].visible);
            const flow = shown.length ? shown : items;

            const mainOf = (i) => (row ? i.w : i.h);
            const crossOf = (i) => (row ? i.h : i.w);
            const total = flow.reduce((s, i) => s + mainOf(i), 0) + gap * Math.max(0, flow.length - 1);
            const cross = Math.max(...items.map(crossOf));
            const gw = row ? total : cross;
            const gh = row ? cross : total;

            const gl = group.l != null ? group.l * R : group.r != null ? W - group.r * R - gw : (W - gw) / 2 + (group.x || 0) * R;
            let gt = group.t != null ? group.t * R : group.b != null ? H - group.b * R - gh : (H - gh) / 2 + (group.y || 0) * R;
            const a = opts.avoid;
            if (a && gl < a.left + a.w + avoidGap && gl + gw > a.left - avoidGap && gt < a.top + a.h + avoidGap && gt + gh > a.top - avoidGap) {
                // grupo de cima desce para baixo da logo; grupo de baixo sobe para cima dela
                gt = group.b != null ? a.top - avoidGap - gh : a.top + a.h + avoidGap;
            }
            const align = row
                ? (group.b != null ? 1 : group.t != null ? 0 : 0.5)
                : (group.r != null ? 1 : group.l != null ? 0 : 0.5);
            // ocultos continuam a fila, para o lado oposto a ancora (assim nao ficam por cima dos visiveis)
            const anchoredEnd = row ? group.r != null : group.b != null;

            const place = (item, offset) => {
                if (onlyMissing && els[item.k].x != null) return;
                const left = row ? gl + offset : gl + (cross - item.w) * align;
                const top = row ? gt + (cross - item.h) * align : gt + offset;
                setFromBox(els[item.k], left, top, item.w, item.h);
            };

            let cursor = 0;
            for (const item of flow) {
                place(item, cursor);
                cursor += mainOf(item) + gap;
            }
            if (flow === shown) {
                let back = 0;
                for (const item of hidden) {
                    if (anchoredEnd) {
                        back -= mainOf(item) + gap;
                        place(item, back);
                    } else {
                        place(item, cursor);
                        cursor += mainOf(item) + gap;
                    }
                }
            }
        }
    }

    function applyPreset(presetKey, keepVisibility) {
        const previous = state.layout;
        const fresh = sanitizeLayout({ preset: presetKey, global: previous ? previous.global : undefined });
        if (keepVisibility && previous) {
            for (const key of Object.keys(fresh.elements)) fresh.elements[key].visible = previous.elements[key].visible;
        }
        state.layout = fresh;
        renderAll();
        placePreset(presetKey, false);
        positionAll();
    }

    function loadLayout(raw) {
        state.layout = sanitizeLayout(raw);
        renderAll();
        const missing = Object.values(state.layout.elements).some((el) => el.x == null);
        if (missing) {
            placePreset(state.layout.preset, true);
            positionAll();
        }
        // layout salvo em outra resolucao/proporcao pode encostar: afasta
        resolveOverlaps();
    }

    // Afasta elementos visiveis que estao encostando (ex.: depois de aumentar o tamanho).
    // Empurra cada par pelo eixo de menor sobreposicao, metade para cada lado, sem sair da tela.
    // Uma fileira cresce para os lados a partir do centro; no eixo vertical a fileira inteira
    // se move junto (elementos com o mesmo centro vertical), para nao ficar desalinhada.
    function resolveOverlaps() {
        const W = window.innerWidth, H = window.innerHeight;
        const gap = remPx() * 0.3;
        const els = state.layout.elements;
        const boxes = Object.keys(nodes).filter((k) => els[k].visible).map((k) => ({ k, ...boxOf(k), pinned: ELEMENTS[k].kind === 'logo' }));

        // agrupa em fileiras pelo centro vertical (a logo fica sozinha: nunca arrasta ninguem junto)
        const rows = [];
        for (const b of boxes) {
            if (b.pinned) { b.row = { cy: -1, items: [b] }; continue; }
            const cy = b.top + b.h / 2;
            let row = rows.find((r) => Math.abs(r.cy - cy) < 3);
            if (!row) rows.push(row = { cy, items: [] });
            row.items.push(b);
            b.row = row;
        }
        const keepIn = (b) => {
            b.left = clamp(b.left, 0, Math.max(0, W - b.w));
            b.top = clamp(b.top, 0, Math.max(0, H - b.h));
        };
        // move a fileira inteira na vertical, limitada pela tela
        const shiftRow = (row, dy) => {
            const top = Math.min(...row.items.map((i) => i.top));
            const bottom = Math.max(...row.items.map((i) => i.top + i.h));
            dy = clamp(dy, -top, H - bottom);
            for (const i of row.items) i.top += dy;
            return dy;
        };

        let changed = false;
        for (let iter = 0; iter < 80; iter++) {
            let moved = false;
            for (let i = 0; i < boxes.length; i++) {
                for (let j = i + 1; j < boxes.length; j++) {
                    const a = boxes[i], b = boxes[j];
                    const ox = Math.min(a.left + a.w, b.left + b.w) - Math.max(a.left, b.left) + gap;
                    const oy = Math.min(a.top + a.h, b.top + b.h) - Math.max(a.top, b.top) + gap;
                    if (ox <= 0.5 || oy <= 0.5) continue;

                    moved = changed = true;
                    if (a.pinned || b.pinned) {
                        // a logo fica onde o jogador escolheu: so o outro se move, para o lado onde couber
                        const p = a.pinned ? a : b, o = a.pinned ? b : a;
                        const options = [
                            { dx: 0, dy: p.top - gap - o.h - o.top },          // acima
                            { dx: 0, dy: p.top + p.h + gap - o.top },          // abaixo
                            { dx: p.left - gap - o.w - o.left, dy: 0 },        // esquerda
                            { dx: p.left + p.w + gap - o.left, dy: 0 },        // direita
                        ].filter((m) => o.left + m.dx >= 0 && o.left + o.w + m.dx <= W && o.top + m.dy >= 0 && o.top + o.h + m.dy <= H);
                        // prefere subir/descer (mantem colunas como a de informacoes alinhadas); lateral so se nao couber
                        const cost = (m) => Math.abs(m.dy) + Math.abs(m.dx) * 4;
                        const best = options.sort((m1, m2) => cost(m1) - cost(m2))[0];
                        if (best) {
                            if (best.dy) shiftRow(o.row, best.dy);
                            o.left += best.dx;
                        }
                        continue;
                    }
                    if (ox < oy) {
                        const dir = a.left + a.w / 2 <= b.left + b.w / 2 ? -1 : 1;
                        a.left += dir * ox / 2;
                        b.left -= dir * ox / 2;
                        keepIn(a);
                        keepIn(b);
                    } else if (a.row !== b.row) {
                        // fileiras diferentes: afasta as duas fileiras; se uma bater na borda, a outra anda o resto
                        const dir = a.top + a.h / 2 <= b.top + b.h / 2 ? -1 : 1;
                        const movedA = shiftRow(a.row, dir * oy / 2);
                        shiftRow(b.row, -dir * (oy - Math.abs(movedA)));
                    } else {
                        const dir = a.top + a.h / 2 <= b.top + b.h / 2 ? -1 : 1;
                        a.top += dir * oy / 2;
                        b.top -= dir * oy / 2;
                        keepIn(a);
                        keepIn(b);
                    }
                }
            }
            if (!moved) break;
        }

        if (!changed) return;
        for (const b of boxes) {
            setFromBox(els[b.k], b.left, b.top, b.w, b.h);
            position(b.k);
        }
    }

    // =========================================================
    // RENDER
    // =========================================================
    function buildElement(key, cfg, global) {
        const def = ELEMENTS[key];
        const node = document.createElement('div');
        node.className = `el kind-${def.kind} ${def.kind === 'info' ? 'in-' : 'st-'}${cfg.style}`;
        if (NO_BG.has(cfg.style)) node.classList.add('nobg');
        node.dataset.key = key;
        node.dataset.label = def.label;
        node.style.setProperty('--c', cfg.color);
        node.style.setProperty('--ic', cfg.iconColor);
        node.style.setProperty('--s', global.scale * cfg.size);
        node.style.setProperty('--bga', global.bgOpacity);

        const svg = iconSvg(cfg.icon);
        const ico = `<div class="ico">${svg}</div>`;
        const badge = `<div class="badge">${ico}</div>`;
        const val = cfg.showValue ? '<span class="val"></span>' : '';

        if (def.kind === 'logo') {
            // o padding da caixa vira a margem da borda da tela (a ancora encosta a caixa na borda)
            node.innerHTML = `<img class="logo-img" src="${esc(state.config.logo || 'assets/logo.png')}" alt="" draggable="false">`;
            return node;
        }

        if (def.kind === 'info') {
            node.innerHTML = cfg.style === 'card'
                ? `${ico}<div class="meta"><small>${esc(def.label)}</small><span class="txt"></span></div>`
                : `${ico}<span class="txt"></span>`;
            return node;
        }

        if (def.kind === 'flag' && FLAG_ICON_ONLY.includes(cfg.style)) {
            node.className = 'el kind-flag st-badge';
            node.innerHTML = ico;
            return node;
        }

        switch (cfg.style) {
            case 'bar':
                node.innerHTML = `${badge}<div class="track"><div class="fill"></div></div>${val}`;
                break;
            case 'vbar':
                node.innerHTML = `<div class="track"><div class="fill"></div></div>${badge}${val}`;
                break;
            case 'minimal':
                node.innerHTML = `<div class="mico"><div class="ico base">${svg}</div><div class="ico top">${svg}</div></div>${val}`;
                break;
            case 'orb':
                node.innerHTML = `<div class="orb"><div class="fill"></div>${ico}</div>${val}`;
                break;
            case 'crystal':
                node.innerHTML = `<div class="crystal">
                    <div class="fill"><svg class="wave" viewBox="0 0 200 20" preserveAspectRatio="none"><path d="${WAVE}"/></svg></div>
                    <svg class="edge" viewBox="0 0 100 100"><path class="trk" d="${CRYSTAL_EDGE}"/><path class="fil" d="${CRYSTAL_EDGE}" pathLength="100"/></svg>
                    ${ico}</div>${val}`;
                break;
            case 'tile':
                node.innerHTML = `<div class="tile">${ico}<div class="track"><div class="fill"></div></div></div>${val}`;
                break;
            case 'pips':
                node.innerHTML = `${badge}<div class="pips">${segs(SEGMENTS)}</div>${val}`;
                break;
            case 'dotrow':
            case 'squares':
                node.innerHTML = `${badge}<div class="segs">${segs(SEGMENTS)}</div>${val}`;
                break;
            case 'battery':
                node.innerHTML = `${badge}<div class="batt">${segs(SEGMENTS)}</div>${val}`;
                break;
            default: {
                if (SEG_STYLES[cfg.style]) {
                    node.classList.add('segframe');
                    node.innerHTML = `<div class="shape">${segShape(cfg.style)}${ico}</div>${val}`;
                    break;
                }
                const d = SHAPES[cfg.style] || SHAPES.ring;
                const bg = SHAPE_BG[cfg.style] || d;
                node.innerHTML = `<div class="shape"><svg viewBox="0 0 100 100"><path class="bg" d="${bg}"/><path class="trk" d="${d}"/><path class="fil" d="${d}" pathLength="100"/></svg>${ico}</div>${val}`;
            }
        }
        return node;
    }

    function renderAll() {
        hud.innerHTML = '';
        for (const key of Object.keys(ELEMENTS)) {
            const node = buildElement(key, state.layout.elements[key], state.layout.global);
            nodes[key] = node;
            hud.appendChild(node);

            const img = node.querySelector('.logo-img');
            if (img) {
                // a imagem carrega depois do layout: confere de novo se passou a encostar em algo
                img.addEventListener('load', () => { if (state.layout) resolveOverlaps(); });
                img.addEventListener('error', () => { node.classList.add('logo-missing'); });
            }
        }
        applyGlobal();
        positionAll();
        update();
    }

    function position(key) {
        const el = state.layout.elements[key];
        const node = nodes[key];
        const x = el.x == null ? 50 : el.x;
        const y = el.y == null ? 50 : el.y;
        node.style.left = x + '%';
        node.style.top = y + '%';
        node.style.transform = `translate(-${x}%, -${y}%)`;
    }

    function positionAll() {
        for (const key of Object.keys(nodes)) position(key);
    }

    function applyGlobal() {
        const g = state.layout.global;
        // aplicada tambem no editor, para o slider mostrar o resultado em tempo real
        hud.style.opacity = g.opacity;
        hud.classList.toggle('alerts', !!g.lowAlert);
        for (const key of Object.keys(nodes)) {
            nodes[key].style.setProperty('--s', g.scale * state.layout.elements[key].size);
            nodes[key].style.setProperty('--bga', g.bgOpacity);
        }
        grid.classList.toggle('lines', !!g.showGrid);
        grid.style.setProperty('--cell', cellPx() + 'px');
    }

    function cellPx() {
        return Math.max(4, window.innerHeight * state.layout.global.grid / 100);
    }

    const fmtMoney = (n) => (+n || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    const fmtInt = (n) => Math.floor(+n || 0).toLocaleString('pt-BR');
    const pad = (n) => String(n || 0).padStart(2, '0');

    function infoText(key, d) {
        switch (key) {
            case 'cash':
            case 'bank':
            case 'bloodmoney': return '$ ' + fmtMoney(d[key]);
            case 'gold': return fmtInt(d.gold);
            case 'id': return 'ID ' + d.id;
            case 'clock': return pad(d.hour) + ':' + pad(d.minute);
            case 'temp': return `${Math.round(+d.temp || 0)}°${state.config.tempUnit}`;
            default: return '';
        }
    }

    function statValue(key, d) {
        const kind = ELEMENTS[key].kind;
        if (kind === 'flag') return 100;
        if (kind === 'voice') return clamp((+d.voiceIndex || 0) / state.config.voiceModes * 100, 0, 100);
        return clamp(+d[key] || 0, 0, 100);
    }

    // referencias das pecas do elemento, buscadas uma vez so (antes era querySelector a cada atualizacao)
    function refsOf(node) {
        if (!node._r) {
            node._r = {
                fil: node.querySelector('.fil'),
                fill: node.querySelector('.fill'),
                segs: node.querySelectorAll('.seg'),
                top: node.querySelector('.ico.top'),
                val: node.querySelector('.val'),
                txt: node.querySelector('.txt'),
            };
        }
        return node._r;
    }

    // so mexe na pagina quando o valor mostrado realmente mudou
    function paint(node, key, cfg, d) {
        const def = ELEMENTS[key];
        if (def.kind === 'logo') return;
        const r = refsOf(node);

        if (def.kind === 'info') {
            const text = infoText(key, d);
            if (node._p !== text) {
                node._p = text;
                r.txt.textContent = text;
            }
            return;
        }

        const v = Math.round(statValue(key, d));
        const talking = def.kind === 'voice' && !!d.talking;
        const sig = v + '|' + talking + '|' + (key === 'outlaw' ? d.outlaw : '') + '|' + (def.kind === 'voice' ? d.voiceIndex : '');
        if (node._p === sig) return;
        node._p = sig;

        if (r.fil) r.fil.style.strokeDashoffset = 100 - v;
        if (r.fill) {
            if (cfg.style === 'bar' || cfg.style === 'tile') r.fill.style.width = v + '%';
            // orbe: o liquido passa 2px da borda em cima e embaixo para nao deixar fresta quando cheio
            else if (cfg.style === 'orb') r.fill.style.height = v > 0 ? `calc(${v}% + 4px)` : '0';
            else r.fill.style.height = v + '%';
        }
        const n = r.segs.length;
        for (let i = 0; i < n; i++) r.segs[i].classList.toggle('on', v > i * (100 / n) + 0.5);
        if (r.top) r.top.style.clipPath = `inset(${100 - v}% 0 0 0)`;

        if (r.val) {
            if (def.kind === 'flag') r.val.textContent = key === 'outlaw' ? String(d.outlaw || '!') : '!';
            else if (def.kind === 'voice') r.val.textContent = d.voiceIndex + '/' + state.config.voiceModes;
            else r.val.textContent = v;
        }

        const thr = state.config.lowThreshold;
        node.classList.toggle('low', def.kind === 'stat' && (def.inverse ? v >= 100 - thr : v <= thr));
        node.classList.toggle('talking', talking);
    }

    function shouldShow(key, cfg, d) {
        if (state.flashing.has(key)) return true;
        if (!cfg.visible) return false;
        const def = ELEMENTS[key];
        if (def.mountOnly && !d.onHorse) return false;
        if (def.kind === 'flag') return key === 'mail' ? !!d.mail : (+d.outlaw || 0) > 0;
        if (def.kind === 'voice' && cfg.autoHide) return !!d.talking;
        if (def.kind === 'stat' && cfg.autoHide) {
            const v = statValue(key, d);
            return def.inverse ? v > 1 : v < 99;
        }
        return true;
    }

    function update() {
        if (!state.layout) return;
        hud.classList.toggle('hidden', !state.show && !state.editing);
        const d = state.editing ? { ...state.data, onHorse: true, mail: true, outlaw: state.data.outlaw || 1 } : state.data;

        for (const key of Object.keys(nodes)) {
            const node = nodes[key];
            const cfg = state.layout.elements[key];
            paint(node, key, cfg, d);
            node.classList.toggle('off', !state.editing && !shouldShow(key, cfg, d));
            node.classList.toggle('ghost', state.editing && !cfg.visible);
            node.classList.toggle('selected', state.editing && state.selected === key);
            node.classList.toggle('flash', state.flashing.has(key));
        }
    }

    // =========================================================
    // EVENTOS DO JOGO
    // =========================================================
    function flash(key) {
        if (!nodes[key]) return;
        clearTimeout(state.flashing.get(key));
        state.flashing.set(key, setTimeout(() => {
            state.flashing.delete(key);
            update();
        }, 5000));
        update();
    }

    function moneyChange(msg) {
        const node = nodes[msg.type];
        const cfg = state.layout && state.layout.elements[msg.type];
        if (!node || !cfg || !cfg.visible || !msg.amount) return;

        const span = document.createElement('span');
        span.className = 'delta ' + (msg.minus ? 'minus' : 'plus') + (cfg.y > 50 ? ' above' : '');
        span.textContent = (msg.minus ? '- ' : '+ ') + (msg.type === 'gold' ? fmtInt(msg.amount) : '$ ' + fmtMoney(msg.amount));
        node.appendChild(span);
        setTimeout(() => span.remove(), 2700);
    }

    window.addEventListener('message', (event) => {
        const msg = event.data || {};
        switch (msg.action) {
            case 'init':
                state.initialized = true;
                Object.assign(state.config, msg.config || {});
                loadLayout(msg.layout);
                break;
            case 'setLayout':
                if (!state.editing) loadLayout(msg.layout);
                break;
            case 'setPresets':
                state.myPresets = Array.isArray(msg.presets) ? msg.presets.filter((p) => p && p.data && p.data.elements) : [];
                if (state.editing && state.tab === 'mine') renderPanel();
                break;
            case 'tick':
                state.show = !!msg.show;
                if (msg.data) state.data = msg.data;
                update();
                break;
            case 'openEditor':
                openEditor();
                break;
            case 'moneyChange':
                moneyChange(msg);
                break;
            case 'flash':
                flash(msg.element);
                break;
        }
    });

    // =========================================================
    // EDITOR
    // =========================================================
    function openEditor() {
        if (!state.layout || state.editing) return;
        state.editing = true;
        state.snapshot = clone(state.layout);
        state.undo = [];
        state.redo = [];
        state.selected = null;
        document.body.classList.add('editing');
        hud.classList.add('editing');
        applyGlobal();
        renderToolbar();
        renderPanel();
        update();
        // janela sempre abre no centro da tela
        panel.classList.remove('moved');
        panel.style.left = '';
        panel.style.top = '';
    }

    function closeEditor(save) {
        if (!state.editing) return;
        if (save) {
            post('saveLayout', { layout: state.layout });
        } else {
            state.layout = state.snapshot;
        }
        state.editing = false;
        state.selected = null;
        document.body.classList.remove('editing');
        hud.classList.remove('editing');
        hideGuides();
        renderAll();
        post('closeEditor');
    }

    function pushUndo() {
        state.undo.push(JSON.stringify(state.layout));
        if (state.undo.length > 60) state.undo.shift();
        state.redo = [];
        renderToolbar();
    }

    function restore(from, to) {
        if (!from.length) return;
        to.push(JSON.stringify(state.layout));
        state.layout = JSON.parse(from.pop());
        renderAll();
        renderToolbar();
        renderPanel();
    }

    // aplica uma alteracao com historico; rebuild recria os elementos (troca de estilo/icone)
    function mutate(fn, rebuild) {
        pushUndo();
        fn();
        // trocar estilo/icone muda o tamanho do elemento: afasta o que passar a encostar
        if (rebuild) { renderAll(); resolveOverlaps(); }
        else { applyGlobal(); update(); }
        renderToolbar();
        renderPanel();
    }

    function select(key) {
        state.selected = key;
        if (key) state.tab = 'elements';
        renderPanel();
        update();
    }

    // ---------- arrastar ----------
    let drag = null;
    const SNAP_PX = 6;

    hud.addEventListener('pointerdown', (e) => {
        if (!state.editing || e.button !== 0) return;
        const node = e.target.closest('.el');
        if (!node) return;
        e.preventDefault();

        const key = node.dataset.key;
        if (state.selected !== key) select(key);

        const box = boxOf(key);
        drag = { key, node, startX: e.clientX, startY: e.clientY, box, moved: false };
        node.setPointerCapture(e.pointerId);
    });

    hud.addEventListener('pointermove', (e) => {
        if (!drag) return;
        const dx = e.clientX - drag.startX;
        const dy = e.clientY - drag.startY;
        if (!drag.moved) {
            if (Math.abs(dx) < 3 && Math.abs(dy) < 3) return;
            drag.moved = true;
            pushUndo();
            drag.node.classList.add('dragging');
        }
        // pontos de alinhamento medidos uma vez por arrasto (antes media todos os elementos a cada movimento do mouse)
        if (!drag.targets) drag.targets = snapTargets(drag.key);
        moveTo(drag.key, drag.box.left + dx, drag.box.top + dy, drag.box.w, drag.box.h, state.layout.global.snap, drag.targets);
    });

    const endDrag = () => {
        if (!drag) return;
        drag.node.classList.remove('dragging');
        drag = null;
        hideGuides();
    };
    hud.addEventListener('pointerup', endDrag);
    hud.addEventListener('pointercancel', endDrag);

    // centros dos outros elementos e da tela, para alinhar ao arrastar
    function snapTargets(key) {
        const xs = [window.innerWidth / 2], ys = [window.innerHeight / 2];
        for (const other of Object.keys(nodes)) {
            if (other === key || nodes[other].classList.contains('ghost')) continue;
            const b = boxOf(other);
            xs.push(b.left + b.w / 2);
            ys.push(b.top + b.h / 2);
        }
        return { xs, ys };
    }

    function moveTo(key, left, top, w, h, snap, targets) {
        const W = window.innerWidth, H = window.innerHeight;
        left = clamp(left, 0, Math.max(0, W - w));
        top = clamp(top, 0, Math.max(0, H - h));

        let guideX = null, guideY = null;
        if (snap) {
            // 1) alinhar centro com outros elementos e com o centro da tela
            const cx = left + w / 2, cy = top + h / 2;
            let bestX = SNAP_PX, bestY = SNAP_PX;
            const { xs: targetsX, ys: targetsY } = targets || snapTargets(key);
            for (const t of targetsX) {
                if (Math.abs(cx - t) < bestX) { bestX = Math.abs(cx - t); guideX = t; }
            }
            for (const t of targetsY) {
                if (Math.abs(cy - t) < bestY) { bestY = Math.abs(cy - t); guideY = t; }
            }

            // 2) se nao alinhou, gruda na grade
            const cell = cellPx();
            left = guideX != null ? guideX - w / 2 : Math.round(left / cell) * cell;
            top = guideY != null ? guideY - h / 2 : Math.round(top / cell) * cell;
            left = clamp(left, 0, Math.max(0, W - w));
            top = clamp(top, 0, Math.max(0, H - h));
        }

        showGuide(guideV, guideX, 'left');
        showGuide(guideH, guideY, 'top');
        setFromBox(state.layout.elements[key], left, top, w, h);
        position(key);
    }

    function showGuide(el, value, prop) {
        el.classList.toggle('show', value != null);
        if (value != null) el.style[prop] = Math.round(value) + 'px';
    }

    function hideGuides() {
        guideV.classList.remove('show');
        guideH.classList.remove('show');
    }

    function nudge(key, dx, dy) {
        const b = boxOf(key);
        moveTo(key, b.left + dx, b.top + dy, b.w, b.h, false);
    }

    // ---------- teclado ----------
    let nudgeTimer = null;
    window.addEventListener('keydown', (e) => {
        if (!state.editing) return;
        const typing = document.activeElement && document.activeElement.tagName === 'INPUT';
        const typingText = typing && document.activeElement.type === 'text';

        if (e.key === 'Escape') {
            e.preventDefault();
            // escrevendo o nome do preset: ESC so sai do campo
            if (typingText) document.activeElement.blur();
            else closeEditor(false);
            return;
        }
        if (typingText) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const saveBtn = panel.querySelector('[data-action="mine-save"]');
                if (saveBtn) saveBtn.click();
            }
            return; // deixa o campo de texto funcionar normalmente (Ctrl+Z, setas, Delete...)
        }
        if (e.ctrlKey && (e.key === 'z' || e.key === 'Z')) {
            e.preventDefault();
            if (e.shiftKey) restore(state.redo, state.undo);
            else restore(state.undo, state.redo);
            return;
        }
        if (e.ctrlKey && (e.key === 'y' || e.key === 'Y')) {
            e.preventDefault();
            restore(state.redo, state.undo);
            return;
        }
        if (typing || !state.selected) return;

        const step = e.shiftKey ? 10 : 1;
        const moves = { ArrowLeft: [-step, 0], ArrowRight: [step, 0], ArrowUp: [0, -step], ArrowDown: [0, step] };
        if (moves[e.key]) {
            e.preventDefault();
            // um passo de desfazer por sequencia de setas
            if (!nudgeTimer) pushUndo();
            clearTimeout(nudgeTimer);
            nudgeTimer = setTimeout(() => { nudgeTimer = null; }, 600);
            nudge(state.selected, ...moves[e.key]);
        } else if (e.key === 'Delete') {
            e.preventDefault();
            const key = state.selected;
            mutate(() => { state.layout.elements[key].visible = !state.layout.elements[key].visible; });
        }
    });

    // ---------- barra de ferramentas ----------
    const TOOLBAR = {
        undo: ['undo', 'Desfazer'],
        redo: ['redo', 'Refazer'],
        grid: ['grid', 'Grade'],
        snap: ['magnet', 'Ima'],
        arrange: ['arrange', 'Organizar'],
        reset: ['reset', 'Restaurar padrao'],
        cancel: ['x', 'Cancelar'],
        save: ['check', 'Salvar'],
    };

    // Organizar: recoloca tudo no layout do modelo atual, medindo os tamanhos reais
    // (mantem estilos, cores, icones e tamanhos). Nada fica em cima de nada.
    function arrangeLayout() {
        pushUndo();
        placePreset(state.layout.preset, false, { avoid: logoBox() });
        positionAll();
        resolveOverlaps();
        renderToolbar();
        renderPanel();
    }

    // Restaurar padrao: volta tudo ao modelo padrao, inclusive escala, opacidade e fundo.
    function restoreDefault() {
        pushUndo();
        state.layout.global = defaultGlobal();
        applyPreset(state.config.defaultPreset, false);
        resolveOverlaps();
        state.selected = null;
        renderToolbar();
        renderPanel();
    }

    function renderToolbar() {
        const g = state.layout.global;
        for (const btn of toolbar.querySelectorAll('[data-action]')) {
            const [icon, label] = TOOLBAR[btn.dataset.action];
            if (!btn.innerHTML) btn.innerHTML = `${ui(icon)}<span class="lbl">${label}</span>`;
        }
        toolbar.querySelector('[data-action="undo"]').disabled = !state.undo.length;
        toolbar.querySelector('[data-action="redo"]').disabled = !state.redo.length;
        toolbar.querySelector('[data-action="grid"]').classList.toggle('active', !!g.showGrid);
        toolbar.querySelector('[data-action="snap"]').classList.toggle('active', !!g.snap);
    }

    toolbar.addEventListener('click', (e) => {
        const btn = e.target.closest('[data-action]');
        if (!btn) return;
        const g = () => state.layout.global;
        switch (btn.dataset.action) {
            case 'undo': restore(state.undo, state.redo); break;
            case 'redo': restore(state.redo, state.undo); break;
            case 'grid': mutate(() => { g().showGrid = !g().showGrid; }); break;
            case 'snap': mutate(() => { g().snap = !g().snap; }); break;
            case 'arrange': arrangeLayout(); break;
            case 'reset': restoreDefault(); break;
            case 'cancel': closeEditor(false); break;
            case 'save': closeEditor(true); break;
        }
    });

    // ---------- painel: arrastar / minimizar ----------
    panel.querySelector('[data-action="collapse"]').innerHTML = ui('minus');
    for (const el of panel.querySelectorAll('[data-ui]')) el.innerHTML = ui(el.dataset.ui);

    let panelDrag = null;
    panel.querySelector('.panel-head').addEventListener('pointerdown', (e) => {
        if (e.target.closest('button') || window.innerWidth <= 760) return;
        const r = panel.getBoundingClientRect();
        panelDrag = { dx: e.clientX - r.left, dy: e.clientY - r.top };
        e.currentTarget.setPointerCapture(e.pointerId);
    });
    panel.querySelector('.panel-head').addEventListener('pointermove', (e) => {
        if (!panelDrag) return;
        const r = panel.getBoundingClientRect();
        panel.style.left = clamp(e.clientX - panelDrag.dx, 0, window.innerWidth - r.width) + 'px';
        panel.style.top = clamp(e.clientY - panelDrag.dy, 0, window.innerHeight - r.height) + 'px';
        panel.classList.add('moved');
    });
    panel.querySelector('.panel-head').addEventListener('pointerup', () => { panelDrag = null; });

    // ---------- painel: conteudo ----------
    function styleThumb(style) {
        const icon = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">';
        const shape = (d) => `<svg viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="9" stroke-linejoin="round"><path d="${d}" opacity=".3"/><path d="${d}" pathLength="100" stroke-dasharray="100" stroke-dashoffset="30" stroke-linecap="round"/></svg>`;
        // estilos segmentados: a miniatura e a propria moldura, com 70% das pecas acesas
        if (SEG_STYLES[style]) {
            const list = SEG_STYLES[style].segs;
            const lit = Math.round(list.length * 0.7);
            return `<svg viewBox="0 0 100 100" class="seg-thumb">${list.map((s, i) => i < lit ? s.replace('class="seg', 'class="seg on') : s).join('')}</svg>`;
        }
        switch (style) {
            case 'bar': return icon + '<rect x="2" y="9" width="20" height="6" rx="3" opacity=".3"/><path d="M5 12h9" stroke-width="4"/></svg>';
            case 'vbar': return icon + '<rect x="9" y="2" width="6" height="20" rx="3" opacity=".3"/><path d="M12 19v-8" stroke-width="4"/></svg>';
            case 'minimal': return icon + ICONS.heart + '</svg>';
            case 'orb': return icon + '<circle cx="12" cy="12" r="9" opacity=".35"/><path d="M3.3 14a9 9 0 0 0 17.4 0Z" fill="currentColor" stroke="none"/></svg>';
            case 'crystal': return icon + '<rect x="3" y="3" width="18" height="18" rx="5" opacity=".35"/><path d="M3.5 14q2.1-1.6 4.2 0t4.2 0 4.2 0 4.2 0V16.5a4.5 4.5 0 0 1-4.5 4.5h-7.8a4.5 4.5 0 0 1-4.5-4.5Z" fill="currentColor" stroke="none" opacity=".55"/><path d="M12 3h4a5 5 0 0 1 5 5v9"/></svg>';
            case 'tile': return icon + '<rect x="4" y="4" width="16" height="16" rx="3" opacity=".35"/><circle cx="12" cy="10" r="2"/><path d="M8 16h5" stroke-width="2.5"/></svg>';
            case 'pips': return icon + '<circle cx="12" cy="8" r="2.5"/><path d="M4 16h2M9 16h2M14 16h2" stroke-width="3"/><path d="M19 16h1" stroke-width="3" opacity=".3"/></svg>';
            case 'dotrow': return icon + '<circle cx="12" cy="8" r="3.5"/><g fill="currentColor" stroke="none"><circle cx="5" cy="17" r="1.6"/><circle cx="9.7" cy="17" r="1.6"/><circle cx="14.3" cy="17" r="1.6"/><circle cx="19" cy="17" r="1.6" opacity=".3"/></g></svg>';
            case 'squares': return icon + '<rect x="8.5" y="4.5" width="7" height="7" rx="1.5"/><g fill="currentColor" stroke="none"><rect x="3.5" y="15.5" width="3" height="3" rx=".5"/><rect x="8" y="15.5" width="3" height="3" rx=".5"/><rect x="12.5" y="15.5" width="3" height="3" rx=".5"/><rect x="17" y="15.5" width="3" height="3" rx=".5" opacity=".3"/></g></svg>';
            case 'battery': return icon + '<circle cx="11" cy="6" r="2.5"/><rect x="3" y="12" width="16" height="8" rx="1.5"/><path d="M21 15v2"/><path d="M6.5 14.5v3M10 14.5v3M13.5 14.5v3" stroke-width="2"/></svg>';
            case 'pill': return icon + '<rect x="2" y="7" width="20" height="10" rx="5"/><circle cx="7" cy="12" r="2"/></svg>';
            case 'card': return icon + '<rect x="3" y="6" width="18" height="12" rx="2"/><path d="M3 6v12" stroke-width="4"/></svg>';
            case 'plain': return icon + '<circle cx="6" cy="12" r="2"/><path d="M11 12h9"/></svg>';
            default: return shape(SHAPES[style]);
        }
    }

    function swatchField(title, field, value) {
        const sw = SWATCHES.map((c) => `<button class="sw ${c.toLowerCase() === value.toLowerCase() ? 'active' : ''}" style="background:${c}" data-action="color" data-field="${field}" data-value="${c}"></button>`).join('');
        return `<div class="field"><div class="field-title">${title}</div><div class="swatches">${sw}<input type="color" data-input="${field}" value="${value}"></div></div>`;
    }

    function rangeField(title, field, value, min, max, step, fmt, scope) {
        return `<div class="field"><div class="field-title">${title}<output>${fmt(value)}</output></div>
            <input type="range" data-input="${field}" data-scope="${scope}" min="${min}" max="${max}" step="${step}" value="${value}"></div>`;
    }

    function switchField(label, hint, field, checked, scope) {
        return `<label class="switch"><span>${label}${hint ? `<small>${hint}</small>` : ''}</span>
            <input type="checkbox" data-toggle="${field}" data-scope="${scope}" ${checked ? 'checked' : ''}><span class="knob"></span></label>`;
    }

    const pct = (v) => Math.round(v * 100) + '%';

    // previas dos modelos nunca mudam: monta uma vez e guarda (eram ~175 elementos recriados a cada clique)
    const presetSampleCache = {};
    function presetSample(key) {
        if (!presetSampleCache[key]) {
            // todos os status do jogador, um do lado do outro, como ficam na tela
            presetSampleCache[key] = ['health', 'stamina', 'hunger', 'thirst', 'cleanliness', 'stress', 'voice'].map((k) => {
                const cfg = defaultElement(k, key);
                const node = buildElement(k, cfg, { scale: 1, bgOpacity: 0.55 });
                paint(node, k, cfg, SAMPLE_DATA);
                return node.outerHTML;
            }).join('');
        }
        return presetSampleCache[key];
    }

    function renderPresets() {
        const cards = Object.entries(PRESETS).map(([key, p]) =>
            `<button class="preset-card ${state.layout.preset === key ? 'active' : ''}" data-action="preset" data-key="${key}">
                <div class="preset-sample">${presetSample(key)}</div>
                <strong>${esc(p.label)}</strong><span>${esc(p.desc)}</span></button>`).join('');
        return `<p class="note">Escolha um modelo pronto como ponto de partida. Depois, ajuste cada icone na aba Elementos ou arrastando na tela.</p>
            <div class="preset-grid">${cards}</div>`;
    }

    function renderElementList() {
        let html = '<p class="note">Clique em um elemento para editar, ou clique direto nele na tela. O olho mostra/esconde.</p>';
        for (const [group, title] of Object.entries(GROUPS)) {
            html += `<div class="group-title">${title}</div><div class="el-list">`;
            for (const [key, def] of Object.entries(ELEMENTS)) {
                if (def.group !== group) continue;
                const cfg = state.layout.elements[key];
                html += `<div class="el-row ${cfg.visible ? '' : 'hidden-el'}" data-action="select" data-key="${key}">
                    <button class="icon-btn eye ${cfg.visible ? 'on' : ''}" data-action="toggle-visible" data-key="${key}" title="Mostrar/esconder">${ui(cfg.visible ? 'eye' : 'eyeoff')}</button>
                    <span class="row-ico" style="color:${cfg.color}">${iconSvg(cfg.icon)}</span>
                    <span class="row-label">${esc(def.label)}<small>${stylesFor(key)[cfg.style]}${def.mountOnly ? ' &middot; so montado' : ''}${def.kind === 'flag' ? ' &middot; so quando ativo' : ''}</small></span>
                    <span class="chev">${ui('chev')}</span></div>`;
            }
            html += '</div>';
        }
        return html;
    }

    // posicao atual da logo (esquerda/centro/direita), ou null se o jogador arrastou para outro lugar
    function logoPosition(cfg) {
        if (cfg.y !== 0) return null;
        const hit = Object.entries(LOGO_POSITIONS).find(([, p]) => Math.abs(p.x - cfg.x) < 0.01);
        return hit ? hit[0] : null;
    }

    function logoPosThumb(pos) {
        const x = { left: 3, center: 9, right: 15 }[pos];
        return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2" opacity=".4"/><rect x="${x}" y="6.5" width="6" height="3.5" rx="1" fill="currentColor" stroke="none"/></svg>`;
    }

    function renderLogoDetail(key) {
        const def = ELEMENTS[key];
        const cfg = state.layout.elements[key];
        const current = logoPosition(cfg);
        const positions = Object.entries(LOGO_POSITIONS).map(([pos, p]) =>
            `<button class="opt ${current === pos ? 'active' : ''}" data-action="logo-pos" data-value="${pos}">${logoPosThumb(pos)}${p.label}</button>`).join('');

        return `<div class="detail-head">
                <button class="icon-btn" data-action="back" title="Voltar">${ui('back')}</button>
                <span class="row-ico">${iconSvg('image')}</span>
                <strong>${esc(def.label)}</strong>
            </div>
            <div class="detail-cols"><div>
                <div class="field">${switchField('Visivel', 'Mostra a logo do servidor na tela', 'visible', cfg.visible, 'el')}</div>
                <div class="field">
                    <div class="field-title">Posicao no topo</div>
                    <div class="style-grid logo-pos">${positions}</div>
                    ${current ? '' : '<p class="note">Posicao livre (voce arrastou a logo). Escolha uma das opcoes acima para encaixar no topo.</p>'}
                </div>
            </div><div>
                <div class="field logo-preview"><img src="${esc(state.config.logo || 'assets/logo.png')}" alt=""></div>
                ${rangeField('Tamanho', 'size', cfg.size, 0.5, 2, 0.05, pct, 'el')}
                <p class="note">Para trocar a imagem, substitua <b>html/assets/logo.png</b> ou use <b>Config.LogoUrl</b>.</p>
            </div></div>`;
    }

    function renderElementDetail(key) {
        const def = ELEMENTS[key];
        if (def.kind === 'logo') return renderLogoDetail(key);
        const cfg = state.layout.elements[key];
        const isInfo = def.kind === 'info';

        const styles = Object.entries(stylesFor(key)).map(([s, label]) =>
            `<button class="opt ${cfg.style === s ? 'active' : ''}" data-action="style" data-value="${s}">${styleThumb(s)}${label}</button>`).join('');
        const icons = iconsFor(key).map((name) =>
            `<button class="opt ${cfg.icon === name ? 'active' : ''}" data-action="icon" data-value="${name}" title="${name}">${iconSvg(name)}</button>`).join('');

        let toggles = switchField('Visivel', null, 'visible', cfg.visible, 'el');
        if (!isInfo) toggles += switchField('Mostrar numero', 'Exibe o valor junto do icone', 'showValue', cfg.showValue, 'el');
        if (def.kind === 'stat') toggles += switchField('Esconder quando cheio', def.inverse ? 'Some quando o estresse esta zerado' : 'Some quando esta em 100%', 'autoHide', cfg.autoHide, 'el');
        if (def.kind === 'voice') toggles += switchField('So mostrar ao falar', null, 'autoHide', cfg.autoHide, 'el');

        return `<div class="detail-head">
                <button class="icon-btn" data-action="back" title="Voltar">${ui('back')}</button>
                <span class="row-ico" style="color:${cfg.color}">${iconSvg(cfg.icon)}</span>
                <strong>${esc(def.label)}</strong>
            </div>
            <div class="detail-cols"><div>
                <div class="field">${toggles}</div>
                <div class="field"><div class="field-title">Estilo</div><div class="style-grid">${styles}</div></div>
            </div><div>
                <div class="field"><div class="field-title">Icone</div><div class="icon-grid">${icons}</div></div>
                ${swatchField('Cor do icone', 'iconColor', cfg.iconColor)}
                ${swatchField(isInfo ? 'Cor do destaque' : 'Cor da barra', 'color', cfg.color)}
                ${rangeField('Tamanho', 'size', cfg.size, 0.5, 2, 0.05, pct, 'el')}
                <div class="btn-row">
                    <button class="btn" data-action="style-group" title="Copia estilo, tamanho e cor do icone para os outros do mesmo grupo">Aplicar visual ao grupo</button>
                    <button class="btn" data-action="center-x">Centralizar</button>
                    <button class="btn" data-action="reset-el">Restaurar</button>
                </div>
            </div></div>`;
    }

    function renderGlobal() {
        const g = state.layout.global;
        const styles = Object.entries(STAT_STYLES).map(([s, label]) =>
            `<button class="opt" data-action="style-all" data-value="${s}">${styleThumb(s)}${label}</button>`).join('');
        const infoStyles = Object.entries(INFO_STYLES).map(([s, label]) =>
            `<button class="opt" data-action="info-style-all" data-value="${s}">${styleThumb(s)}${label}</button>`).join('');

        return `${rangeField('Escala geral', 'scale', g.scale, 0.6, 1.6, 0.05, pct, 'global')}
            ${rangeField('Opacidade da HUD', 'opacity', g.opacity, 0.3, 1, 0.05, pct, 'global')}
            ${rangeField('Fundo dos icones', 'bgOpacity', g.bgOpacity, 0, 1, 0.05, pct, 'global')}
            <div class="field">
                ${switchField('Alerta de status baixo', `Pisca em vermelho abaixo de ${state.config.lowThreshold}%`, 'lowAlert', g.lowAlert, 'global')}
                ${switchField('Mostrar grade', null, 'showGrid', g.showGrid, 'global')}
                ${switchField('Ima', 'Gruda na grade e alinha com outros icones', 'snap', g.snap, 'global')}
            </div>
            ${rangeField('Tamanho da grade', 'grid', g.grid, 1, 5, 0.5, (v) => v + '%', 'global')}
            <div class="field"><div class="field-title">Estilo de todos os status</div><div class="style-grid">${styles}</div></div>
            <div class="field"><div class="field-title">Estilo de todas as informacoes</div><div class="style-grid">${infoStyles}</div></div>
            <div class="field"><div class="field-title">Esconder status cheios</div>
                <div class="btn-row">
                    <button class="btn" data-action="autohide-all" data-value="1">Ativar em todos</button>
                    <button class="btn" data-action="autohide-all" data-value="0">Desativar em todos</button>
                </div>
            </div>`;
    }

    // =========================================================
    // MEUS PRESETS (configuracoes salvas pelo proprio jogador)
    // =========================================================
    let presetsTimer = null;

    // a lista inteira vai para o client; espera o jogador parar de mexer para nao bater no limite do servidor
    function persistPresets() {
        clearTimeout(presetsTimer);
        presetsTimer = setTimeout(() => post('savePresets', { presets: state.myPresets }), 1200);
    }

    function saveCurrentAsPreset(name) {
        if (state.myPresets.length >= state.config.maxPresets) return;
        state.myPresets.unshift({
            id: Date.now().toString(36),
            name: (name || '').trim().slice(0, 32) || `Meu preset ${state.myPresets.length + 1}`,
            date: Date.now(),
            data: clone(state.layout),
        });
        persistPresets();
    }

    function applyMyPreset(id) {
        const preset = state.myPresets.find((p) => p.id === id);
        if (!preset) return;
        pushUndo();
        state.layout = sanitizeLayout(clone(preset.data));
        renderAll();
        // posicoes sao em %, mas a proporcao da tela pode ser outra: garante que nada encoste
        resolveOverlaps();
        state.selected = null;
        renderToolbar();
        renderPanel();
    }

    function presetPreview(data) {
        const layout = sanitizeLayout(data);
        return ['health', 'stamina', 'hunger', 'thirst', 'cleanliness', 'stress', 'voice'].map((k) => {
            const cfg = { ...layout.elements[k], size: 1 };
            const node = buildElement(k, cfg, { scale: 1, bgOpacity: layout.global.bgOpacity });
            paint(node, k, cfg, SAMPLE_DATA);
            if (!cfg.visible) node.style.opacity = '.3';
            return node.outerHTML;
        }).join('');
    }

    function renderMyPresets() {
        const max = state.config.maxPresets;
        const full = state.myPresets.length >= max;
        const fmtDate = (t) => new Date(t).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });

        const cards = state.myPresets.map((p) => {
            const confirming = state.confirmDelete === p.id;
            return `<div class="preset-card my-preset">
                <div class="preset-sample">${presetPreview(p.data)}</div>
                <strong>${esc(p.name)}</strong><span>Salvo em ${fmtDate(p.date)}</span>
                <div class="btn-row">
                    <button class="btn primary" data-action="mine-apply" data-id="${esc(p.id)}">${ui('check')}Aplicar</button>
                    <button class="btn" data-action="mine-update" data-id="${esc(p.id)}" title="Substitui pelo visual que esta na tela agora">${ui('reset')}Atualizar</button>
                    <button class="btn ${confirming ? 'danger' : ''}" data-action="mine-delete" data-id="${esc(p.id)}">${ui('x')}${confirming ? 'Confirmar' : 'Excluir'}</button>
                </div>
            </div>`;
        }).join('');

        return `<div class="field">
                <div class="field-title">Salvar a configuracao atual</div>
                <p class="note">Guarda tudo o que esta na tela agora (estilos, cores, icones, tamanhos e posicoes) para voltar quando quiser.</p>
                <div class="save-row">
                    <input type="text" id="preset-name" maxlength="32" placeholder="Nome do preset (ex.: HUD de caca)" ${full ? 'disabled' : ''}>
                    <button class="btn primary" data-action="mine-save" ${full ? 'disabled' : ''}>${ui('plus')}Salvar preset</button>
                </div>
                ${full ? `<p class="note warn">Limite de ${max} presets atingido. Exclua ou atualize um preset existente.</p>` : ''}
            </div>
            <div class="field-title">Meus presets <output>${state.myPresets.length}/${max}</output></div>
            ${cards ? `<div class="preset-grid">${cards}</div>` : '<div class="empty">Voce ainda nao salvou nenhum preset. Monte sua HUD e salve acima.</div>'}`;
    }

    function renderPanel() {
        if (!state.editing) return;
        for (const tab of panel.querySelectorAll('.tab')) tab.classList.toggle('active', tab.dataset.tab === state.tab);

        // aba de modelos ja aberta: so troca qual card esta selecionado, sem recriar as previas
        if (state.tab === 'presets' && panelBody.dataset.view === 'presets') {
            for (const card of panelBody.querySelectorAll('.preset-card')) {
                card.classList.toggle('active', card.dataset.key === state.layout.preset);
            }
            return;
        }

        const scroll = panelBody.scrollTop;
        if (state.tab === 'presets') panelBody.innerHTML = renderPresets();
        else if (state.tab === 'mine') panelBody.innerHTML = renderMyPresets();
        else if (state.tab === 'global') panelBody.innerHTML = renderGlobal();
        else panelBody.innerHTML = state.selected ? renderElementDetail(state.selected) : renderElementList();
        panelBody.dataset.view = state.tab;
        panelBody.scrollTop = scroll;
    }

    panel.querySelector('.panel-tabs').addEventListener('click', (e) => {
        const tab = e.target.closest('.tab');
        if (!tab) return;
        state.tab = tab.dataset.tab;
        panelBody.scrollTop = 0;
        renderPanel();
    });

    panel.addEventListener('click', (e) => {
        const target = e.target.closest('[data-action]');
        // botoes do cabecalho (salvar, desfazer...) tem o proprio tratamento: nao executa duas vezes
        if (!target || !panel.contains(target) || target.closest('#toolbar')) return;
        const action = target.dataset.action;
        const value = target.dataset.value;
        const key = state.selected;
        const el = key && state.layout.elements[key];
        const all = state.layout.elements;

        switch (action) {
            case 'collapse':
                panel.classList.toggle('collapsed');
                target.innerHTML = ui(panel.classList.contains('collapsed') ? 'plus' : 'minus');
                break;
            case 'preset':
                pushUndo();
                applyPreset(target.dataset.key, true);
                renderToolbar();
                renderPanel();
                break;
            case 'select':
                select(target.dataset.key);
                break;
            case 'toggle-visible': {
                e.stopPropagation();
                const k = target.dataset.key;
                mutate(() => { all[k].visible = !all[k].visible; });
                break;
            }
            case 'back':
                state.selected = null;
                renderPanel();
                update();
                break;
            case 'style':
                mutate(() => { el.style = value; }, true);
                break;
            case 'icon':
                mutate(() => { el.icon = value; }, true);
                break;
            case 'color':
                mutate(() => { el[target.dataset.field] = value; }, true);
                break;
            case 'style-group': {
                const def = ELEMENTS[key];
                const sameFamily = (k) => ELEMENTS[k].group === def.group && ELEMENTS[k].kind !== 'logo' && (ELEMENTS[k].kind === 'info') === (def.kind === 'info');
                mutate(() => {
                    for (const k of Object.keys(all)) {
                        if (k === key || !sameFamily(k)) continue;
                        Object.assign(all[k], { style: el.style, size: el.size, iconColor: el.iconColor, showValue: el.showValue });
                    }
                }, true);
                break;
            }
            case 'center-x': {
                pushUndo();
                el.x = 50;
                position(key);
                renderToolbar();
                break;
            }
            case 'reset-el': {
                const fresh = defaultElement(key, state.layout.preset);
                mutate(() => {
                    Object.assign(el, { ...fresh, x: el.x, y: el.y, visible: el.visible });
                }, true);
                break;
            }
            case 'style-all':
                mutate(() => {
                    for (const k of Object.keys(all)) if (isStatLike(k)) all[k].style = value;
                }, true);
                break;
            case 'info-style-all':
                mutate(() => {
                    for (const k of Object.keys(all)) if (ELEMENTS[k].kind === 'info') all[k].style = value;
                }, true);
                break;
            case 'logo-pos': {
                const pos = LOGO_POSITIONS[value];
                if (!pos) break;
                pushUndo();
                setLogoPosition(value);
                renderToolbar();
                renderPanel();
                break;
            }
            case 'mine-save': {
                const input = panel.querySelector('#preset-name');
                saveCurrentAsPreset(input ? input.value : '');
                state.confirmDelete = null;
                renderPanel();
                break;
            }
            case 'mine-apply':
                state.confirmDelete = null;
                applyMyPreset(target.dataset.id);
                break;
            case 'mine-update': {
                const preset = state.myPresets.find((p) => p.id === target.dataset.id);
                if (preset) {
                    preset.data = clone(state.layout);
                    preset.date = Date.now();
                    persistPresets();
                }
                state.confirmDelete = null;
                renderPanel();
                break;
            }
            case 'mine-delete': {
                const id = target.dataset.id;
                // primeiro clique pede confirmacao, o segundo exclui
                if (state.confirmDelete !== id) {
                    state.confirmDelete = id;
                } else {
                    state.myPresets = state.myPresets.filter((p) => p.id !== id);
                    state.confirmDelete = null;
                    persistPresets();
                }
                renderPanel();
                break;
            }
            case 'autohide-all':
                mutate(() => {
                    for (const k of Object.keys(all)) if (ELEMENTS[k].kind === 'stat') all[k].autoHide = value === '1';
                });
                break;
        }
    });

    // sliders e seletor de cor: atualizam ao vivo sem recriar o painel; um passo de desfazer por arrasto
    const RESIZE_FIELDS = ['scale', 'size'];
    let slideBase = null; // posicoes de quando comecou a arrastar o slider de tamanho

    panel.addEventListener('input', (e) => {
        const input = e.target;
        const field = input.dataset.input;
        if (!field) return;
        if (!state.sliding) {
            pushUndo();
            state.sliding = true;
            if (RESIZE_FIELDS.includes(field)) {
                slideBase = {};
                for (const [k, el] of Object.entries(state.layout.elements)) slideBase[k] = { x: el.x, y: el.y };
            }
        }

        if (input.type === 'color') {
            const el = state.layout.elements[state.selected];
            el[field] = input.value;
            nodes[state.selected].style.setProperty(field === 'color' ? '--c' : '--ic', input.value);
            return;
        }

        const v = parseFloat(input.value);
        const target = input.dataset.scope === 'global' ? state.layout.global : state.layout.elements[state.selected];
        target[field] = v;
        const out = input.parentElement.querySelector('output');
        if (out) out.textContent = field === 'grid' ? v + '%' : pct(v);

        // tamanho mudou: parte sempre das posicoes originais e afasta o que encostar,
        // assim diminuir de novo devolve o layout exatamente como era
        if (slideBase && RESIZE_FIELDS.includes(field)) {
            for (const [k, pos] of Object.entries(slideBase)) Object.assign(state.layout.elements[k], pos);
            positionAll();
            applyGlobal();
            resolveOverlaps();
            return;
        }
        applyGlobal();
    });

    panel.addEventListener('change', (e) => {
        const input = e.target;
        if (input.dataset.input) {
            state.sliding = false;
            slideBase = null;
            if (input.type === 'color') renderPanel();
            return;
        }
        const field = input.dataset.toggle;
        if (!field) return;
        const target = input.dataset.scope === 'global' ? state.layout.global : state.layout.elements[state.selected];
        const rebuild = field === 'showValue';
        mutate(() => { target[field] = input.checked; }, rebuild);
    });

    // clique no fundo desmarca
    grid.addEventListener('pointerdown', () => {
        if (state.selected) select(null);
    });

    window.addEventListener('resize', () => {
        if (!state.layout) return;
        applyGlobal();
        resolveOverlaps();
    });

    // =========================================================
    // INICIO
    // =========================================================
    if (IN_GAME) {
        // repete ate o client responder (a NUI pode carregar antes do callback ser registrado)
        const sendReady = () => {
            if (state.initialized) return;
            post('ready');
            setTimeout(sendReady, 2000);
        };
        sendReady();
    } else {
        // pre-visualizacao no navegador (abrir html/index.html direto)
        document.body.classList.add('browser');
        loadLayout(null);
        state.show = true;
        state.data = { ...SAMPLE_DATA };
        update();
        // ex.: index.html#preset=barras&tab=elements&sel=health   |   #hud = so a HUD, sem editor
        const params = new URLSearchParams(location.hash.slice(1));
        if (params.get('preset')) applyPreset(params.get('preset'), true);
        if (params.get('scale')) {
            state.layout.global.scale = clamp(+params.get('scale'), 0.6, 1.6);
            applyGlobal();
            resolveOverlaps();
        }
        if (params.has('messy')) {
            // embaralha as posicoes para testar o botao Organizar
            for (const el of Object.values(state.layout.elements)) { el.x = Math.random() * 100; el.y = 60 + Math.random() * 40; }
            positionAll();
        }
        if (params.has('arrange')) arrangeLayout();
        if (params.get('logo')) setLogoPosition(params.get('logo'));
        if (params.has('mypresets')) {
            // presets de exemplo para testar a aba "Presets"
            applyPreset('cristal', true);
            saveCurrentAsPreset('HUD de caca');
            applyPreset('xerife', true);
            state.layout.elements.voice.visible = false;
            saveCurrentAsPreset('Xerife sem voz');
        }
        if (!params.has('hud')) {
            openEditor();
            if (params.get('tab')) state.tab = params.get('tab');
            if (params.get('sel')) select(params.get('sel'));
            renderPanel();
        }
        setInterval(() => {
            const d = state.data;
            d.stamina = clamp(d.stamina + (Math.random() * 20 - 10), 0, 100);
            d.hunger = clamp(d.hunger - 1, 0, 100) || 100;
            d.talking = Math.random() > 0.6;
            d.minute = (d.minute + 1) % 60;
            update();
        }, 1000);
    }
})();
