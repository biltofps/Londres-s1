const app = document.getElementById('app');
const panelTitle = document.getElementById('panelTitle');
const closeBtn = document.getElementById('closeBtn');
const refreshBtn = document.getElementById('refreshBtn');
const searchInput = document.getElementById('searchInput');
const playersBody = document.getElementById('playersBody');
const bannedPlayersBody = document.getElementById('bannedPlayersBody');
const permissionsBody = document.getElementById('permissionsBody');
const toastStack = document.getElementById('toastStack');
const jobsList = document.getElementById('jobsList');
const topRichPlayersHead = document.getElementById('topRichPlayersHead');
const topRichPlayersBody = document.getElementById('topRichPlayersBody');
const selectedInfoGrid = document.getElementById('selectedInfoGrid');
const banksGrid = document.getElementById('banksGrid');
const backToPlayersBtn = document.getElementById('backToPlayersBtn');
const openJobModalBtn = document.getElementById('openJobModalBtn');
const removeJobBtn = document.getElementById('removeJobBtn');
const openItemModalBtn = document.getElementById('openItemModalBtn');
const openAddMoneyModalBtn = document.getElementById('openAddMoneyModalBtn');
const openRemoveMoneyModalBtn = document.getElementById('openRemoveMoneyModalBtn');
const openAddWeightModalBtn = document.getElementById('openAddWeightModalBtn');
const openAddSlotsModalBtn = document.getElementById('openAddSlotsModalBtn');
const openRenamePlayerModalBtn = document.getElementById('openRenamePlayerModalBtn');
const openHeightPlayerModalBtn = document.getElementById('openHeightPlayerModalBtn');
const clearInventoryBtn = document.getElementById('clearInventoryBtn');
const openMessageModalBtn = document.getElementById('openMessageModalBtn');
const openKickModalBtn = document.getElementById('openKickModalBtn');
const openBanModalBtn = document.getElementById('openBanModalBtn');
const openCoordsModalBtn = document.getElementById('openCoordsModalBtn');
const togglePlayerBlipsBtn = document.getElementById('togglePlayerBlipsBtn');
const togglePlayerWallBtn = document.getElementById('togglePlayerWallBtn');
const toggleNoclipBtn = document.getElementById('toggleNoclipBtn');
const openHorseModalBtnDashboard = document.getElementById('openHorseModalBtnDashboard');
const openCompanyStashModalBtn = document.getElementById('openCompanyStashModalBtn');
const openCompanyStashModalBtnSupport = document.getElementById('openCompanyStashModalBtnSupport');
const openDeleteCharacterModalBtn = null;
const deleteCharacterModal = null;
const deleteCharacterModalCloseBtn = null;
const developerCitizenIdInput = null;
const developerSearchBtn = null;
const developerDeleteCharacterBtn = null;
const developerCharacterResult = null;
const developerCharacterInfoModal = null;
const developerCharacterInfoModalCloseBtn = null;
const developerCharacterDetails = null;
const supportSpectateBtn = document.getElementById('supportSpectateBtn');
const openPermissionAddModalBtn = document.getElementById('openPermissionAddModalBtn');
const moneyTypeSelect = document.getElementById('moneyTypeSelect');
const moneyAmountInput = document.getElementById('moneyAmountInput');
const moneyModal = document.getElementById('moneyModal');
const moneyModalTitle = document.getElementById('moneyModalTitle');
const moneyModalCloseBtn = document.getElementById('moneyModalCloseBtn');
const moneyModalApplyBtn = document.getElementById('moneyModalApplyBtn');
const supportAdjustModal = document.getElementById('supportAdjustModal');
const supportAdjustModalTitle = document.getElementById('supportAdjustModalTitle');
const supportAdjustModalCloseBtn = document.getElementById('supportAdjustModalCloseBtn');
const supportAdjustModalInfo = document.getElementById('supportAdjustModalInfo');
const supportAdjustAmountInput = document.getElementById('supportAdjustAmountInput');
const supportAdjustAmountLabel = document.getElementById('supportAdjustAmountLabel');
const supportAdjustModalApplyBtn = document.getElementById('supportAdjustModalApplyBtn');
const renamePlayerModal = document.getElementById('renamePlayerModal');
const renamePlayerModalCloseBtn = document.getElementById('renamePlayerModalCloseBtn');
const renamePlayerModalInfo = document.getElementById('renamePlayerModalInfo');
const renamePlayerFirstNameInput = document.getElementById('renamePlayerFirstNameInput');
const renamePlayerLastNameInput = document.getElementById('renamePlayerLastNameInput');
const renamePlayerModalApplyBtn = document.getElementById('renamePlayerModalApplyBtn');
const heightPlayerModal = document.getElementById('heightPlayerModal');
const heightPlayerModalCloseBtn = document.getElementById('heightPlayerModalCloseBtn');
const heightPlayerModalInfo = document.getElementById('heightPlayerModalInfo');
const heightPlayerPresetGrid = document.getElementById('heightPlayerPresetGrid');
const heightPlayerCustomInput = document.getElementById('heightPlayerCustomInput');
const heightPlayerModalApplyBtn = document.getElementById('heightPlayerModalApplyBtn');
const coordsModal = document.getElementById('coordsModal');
const coordsModalCloseBtn = document.getElementById('coordsModalCloseBtn');
const coordsModalGrid = document.getElementById('coordsModalGrid');
const coordsVector1Input = document.getElementById('coordsVector1Input');
const coordsVector2Input = document.getElementById('coordsVector2Input');
const coordsVector3Input = document.getElementById('coordsVector3Input');
const coordsVector4Input = document.getElementById('coordsVector4Input');
const coordsHeadingInput = document.getElementById('coordsHeadingInput');
const messageModal = document.getElementById('messageModal');
const messageModalCloseBtn = document.getElementById('messageModalCloseBtn');
const messageModalSendBtn = document.getElementById('messageModalSendBtn');
const messageModalInput = document.getElementById('messageModalInput');
const kickModal = document.getElementById('kickModal');
const kickModalCloseBtn = document.getElementById('kickModalCloseBtn');
const kickModalApplyBtn = document.getElementById('kickModalApplyBtn');
const kickModalReason = document.getElementById('kickModalReason');
const banModal = document.getElementById('banModal');
const banModalCloseBtn = document.getElementById('banModalCloseBtn');
const banModalApplyBtn = document.getElementById('banModalApplyBtn');
const banModeSelect = document.getElementById('banModeSelect');
const banReasonInput = document.getElementById('banReasonInput');
const banModalTypeLabel = document.getElementById('banModalTypeLabel');
const banModalSummary = document.getElementById('banModalSummary');
const editBanModal = document.getElementById('editBanModal');
const editBanModalCloseBtn = document.getElementById('editBanModalCloseBtn');
const editBanCurrentInfo = document.getElementById('editBanCurrentInfo');
const editBanModeSelect = document.getElementById('editBanModeSelect');
const editBanModalApplyBtn = document.getElementById('editBanModalApplyBtn');
const companyStashModal = document.getElementById('companyStashModal');
const companyStashModalCloseBtn = document.getElementById('companyStashModalCloseBtn');
const companyStashModalOpenBtn = document.getElementById('companyStashModalOpenBtn');
const companyStashSearchInput = document.getElementById('companyStashSearchInput');
const companyStashCurrentInfo = document.getElementById('companyStashCurrentInfo');
const companyStashModalList = document.getElementById('companyStashModalList');
const teleportSearchInput = document.getElementById('teleportSearchInput');
const teleportCategoryFilter = document.getElementById('teleportCategoryFilter');
const openCustomTeleportModalBtn = document.getElementById('openCustomTeleportModalBtn');
const openAddTeleportModalBtn = document.getElementById('openAddTeleportModalBtn');
const teleportsGrid = document.getElementById('teleportsGrid');
const customTeleportModal = document.getElementById('customTeleportModal');
const customTeleportModalCloseBtn = document.getElementById('customTeleportModalCloseBtn');
const customTeleportXInput = document.getElementById('customTeleportXInput');
const customTeleportYInput = document.getElementById('customTeleportYInput');
const customTeleportZInput = document.getElementById('customTeleportZInput');
const customTeleportHeadingInput = document.getElementById('customTeleportHeadingInput');
const customTeleportModalApplyBtn = document.getElementById('customTeleportModalApplyBtn');
const addTeleportModal = document.getElementById('addTeleportModal');
const addTeleportModalCloseBtn = document.getElementById('addTeleportModalCloseBtn');
const addTeleportNameInput = document.getElementById('addTeleportNameInput');
const addTeleportCategorySelect = document.getElementById('addTeleportCategorySelect');
const addTeleportDescriptionInput = document.getElementById('addTeleportDescriptionInput');
const addTeleportUseCurrentBtn = document.getElementById('addTeleportUseCurrentBtn');
const addTeleportXInput = document.getElementById('addTeleportXInput');
const addTeleportYInput = document.getElementById('addTeleportYInput');
const addTeleportZInput = document.getElementById('addTeleportZInput');
const addTeleportHeadingInput = document.getElementById('addTeleportHeadingInput');
const addTeleportModalApplyBtn = document.getElementById('addTeleportModalApplyBtn');
const horseModal = document.getElementById('horseModal');
const horseModalCloseBtn = document.getElementById('horseModalCloseBtn');
const horseModalCurrentInfo = document.getElementById('horseModalCurrentInfo');
const horseModalList = document.getElementById('horseModalList');
const horseModalSpawnBtn = document.getElementById('horseModalSpawnBtn');
const permissionAddModal = document.getElementById('permissionAddModal');
const permissionAddModalCloseBtn = document.getElementById('permissionAddModalCloseBtn');
const permissionAddSelectedInfo = document.getElementById('permissionAddSelectedInfo');
const permissionAddOnlineList = document.getElementById('permissionAddOnlineList');
const permissionAddAllInput = document.getElementById('permissionAddAllInput');
const permissionAddPresetSelect = document.getElementById('permissionAddPresetSelect');
const permissionAddOptions = document.getElementById('permissionAddOptions');
const permissionAddCancelBtn = document.getElementById('permissionAddCancelBtn');
const permissionAddConfirmBtn = document.getElementById('permissionAddConfirmBtn');
const permissionEditModal = document.getElementById('permissionEditModal');
const permissionEditModalCloseBtn = document.getElementById('permissionEditModalCloseBtn');
const permissionEditTargetInfo = document.getElementById('permissionEditTargetInfo');
const permissionEditPresetSelect = document.getElementById('permissionEditPresetSelect');
const permissionEditAllInput = document.getElementById('permissionEditAllInput');
const permissionEditOptions = document.getElementById('permissionEditOptions');
const permissionEditSaveBtn = document.getElementById('permissionEditSaveBtn');
const permissionRemoveConfirmModal = document.getElementById('permissionRemoveConfirmModal');
const permissionRemoveConfirmCurrentInfo = document.getElementById('permissionRemoveConfirmCurrentInfo');
const permissionRemoveConfirmCancelBtn = document.getElementById('permissionRemoveConfirmCancelBtn');
const permissionRemoveConfirmBtn = document.getElementById('permissionRemoveConfirmBtn');
const permissionRemoveConfirmCloseBtn = document.getElementById('permissionRemoveConfirmCloseBtn');
const permissionPresetList = document.getElementById('permissionPresetList');
const permissionPresetEditModal = document.getElementById('permissionPresetEditModal');
const permissionPresetEditModalCloseBtn = document.getElementById('permissionPresetEditModalCloseBtn');
const permissionPresetEditTargetInfo = document.getElementById('permissionPresetEditTargetInfo');
const permissionPresetEditAllInput = document.getElementById('permissionPresetEditAllInput');
const permissionPresetEditOptions = document.getElementById('permissionPresetEditOptions');
const permissionPresetEditSaveBtn = document.getElementById('permissionPresetEditSaveBtn');
const criticalConfirmModal = document.getElementById('criticalConfirmModal');
const criticalConfirmModalBox = document.getElementById('criticalConfirmModalBox');
const criticalConfirmBadge = document.getElementById('criticalConfirmBadge');
const criticalConfirmTitle = document.getElementById('criticalConfirmTitle');
const criticalConfirmSummary = document.getElementById('criticalConfirmSummary');
const criticalConfirmDetails = document.getElementById('criticalConfirmDetails');
const criticalConfirmCancelBtn = document.getElementById('criticalConfirmCancelBtn');
const criticalConfirmBtn = document.getElementById('criticalConfirmBtn');
const criticalConfirmCloseBtn = document.getElementById('criticalConfirmCloseBtn');

if (document && document.body) {
    document.body.setAttribute('data-theme', 'mono');
}
if (app) {
    app.classList.add('theme-mono');
}

const metricOnline = document.getElementById('metricOnline');
const metricMax = document.getElementById('metricMax');
const metricStaff = document.getElementById('metricStaff');
const metricDead = document.getElementById('metricDead');
const metricPing = document.getElementById('metricPing');
const metricUpdated = document.getElementById('metricUpdated');
const metricBank = document.getElementById('metricBank');

const jobModal = document.getElementById('jobModal');
const jobModalCloseBtn = document.getElementById('jobModalCloseBtn');
const jobModalList = document.getElementById('jobModalList');
const jobSearchInput = document.getElementById('jobSearchInput');
const jobModalGradeSelect = document.getElementById('jobModalGradeSelect');
const jobModalSetActiveInput = document.getElementById('jobModalSetActiveInput');
const jobModalMultijobApplyBtn = document.getElementById('jobModalMultijobApplyBtn');
const jobModalApplyBtn = document.getElementById('jobModalApplyBtn');
const jobCurrentInfo = document.getElementById('jobCurrentInfo');
const jobMultijobInfo = document.getElementById('jobMultijobInfo');
const jobMultijobList = document.getElementById('jobMultijobList');
const removeJobConfirmModal = document.getElementById('removeJobConfirmModal');
const removeJobCurrentInfo = document.getElementById('removeJobCurrentInfo');
const removeJobModalList = document.getElementById('removeJobModalList');
const removeJobModalHint = document.getElementById('removeJobModalHint');
const removeJobCancelBtn = document.getElementById('removeJobCancelBtn');
const removeJobConfirmBtn = document.getElementById('removeJobConfirmBtn');
const removeJobConfirmCloseBtn = document.getElementById('removeJobConfirmCloseBtn');

const itemModal = document.getElementById('itemModal');
const itemModalCloseBtn = document.getElementById('itemModalCloseBtn');
const itemModalList = document.getElementById('itemModalList');
const itemSearchInput = document.getElementById('itemSearchInput');
const itemCategoryList = document.getElementById('itemCategoryList');
const itemModalCount = document.getElementById('itemModalCount');
const itemQueueDock = document.getElementById('itemQueueDock');
const itemQueueList = document.getElementById('itemQueueList');
const itemQueueWeightTotal = document.getElementById('itemQueueWeightTotal');
const itemQueueClearBtn = document.getElementById('itemQueueClearBtn');
const itemQueueConfirmBtn = document.getElementById('itemQueueConfirmBtn');
const itemConfirmModal = document.getElementById('itemConfirmModal');
const itemConfirmCloseBtn = document.getElementById('itemConfirmCloseBtn');
const itemConfirmCancelBtn = document.getElementById('itemConfirmCancelBtn');
const itemConfirmSendBtn = document.getElementById('itemConfirmSendBtn');
const itemConfirmList = document.getElementById('itemConfirmList');
const itemCapacityStatus = document.getElementById('itemCapacityStatus');

const navButtons = Array.from(document.querySelectorAll('.nav-btn'));
const panels = Array.from(document.querySelectorAll('.panel'));
const actionButtons = Array.from(document.querySelectorAll('[data-action]'));
const PLAYER_HEIGHT_PRESETS = [
    { value: '95', labelKey: 'modal_height_preset_very_short', fallback: 'Muito baixa (95)' },
    { value: '97', labelKey: 'modal_height_preset_short', fallback: 'Baixa (97)' },
    { value: '100', labelKey: 'modal_height_preset_normal', fallback: 'Normal (100)' },
    { value: '103', labelKey: 'modal_height_preset_tall', fallback: 'Alta (103)' },
    { value: '105', labelKey: 'modal_height_preset_very_tall', fallback: 'Muito alta (105)' },
    { value: 'custom', labelKey: 'modal_height_preset_custom', fallback: 'Personalizada' }
];

const TELEPORT_CATEGORY_LABELS = {
    towns: 'Cidades e Vilarejos',
    gangcamps: 'Acampamentos',
    nature: 'Natureza e Marcos',
    shops: 'Lojas e Servicos',
    special: 'Locais Especiais'
};

const TELEPORT_CATEGORY_ICONS = {
    towns: '\u{1F3D8}\u{FE0F}',
    gangcamps: '⛺',
    nature: '\u{1F3D4}\u{FE0F}',
    shops: '\u{1F3EA}',
    special: '⭐'
};

// Curated built-in locations (real RDR2 world coordinates). Admins can add more via "Adicionar Local".
function buildDefaultCriticalConfirmState() {
    return {
        title: '',
        summary: '',
        details: [],
        variant: 'default',
        badge: '',
        confirmLabel: '',
        loading: false,
        onConfirm: null,
        closeOnSuccess: []
    };
}

const state = {
    open: false,
    localeKey: 'ptbr',
    numberLocale: 'pt-BR',
    i18n: {},
    settings: {
        modalDebug: false
    },
    activePanel: 'dashboard',
    dashboard: null,
    players: [],
    bannedPlayers: [],
    teleports: {
        customLocations: [],
        loaded: false,
        search: '',
        category: 'all'
    },
    permissions: {
        entries: [],
        onlinePlayers: [],
        canManage: false,
        self: {
            role: '',
            roleLabel: '',
            permissions: {}
        }
    },
    support: {
        spectateTargetSource: 0
    },
    selectedSource: null,
    filter: '',
    supportUnlocked: false,
    catalog: {
        jobs: [],
        items: [],
        moneyTypes: [],
        banDurations: [],
        companyStashes: [],
        adminHorses: [],
        builtInTeleports: [],
        permissionDefinitions: [],
        permissionPresets: []
    },
    jobModal: {
        search: '',
        selectedJobName: null,
        setActive: true
    },
    itemModal: {
        search: '',
        category: 'all',
        selectedItemName: null,
        queue: [],
        sending: false,
        lastCapacity: null
    },
    moneyModal: {
        mode: 'add'
    },
    supportAdjustModal: {
        mode: 'weight'
    },
    heightPlayerModal: {
        preset: '100'
    },
    banModal: {
        mode: '1'
    },
    editBanModal: {
        banId: null,
        mode: '1'
    },
    companyStashModal: {
        search: '',
        selectedStashName: null
    },
    horseModal: {
        selectedHorseId: null
    },
    developerCharacter: {
        citizenid: '',
        lookup: null,
        selectedCitizenid: ''
    },
    removeJobModal: {
        jobName: '',
        jobs: []
    },
    permissionAddModal: {
        selectedSource: null,
        presetKey: '',
        permissions: {
            all_permissions: false
        }
    },
    permissionEditModal: {
        license: '',
        targetSource: null,
        name: '',
        accessType: '',
        presetKey: '',
        editable: false,
        permissions: {
            all_permissions: false
        }
    },
    permissionRemoveModal: {
        license: ''
    },
    permissionPresetEditModal: {
        key: '',
        label: '',
        permissions: {
            all_permissions: false
        }
    },
    criticalConfirm: buildDefaultCriticalConfirmState()
};

function textValue(key, fallback = '') {
    const dict = state.i18n && typeof state.i18n === 'object' ? state.i18n : {};
    const value = dict[key];
    if (typeof value === 'string' && value.length > 0) {
        return value;
    }
    return fallback;
}

function t(key, params = {}, fallback = '') {
    let output = textValue(key, fallback || key);
    if (params && typeof params === 'object') {
        Object.keys(params).forEach((name) => {
            const token = `{${name}}`;
            output = output.split(token).join(String(params[name]));
        });
    }
    return output;
}

function getNumberLocale() {
    return state.numberLocale || 'pt-BR';
}

function applyLocalePayload(payload) {
    if (!payload || typeof payload !== 'object') {
        return;
    }

    if (typeof payload.key === 'string' && payload.key.length) {
        state.localeKey = payload.key;
    }
    if (typeof payload.numberLocale === 'string' && payload.numberLocale.length) {
        state.numberLocale = payload.numberLocale;
    }
    if (payload.ui && typeof payload.ui === 'object') {
        state.i18n = payload.ui;
    }
    if (payload.settings && typeof payload.settings === 'object') {
        state.settings.modalDebug = payload.settings.modalDebug === true;
    }
    if (typeof payload.htmlLang === 'string' && payload.htmlLang.length) {
        document.documentElement.setAttribute('lang', payload.htmlLang);
    }
}

function isModalDebugEnabled() {
    return state.settings && state.settings.modalDebug === true;
}

function logModalDebug(action, detail) {
    if (!isModalDebugEnabled()) {
        return;
    }

    const payload = detail && typeof detail === 'object' ? detail : { detail };
    let serialized = '{}';
    try {
        serialized = JSON.stringify(payload);
    } catch (_error) {
        serialized = '{"serialize":"failed"}';
    }

}

window.addEventListener('error', (event) => {
    logModalDebug('window:error', {
        message: event.message,
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno
    });
});

window.addEventListener('unhandledrejection', (event) => {
    logModalDebug('window:unhandledrejection', {
        reason: String(event.reason || 'unknown')
    });
});

function getResourceName() {
    return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bilto_admin';
}

async function postNui(route, payload = {}) {
    const response = await fetch(`https://${getResourceName()}/${route}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    });

    return response.json();
}

function escapeHtml(value) {
    return String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function valueOr(value, fallback) {
    return value === undefined || value === null ? fallback : value;
}

function bindEvent(element, eventName, handler) {
    if (!element) {
        logModalDebug('bindEvent:missingElement', { eventName });
        return;
    }

    element.addEventListener(eventName, handler);
}

function syncAppVisibility() {
    if (!app) {
        return;
    }

    const visible = state.open === true;
    app.classList.toggle('hidden', !visible);
}

function formatMoney(value) {
    return new Intl.NumberFormat(getNumberLocale()).format(Number(value || 0));
}

function formatKgFromUnits(value) {
    const kg = Number(value || 0) / 1000;
    return `${kg.toLocaleString(getNumberLocale(), { minimumFractionDigits: 2, maximumFractionDigits: 2 })} KG`;
}

function formatInteger(value) {
    return new Intl.NumberFormat(getNumberLocale(), { maximumFractionDigits: 0 }).format(Math.floor(Number(value || 0)));
}

function formatCoordNumber(value) {
    const parsed = Number(value || 0);
    if (!Number.isFinite(parsed)) {
        return '0.0000';
    }

    return parsed.toFixed(4);
}

function buildCoordsPayload(data) {
    const x = formatCoordNumber(data && data.x);
    const y = formatCoordNumber(data && data.y);
    const z = formatCoordNumber(data && data.z);
    const heading = formatCoordNumber(data && data.heading);

    return {
        vector1: `vector1(${x})`,
        vector2: `vector2(${x}, ${y})`,
        vector3: `vector3(${x}, ${y}, ${z})`,
        vector4: `vector4(${x}, ${y}, ${z}, ${heading})`,
        heading
    };
}

function getCoordsFieldMap() {
    return {
        vector1: coordsVector1Input,
        vector2: coordsVector2Input,
        vector3: coordsVector3Input,
        vector4: coordsVector4Input,
        heading: coordsHeadingInput
    };
}

function fillCoordsModalValues(payload) {
    const values = payload && typeof payload === 'object' ? payload : {
        vector1: '',
        vector2: '',
        vector3: '',
        vector4: '',
        heading: ''
    };
    const fieldMap = getCoordsFieldMap();

    Object.keys(fieldMap).forEach((key) => {
        const field = fieldMap[key];
        if (!field) {
            return;
        }
        field.textContent = String(values[key] || '');
    });
}

function getCoordsFieldValue(field) {
    if (!field) {
        return '';
    }

    if (typeof field.value === 'string' && field.value.length > 0) {
        return field.value;
    }

    return typeof field.textContent === 'string' ? field.textContent.trim() : '';
}

function legacyCopyToClipboard(text) {
    let textarea = null;
    try {
        textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.setAttribute('readonly', '');
        textarea.style.position = 'fixed';
        textarea.style.top = '0';
        textarea.style.left = '-9999px';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.focus();
        textarea.select();
        textarea.setSelectionRange(0, textarea.value.length);
        return document.execCommand('copy') === true;
    } catch (_error) {
        return false;
    } finally {
        if (textarea && textarea.parentNode) {
            textarea.parentNode.removeChild(textarea);
        }
    }
}

async function copyTextToClipboard(value) {
    const output = String(value || '');
    if (!output.length) {
        return false;
    }

    if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
        try {
            await navigator.clipboard.writeText(output);
            return true;
        } catch (_error) {
            // fall through to legacy/native fallback below
        }
    }

    if (legacyCopyToClipboard(output)) {
        return true;
    }

    try {
        const bridgeResult = await postNui('copyToClipboard', { text: output });
        return !!(bridgeResult && bridgeResult.ok === true);
    } catch (_error) {
        return false;
    }
}

let toastSequence = 0;
function pushToast(message, type = 'info', duration = 4200, title = '') {
    if (!message || !toastStack) {
        return;
    }

    const normalizedType = String(type || 'info').toLowerCase();
    let resolvedTitle = String(title || '').trim();
    const panelNotificationTitle = t('panel_title', {}, 'Bitinho Admin');
    if (resolvedTitle.toLowerCase() === panelNotificationTitle.toLowerCase()) {
        resolvedTitle = '';
    }
    if (!resolvedTitle) {
        if (normalizedType === 'ok' || normalizedType === 'success') {
            resolvedTitle = t('notification_success_title', {}, 'Sucesso');
        } else if (normalizedType === 'error') {
            resolvedTitle = t('notification_denied_title', {}, 'Negado');
        } else if (normalizedType === 'warn' || normalizedType === 'warning') {
            resolvedTitle = t('notification_warning_title', {}, 'Aviso');
        } else {
            resolvedTitle = t('notification_info_title', {}, 'Informação');
        }
    }

    const toastId = ++toastSequence;
    const card = document.createElement('article');
    card.className = `toast-card ${normalizedType}`;
    card.dataset.toastId = String(toastId);
    card.innerHTML = `
        <strong>${escapeHtml(resolvedTitle)}</strong>
        <p>${escapeHtml(message)}</p>
    `;

    toastStack.prepend(card);

    const ttl = Math.max(1200, Number(duration || 4200));
    setTimeout(() => {
        if (card.parentElement) {
            card.classList.add('is-leaving');
            setTimeout(() => {
                card.remove();
            }, 180);
        }
    }, ttl);
}

function getMoneyTypes() {
    return Array.isArray(state.catalog.moneyTypes) ? state.catalog.moneyTypes : [];
}

function getBanDurations() {
    return Array.isArray(state.catalog.banDurations) ? state.catalog.banDurations : [];
}

function closeAllCustomSelects(exceptId) {
    void exceptId;
}

function syncCustomSelect(selectElement) {
    if (!selectElement || !selectElement.id) {
        return;
    }

    const host = document.querySelector(`.option-button-group[data-select-id="${selectElement.id}"]`);
    if (!host) {
        return;
    }

    const options = Array.from(selectElement.options || []);
    host.innerHTML = options.filter((option) => {
        if (selectElement === permissionAddPresetSelect || selectElement === permissionEditPresetSelect) {
            return String(valueOr(option.value, '')).trim().length > 0;
        }
        return true;
    }).map((option) => {
        const selectedClass = option.value === selectElement.value ? 'active' : '';
        const disabledAttr = selectElement.disabled ? 'disabled' : '';
        return `<button type="button" class="option-button ${selectedClass}" data-select-value="${escapeHtml(option.value)}" ${disabledAttr}>${escapeHtml(option.textContent || option.label || option.value)}</button>`;
    }).join('');
    host.classList.toggle('is-disabled', !!selectElement.disabled);
}

function ensureCustomSelect(selectElement) {
    if (!selectElement || !selectElement.id) {
        return;
    }

    let host = document.querySelector(`.option-button-group[data-select-id="${selectElement.id}"]`);
    if (!host) {
        host = document.createElement('div');
        host.className = 'option-button-group';
        host.dataset.selectId = selectElement.id;

        selectElement.classList.add('native-select-hidden');
        selectElement.insertAdjacentElement('afterend', host);

        bindEvent(host, 'click', (event) => {
            const optionButton = event.target.closest('[data-select-value]');
            if (!optionButton || selectElement.disabled) {
                return;
            }

            selectElement.value = optionButton.dataset.selectValue || '';
            selectElement.dispatchEvent(new Event('change', { bubbles: true }));
            syncCustomSelect(selectElement);
        });

        bindEvent(selectElement, 'change', () => {
            syncCustomSelect(selectElement);
        });
    }

    syncCustomSelect(selectElement);
}

function setupCustomSelects() {
    ensureCustomSelect(jobModalGradeSelect);
    ensureCustomSelect(moneyTypeSelect);
    ensureCustomSelect(banModeSelect);
    ensureCustomSelect(editBanModeSelect);
    ensureCustomSelect(permissionAddPresetSelect);
    ensureCustomSelect(permissionEditPresetSelect);
}

function syncFocusedModalMode() {
    if (!app) {
        return;
    }
}

function setStatus(message, type = 'info') {
    if (!message) {
        return;
    }

    let normalized = 'info';
    if (type === 'error') {
        normalized = 'error';
    } else if (type === 'ok' || type === 'success') {
        normalized = 'ok';
    } else if (type === 'warning' || type === 'warn') {
        normalized = 'warn';
    }

    pushToast(message, normalized);
}

function getSelectedPlayerDisplayName() {
    const player = getSelectedPlayer();
    if (!player) {
        return t('value_na', {}, 'N/A');
    }

    const fullName = String(valueOr(player.fullname, '')).trim();
    const name = String(valueOr(player.name, '')).trim();
    if (fullName.length) {
        return fullName;
    }
    if (name.length) {
        return name;
    }
    return `ID: ${player.source}`;
}

function getSelectedPlayerIdentityLabel() {
    const player = getSelectedPlayer();
    if (!player) {
        return t('value_na', {}, 'N/A');
    }

    return `${getSelectedPlayerDisplayName()} [${player.source}]`;
}

function setCriticalConfirmButtonState() {
    if (!criticalConfirmBtn) {
        return;
    }

    const hasHandler = typeof state.criticalConfirm.onConfirm === 'function';
    const ready = hasHandler && !state.criticalConfirm.loading;
    criticalConfirmBtn.disabled = !ready;
    const idleLabel = String(valueOr(state.criticalConfirm.confirmLabel, '')).trim()
        || t('critical_confirm_execute', {}, 'Executar Acao');
    criticalConfirmBtn.textContent = state.criticalConfirm.loading
        ? t('critical_confirm_loading', {}, 'Processando...')
        : idleLabel;
}

function renderCriticalConfirmModal() {
    if (!criticalConfirmModal) {
        return;
    }

    const variant = String(valueOr(state.criticalConfirm.variant, 'default')).trim() || 'default';
    if (criticalConfirmModalBox) {
        criticalConfirmModalBox.dataset.variant = variant;
    }
    if (criticalConfirmBadge) {
        const badgeText = String(valueOr(state.criticalConfirm.badge, '')).trim();
        criticalConfirmBadge.textContent = badgeText;
        criticalConfirmBadge.classList.toggle('hidden', !badgeText.length);
    }
    if (criticalConfirmTitle) {
        criticalConfirmTitle.textContent = state.criticalConfirm.title || t('critical_confirm_title', {}, 'Confirmacao Critica');
    }
    if (criticalConfirmSummary) {
        criticalConfirmSummary.textContent = state.criticalConfirm.summary || t('critical_confirm_summary_default', {}, 'Revise os dados antes de continuar.');
    }
    if (criticalConfirmDetails) {
        const details = Array.isArray(state.criticalConfirm.details) ? state.criticalConfirm.details : [];
        criticalConfirmDetails.innerHTML = details.map((entry) => `<li>${escapeHtml(String(valueOr(entry, '-')))}</li>`).join('');
    }
    if (criticalConfirmCancelBtn) {
        criticalConfirmCancelBtn.textContent = t('critical_confirm_cancel', {}, 'Cancelar');
    }

    setCriticalConfirmButtonState();
}

function openCriticalConfirmModal(config) {
    const payload = config && typeof config === 'object' ? config : {};
    const details = Array.isArray(payload.details) ? payload.details : [];

    state.criticalConfirm = {
        title: String(valueOr(payload.title, t('critical_confirm_title', {}, 'Confirmacao Critica'))),
        summary: String(valueOr(payload.summary, t('critical_confirm_summary_default', {}, 'Revise os dados antes de continuar.'))),
        details,
        variant: String(valueOr(payload.variant, 'default')).trim() || 'default',
        badge: String(valueOr(payload.badge, '')).trim().toUpperCase(),
        confirmLabel: String(valueOr(payload.confirmLabel, '')).trim(),
        loading: false,
        onConfirm: typeof payload.onConfirm === 'function' ? payload.onConfirm : null,
        closeOnSuccess: Array.isArray(payload.closeOnSuccess) ? payload.closeOnSuccess : []
    };

    renderCriticalConfirmModal();
    openModal(criticalConfirmModal, 'criticalConfirm');
}

function countEnabledPermissionFlags(flags) {
    const normalized = normalizePermissionFlags(flags || {});
    if (normalized.all_permissions === true) {
        return getPermissionDefinitions().length;
    }

    return getPermissionDefinitions().reduce((total, definition) => {
        const key = String(valueOr(definition && definition.key, '')).trim();
        if (!key.length) {
            return total;
        }
        return total + (normalized[key] === true ? 1 : 0);
    }, 0);
}

async function submitItemQueueConfirmed() {
    if (state.itemModal.sending) {
        return null;
    }

    if (!state.itemModal.queue.length) {
        setStatus(t('status_add_item_min_one', {}, 'Adicione pelo menos um item na lista.'), 'error');
        closeModal(itemConfirmModal);
        return null;
    }

    const capacityCheckPayload = {
        items: state.itemModal.queue.map((entry) => ({
            itemName: entry.name,
            amount: Number(entry.amount || 1)
        }))
    };

    const capacityResponse = await executeAction('checkItemCapacity', capacityCheckPayload, {
        silentSuccess: true,
        silentError: true
    });

    if (!capacityResponse.ok) {
        const failData = capacityResponse.result && capacityResponse.result.data
            ? capacityResponse.result.data
            : {
                ...(state.itemModal.lastCapacity || buildLocalItemCapacityData()),
                hasEnough: false
            };
        renderItemCapacityStatus(failData);
        return capacityResponse;
    }

    const capacityData = capacityResponse.result && capacityResponse.result.data ? capacityResponse.result.data : null;
    renderItemCapacityStatus(capacityData);
    if (!capacityData || capacityData.hasEnough !== true) {
        return capacityResponse;
    }

    state.itemModal.sending = true;
    itemConfirmSendBtn.disabled = true;

    const response = await executeAction('addItem', capacityCheckPayload, {
        silentSuccess: true,
        silentError: true
    });

    if (!response.ok) {
        const responseMessage = response.result && response.result.message
            ? response.result.message
            : t('modal_fail_send_item', { label: t('field_items', {}, 'itens') }, 'Falha ao enviar {label}.');
        const shouldKeepDisabled = responseMessage.toLowerCase().includes('kg');
        if (shouldKeepDisabled) {
            renderItemCapacityStatus({
                ...(state.itemModal.lastCapacity || buildLocalItemCapacityData()),
                hasEnough: false
            });
        } else {
            setStatus(responseMessage, 'error');
            itemConfirmSendBtn.classList.remove('is-insufficient');
        }
        state.itemModal.sending = false;
        itemConfirmSendBtn.disabled = shouldKeepDisabled;
        return response;
    }

    state.itemModal.sending = false;
    itemConfirmSendBtn.disabled = false;
    itemConfirmSendBtn.classList.remove('is-insufficient');
    setStatus(t('status_list_sent', { count: state.itemModal.queue.length }, 'Lista enviada. Itens processados: {count}.'), 'ok');
    return { ok: true };
}

function applyStaticTranslations() {
    document.querySelectorAll('[data-i18n]').forEach((element) => {
        const key = element.getAttribute('data-i18n');
        if (!key) {
            return;
        }
        element.textContent = t(key, {}, element.textContent || '');
    });

    document.querySelectorAll('[data-i18n-placeholder]').forEach((element) => {
        const key = element.getAttribute('data-i18n-placeholder');
        if (!key) {
            return;
        }
        element.setAttribute('placeholder', t(key, {}, element.getAttribute('placeholder') || ''));
    });

    if (moneyModalTitle) {
        const titleKey = state.moneyModal.mode === 'remove' ? 'modal_remove_money_title' : 'modal_add_money_title';
        moneyModalTitle.textContent = t(titleKey, {}, moneyModalTitle.textContent || '');
    }

    if (moneyModalApplyBtn) {
        const applyKey = state.moneyModal.mode === 'remove' ? 'modal_money_apply_remove' : 'modal_money_apply_add';
        const fallback = state.moneyModal.mode === 'remove' ? 'Remover' : 'Adicionar';
        moneyModalApplyBtn.textContent = t(applyKey, {}, fallback);
    }

    if (isVisible(supportAdjustModal)) {
        renderSupportAdjustModalInfo();
    }

    if (isVisible(criticalConfirmModal)) {
        renderCriticalConfirmModal();
    }
}

function getSelectedPlayer() {
    if (state.selectedSource === null) {
        return null;
    }

    return state.players.find((player) => player.source === state.selectedSource) || null;
}

function upsertSelectedPlayerMultijobEntry(jobName, gradeLevel, setActive) {
    const player = getSelectedPlayer();
    if (!player) {
        return;
    }

    const normalizedJobName = String(valueOr(jobName, '')).trim().toLowerCase();
    if (!normalizedJobName.length) {
        return;
    }

    const grade = Number.isFinite(Number(gradeLevel)) ? Math.floor(Number(gradeLevel)) : 0;
    const catalogJob = Array.isArray(state.catalog.jobs)
        ? state.catalog.jobs.find((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === normalizedJobName)
        : null;
    const catalogGrade = catalogJob && Array.isArray(catalogJob.grades)
        ? catalogJob.grades.find((entry) => Number(entry.level || 0) === grade)
        : null;
    const jobLabel = String(valueOr(catalogJob && catalogJob.label, normalizedJobName)).trim() || normalizedJobName;
    const gradeLabel = String(valueOr(catalogGrade && catalogGrade.name, `#${grade}`)).trim() || `#${grade}`;

    if (!Array.isArray(player.jobs)) {
        player.jobs = [];
    }

    const existing = player.jobs.find((entry) => String(valueOr(entry.name, valueOr(entry.job, ''))).trim().toLowerCase() === normalizedJobName);
    if (existing) {
        existing.name = normalizedJobName;
        existing.job = normalizedJobName;
        existing.label = jobLabel;
        existing.jobLabel = jobLabel;
        existing.grade = grade;
        existing.gradeName = gradeLabel;
        existing.gradeLabel = gradeLabel;
        existing.onduty = setActive === true ? true : existing.onduty === true;
    } else {
        player.jobs.push({
            name: normalizedJobName,
            job: normalizedJobName,
            label: jobLabel,
            jobLabel: jobLabel,
            grade,
            gradeName: gradeLabel,
            gradeLabel,
            onduty: setActive === true
        });
    }
}

function getBannedPlayerById(banId) {
    const normalizedId = String(valueOr(banId, '')).trim();
    if (!normalizedId.length) {
        return null;
    }

    return state.bannedPlayers.find((entry) => String(valueOr(entry.id, '')).trim() === normalizedId) || null;
}

function getPermissionDefinitions() {
    return Array.isArray(state.catalog.permissionDefinitions) ? state.catalog.permissionDefinitions : [];
}

function getPermissionDescription(key) {
    const descriptions = {
        copyCoords: t('permission_desc_copyCoords', {}, 'Copiar as coordenadas atuais do mapa.'),
        viewBannedPlayers: t('permission_desc_viewBannedPlayers', {}, 'Ver a lista de jogadores banidos.'),
        viewUtilitiesPanel: t('permission_desc_viewUtilitiesPanel', {}, 'Acessar o painel de utilidades administrativas.'),
        manage_permissions: t('permission_desc_manage_permissions', {}, 'Gerenciar cargos e acessos do painel.'),
        goto: t('permission_desc_goto', {}, 'Ir ate a localizacao do player.'),
        bring: t('permission_desc_bring', {}, 'Trazer o player ate voce.'),
        revive: t('permission_desc_revive', {}, 'Reviver o player selecionado.'),
        heal: t('permission_desc_heal', {}, 'Curar a vida do player.'),
        toggleFreeze: t('permission_desc_toggleFreeze', {}, 'Congelar ou descongelar o player.'),
        spectate: t('permission_desc_spectate', {}, 'Entrar em modo espectador no player.'),
        openInventory: t('permission_desc_openInventory', {}, 'Abrir o inventario do player.'),
        setJob: t('permission_desc_setJob', {}, 'Definir ou trocar o emprego do player.'),
        upsertMultijobJob: t('permission_desc_upsertMultijobJob', {}, 'Adicionar ou atualizar um job na multijob.'),
        removeJob: t('permission_desc_removeJob', {}, 'Remover um emprego do player.'),
        addItem: t('permission_desc_addItem', {}, 'Adicionar item ao inventario do player.'),
        addMoney: t('permission_desc_addMoney', {}, 'Adicionar dinheiro ao player.'),
        removeMoney: t('permission_desc_removeMoney', {}, 'Remover dinheiro do player.'),
        addWeight: t('permission_desc_addWeight', {}, 'Adicionar capacidade de peso ao player.'),
        addSlots: t('permission_desc_addSlots', {}, 'Adicionar slots de inventario ao player.'),
        renameCharacter: t('permission_desc_renameCharacter', {}, 'Trocar nome e sobrenome do personagem.'),
        changeHeight: t('permission_desc_changeHeight', {}, 'Alterar a altura do personagem no banco de dados.'),
        clearInventory: t('permission_desc_clearInventory', {}, 'Limpar todo o inventario do player.'),
        privateMessage: t('permission_desc_privateMessage', {}, 'Enviar mensagem privada para o player.'),
        kick: t('permission_desc_kick', {}, 'Expulsar o player do servidor.'),
        banPlayer: t('permission_desc_banPlayer', {}, 'Aplicar banimento em um player.'),
        editBan: t('permission_desc_editBan', {}, 'Editar a duracao de um banimento.'),
        removeBan: t('permission_desc_removeBan', {}, 'Remover o banimento de um player.'),
        checkItemCapacity: t('permission_desc_checkItemCapacity', {}, 'Verificar se o inventario suporta os itens.'),
        togglePlayerBlips: t('permission_desc_togglePlayerBlips', {}, 'Ativar ou desativar blips dos players.'),
        togglePlayerWall: t('permission_desc_togglePlayerWall', {}, 'Ativar ou desativar wallhack dos players.'),
        toggleNoclip: t('permission_desc_toggleNoclip', {}, 'Ativar ou desativar o noclip.'),
        spawnAdminHorse: t('permission_desc_spawnAdminHorse', {}, 'Spawnar um cavalo administrativo.'),
        openCompanyStash: t('permission_desc_openCompanyStash', {}, 'Abrir o bau de uma empresa.'),
        teleportToCoords: t('permission_desc_teleportToCoords', {}, 'Usar a aba de Teleports (locais salvos e coordenadas customizadas).'),
        manageTeleportLocations: t('permission_desc_manageTeleportLocations', {}, 'Adicionar ou remover locais de teleporte customizados.'),
        findCharacterByCitizenid: t('permission_desc_deleteCharacterByCitizenid', {}, 'Buscar e deletar um personagem offline pela citizenid em todas as tabelas compativeis.'),
        deleteCharacterByCitizenid: t('permission_desc_deleteCharacterByCitizenid', {}, 'Buscar e deletar um personagem offline pela citizenid em todas as tabelas compativeis.')
    };

    return descriptions[key] || t('permission_desc_default', {}, 'Executar esta funcao no painel.');
}

function getPermissionPresets() {
    return Array.isArray(state.catalog.permissionPresets) ? state.catalog.permissionPresets : [];
}

function getPermissionPresetByKey(presetKey) {
    const normalized = String(valueOr(presetKey, '')).trim();
    if (!normalized.length) {
        return null;
    }

    return getPermissionPresets().find((entry) => String(valueOr(entry.key, '')).trim() === normalized) || null;
}

function getPermissionPresetLabel(presetOrKey) {
    const key = typeof presetOrKey === 'string'
        ? String(valueOr(presetOrKey, '')).trim()
        : String(valueOr(presetOrKey && presetOrKey.key, '')).trim();
    const fallbackLabel = typeof presetOrKey === 'string'
        ? key
        : String(valueOr(presetOrKey && presetOrKey.label, key)).trim() || key;

    const labelMap = {
        fundador: t('permission_role_fundador', {}, 'Founder'),
        developer: t('permission_role_developer', {}, 'Developer'),
        administrador: t('permission_role_administrador', {}, 'Administrator'),
        banimento: t('permission_role_banimento', {}, 'Ban'),
        suporte: t('permission_role_suporte', {}, 'Support')
    };

    return labelMap[key] || fallbackLabel;
}

const PANEL_PERMISSION_BY_TARGET = {
    bannedPlayers: 'viewBannedPlayers',
    permissions: 'manage_permissions',
    utilities: 'viewUtilitiesPanel',
    teleports: 'teleportToCoords'
};

// `keys` is one or more space separated permission keys; any of them is enough.
function hasSelfPermission(keys) {
    const self = state.permissions && state.permissions.self ? state.permissions.self.permissions : null;
    if (!self || typeof self !== 'object') {
        return false;
    }
    if (self.all_permissions === true) {
        return true;
    }
    return String(valueOr(keys, '')).split(/\s+/).filter(Boolean).some((key) => self[key] === true);
}

function applyPermissionVisibility() {
    document.querySelectorAll('[data-requires-permission]').forEach((element) => {
        element.classList.toggle('perm-hidden', !hasSelfPermission(element.dataset.requiresPermission));
    });

    // A card left without any visible option is hidden too.
    document.querySelectorAll('.dashboard-actions, .teleports-actions-row').forEach((group) => {
        const hasVisible = Array.from(group.children).some((child) => !child.classList.contains('perm-hidden'));
        const card = group.closest('.panel-card') || group;
        card.classList.toggle('perm-hidden', !hasVisible);
    });

    const activeNav = navButtons.find((button) => button.dataset.panelTarget === state.activePanel);
    if (activeNav && activeNav.classList.contains('perm-hidden')) {
        setActivePanel('dashboard');
    }
}

function getDeveloperCharacterLookup() {
    const lookup = state.developerCharacter && state.developerCharacter.lookup && typeof state.developerCharacter.lookup === 'object'
        ? { ...state.developerCharacter.lookup }
        : null;
    if (!lookup) {
        return null;
    }

    const citizenid = String(valueOr(lookup.citizenid, '')).trim().toLowerCase();
    if (citizenid.length) {
        const onlinePlayer = state.players.find((player) => String(valueOr(player.citizenid, '')).trim().toLowerCase() === citizenid) || null;
        lookup.online = !!onlinePlayer;
        if (onlinePlayer) {
            lookup.onlineSource = Number(onlinePlayer.source || 0);
            lookup.fullname = lookup.fullname || onlinePlayer.fullname || onlinePlayer.name || lookup.citizenid;
        }
    }

    return lookup;
}

function isDeveloperCharacterSelected(lookup) {
    const selectedCitizenid = String(valueOr(state.developerCharacter && state.developerCharacter.selectedCitizenid, '')).trim().toLowerCase();
    const lookupCitizenid = String(valueOr(lookup && lookup.citizenid, '')).trim().toLowerCase();
    return !!selectedCitizenid.length && selectedCitizenid === lookupCitizenid;
}

function renderDeveloperCharacterPanel() {
    if (developerCitizenIdInput && document.activeElement !== developerCitizenIdInput) {
        developerCitizenIdInput.value = state.developerCharacter.citizenid || '';
    }

    const lookup = getDeveloperCharacterLookup();
    const hasCitizenid = String(valueOr(state.developerCharacter.citizenid, '')).trim().length > 0;
    const isSelected = isDeveloperCharacterSelected(lookup);
    if (developerSearchBtn) {
        developerSearchBtn.disabled = !hasCitizenid;
    }
    if (developerDeleteCharacterBtn) {
        developerDeleteCharacterBtn.disabled = !lookup || lookup.found !== true || !isSelected;
    }
    if (!developerCharacterResult || !developerCharacterDetails) {
        return;
    }

    if (!lookup) {
        developerCharacterResult.innerHTML = `
            <div class="delete-character-inline-state">
                <span>${escapeHtml(t('developer_delete_intro', {}, 'Busque uma citizenid offline e remova todos os registros encontrados no banco de dados.'))}</span>
            </div>
        `;
        developerCharacterDetails.innerHTML = `<div class="helper-note delete-character-inline-copy">${escapeHtml(t('developer_delete_character_pick', {}, 'Clique no personagem encontrado para habilitar a exclusao.'))}</div>`;
        return;
    }

    if (lookup.found !== true) {
        developerCharacterResult.innerHTML = `
            <div class="delete-character-inline-state">
                <strong>${escapeHtml(t('developer_result_not_found', {}, 'Nenhum personagem encontrado para esta citizenid.'))}</strong>
                <span>${escapeHtml(t('developer_citizenid_label', {}, 'Citizenid'))}: ${escapeHtml(state.developerCharacter.citizenid || '-')}</span>
            </div>
        `;
        developerCharacterDetails.innerHTML = `<div class="helper-note delete-character-inline-copy">${escapeHtml(t('developer_result_not_found', {}, 'Nenhum personagem encontrado para esta citizenid.'))}</div>`;
        return;
    }

    const matchedTables = Array.isArray(lookup.matchedTables) ? lookup.matchedTables : [];
    const moneyTypes = getMoneyTypes();
    const money = lookup.money && typeof lookup.money === 'object' ? lookup.money : {};
    const moneyLines = moneyTypes.length
        ? moneyTypes.map((entry) => {
            const key = String(valueOr(entry && entry.key, '')).trim();
            const label = String(valueOr(entry && entry.label, key || 'Money')).trim() || 'Money';
            return `
                <div class="bank-item">
                    <span>${escapeHtml(label)}</span>
                    <strong>${escapeHtml(formatMoney(Number(valueOr(money[key], 0))))}</strong>
                </div>
            `;
        }).join('')
        : `
            <div class="bank-item">
                <span>Money</span>
                <strong>0</strong>
            </div>
        `;
    const tableLines = matchedTables.length
        ? matchedTables.map((entry) => {
            const tableName = String(valueOr(entry.tableName, '-')).trim() || '-';
            const matchCount = Number(valueOr(entry.matchCount, 0));
            return `
                <div class="info-item delete-character-table-card">
                    <span>${escapeHtml(tableName)}</span>
                    <strong>${escapeHtml(String(matchCount))}</strong>
                </div>
            `;
        }).join('')
        : `<div class="helper-note">${escapeHtml(t('developer_result_no_tables', {}, 'Nenhuma tabela compativel encontrada.'))}</div>`;
    const statusText = lookup.online === true
        ? t('developer_result_online', {}, 'Online')
        : t('developer_result_offline', {}, 'Offline');
    const footerText = lookup.online === true
        ? t('developer_delete_character_online_flow', {}, 'Se deletar agora, o jogador sera kickado em 5 segundos e o personagem sera apagado 5 segundos depois.')
        : (isSelected
            ? t('developer_delete_character_ready', {}, 'Personagem selecionado. Agora voce pode deletar.')
            : t('developer_delete_character_pick', {}, 'Clique no personagem encontrado para habilitar a exclusao.'));

    developerCharacterResult.innerHTML = `
        <div class="delete-character-row ${isSelected ? 'is-selected' : ''}">
            <div class="delete-character-row-head">
                <div class="delete-character-name-block">
                    <strong>${escapeHtml(lookup.fullname || lookup.citizenid || '-')}</strong>
                </div>
                <button
                    type="button"
                    class="delete-character-eye-btn"
                    data-developer-character-select="true"
                    aria-label="Abrir informacoes do personagem"
                    title="Abrir informacoes do personagem"
                >👁</button>
            </div>
        </div>
    `;

    if (!isSelected) {
        developerCharacterDetails.innerHTML = `<div class="helper-note delete-character-inline-copy">${escapeHtml(t('developer_delete_character_pick', {}, 'Clique no personagem encontrado para habilitar a exclusao.'))}</div>`;
        return;
    }

    developerCharacterDetails.innerHTML = `
        <div class="delete-character-section">
            <div class="info-grid delete-character-meta-grid">
                <div class="info-item">
                    <span>Nome</span>
                    <strong>${escapeHtml(lookup.fullname || lookup.citizenid || '-')}</strong>
                </div>
                <div class="info-item">
                    <span>ID Online</span>
                    <strong>${escapeHtml(lookup.online === true ? String(valueOr(lookup.onlineSource, '-')) : '-')}</strong>
                </div>
                <div class="info-item">
                    <span>${escapeHtml(t('developer_result_status', {}, 'Status'))}</span>
                    <strong>${escapeHtml(statusText)}</strong>
                </div>
                <div class="info-item">
                    <span>${escapeHtml(t('developer_result_license', {}, 'License'))}</span>
                    <strong>${escapeHtml(lookup.license || '-')}</strong>
                </div>
                <div class="info-item">
                    <span>${escapeHtml(t('developer_result_rows', {}, 'Registros'))}</span>
                    <strong>${escapeHtml(String(valueOr(lookup.totalRows, 0)))}</strong>
                </div>
                <div class="info-item">
                    <span>${escapeHtml(t('developer_result_tables', {}, 'Tabelas afetadas'))}</span>
                    <strong>${escapeHtml(String(matchedTables.length))}</strong>
                </div>
                <div class="info-item">
                    <span>${escapeHtml(t('field_citizenid', {}, 'Citizenid'))}</span>
                    <strong>${escapeHtml(lookup.citizenid || '-')}</strong>
                </div>
            </div>
        </div>
        <div class="delete-character-section">
            <h4>Dinheiro</h4>
            <div class="info-grid delete-character-meta-grid">${moneyLines}</div>
        </div>
        <div class="delete-character-section">
            <h4>Tabelas que serao deletadas</h4>
            <div class="info-grid delete-character-tables">${tableLines}</div>
        </div>
        <div class="delete-character-section">
            <h4>Confirmacao</h4>
            <div class="helper-note delete-character-inline-copy">${escapeHtml(footerText)}</div>
        </div>
    `;
}

function resetDeveloperCharacterState(options = {}) {
    const keepCitizenid = options.keepCitizenid === true;
    if (!keepCitizenid) {
        state.developerCharacter.citizenid = '';
    }
    state.developerCharacter.lookup = null;
    state.developerCharacter.selectedCitizenid = '';
}

function openDeleteCharacterModal() {
    resetDeveloperCharacterState();
    renderDeveloperCharacterPanel();
    openModal(deleteCharacterModal, 'deleteCharacter');
}

function openDeveloperCharacterInfoModal() {
    const lookup = getDeveloperCharacterLookup();
    if (!lookup || lookup.found !== true) {
        setStatus(t('developer_status_lookup_first', {}, 'Procure uma citizenid valida antes de deletar.'), 'warn');
        return;
    }

    state.developerCharacter.selectedCitizenid = String(valueOr(lookup.citizenid, '')).trim();
    renderDeveloperCharacterPanel();
    openModal(developerCharacterInfoModal, 'developerCharacterInfo');
}

function buildEmptyPermissionFlags() {
    const flags = { all_permissions: false };
    getPermissionDefinitions().forEach((definition) => {
        const key = String(valueOr(definition.key, '')).trim();
        if (key.length) {
            flags[key] = false;
        }
    });
    return flags;
}

function normalizePermissionFlags(rawFlags) {
    const output = buildEmptyPermissionFlags();
    if (!rawFlags || typeof rawFlags !== 'object') {
        return output;
    }

    output.all_permissions = rawFlags.all_permissions === true;
    getPermissionDefinitions().forEach((definition) => {
        const key = String(valueOr(definition.key, '')).trim();
        if (key.length) {
            output[key] = rawFlags[key] === true;
        }
    });

    if (output.all_permissions) {
        getPermissionDefinitions().forEach((definition) => {
            const key = String(valueOr(definition.key, '')).trim();
            if (key.length) {
                output[key] = true;
            }
        });
    }

    return output;
}

function formatDateTimeLabel(value, fallback = '-') {
    const raw = String(valueOr(value, '')).trim();
    if (!raw.length) {
        return fallback;
    }

    const parsed = Date.parse(raw.replace(' ', 'T'));
    if (!Number.isFinite(parsed)) {
        return raw;
    }

    try {
        return new Intl.DateTimeFormat(getNumberLocale(), {
            dateStyle: 'short',
            timeStyle: 'short'
        }).format(new Date(parsed));
    } catch (_error) {
        return raw;
    }
}

function truncateText(value, maxLength = 140) {
    const text = String(valueOr(value, '')).trim();
    if (!text.length || text.length <= maxLength) {
        return text;
    }
    return `${text.slice(0, maxLength - 1)}...`;
}

function getPermissionEntryByLicense(license) {
    const normalized = String(valueOr(license, '')).trim();
    if (!normalized.length) {
        return null;
    }
    const entries = state.permissions && Array.isArray(state.permissions.entries) ? state.permissions.entries : [];
    return entries.find((entry) => String(valueOr(entry.citzenid, '')).trim() === normalized) || null;
}

function getOnlinePermissionCandidateBySource(source) {
    const targetSource = Number(source || 0);
    if (!Number.isFinite(targetSource) || targetSource <= 0) {
        return null;
    }
    const online = state.permissions && Array.isArray(state.permissions.onlinePlayers) ? state.permissions.onlinePlayers : [];
    return online.find((entry) => Number(entry.source || 0) === targetSource) || null;
}

function getPermissionAccessLabel(accessType, presetLabel = '') {
    const value = String(valueOr(accessType, 'custom')).trim();
    if (value === 'god') {
        return t('permissions_access_god', {}, 'GOD');
    }
    if (value === 'framework') {
        const frameworkLabel = t('permissions_access_framework', {}, 'Framework');
        return presetLabel ? `${frameworkLabel}: ${presetLabel}` : frameworkLabel;
    }
    if (value === 'preset') {
        return presetLabel
            ? t('permissions_access_role_named', { role: getPermissionPresetLabel(presetLabel) }, 'Cargo: {role}')
            : t('permissions_access_role', {}, 'Cargo');
    }
    return t('permissions_access_custom', {}, 'Custom');
}

function setActivePanel(panelName) {
    if (panelName === 'support' && !state.supportUnlocked) {
        return;
    }

    state.activePanel = panelName;

    navButtons.forEach((button) => {
        const target = button.dataset.panelTarget;
        const isSupportView = panelName === 'support';
        button.classList.toggle('active', isSupportView ? target === 'players' : target === panelName);
    });

    panels.forEach((panel) => {
        panel.classList.toggle('active', panel.dataset.panel === panelName);
    });
}

function updateSupportAccess() {
    if (!state.supportUnlocked && state.activePanel === 'support') {
        setActivePanel('players');
    }
}

function getFilteredPlayers() {
    const query = state.filter.trim().toLowerCase();
    if (!query) {
        return state.players;
    }

    return state.players.filter((player) => {
        const jobData = player.job || {};
        const blob = `${player.source} ${player.name} ${player.fullname} ${player.citizenid} ${jobData.label || ''}`.toLowerCase();
        return blob.includes(query);
    });
}

function toFiniteNumber(value) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
}

function clampNumber(value, minValue, maxValue) {
    return Math.min(maxValue, Math.max(minValue, value));
}

function renderTopRichPlayers(entries) {
    if (!topRichPlayersHead || !topRichPlayersBody) {
        return;
    }

    const moneyTypes = getMoneyTypes();
    const rows = Array.isArray(entries) ? entries : [];

    const headCells = [
        `<th>#</th>`,
        `<th data-i18n="dashboard_top_rich_col_name">${escapeHtml(t('dashboard_top_rich_col_name', {}, 'Nome'))}</th>`,
        `<th data-i18n="dashboard_top_rich_col_citizenid">${escapeHtml(t('dashboard_top_rich_col_citizenid', {}, 'Citizen ID'))}</th>`,
        ...moneyTypes.map((entry) => `<th>${escapeHtml(entry.label || entry.key)}</th>`),
        `<th data-i18n="dashboard_top_rich_col_total">${escapeHtml(t('dashboard_top_rich_col_total', {}, 'Total'))}</th>`
    ];
    topRichPlayersHead.innerHTML = `<tr>${headCells.join('')}</tr>`;

    if (!rows.length) {
        const colspan = moneyTypes.length + 4;
        topRichPlayersBody.innerHTML = `<tr><td colspan="${colspan}">${escapeHtml(t('dashboard_top_rich_empty', {}, 'Sem dados.'))}</td></tr>`;
        return;
    }

    topRichPlayersBody.innerHTML = rows.map((player, index) => {
        const money = player.money || {};
        const moneyCells = moneyTypes
            .map((entry) => `<td>${formatMoney(valueOr(money[entry.key], 0))}</td>`)
            .join('');

        return `
            <tr>
                <td>${index + 1}</td>
                <td>${escapeHtml(player.name)}</td>
                <td>${escapeHtml(player.citizenid)}</td>
                ${moneyCells}
                <td><strong>${formatMoney(valueOr(player.total, 0))}</strong></td>
            </tr>
        `;
    }).join('');
}

function renderDashboard() {
    const data = state.dashboard || {};

    metricOnline.textContent = valueOr(data.online, 0);
    metricMax.textContent = valueOr(data.maxClients, 0);
    metricStaff.textContent = valueOr(data.staffOnline, 0);
    metricDead.textContent = valueOr(data.deadPlayers, 0);
    metricPing.textContent = valueOr(data.averagePing, 0);
    metricUpdated.textContent = data.updatedAt ? String(data.updatedAt).slice(11, 19) : '--';
    metricBank.textContent = formatMoney(valueOr(data.totalMoney, 0));

    renderTopRichPlayers(data.topRichPlayers);

    const jobs = Array.isArray(data.jobDistribution) ? data.jobDistribution : [];
    if (!jobs.length) {
        jobsList.innerHTML = `<li><span>${escapeHtml(t('empty_jobs_data', {}, 'Sem dados'))}</span><em>0</em></li>`;
        return;
    }

    jobsList.innerHTML = jobs.map((entry) => {
        const label = escapeHtml(entry.job || 'unemployed');
        const onDuty = Number(entry.onDuty || 0);
        const total = Number(entry.total || 0);
        const offDuty = Math.max(0, total - onDuty);
        return `
            <li>
                <strong>${label}</strong>
                <div class="job-duty-line">
                    <span>${escapeHtml(t('job_on_duty_label', {}, 'Em servico:'))}</span>
                    <em>${onDuty}</em>
                </div>
                <div class="job-duty-line">
                    <span>${escapeHtml(t('job_off_duty_label', {}, 'Fora de servico:'))}</span>
                    <em>${offDuty}</em>
                </div>
            </li>
        `;
    }).join('');
}

function renderPlayers() {
    const rows = getFilteredPlayers();

    if (!rows.length) {
        playersBody.innerHTML = `<tr><td colspan="8">${escapeHtml(t('empty_players', {}, 'Nenhum jogador encontrado.'))}</td></tr>`;
        return;
    }

    playersBody.innerHTML = rows.map((player) => {
        const metadata = player.metadata || {};
        const jobData = player.job || {};
        const isDead = metadata.isdead === true;
        const deadClass = isDead ? 'status-dead' : 'status-live';

        return `
            <tr data-source="${player.source}">
                <td>${player.source}</td>
                <td>${escapeHtml(player.fullname)}${player.staffRole ? ` <span class="player-staff-role">${escapeHtml(player.staffRole)}</span>` : ''}</td>
                <td>${escapeHtml(jobData.name || t('value_na', {}, 'N/A'))} <small>(${getJobGradeValue(jobData)})</small></td>
                <td class="${jobData.onduty ? 'flag-on' : 'flag-off'}">${jobData.onduty ? t('value_on', {}, 'ON') : t('value_off', {}, 'OFF')}</td>
                <td>${valueOr(player.ping, 0)}</td>
                <td class="${deadClass}">${isDead ? t('value_dead', {}, 'Morto') : t('value_alive', {}, 'Vivo')}</td>
                <td class="${player.frozen ? 'status-dead' : 'flag-off'}">${player.frozen ? t('value_yes', {}, 'Sim') : t('value_no', {}, 'Nao')}</td>
                <td>
                    <div class="player-row-actions">
                        ${hasSelfPermission('goto') ? `<button type="button" class="player-row-btn" data-player-action="goto" data-player-source="${player.source}">${escapeHtml(t('action_goto', {}, 'Ir ate jogador'))}</button>` : ''}
                        ${hasSelfPermission('bring') ? `<button type="button" class="player-row-btn" data-player-action="bring" data-player-source="${player.source}">${escapeHtml(t('action_bring', {}, 'Trazer jogador'))}</button>` : ''}
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

function getAllTeleportLocations() {
    const towns = Array.isArray(state.catalog.builtInTeleports) ? state.catalog.builtInTeleports : [];
    const custom = Array.isArray(state.teleports.customLocations) ? state.teleports.customLocations : [];
    return [...towns, ...custom.map((entry) => ({ ...entry, custom: true }))];
}

function getFilteredTeleportLocations() {
    const query = String(state.teleports.search || '').trim().toLowerCase();
    const category = state.teleports.category || 'all';

    return getAllTeleportLocations().filter((loc) => {
        if (category !== 'all' && loc.category !== category) {
            return false;
        }
        if (query && !String(loc.name || '').toLowerCase().includes(query)) {
            return false;
        }
        return true;
    });
}

function renderTeleportCategoryOptions() {
    const categoryEntries = Object.keys(TELEPORT_CATEGORY_LABELS);

    if (teleportCategoryFilter) {
        const options = [`<option value="all">${escapeHtml(t('teleports_filter_all', {}, 'Todas as Categorias'))}</option>`]
            .concat(categoryEntries.map((key) => `<option value="${key}">${escapeHtml(TELEPORT_CATEGORY_LABELS[key])}</option>`));
        teleportCategoryFilter.innerHTML = options.join('');
        teleportCategoryFilter.value = state.teleports.category || 'all';
    }

    if (addTeleportCategorySelect) {
        addTeleportCategorySelect.innerHTML = categoryEntries
            .map((key) => `<option value="${key}">${escapeHtml(TELEPORT_CATEGORY_LABELS[key])}</option>`)
            .join('');
    }
}

function renderTeleports() {
    if (!teleportsGrid) {
        return;
    }

    const rows = getFilteredTeleportLocations();
    if (!rows.length) {
        teleportsGrid.innerHTML = `<p class="teleports-empty">${escapeHtml(t('teleports_empty', {}, 'Nenhum local encontrado.'))}</p>`;
        return;
    }

    teleportsGrid.innerHTML = rows.map((loc) => {
        const icon = TELEPORT_CATEGORY_ICONS[loc.category] || '📍';
        const categoryLabel = TELEPORT_CATEGORY_LABELS[loc.category] || loc.category;
        const deleteBtn = loc.custom && hasSelfPermission('manageTeleportLocations')
            ? `<button type="button" class="player-row-btn danger teleport-card-delete-btn" data-teleport-delete="${escapeHtml(String(loc.id))}">${escapeHtml(t('teleports_delete_button', {}, 'Remover'))}</button>`
            : '';

        return `
            <div class="teleport-card">
                <div class="teleport-card-head">
                    <span class="teleport-card-icon">${icon}</span>
                    <div class="teleport-card-title">
                        <strong>${escapeHtml(loc.name)}</strong>
                        <small>${escapeHtml(categoryLabel)}</small>
                    </div>
                </div>
                ${loc.description ? `<p class="teleport-card-desc">${escapeHtml(loc.description)}</p>` : ''}
                <div class="teleport-card-coords">
                    <span>X: <em>${Number(loc.x).toFixed(1)}</em></span>
                    <span>Y: <em>${Number(loc.y).toFixed(1)}</em></span>
                    <span>Z: <em>${Number(loc.z).toFixed(1)}</em></span>
                    <span>H: <em>${Number(loc.heading || 0).toFixed(0)}</em></span>
                </div>
                <div class="teleport-card-actions">
                    <button type="button" class="player-row-btn teleport-card-go-btn" data-teleport-go="${escapeHtml(String(loc.id))}">${escapeHtml(t('teleports_go_button', {}, 'Teleportar'))}</button>
                    ${deleteBtn}
                </div>
            </div>
        `;
    }).join('');
}

async function loadTeleportLocations() {
    try {
        const response = await postNui('getTeleportLocations');
        if (response && response.ok === true) {
            state.teleports.customLocations = Array.isArray(response.data) ? response.data : [];
        } else if (response && response.message) {
            setStatus(response.message, 'error');
        }
    } catch (_error) {
        setStatus(t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
    }

    state.teleports.loaded = true;
    renderTeleports();
}

async function teleportToLocation(loc) {
    if (!loc) {
        return;
    }

    const response = await postNui('teleportToCoords', {
        x: loc.x,
        y: loc.y,
        z: loc.z,
        heading: loc.heading || 0
    });

    if (!response || response.ok !== true) {
        setStatus((response && response.message) || t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
        return;
    }

    setStatus(t('status_teleport_success', { name: loc.name }, 'Teleportado para {name}.'), 'ok');
}

async function deleteTeleportLocationById(loc) {
    const response = await postNui('deleteTeleportLocation', { id: loc.id });
    if (response && response.ok === true) {
        setStatus(response.message || t('status_teleport_delete_success', {}, 'Local removido.'), 'ok');
        await loadTeleportLocations();
        return { ok: true };
    }

    setStatus((response && response.message) || t('status_teleport_delete_fail', {}, 'Falha ao remover local.'), 'error');
    return { ok: false };
}

function confirmDeleteTeleportLocation(loc) {
    openCriticalConfirmModal({
        title: t('modal_delete_teleport_title', {}, 'Remover Local'),
        summary: t('modal_delete_teleport_summary', { name: loc.name }, 'Remover "{name}"? Esta acao nao pode ser desfeita.'),
        variant: 'ban',
        badge: 'DEL',
        confirmLabel: t('teleports_delete_button', {}, 'Remover'),
        onConfirm: () => deleteTeleportLocationById(loc)
    });
}

function openCustomTeleportModal() {
    if (customTeleportXInput) customTeleportXInput.value = '';
    if (customTeleportYInput) customTeleportYInput.value = '';
    if (customTeleportZInput) customTeleportZInput.value = '';
    if (customTeleportHeadingInput) customTeleportHeadingInput.value = '0';
    openModal(customTeleportModal, 'customTeleport');
}

async function submitCustomTeleport() {
    const x = toFiniteNumber(customTeleportXInput && customTeleportXInput.value);
    const y = toFiniteNumber(customTeleportYInput && customTeleportYInput.value);
    const z = toFiniteNumber(customTeleportZInput && customTeleportZInput.value);
    const heading = toFiniteNumber(customTeleportHeadingInput && customTeleportHeadingInput.value) || 0;

    if (x === null || y === null || z === null) {
        setStatus(t('teleport_coords_invalid', {}, 'Coordenadas invalidas.'), 'error');
        return;
    }

    const response = await postNui('teleportToCoords', { x, y, z, heading });
    if (!response || response.ok !== true) {
        setStatus((response && response.message) || t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
        return;
    }

    setStatus(t('status_teleport_custom_success', {}, 'Teleportado.'), 'ok');
    closeModal(customTeleportModal);
}

function openAddTeleportModal() {
    if (addTeleportNameInput) addTeleportNameInput.value = '';
    if (addTeleportDescriptionInput) addTeleportDescriptionInput.value = '';
    if (addTeleportXInput) addTeleportXInput.value = '';
    if (addTeleportYInput) addTeleportYInput.value = '';
    if (addTeleportZInput) addTeleportZInput.value = '';
    if (addTeleportHeadingInput) addTeleportHeadingInput.value = '0';
    if (addTeleportCategorySelect) addTeleportCategorySelect.value = 'special';
    openModal(addTeleportModal, 'addTeleport');
}

async function useCurrentLocationForAddTeleport() {
    const response = await postNui('getCurrentCoords');
    if (!response || response.ok !== true || !response.data) {
        setStatus((response && response.message) || t('status_coords_fetch_fail', {}, 'Falha ao pegar coordenadas.'), 'error');
        return;
    }

    if (addTeleportXInput) addTeleportXInput.value = Number(response.data.x).toFixed(2);
    if (addTeleportYInput) addTeleportYInput.value = Number(response.data.y).toFixed(2);
    if (addTeleportZInput) addTeleportZInput.value = Number(response.data.z).toFixed(2);
    if (addTeleportHeadingInput) addTeleportHeadingInput.value = Number(response.data.heading).toFixed(1);
}

async function submitAddTeleport() {
    const name = String((addTeleportNameInput && addTeleportNameInput.value) || '').trim();
    const x = toFiniteNumber(addTeleportXInput && addTeleportXInput.value);
    const y = toFiniteNumber(addTeleportYInput && addTeleportYInput.value);
    const z = toFiniteNumber(addTeleportZInput && addTeleportZInput.value);
    const heading = toFiniteNumber(addTeleportHeadingInput && addTeleportHeadingInput.value) || 0;
    const category = (addTeleportCategorySelect && addTeleportCategorySelect.value) || 'special';
    const description = String((addTeleportDescriptionInput && addTeleportDescriptionInput.value) || '').trim();

    if (!name.length || x === null || y === null || z === null) {
        setStatus(t('teleport_add_invalid', {}, 'Preencha nome e coordenadas validas.'), 'error');
        return;
    }

    const response = await postNui('addTeleportLocation', { name, category, description, x, y, z, heading });
    if (!response || response.ok !== true) {
        setStatus((response && response.message) || t('status_teleport_add_fail', {}, 'Falha ao adicionar local.'), 'error');
        return;
    }

    setStatus(response.message || t('status_teleport_add_success', {}, 'Local adicionado.'), 'ok');
    closeModal(addTeleportModal);
    await loadTeleportLocations();
}


function renderBannedPlayers() {
    if (!bannedPlayersBody) {
        return;
    }

    const rows = Array.isArray(state.bannedPlayers) ? state.bannedPlayers : [];
    if (!rows.length) {
        bannedPlayersBody.innerHTML = `<tr><td colspan="6">${escapeHtml(t('empty_banned_players', {}, 'Nenhum banimento ativo encontrado.'))}</td></tr>`;
        return;
    }

    bannedPlayersBody.innerHTML = rows.map((entry) => {
        const banId = String(valueOr(entry.id, '')).trim();
        const expireLabel = entry.expiresLabel || t('value_na', {}, 'N/A');
        const actionsHtml = `
            <div class="ban-actions">
                ${hasSelfPermission('editBan') ? `<button type="button" class="ban-action-btn" data-ban-action="edit" data-ban-id="${escapeHtml(banId)}">${escapeHtml(t('banned_action_edit', {}, 'Editar'))}</button>` : ''}
                ${hasSelfPermission('removeBan') ? `<button type="button" class="ban-action-btn" data-ban-action="remove" data-ban-id="${escapeHtml(banId)}">${escapeHtml(t('banned_action_remove', {}, 'Remover Ban'))}</button>` : ''}
            </div>
        `;

        return `
            <tr data-ban-id="${escapeHtml(banId)}">
                <td>${escapeHtml(banId)}</td>
                <td>${escapeHtml(entry.name || t('value_na', {}, 'N/A'))}</td>
                <td>${escapeHtml(entry.citzenid || t('value_na', {}, 'N/A'))}</td>
                <td>${escapeHtml(entry.reason || '-')}</td>
                <td>${escapeHtml(expireLabel)}</td>
                <td>
                    ${actionsHtml}
                </td>
            </tr>
        `;
    }).join('');
}

function renderPermissionOptions(container, flags, mode, disabled) {
    if (!container) {
        return;
    }

    const definitions = getPermissionDefinitions();
    if (!definitions.length) {
        container.innerHTML = `<div class="history-empty">${escapeHtml(t('permissions_empty_definitions', {}, 'Nenhuma permissao disponivel.'))}</div>`;
        return;
    }

    container.innerHTML = definitions.map((definition) => {
        const key = String(valueOr(definition.key, '')).trim();
        const label = definition.label || key;
        const description = getPermissionDescription(key);
        const isSelected = flags[key] === true;
        const activeClass = isSelected ? 'active' : '';
        const attr = mode === 'add'
            ? 'data-permission-add-key'
            : mode === 'edit'
                ? 'data-permission-edit-key'
                : 'data-permission-preset-key';
        const isDisabled = disabled ? 'disabled' : '';
        return `
            <button type="button" class="permission-check-item ${activeClass}" ${attr}="${escapeHtml(key)}" data-permission-selected="${isSelected ? '1' : '0'}" ${isDisabled}>
                <span>${escapeHtml(label)}</span>
                <small>${escapeHtml(description)}</small>
            </button>
        `;
    }).join('');
}

function renderPermissions() {
    if (!permissionsBody) {
        return;
    }

    const data = state.permissions || {};
    const entries = Array.isArray(data.entries) ? data.entries : [];
    const canManage = data.canManage === true;
    if (openPermissionAddModalBtn) {
        openPermissionAddModalBtn.disabled = !canManage;
    }

    if (!entries.length) {
        permissionsBody.innerHTML = `<tr><td colspan="8">${escapeHtml(t('permissions_empty_entries', {}, 'Nenhum acesso customizado encontrado.'))}</td></tr>`;
        return;
    }

    permissionsBody.innerHTML = entries.map((entry) => {
        const license = String(valueOr(entry.citzenid, '')).trim();
        const permissions = normalizePermissionFlags(entry.permissions || {});
        const source = Number(entry.source || 0);
        const canManageTarget = permissions.all_permissions === true || permissions.manage_permissions === true;
        const accessLabel = getPermissionAccessLabel(entry.accessType, entry.presetLabel || '');
        const onlineLabel = entry.online ? t('value_yes', {}, 'Sim') : t('value_no', {}, 'Nao');
        const sourceLabel = source > 0 ? String(source) : '-';
        const canEditRow = canManage && entry.editable === true;
        const actionsHtml = canEditRow
            ? `
                <div class="permission-row-actions">
                    <button type="button" data-permission-action="edit" data-permission-license="${escapeHtml(license)}">${escapeHtml(t('permissions_edit_btn', {}, 'Editar'))}</button>
                    <button type="button" data-permission-action="remove" data-permission-license="${escapeHtml(license)}">${escapeHtml(t('permissions_remove_btn', {}, 'Remover'))}</button>
                </div>
            `
            : '-';

        return `
            <tr data-permission-license="${escapeHtml(license)}">
                <td>${escapeHtml(entry.name || t('value_na', {}, 'N/A'))}</td>
                <td>${escapeHtml(sourceLabel)}</td>
                <td>${escapeHtml(license || t('value_na', {}, 'N/A'))}</td>
                <td>${escapeHtml(accessLabel)}</td>
                <td>${permissions.all_permissions ? escapeHtml(t('value_yes', {}, 'Sim')) : escapeHtml(t('value_no', {}, 'Nao'))}</td>
                <td>${canManageTarget ? escapeHtml(t('value_yes', {}, 'Sim')) : escapeHtml(t('value_no', {}, 'Nao'))}</td>
                <td>${escapeHtml(onlineLabel)}</td>
                <td>${actionsHtml}</td>
            </tr>
        `;
    }).join('');
}

function renderPermissionPresetList() {
    if (!permissionPresetList) {
        return;
    }

    const presets = getPermissionPresets();
    const canManage = state.permissions && state.permissions.canManage === true;
    if (!presets.length) {
        permissionPresetList.innerHTML = `<div class="history-empty">${escapeHtml(t('permissions_presets_empty', {}, 'Nenhum preset configurado.'))}</div>`;
        return;
    }

    permissionPresetList.innerHTML = presets.map((preset) => {
        const enabledCount = countEnabledPermissionFlags(preset.permissions || {});
        return `
            <div class="permission-preset-card" data-permission-preset-key="${escapeHtml(preset.key)}">
                <div class="permission-preset-copy">
                    <strong>${escapeHtml(getPermissionPresetLabel(preset))}</strong>
                    <small>${escapeHtml(t('permissions_preset_count', { count: enabledCount }, '{count} permissoes'))}</small>
                </div>
                <button type="button" data-permission-preset-edit="${escapeHtml(preset.key)}" ${canManage ? '' : 'disabled'}>${escapeHtml(t('permissions_edit_btn', {}, 'Editar'))}</button>
            </div>
        `;
    }).join('');
}

function renderPermissionAddModal() {
    const canManage = state.permissions && state.permissions.canManage === true;
    const online = state.permissions && Array.isArray(state.permissions.onlinePlayers) ? state.permissions.onlinePlayers : [];

    if (!permissionAddOnlineList || !permissionAddSelectedInfo) {
        return;
    }

    if (!online.length) {
        permissionAddOnlineList.innerHTML = `<div class="history-empty">${escapeHtml(t('permissions_empty_online', {}, 'Nenhum player online encontrado.'))}</div>`;
        permissionAddSelectedInfo.textContent = t('permissions_select_online_player', {}, 'Selecione um player online.');
        if (permissionAddConfirmBtn) {
            permissionAddConfirmBtn.disabled = true;
        }
        renderPermissionOptions(permissionAddOptions, normalizePermissionFlags(state.permissionAddModal.permissions), 'add', true);
        return;
    }

    const selectedExists = online.some((entry) => Number(entry.source || 0) === Number(state.permissionAddModal.selectedSource || 0));
    if (!selectedExists) {
        state.permissionAddModal.selectedSource = Number(online[0].source || 0);
    }

    permissionAddOnlineList.innerHTML = online.map((entry) => {
        const source = Number(entry.source || 0);
        const active = source === Number(state.permissionAddModal.selectedSource || 0) ? 'active' : '';
        const displayName = String(valueOr(entry.fullname, '')).trim()
            || String(valueOr(entry.name, '')).trim()
            || `ID ${source}`;
        const hasAccess = entry.hasPanelAccess === true
            ? t('permissions_online_has_access', {}, 'Ja possui acesso')
            : t('permissions_online_no_access', {}, 'Sem acesso');
        return `
            <button type="button" class="permission-online-row ${active}" data-permission-add-source="${source}">
                <strong>${escapeHtml(displayName)}</strong>
                <small>ID: ${escapeHtml(String(source))}</small>
                <small>${escapeHtml(hasAccess)}</small>
            </button>
        `;
    }).join('');

    const selected = getOnlinePermissionCandidateBySource(state.permissionAddModal.selectedSource);
    permissionAddSelectedInfo.textContent = selected
        ? `${selected.fullname || selected.name || `ID ${selected.source}`} [${selected.source}]`
        : t('permissions_select_online_player', {}, 'Selecione um player online.');

    renderPermissionPresetSelect(
        permissionAddPresetSelect,
        state.permissionAddModal.presetKey,
        false,
        t('permissions_role_select_placeholder', {}, 'Selecione um cargo')
    );
    const normalizedFlags = normalizePermissionFlags(state.permissionAddModal.permissions || {});
    const presetSelected = !!getPermissionPresetByKey(state.permissionAddModal.presetKey);
    if (permissionAddPresetSelect) {
        permissionAddPresetSelect.disabled = !canManage;
    }
    if (permissionAddAllInput) {
        permissionAddAllInput.checked = normalizedFlags.all_permissions === true;
        permissionAddAllInput.disabled = !canManage || presetSelected;
    }
    renderPermissionOptions(permissionAddOptions, normalizedFlags, 'add', !canManage || presetSelected);

    if (permissionAddConfirmBtn) {
        permissionAddConfirmBtn.disabled = !canManage || !selected || !presetSelected;
    }
}

function renderPermissionEditModal() {
    if (!permissionEditTargetInfo) {
        return;
    }

    const canManage = state.permissions && state.permissions.canManage === true;
    const editable = state.permissionEditModal.editable === true;
    const canEdit = canManage && editable;
    const source = Number(state.permissionEditModal.targetSource || 0);
    const sourceLabel = source > 0 ? String(source) : '-';

    permissionEditTargetInfo.textContent = `ID: ${sourceLabel}`;

    renderPermissionPresetSelect(
        permissionEditPresetSelect,
        state.permissionEditModal.presetKey,
        false,
        t('permissions_role_select_placeholder', {}, 'Selecione um cargo')
    );
    const presetSelected = !!getPermissionPresetByKey(state.permissionEditModal.presetKey);
    if (permissionEditPresetSelect) {
        permissionEditPresetSelect.disabled = !canEdit;
    }

    if (permissionEditSaveBtn) {
        permissionEditSaveBtn.disabled = !canEdit || !state.permissionEditModal.license || !presetSelected;
    }
}

function renderPermissionPresetSelect(element, selectedKey, allowCustom = true, emptyLabel) {
    if (!element) {
        return;
    }

    const options = [];
    options.push(`<option value="">${escapeHtml(emptyLabel || t('permissions_role_custom', {}, 'Custom'))}</option>`);
    getPermissionPresets().forEach((preset) => {
        options.push(`<option value="${escapeHtml(preset.key)}">${escapeHtml(getPermissionPresetLabel(preset))}</option>`);
    });

    element.innerHTML = options.join('');
    element.value = String(valueOr(selectedKey, '')).trim();
    if (!allowCustom && !getPermissionPresetByKey(element.value || '')) {
        element.value = '';
    }
    syncCustomSelect(element);
}

function applyPermissionPresetToMode(mode, presetKey) {
    const preset = getPermissionPresetByKey(presetKey);
    const normalizedPresetKey = preset ? String(valueOr(preset.key, '')).trim() : '';

    if (mode === 'add') {
        state.permissionAddModal.presetKey = normalizedPresetKey;
        state.permissionAddModal.permissions = preset
            ? normalizePermissionFlags(preset.permissions || {})
            : buildEmptyPermissionFlags();
        renderPermissionAddModal();
        return;
    }

    if (mode === 'edit') {
        state.permissionEditModal.presetKey = normalizedPresetKey;
        if (preset) {
            state.permissionEditModal.permissions = normalizePermissionFlags(preset.permissions || {});
        }
        renderPermissionEditModal();
    }
}

function renderPermissionPresetEditModal() {
    const preset = getPermissionPresetByKey(state.permissionPresetEditModal.key);
    if (!preset) {
        return;
    }

    if (permissionPresetEditTargetInfo) {
        permissionPresetEditTargetInfo.textContent = `${getPermissionPresetLabel(preset)} [${preset.key}]`;
    }

    const normalizedFlags = normalizePermissionFlags(state.permissionPresetEditModal.permissions || {});
    if (permissionPresetEditAllInput) {
        permissionPresetEditAllInput.checked = normalizedFlags.all_permissions === true;
    }
    renderPermissionOptions(permissionPresetEditOptions, normalizedFlags, 'preset', false);
    if (permissionPresetEditSaveBtn) {
        permissionPresetEditSaveBtn.disabled = !state.permissionPresetEditModal.key;
    }
}

function openPermissionPresetEditModal(presetKey) {
    const preset = getPermissionPresetByKey(presetKey);
    if (!preset) {
        setStatus(t('permission_preset_invalid', {}, 'Cargo de permissao invalido.'), 'error');
        return;
    }

    state.permissionPresetEditModal.key = preset.key;
    state.permissionPresetEditModal.label = getPermissionPresetLabel(preset);
    state.permissionPresetEditModal.permissions = normalizePermissionFlags(preset.permissions || {});
    renderPermissionPresetEditModal();
    openModal(permissionPresetEditModal, 'permissionPresetEdit');
}

function readPermissionFlagsFromInputs(mode) {
    const allInput = mode === 'add'
        ? permissionAddAllInput
        : mode === 'edit'
            ? permissionEditAllInput
            : permissionPresetEditAllInput;
    const selector = mode === 'add'
        ? '[data-permission-add-key]'
        : mode === 'edit'
            ? '[data-permission-edit-key]'
            : '[data-permission-preset-key]';
    const root = mode === 'add'
        ? permissionAddOptions
        : mode === 'edit'
            ? permissionEditOptions
            : permissionPresetEditOptions;
    const keyAttr = mode === 'add'
        ? 'data-permission-add-key'
        : mode === 'edit'
            ? 'data-permission-edit-key'
            : 'data-permission-preset-key';
    const baseFlags = mode === 'add'
        ? state.permissionAddModal.permissions
        : mode === 'edit'
            ? state.permissionEditModal.permissions
            : state.permissionPresetEditModal.permissions;
    const flags = normalizePermissionFlags(baseFlags || {});
    flags.all_permissions = allInput && allInput.checked === true;

    if (root) {
        root.querySelectorAll(selector).forEach((card) => {
            const key = String(valueOr(card.getAttribute(keyAttr), '')).trim();
            if (key.length) {
                flags[key] = String(valueOr(card.getAttribute('data-permission-selected'), '0')) === '1';
            }
        });
    }

    if (flags.all_permissions) {
        getPermissionDefinitions().forEach((definition) => {
            const key = String(valueOr(definition.key, '')).trim();
            if (key.length) {
                flags[key] = true;
            }
        });
    }

    return flags;
}

function syncPermissionAllToggle(mode) {
    const allInput = mode === 'add' ? permissionAddAllInput : mode === 'edit' ? permissionEditAllInput : permissionPresetEditAllInput;
    const selector = mode === 'add' ? '[data-permission-add-key]' : mode === 'edit' ? '[data-permission-edit-key]' : '[data-permission-preset-key]';
    const root = mode === 'add' ? permissionAddOptions : mode === 'edit' ? permissionEditOptions : permissionPresetEditOptions;
    if (!allInput || !root) {
        return;
    }

    const checked = allInput.checked === true;
    root.querySelectorAll(selector).forEach((card) => {
        card.setAttribute('data-permission-selected', checked ? '1' : '0');
        card.classList.toggle('active', checked);
    });

    if (mode === 'add') {
        state.permissionAddModal.permissions = readPermissionFlagsFromInputs('add');
    } else if (mode === 'edit') {
        state.permissionEditModal.permissions = readPermissionFlagsFromInputs('edit');
    } else {
        state.permissionPresetEditModal.permissions = readPermissionFlagsFromInputs('preset');
    }
}

function syncPermissionIndividualToggle(mode) {
    const allInput = mode === 'add' ? permissionAddAllInput : mode === 'edit' ? permissionEditAllInput : permissionPresetEditAllInput;
    const selector = mode === 'add' ? '[data-permission-add-key]' : mode === 'edit' ? '[data-permission-edit-key]' : '[data-permission-preset-key]';
    const root = mode === 'add' ? permissionAddOptions : mode === 'edit' ? permissionEditOptions : permissionPresetEditOptions;
    if (!allInput || !root) {
        return;
    }

    const list = Array.from(root.querySelectorAll(selector));
    const allChecked = list.length > 0 && list.every((card) => String(valueOr(card.getAttribute('data-permission-selected'), '0')) === '1');
    allInput.checked = allChecked;

    if (mode === 'add') {
        state.permissionAddModal.permissions = readPermissionFlagsFromInputs('add');
    } else if (mode === 'edit') {
        state.permissionEditModal.permissions = readPermissionFlagsFromInputs('edit');
    } else {
        state.permissionPresetEditModal.permissions = readPermissionFlagsFromInputs('preset');
    }
}

function togglePermissionCard(mode, card) {
    if (!card || card.disabled) {
        return;
    }

    const selected = String(valueOr(card.getAttribute('data-permission-selected'), '0')) === '1';
    const nextValue = selected ? '0' : '1';
    card.setAttribute('data-permission-selected', nextValue);
    card.classList.toggle('active', !selected);
    syncPermissionIndividualToggle(mode);
}

function infoCell(label, value) {
    return `<div class="info-item"><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>`;
}

function bankCell(label, value) {
    return `<div class="bank-item"><span>${escapeHtml(label)}</span><strong>${formatMoney(value)}</strong></div>`;
}

function getJobGradeValue(jobData) {
    if (!jobData) {
        return 0;
    }

    const raw = jobData.grade;
    if (typeof raw === 'number' && Number.isFinite(raw)) {
        return Math.floor(raw);
    }

    if (typeof raw === 'string') {
        const parsed = Number(raw);
        return Number.isFinite(parsed) ? Math.floor(parsed) : 0;
    }

    if (raw && typeof raw === 'object') {
        const parsed = Number(raw.level || raw.grade || raw.id || raw.rank || 0);
        return Number.isFinite(parsed) ? Math.floor(parsed) : 0;
    }

    const alt = Number(jobData.gradeLevel || jobData.grade_level || 0);
    return Number.isFinite(alt) ? Math.floor(alt) : 0;
}

function renderMoneyTypeSelect() {
    if (!moneyTypeSelect) {
        return;
    }

    const moneyTypes = getMoneyTypes();
    const currentValue = moneyTypeSelect.value;
    if (!moneyTypes.length) {
        moneyTypeSelect.disabled = true;
        moneyTypeSelect.innerHTML = `<option value="">${escapeHtml(t('empty_no_types', {}, 'Sem tipos'))}</option>`;
        syncCustomSelect(moneyTypeSelect);
        return;
    }

    moneyTypeSelect.disabled = false;
    moneyTypeSelect.innerHTML = moneyTypes.map((entry) => {
        return `<option value="${escapeHtml(entry.key)}">${escapeHtml(entry.label)}</option>`;
    }).join('');

    const hasCurrent = moneyTypes.some((entry) => entry.key === currentValue);
    if (hasCurrent) {
        moneyTypeSelect.value = currentValue;
        syncCustomSelect(moneyTypeSelect);
        return;
    }

    moneyTypeSelect.value = moneyTypes[0].key;
    syncCustomSelect(moneyTypeSelect);
}

function getCatalogItemByName(itemName) {
    return state.catalog.items.find((entry) => entry.name === itemName) || null;
}

function isVisible(element) {
    return !!element && !element.classList.contains('hidden');
}

function syncSupportActionSelection() {
    const selectedPlayer = getSelectedPlayer();
    const hasSelectedPlayer = !!selectedPlayer;

    if (openJobModalBtn) {
        openJobModalBtn.classList.toggle('is-selected', isVisible(jobModal));
        openJobModalBtn.disabled = !hasSelectedPlayer;
    }

    const moneyModalVisible = isVisible(moneyModal);
    const isRemoveMode = state.moneyModal.mode === 'remove';
    const supportAdjustVisible = isVisible(supportAdjustModal);
    const isSlotsMode = state.supportAdjustModal && state.supportAdjustModal.mode === 'slots';

    if (openAddMoneyModalBtn) {
        openAddMoneyModalBtn.classList.toggle('is-selected', moneyModalVisible && !isRemoveMode);
        openAddMoneyModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openRemoveMoneyModalBtn) {
        openRemoveMoneyModalBtn.classList.toggle('is-selected', moneyModalVisible && isRemoveMode);
        openRemoveMoneyModalBtn.disabled = !hasSelectedPlayer;
    }
    if (removeJobBtn) {
        removeJobBtn.disabled = !hasSelectedPlayer;
    }
    if (openItemModalBtn) {
        openItemModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openRenamePlayerModalBtn) {
        openRenamePlayerModalBtn.classList.toggle('is-selected', isVisible(renamePlayerModal));
        openRenamePlayerModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openHeightPlayerModalBtn) {
        openHeightPlayerModalBtn.classList.toggle('is-selected', isVisible(heightPlayerModal));
        openHeightPlayerModalBtn.disabled = !hasSelectedPlayer;
    }
    if (clearInventoryBtn) {
        clearInventoryBtn.disabled = !hasSelectedPlayer;
    }
    if (openAddWeightModalBtn) {
        openAddWeightModalBtn.classList.toggle('is-selected', supportAdjustVisible && !isSlotsMode);
        openAddWeightModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openAddSlotsModalBtn) {
        openAddSlotsModalBtn.classList.toggle('is-selected', supportAdjustVisible && isSlotsMode);
        openAddSlotsModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openMessageModalBtn) {
        openMessageModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openKickModalBtn) {
        openKickModalBtn.disabled = !hasSelectedPlayer;
    }
    if (openBanModalBtn) {
        openBanModalBtn.disabled = !hasSelectedPlayer;
    }
    if (supportSpectateBtn) {
        const spectatingSelected = hasSelectedPlayer
            && Number(state.support.spectateTargetSource || 0) === Number(selectedPlayer.source || 0);
        supportSpectateBtn.classList.toggle('is-selected', spectatingSelected);
        supportSpectateBtn.disabled = !hasSelectedPlayer;
    }
}

function syncItemQueueDockVisibility() {
    if (!itemQueueDock) {
        return;
    }

    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    const hasQueue = queue.length > 0;
    const modalOpen = isVisible(itemModal);
    const confirmOpen = isVisible(itemConfirmModal);
    const shouldShow = hasQueue && modalOpen && !confirmOpen;
    itemQueueDock.classList.toggle('hidden', !shouldShow);
}

function updateItemQueueDockPosition() {
    if (!itemQueueDock || itemQueueDock.classList.contains('hidden')) {
        return;
    }

    const modalBox = itemModal.querySelector('.item-modal-box') || itemModal.querySelector('.modal-box');
    if (!modalBox) {
        return;
    }

    const rect = modalBox.getBoundingClientRect();
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const margin = 12;
    const preferredWidth = 360;
    const minWidth = 240;

    const spaceRight = viewportWidth - rect.right - (margin * 2);
    const spaceLeft = rect.left - (margin * 2);

    let left;
    let width;

    if (spaceRight >= minWidth) {
        width = Math.min(preferredWidth, spaceRight);
        left = rect.right + margin;
    } else if (spaceLeft >= minWidth) {
        width = Math.min(preferredWidth, spaceLeft);
        left = Math.max(margin, rect.left - margin - width);
    } else {
        width = Math.max(minWidth, Math.min(preferredWidth, viewportWidth - (margin * 2)));
        left = Math.max(margin, viewportWidth - width - margin);
    }

    const top = Math.max(margin, rect.top);
    const height = Math.max(240, Math.min(viewportHeight - (margin * 2), rect.height));

    itemQueueDock.style.top = `${top}px`;
    itemQueueDock.style.left = `${left}px`;
    itemQueueDock.style.width = `${width}px`;
    itemQueueDock.style.height = `${height}px`;
}

function renderItemQueue() {
    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    syncItemQueueDockVisibility();
    updateItemQueueDockPosition();

    if (!itemQueueList) {
        return;
    }

    if (!queue.length) {
        itemQueueList.innerHTML = '';
        if (itemQueueWeightTotal) {
            itemQueueWeightTotal.textContent = t('queue_total_weight', { weight: formatKgFromUnits(0) }, 'KG total da lista: {weight}');
            itemQueueWeightTotal.classList.remove('is-insufficient');
        }
        updateItemQueueConfirmButtonState();
        return;
    }

    itemQueueList.innerHTML = queue.map((entry) => {
        const catalogItem = getCatalogItemByName(entry.name);
        const amount = Math.max(1, Math.min(1000, Number(entry.amount || 1)));

        const imageUrl = getItemImageUrl(catalogItem || entry);
        const thumb = imageUrl
            ? `<img class="queue-thumb" src="${escapeHtml(imageUrl)}" alt="${escapeHtml(entry.label)}" onerror="this.style.opacity='0.2'" />`
            : '<div class="queue-thumb"></div>';

        return `
            <div class="queue-row" data-queue-item="${escapeHtml(entry.name)}">
                ${thumb}
                <div class="queue-name">${escapeHtml(entry.label)}</div>
                <input
                    type="number"
                    class="queue-amount-input"
                    data-queue-amount-input
                    min="1"
                    max="1000"
                    step="1"
                    value="${amount}"
                />
                <button type="button" class="queue-remove-btn" data-queue-action="remove">${escapeHtml(t('queue_remove', {}, 'Remover'))}</button>
            </div>
        `;
    }).join('');

    updateItemQueueConfirmButtonState();
}

function getQueueRequiredWeight() {
    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    if (!queue.length) {
        return 0;
    }

    return queue.reduce((total, entry) => {
        const catalogItem = getCatalogItemByName(entry.name);
        const itemWeight = Number(catalogItem && catalogItem.weight ? catalogItem.weight : 0);
        const amount = Math.max(1, Number(entry.amount || 1));
        return total + (itemWeight * amount);
    }, 0);
}

function buildLocalItemCapacityData() {
    const player = getSelectedPlayer();
    const inventory = (player && player.inventory) || {};
    const maxWeight = Number(inventory.maxWeight || 0);
    const usedWeight = Number(inventory.usedWeight || 0);
    const freeWeightRaw = Number(inventory.freeWeight);
    const freeWeight = Number.isFinite(freeWeightRaw) ? freeWeightRaw : Math.max(0, maxWeight - usedWeight);
    const requiredWeight = Number(getQueueRequiredWeight() || 0);
    const hasEnough = freeWeight >= requiredWeight;

    return {
        maxWeight,
        usedWeight,
        freeWeight,
        requiredWeight,
        remainingWeight: Math.max(0, freeWeight - requiredWeight),
        hasEnough
    };
}

function updateItemQueueWeightIndicator(capacityData) {
    if (!itemQueueWeightTotal) {
        return;
    }

    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    if (!queue.length) {
        itemQueueWeightTotal.textContent = t('queue_total_weight', { weight: formatKgFromUnits(0) }, 'KG total da lista: {weight}');
        itemQueueWeightTotal.classList.remove('is-insufficient');
        return;
    }

    const requiredWeight = Number(getQueueRequiredWeight() || 0);
    const localData = buildLocalItemCapacityData();
    const freeWeightRaw = capacityData && Number.isFinite(Number(capacityData.freeWeight))
        ? Number(capacityData.freeWeight)
        : Number(localData.freeWeight || 0);
    const freeWeight = Math.max(0, freeWeightRaw);
    const isInsufficient = requiredWeight > freeWeight;

    const textKey = isInsufficient ? 'queue_total_weight_insufficient' : 'queue_total_weight_with_free';
    const textFallback = isInsufficient
        ? 'KG total da lista: {weight} | KG livre: {free} - Peso insuficiente'
        : 'KG total da lista: {weight} | KG livre: {free}';
    itemQueueWeightTotal.textContent = t(textKey, {
        weight: formatKgFromUnits(requiredWeight),
        free: formatKgFromUnits(freeWeight)
    }, textFallback);

    itemQueueWeightTotal.classList.toggle('is-insufficient', isInsufficient);
}

function updateItemQueueConfirmButtonState(capacityData) {
    if (!itemQueueConfirmBtn) {
        return;
    }

    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    if (!queue.length || !getSelectedPlayer()) {
        itemQueueConfirmBtn.disabled = true;
        itemQueueConfirmBtn.classList.remove('is-insufficient');
        updateItemQueueWeightIndicator(null);
        return;
    }

    const data = capacityData && typeof capacityData === 'object' ? capacityData : buildLocalItemCapacityData();
    const insufficient = data.hasEnough !== true;
    itemQueueConfirmBtn.disabled = insufficient;
    itemQueueConfirmBtn.classList.toggle('is-insufficient', insufficient);
    itemQueueConfirmBtn.title = insufficient
        ? t('status_capacity_insufficient_title', {}, 'Peso insuficiente')
        : '';
    updateItemQueueWeightIndicator(data);
}

function renderItemCapacityStatus(capacityData) {
    if (!itemCapacityStatus) {
        return;
    }

    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    if (!queue.length) {
        state.itemModal.lastCapacity = null;
        itemCapacityStatus.innerHTML = '';
        if (itemConfirmSendBtn) {
            itemConfirmSendBtn.disabled = true;
            itemConfirmSendBtn.classList.remove('is-insufficient');
        }
        updateItemQueueConfirmButtonState();
        return;
    }

    const data = capacityData && typeof capacityData === 'object' ? capacityData : buildLocalItemCapacityData();
    state.itemModal.lastCapacity = data;
    const hasEnough = data.hasEnough === true;

    if (hasEnough) {
        itemCapacityStatus.innerHTML = '';
    } else {
        itemCapacityStatus.innerHTML = `
            <div class="capacity-result fail">
                <strong>${escapeHtml(t('status_capacity_insufficient_title', {}, 'Peso insuficiente'))}</strong>
                <span>${escapeHtml(t('status_capacity_insufficient_detail', {
                    required: formatKgFromUnits(data.requiredWeight),
                    free: formatKgFromUnits(data.freeWeight)
                }, 'Necessario: {required} | Disponivel: {free}'))}</span>
            </div>
        `;
    }

    if (itemConfirmSendBtn) {
        itemConfirmSendBtn.disabled = state.itemModal.sending || !hasEnough;
        itemConfirmSendBtn.classList.toggle('is-insufficient', !hasEnough);
    }

    updateItemQueueConfirmButtonState(data);
}

function renderItemConfirmationList() {
    const queue = Array.isArray(state.itemModal.queue) ? state.itemModal.queue : [];
    if (!itemConfirmList) {
        return;
    }

    if (!queue.length) {
        itemConfirmList.innerHTML = '';
        renderItemCapacityStatus(null);
        return;
    }

    itemConfirmList.innerHTML = queue.map((entry) => {
        const catalogItem = getCatalogItemByName(entry.name);
        const imageUrl = getItemImageUrl(catalogItem || entry);
        const thumb = imageUrl
            ? `<img class="queue-thumb" src="${escapeHtml(imageUrl)}" alt="${escapeHtml(entry.label)}" onerror="this.style.opacity='0.2'" />`
            : '<div class="queue-thumb"></div>';

        return `
            <div class="confirm-row">
                ${thumb}
                <div class="confirm-name">${escapeHtml(entry.label)}</div>
                <strong class="confirm-amount">x${Number(entry.amount || 1)}</strong>
            </div>
        `;
    }).join('');

    renderItemCapacityStatus(state.itemModal.lastCapacity);
}

function renderMoneyModalInfo() {
    return;
}

function renderSupportAdjustModalInfo() {
    const player = getSelectedPlayer();
    const mode = state.supportAdjustModal && state.supportAdjustModal.mode === 'slots' ? 'slots' : 'weight';
    const inventory = player && player.inventory && typeof player.inventory === 'object' ? player.inventory : {};
    const isSlots = mode === 'slots';

    if (supportAdjustModalTitle) {
        supportAdjustModalTitle.textContent = isSlots
            ? t('modal_add_slots_title', {}, 'Adicionar Slots')
            : t('modal_add_weight_title', {}, 'Adicionar Peso');
    }

    if (supportAdjustAmountLabel) {
        supportAdjustAmountLabel.textContent = isSlots
            ? t('modal_slots_amount_label', {}, 'Quantidade de Slots')
            : t('modal_weight_amount_label', {}, 'Quantidade de Peso');
    }

    if (supportAdjustModalApplyBtn) {
        supportAdjustModalApplyBtn.textContent = isSlots
            ? t('modal_add_slots_apply', {}, 'Adicionar Slots')
            : t('modal_add_weight_apply', {}, 'Adicionar Peso');
    }

    if (supportAdjustAmountInput) {
        supportAdjustAmountInput.step = '1';
        supportAdjustAmountInput.min = '1';
        supportAdjustAmountInput.placeholder = isSlots ? '10' : '10000';
    }

    if (!supportAdjustModalInfo) {
        return;
    }

    if (!player) {
        supportAdjustModalInfo.textContent = t('status_select_player', {}, 'Selecione um jogador primeiro.');
        return;
    }

    supportAdjustModalInfo.textContent = isSlots
        ? t('modal_add_slots_info', {
            current: formatInteger(valueOr(inventory.maxSlots, 0)),
            free: formatInteger(valueOr(inventory.freeSlots, 0))
        }, 'Atual: {current} slots | Livres: {free} slots')
        : t('modal_add_weight_info', {
            current: formatKgFromUnits(valueOr(inventory.maxWeight, 0)),
            free: formatKgFromUnits(valueOr(inventory.freeWeight, 0))
        }, 'Atual: {current} | Livre: {free}');
}

function renderMessageModalInfo() {
    return;
}

function renderKickModalInfo() {
    return;
}

function getSelectedPlayerNameParts() {
    const player = getSelectedPlayer();
    if (!player) {
        return {
            firstName: '',
            lastName: ''
        };
    }

    const firstName = String(valueOr(player.firstname, valueOr(player.firstName, ''))).trim();
    const lastName = String(valueOr(player.lastname, valueOr(player.lastName, ''))).trim();
    if (firstName || lastName) {
        return {
            firstName,
            lastName
        };
    }

    const fullName = String(valueOr(player.fullname, '')).trim();
    if (!fullName.length) {
        return {
            firstName: '',
            lastName: ''
        };
    }

    const parts = fullName.split(/\s+/).filter(Boolean);
    return {
        firstName: parts[0] || '',
        lastName: parts.slice(1).join(' ')
    };
}

function renderRenamePlayerModalInfo() {
    if (!renamePlayerModalInfo) {
        return;
    }

    const player = getSelectedPlayer();
    if (!player) {
        renamePlayerModalInfo.textContent = t('status_select_player', {}, 'Selecione um jogador primeiro.');
        return;
    }

    renamePlayerModalInfo.textContent = t('modal_rename_player_info', {
        player: getSelectedPlayerIdentityLabel()
    }, 'A troca atualiza o banco de dados do personagem. O jogador sera kickado automaticamente para relogar com o novo nome.');
}

function formatHeightValue(value) {
    const parsed = Number(value || 0);
    if (!Number.isFinite(parsed)) {
        return '0';
    }

    const rounded = Math.round(parsed * 10) / 10;
    return Number.isInteger(rounded) ? String(rounded) : rounded.toFixed(1);
}

function getHeightPresetLabel(presetValue) {
    const preset = PLAYER_HEIGHT_PRESETS.find((entry) => entry.value === presetValue) || null;
    if (!preset) {
        return presetValue;
    }

    return t(preset.labelKey, {}, preset.fallback);
}

function renderHeightPlayerPresetOptions(selectedValue = '100') {
    if (!heightPlayerPresetGrid) {
        return;
    }

    const normalizedSelected = String(valueOr(selectedValue, '100')).trim() || '100';
    heightPlayerPresetGrid.innerHTML = PLAYER_HEIGHT_PRESETS.map((entry) => {
        const selected = entry.value === normalizedSelected ? ' is-selected' : '';
        return `<button type="button" class="height-preset-card${selected}" data-height-preset="${escapeHtml(entry.value)}">${escapeHtml(t(entry.labelKey, {}, entry.fallback))}</button>`;
    }).join('');
}

function syncHeightPlayerCustomInput() {
    if (!heightPlayerCustomInput) {
        return;
    }

    const presetValue = String(valueOr(state.heightPlayerModal.preset, '100')).trim() || '100';
    const isCustom = presetValue === 'custom';
    heightPlayerCustomInput.disabled = !isCustom;
    if (!isCustom) {
        heightPlayerCustomInput.value = presetValue;
    }
}

function renderHeightPlayerModalInfo() {
    if (!heightPlayerModalInfo) {
        return;
    }

    const player = getSelectedPlayer();
    if (!player) {
        heightPlayerModalInfo.textContent = t('status_select_player', {}, 'Selecione um jogador primeiro.');
        return;
    }

    heightPlayerModalInfo.textContent = t('modal_change_height_info', {
        player: getSelectedPlayerIdentityLabel()
    }, 'A altura sera atualizada no banco de dados da aparencia. O jogador sera removido em 5 segundos e precisara relogar.');
}

function openHeightPlayerModal() {
    logModalDebug('openHeightPlayerModal:request', {
        selectedSource: state.selectedSource
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_change_height', {}, 'Selecione um jogador para alterar a altura.'), 'warn');
        return;
    }

    state.heightPlayerModal.preset = '100';
    renderHeightPlayerPresetOptions(state.heightPlayerModal.preset);
    if (heightPlayerCustomInput) {
        heightPlayerCustomInput.value = '100';
    }
    syncHeightPlayerCustomInput();
    renderHeightPlayerModalInfo();
    openModal(heightPlayerModal, 'changeHeight');
}

function getBanModalSelectionInfo() {
    const selectedDuration = String(valueOr(state.banModal.mode, banModeSelect ? banModeSelect.value : '1')).trim() || '1';
    const isPermanent = selectedDuration === 'permanent';
    const banAmount = isPermanent ? 0 : Math.max(1, Number(selectedDuration || 1));
    let typeLabel = t('modal_ban_type_permanent', {}, 'Permanente');
    let summary = t('modal_ban_summary_permanent', {}, 'Banimento permanente');

    if (!isPermanent) {
        const days = banAmount;
        typeLabel = t('modal_ban_type_temporary', {}, 'Temporario (dias)');
        summary = t('modal_ban_summary_days', { days }, '{days} dia(s)');
    }

    return {
        selectedDuration,
        isPermanent,
        banAmount,
        typeLabel,
        summary
    };
}

function renderBanModalInfo() {
    if (!banModalTypeLabel || !banModalSummary) {
        return;
    }

    const selection = getBanModalSelectionInfo();

    banModalTypeLabel.textContent = selection.typeLabel;
    banModalSummary.textContent = selection.summary;
}

function renderBanModeSelect() {
    if (!banModeSelect) {
        return;
    }

    const durations = getBanDurations();
    if (!durations.length) {
        const dayLabel = (days) => days === 1
            ? t('modal_ban_summary_days', { days }, '{days} dia(s)')
            : t('modal_ban_summary_days', { days }, '{days} dia(s)');
        banModeSelect.innerHTML = `
            <option value="1">${escapeHtml(dayLabel(1))}</option>
            <option value="2">${escapeHtml(dayLabel(2))}</option>
            <option value="3">${escapeHtml(dayLabel(3))}</option>
            <option value="7">${escapeHtml(dayLabel(7))}</option>
            <option value="15">${escapeHtml(dayLabel(15))}</option>
            <option value="30">${escapeHtml(dayLabel(30))}</option>
            <option value="permanent">${escapeHtml(t('modal_ban_type_permanent', {}, 'Permanente'))}</option>
        `;
        state.banModal.mode = banModeSelect.value || '1';
        syncCustomSelect(banModeSelect);
        return;
    }

    const current = banModeSelect.value || state.banModal.mode || '1';
    banModeSelect.innerHTML = durations.map((entry) => {
        const value = String(valueOr(entry.value, ''));
        const label = String(valueOr(entry.label, value));
        return `<option value="${escapeHtml(value)}">${escapeHtml(label)}</option>`;
    }).join('');

    const valid = durations.some((entry) => String(entry.value) === current);
    if (valid) {
        banModeSelect.value = current;
    } else {
        banModeSelect.value = String(durations[0].value);
    }

    state.banModal.mode = banModeSelect.value || '1';
    syncCustomSelect(banModeSelect);
}

function renderEditBanModeSelect() {
    if (!editBanModeSelect) {
        return;
    }

    const durations = getBanDurations();
    if (!durations.length) {
        editBanModeSelect.innerHTML = `
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="7">7</option>
            <option value="15">15</option>
            <option value="30">30</option>
            <option value="permanent">${escapeHtml(t('modal_ban_type_permanent', {}, 'Permanente'))}</option>
        `;
    } else {
        editBanModeSelect.innerHTML = durations.map((entry) => {
            const value = String(valueOr(entry.value, ''));
            const label = String(valueOr(entry.label, value));
            return `<option value="${escapeHtml(value)}">${escapeHtml(label)}</option>`;
        }).join('');
    }

    const desired = state.editBanModal.mode || '1';
    const hasDesired = Array.from(editBanModeSelect.options || []).some((opt) => opt.value === desired);
    editBanModeSelect.value = hasDesired ? desired : (editBanModeSelect.options[0] ? editBanModeSelect.options[0].value : '1');
    state.editBanModal.mode = editBanModeSelect.value || '1';
    syncCustomSelect(editBanModeSelect);
}

function renderEditBanModalInfo() {
    if (!editBanCurrentInfo) {
        return;
    }

    const banEntry = getBannedPlayerById(state.editBanModal.banId);
    if (!banEntry) {
        editBanCurrentInfo.textContent = t('value_na', {}, 'N/A');
        return;
    }

    editBanCurrentInfo.textContent = `ID Ban: ${banEntry.id || 0} | ${t('banned_th_expire', {}, 'Expira em')}: ${banEntry.expiresLabel || t('value_na', {}, 'N/A')}`;
}

function getFilteredCompanyStashes() {
    const rows = Array.isArray(state.catalog.companyStashes) ? state.catalog.companyStashes : [];
    const query = state.companyStashModal.search.trim().toLowerCase();
    if (!query) {
        return rows;
    }

    return rows.filter((entry) => {
        const blob = `${valueOr(entry.label, '')} ${valueOr(entry.job, '')} ${valueOr(entry.stashName, '')}`.toLowerCase();
        return blob.includes(query);
    });
}

function renderCompanyStashModalInfo() {
    if (!companyStashCurrentInfo) {
        return;
    }

    const stashName = String(valueOr(state.companyStashModal.selectedStashName, '')).trim();
    if (!stashName.length) {
        companyStashCurrentInfo.textContent = t('status_company_stash_select', {}, 'Selecione um bau de empresa.');
        return;
    }

    const selected = (state.catalog.companyStashes || []).find((entry) => String(valueOr(entry.stashName, '')).trim() === stashName);
    if (!selected) {
        companyStashCurrentInfo.textContent = t('status_company_stash_select', {}, 'Selecione um bau de empresa.');
        return;
    }

    companyStashCurrentInfo.textContent = `${t('modal_selected_label', {}, 'Selecionado')}: ${selected.label || selected.stashName || '-'}`;
}

function renderCompanyStashModalList() {
    if (!companyStashModalList) {
        return;
    }

    const rows = getFilteredCompanyStashes();
    if (!rows.length) {
        companyStashModalList.innerHTML = `<div class="modal-card"><strong>${escapeHtml(t('empty_no_company_stash', {}, 'Nenhum bau de empresa encontrado.'))}</strong></div>`;
        renderCompanyStashModalInfo();
        return;
    }

    companyStashModalList.innerHTML = rows.map((entry) => {
        const stashName = String(valueOr(entry.stashName, '')).trim();
        const active = stashName === state.companyStashModal.selectedStashName ? 'active' : '';
        return `
            <button type="button" class="modal-card ${active}" data-company-stash-name="${escapeHtml(stashName)}">
                <strong>${escapeHtml(entry.label || stashName)}</strong>
                <small>${escapeHtml(t('history_source_label', {}, 'Origem'))}: ${escapeHtml(entry.job || '-')} | ${escapeHtml(stashName)}</small>
            </button>
        `;
    }).join('');

    renderCompanyStashModalInfo();
}

function getAdminHorseRows() {
    return Array.isArray(state.catalog.adminHorses) ? state.catalog.adminHorses : [];
}

function renderHorseModalInfo() {
    if (!horseModalCurrentInfo) {
        return;
    }

    const selectedId = String(valueOr(state.horseModal.selectedHorseId, '')).trim();
    if (!selectedId.length) {
        horseModalCurrentInfo.textContent = t('status_horse_select', {}, 'Selecione um cavalo.');
        return;
    }

    const selected = getAdminHorseRows().find((entry) => String(valueOr(entry.id, '')).trim() === selectedId);
    if (!selected) {
        horseModalCurrentInfo.textContent = t('status_horse_select', {}, 'Selecione um cavalo.');
        return;
    }

    horseModalCurrentInfo.textContent = `${t('modal_selected_label', {}, 'Selecionado')}: ${selected.label || selected.model || '-'}`;
}

function renderHorseModalList() {
    if (!horseModalList) {
        return;
    }

    const rows = getAdminHorseRows();
    if (!rows.length) {
        horseModalList.innerHTML = `<div class="modal-card"><strong>${escapeHtml(t('status_horse_catalog_empty', {}, 'Catalogo de cavalos vazio.'))}</strong></div>`;
        renderHorseModalInfo();
        return;
    }

    horseModalList.innerHTML = rows.map((entry) => {
        const horseId = String(valueOr(entry.id, '')).trim();
        const active = horseId === String(valueOr(state.horseModal.selectedHorseId, '')).trim() ? 'active' : '';
        const label = String(valueOr(entry.label, horseId)).trim() || horseId;
        const model = String(valueOr(entry.model, '')).trim();
        return `
            <button type="button" class="modal-card horse-card ${active}" data-horse-id="${escapeHtml(horseId)}">
                <strong>${escapeHtml(label)}</strong>
                <small>${escapeHtml(model)}</small>
            </button>
        `;
    }).join('');

    renderHorseModalInfo();
}

function renderSupportDetails() {
    if (!selectedInfoGrid || !banksGrid) {
        return;
    }

    const player = getSelectedPlayer();
    actionButtons.forEach((button) => {
        button.disabled = !player;
    });
    syncSupportActionSelection();

    if (!player) {
        selectedInfoGrid.innerHTML = `<div class="info-item"><span>${escapeHtml(t('field_status', {}, 'Status'))}</span><strong>${escapeHtml(t('field_select_player', {}, 'Selecione um jogador'))}</strong></div>`;
        banksGrid.innerHTML = `<div class="bank-item"><span>${escapeHtml(t('field_banks', {}, 'Bancos'))}</span><strong>0</strong></div>`;
        if (isVisible(moneyModal)) {
            renderMoneyModalInfo();
        }
        if (isVisible(messageModal)) {
            renderMessageModalInfo();
        }
        if (isVisible(kickModal)) {
            renderKickModalInfo();
        }
        return;
    }

    const coords = player.coords ? `${player.coords.x}, ${player.coords.y}, ${player.coords.z}` : t('value_na', {}, 'N/A');
    const money = player.money || {};
    const jobData = player.job || {};
    const metadata = player.metadata || {};
    const inventory = player.inventory || {};
    const moneyTypes = getMoneyTypes();
    const gradeValue = getJobGradeValue(jobData);
    const gradeDisplay = jobData.gradeName ? `${gradeValue} - ${jobData.gradeName}` : String(gradeValue);
    const multijobTotal = Array.isArray(player.jobs) ? player.jobs.length : 0;

    selectedInfoGrid.innerHTML = [
        infoCell(t('field_name', {}, 'Nome'), player.fullname || t('value_na', {}, 'N/A')),
        infoCell(t('field_id', {}, 'ID'), player.source),
        infoCell(t('field_citizenid', {}, 'Citizenid'), player.citizenid || t('value_na', {}, 'N/A')),
        infoCell(t('field_job', {}, 'Job'), jobData.name || t('value_na', {}, 'N/A')),
        infoCell(t('field_grade', {}, 'Grade'), gradeDisplay),
        infoCell(t('field_duty', {}, 'Duty'), jobData.onduty ? t('value_on', {}, 'ON') : t('value_off', {}, 'OFF')),
        infoCell(t('field_player_status', {}, 'Status'), metadata.isdead ? t('value_dead', {}, 'Morto') : t('value_alive', {}, 'Vivo')),
        infoCell(t('field_freeze', {}, 'Freeze'), player.frozen ? t('value_yes', {}, 'Sim') : t('value_no', {}, 'Nao')),
        infoCell(t('field_ping', {}, 'Ping'), valueOr(player.ping, 0)),
        infoCell(t('field_coords', {}, 'Coords'), coords),
        infoCell(t('field_hunger', {}, 'Fome'), valueOr(metadata.hunger, 0)),
        infoCell(t('field_thirst', {}, 'Sede'), valueOr(metadata.thirst, 0)),
        infoCell(t('field_height', {}, 'Altura'), player.height != null ? formatHeightValue(player.height) : t('value_na', {}, 'N/A')),
        infoCell(t('field_kg_total', {}, 'KG Total'), formatKgFromUnits(valueOr(inventory.maxWeight, 0))),
        infoCell(t('field_kg_free', {}, 'KG Livre'), formatKgFromUnits(valueOr(inventory.freeWeight, 0))),
        infoCell(t('field_slots_total', {}, 'Slots Totais'), formatInteger(valueOr(inventory.maxSlots, 0))),
        infoCell(t('field_slots_free', {}, 'Slots Livres'), formatInteger(valueOr(inventory.freeSlots, 0))),
        infoCell(t('field_multijob_total', {}, 'Multijob'), multijobTotal)
    ].join('');

    const bankRows = moneyTypes
        .filter((entry) => String(valueOr(entry && entry.key, '')).toLowerCase() !== 'cash')
        .map((entry) => {
            const value = Number(money[entry.key] || 0);
            return bankCell(entry.label, value);
        });

    banksGrid.innerHTML = bankRows.length
        ? bankRows.join('')
        : `<div class="bank-item"><span>${escapeHtml(t('field_banks', {}, 'Bancos'))}</span><strong>0</strong></div>`;

    if (isVisible(moneyModal)) {
        renderMoneyModalInfo();
    }
    if (isVisible(messageModal)) {
        renderMessageModalInfo();
    }
    if (isVisible(kickModal)) {
        renderKickModalInfo();
    }
    if (isVisible(supportAdjustModal)) {
        renderSupportAdjustModalInfo();
    }
}

function renderAll() {
    applyPermissionVisibility();
    updateSupportAccess();
    renderMoneyTypeSelect();
    renderDashboard();
    renderPlayers();
    renderBannedPlayers();
    renderPermissions();
    renderPermissionPresetList();
    renderDeveloperCharacterPanel();
    renderSupportDetails();
    updateItemQueueConfirmButtonState();
    if (isVisible(itemConfirmModal)) {
        renderItemConfirmationList();
    }
    if (isVisible(permissionAddModal)) {
        renderPermissionAddModal();
    }
    if (isVisible(permissionEditModal)) {
        renderPermissionEditModal();
    }
    if (isVisible(permissionRemoveConfirmModal)) {
        renderPermissionRemoveConfirmModal();
    }
    if (isVisible(permissionPresetEditModal)) {
        renderPermissionPresetEditModal();
    }
}

function applyPayload(payload) {
    if (!payload || payload.ok !== true) {
        return;
    }

    applyLocalePayload(payload.locale);
    applyStaticTranslations();

    state.dashboard = payload.dashboard || {};
    state.players = Array.isArray(payload.players) ? payload.players : [];
    state.bannedPlayers = Array.isArray(payload.bannedPlayers) ? payload.bannedPlayers : [];
    const payloadPermissions = payload.permissions || {};
    state.permissions.entries = Array.isArray(payloadPermissions.entries) ? payloadPermissions.entries : [];
    state.permissions.onlinePlayers = Array.isArray(payloadPermissions.onlinePlayers) ? payloadPermissions.onlinePlayers : [];
    state.permissions.canManage = payloadPermissions.canManage === true;
    const payloadSelf = payloadPermissions.self && typeof payloadPermissions.self === 'object' ? payloadPermissions.self : {};
    state.permissions.self = {
        role: String(valueOr(payloadSelf.role, '')),
        roleLabel: String(valueOr(payloadSelf.roleLabel, '')),
        permissions: payloadSelf.permissions && typeof payloadSelf.permissions === 'object' ? payloadSelf.permissions : {}
    };
    const payloadCatalog = payload.catalog || {};
    state.catalog.jobs = Array.isArray(payloadCatalog.jobs) ? payloadCatalog.jobs : [];
    state.catalog.items = Array.isArray(payloadCatalog.items) ? payloadCatalog.items : [];
    state.catalog.moneyTypes = Array.isArray(payloadCatalog.moneyTypes) ? payloadCatalog.moneyTypes : [];
    state.catalog.banDurations = Array.isArray(payloadCatalog.banDurations) ? payloadCatalog.banDurations : [];
    state.catalog.companyStashes = Array.isArray(payloadCatalog.companyStashes) ? payloadCatalog.companyStashes : [];
    state.catalog.adminHorses = Array.isArray(payloadCatalog.adminHorses) ? payloadCatalog.adminHorses : [];
    state.catalog.builtInTeleports = Array.isArray(payloadCatalog.builtInTeleports) ? payloadCatalog.builtInTeleports : [];
    state.catalog.permissionDefinitions = Array.isArray(payloadCatalog.permissionDefinitions) ? payloadCatalog.permissionDefinitions : [];
    state.catalog.permissionPresets = Array.isArray(payloadCatalog.permissionPresets) ? payloadCatalog.permissionPresets : [];

    if (!state.players.some((player) => player.source === state.selectedSource)) {
        state.selectedSource = null;
        state.supportUnlocked = false;
    }
    if (!state.players.some((player) => Number(player.source || 0) === Number(state.support.spectateTargetSource || 0))) {
        state.support.spectateTargetSource = 0;
    }

    if (!state.catalog.companyStashes.some((entry) => String(valueOr(entry.stashName, '')).trim() === String(valueOr(state.companyStashModal.selectedStashName, '')).trim())) {
        state.companyStashModal.selectedStashName = null;
    }
    if (!state.catalog.adminHorses.some((entry) => String(valueOr(entry.id, '')).trim() === String(valueOr(state.horseModal.selectedHorseId, '')).trim())) {
        state.horseModal.selectedHorseId = null;
    }
    if (!state.permissions.onlinePlayers.some((entry) => Number(entry.source || 0) === Number(state.permissionAddModal.selectedSource || 0))) {
        state.permissionAddModal.selectedSource = null;
    }
    if (!state.permissions.entries.some((entry) => String(valueOr(entry.citzenid, '')).trim() === String(valueOr(state.permissionEditModal.license, '')).trim())) {
        state.permissionEditModal.license = '';
    }
    if (!state.permissions.entries.some((entry) => String(valueOr(entry.citzenid, '')).trim() === String(valueOr(state.permissionRemoveModal.license, '')).trim())) {
        state.permissionRemoveModal.license = '';
    }
    if (isVisible(companyStashModal)) {
        renderCompanyStashModalList();
    }
    if (isVisible(horseModal)) {
        renderHorseModalList();
    }
    if (isVisible(permissionAddModal)) {
        renderPermissionAddModal();
    }
    if (isVisible(permissionEditModal)) {
        if (state.permissionEditModal.license) {
            const entry = getPermissionEntryByLicense(state.permissionEditModal.license);
            if (entry) {
                state.permissionEditModal.targetSource = Number(entry.source || 0);
                state.permissionEditModal.name = entry.name || '';
                state.permissionEditModal.accessType = entry.accessType || 'custom';
                state.permissionEditModal.presetKey = entry.presetKey || '';
                state.permissionEditModal.editable = entry.editable === true;
                state.permissionEditModal.permissions = normalizePermissionFlags(entry.permissions || {});
            }
            renderPermissionEditModal();
        } else {
            closeModal(permissionEditModal);
        }
    }
    if (isVisible(jobModal)) {
        renderJobModalList();
        renderJobModalGrades();
        renderJobModalMultijob();
    }
    if (isVisible(permissionRemoveConfirmModal)) {
        if (state.permissionRemoveModal.license) {
            renderPermissionRemoveConfirmModal();
        } else {
            closeModal(permissionRemoveConfirmModal);
        }
    }
    if (isVisible(permissionPresetEditModal)) {
        if (getPermissionPresetByKey(state.permissionPresetEditModal.key)) {
            const preset = getPermissionPresetByKey(state.permissionPresetEditModal.key);
            state.permissionPresetEditModal.label = preset.label || preset.key;
            state.permissionPresetEditModal.permissions = normalizePermissionFlags(preset.permissions || {});
            renderPermissionPresetEditModal();
        } else {
            closeModal(permissionPresetEditModal);
        }
    }
    if (isVisible(banModal)) {
        renderBanModeSelect();
        renderBanModalInfo();
    }
    if (isVisible(editBanModal)) {
        if (getBannedPlayerById(state.editBanModal.banId)) {
            renderEditBanModeSelect();
            renderEditBanModalInfo();
        } else {
            closeModal(editBanModal);
        }
    }

    renderAll();
}

async function executeAction(action, extra = {}, options = {}) {
    const silentSuccess = options.silentSuccess === true;
    const silentError = options.silentError === true;

    if (state.selectedSource === null) {
        if (!silentError) {
            setStatus(t('status_select_player', {}, 'Selecione um jogador primeiro.'), 'error');
        }
        return { ok: false };
    }

    if (action === 'openInventory') {
        try {
            const fastResult = await postNui('openInventoryFast', {
                targetSource: state.selectedSource,
                ...extra
            });

            if (!fastResult || fastResult.ok !== true) {
                if (!silentError) {
                    setStatus((fastResult && fastResult.message) || t('status_open_inventory_fail', {}, 'Falha ao abrir inventario.'), 'error');
                }
                return { ok: false, result: fastResult };
            }

            return { ok: true, result: fastResult };
        } catch (_error) {
            if (!silentError) {
                setStatus(t('status_game_comm_fail', {}, 'Falha de comunicacao com o jogo.'), 'error');
            }
            return { ok: false };
        }
    }

    const payload = {
        action,
        targetSource: state.selectedSource,
        ...extra
    };

    try {
        const result = await postNui('performAction', payload);
        if (!result || result.ok !== true) {
            if (!silentError) {
                setStatus((result && result.message) || t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
            }
            return { ok: false, result };
        }

        if (action === 'spectate') {
            const target = Number(payload.targetSource || 0);
            if (Number(state.support.spectateTargetSource || 0) === target) {
                state.support.spectateTargetSource = 0;
            } else {
                state.support.spectateTargetSource = target;
            }
            syncSupportActionSelection();
        }

        if (!silentSuccess) {
            setStatus(result.message || t('status_action_success', {}, 'Acao executada.'), 'ok');
        }
        return { ok: true, result };
    } catch (_error) {
        if (!silentError) {
            setStatus(t('status_game_comm_fail', {}, 'Falha de comunicacao com o jogo.'), 'error');
        }
        return { ok: false };
    }
}

async function executeGlobalAction(action, extra = {}, options = {}) {
    const silentSuccess = options.silentSuccess === true;
    const silentError = options.silentError === true;
    const payload = {
        action,
        ...extra
    };

    try {
        const result = await postNui('performAction', payload);
        if (!result || result.ok !== true) {
            if (!silentError) {
                setStatus((result && result.message) || t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
            }
            return { ok: false, result };
        }

        if (!silentSuccess) {
            setStatus(result.message || t('status_action_success', {}, 'Acao executada.'), 'ok');
        }
        return { ok: true, result };
    } catch (_error) {
        if (!silentError) {
            setStatus(t('status_game_comm_fail', {}, 'Falha de comunicacao com o jogo.'), 'error');
        }
        return { ok: false };
    }
}

async function searchDeveloperCharacterByCitizenid() {
    const citizenid = String(valueOr(state.developerCharacter.citizenid, '')).trim();
    if (!citizenid.length) {
        setStatus(t('developer_status_citizenid_required', {}, 'Informe uma citizenid para procurar.'), 'warn');
        return;
    }

    const permissionCheck = await canExecutePanelAction('deleteCharacterByCitizenid');
    if (!permissionCheck.ok) {
        setStatus(permissionCheck.message || t('permission_action_denied_specific', {}, 'Sem permissao para executar esta acao.'), 'error');
        return;
    }

    const response = await executeGlobalAction('findCharacterByCitizenid', { citizenid }, { silentSuccess: true });
    if (!response.ok) {
        state.developerCharacter.lookup = null;
        state.developerCharacter.selectedCitizenid = '';
        renderDeveloperCharacterPanel();
        return;
    }

    state.developerCharacter.lookup = response.result && response.result.data && typeof response.result.data === 'object'
        ? response.result.data
        : null;
    state.developerCharacter.selectedCitizenid = '';
    renderDeveloperCharacterPanel();
    setStatus(
        response.result && response.result.message
            ? response.result.message
            : t('developer_status_lookup_done', {}, 'Busca concluida.'),
        'ok'
    );
}

function focusSupportTarget(targetSource, panelName = 'players') {
    const parsedTarget = Number(targetSource || 0);
    if (!Number.isFinite(parsedTarget) || parsedTarget <= 0) {
        return false;
    }

    state.selectedSource = Math.floor(parsedTarget);
    state.supportUnlocked = true;
    renderAll();
    if (typeof panelName === 'string' && panelName.length) {
        setActivePanel(panelName);
    }
    return true;
}

async function canExecutePanelAction(actionName) {
    const action = String(valueOr(actionName, '')).trim();
    if (!action.length) {
        return {
            ok: false,
            message: t('permission_action_denied_specific', {}, 'Sem permissao para executar esta acao.')
        };
    }

    try {
        const response = await postNui('canExecutePanelAction', { action });
        return response || { ok: false };
    } catch (_error) {
        return {
            ok: false,
            message: t('permission_action_denied_specific', {}, 'Sem permissao para executar esta acao.')
        };
    }
}

function openModal(element, modalName) {
    const context = modalName || 'unknown';
    logModalDebug('openModal:attempt', {
        modal: context,
        hasElement: !!element,
        selectedSource: state.selectedSource
    });

    if (!element) {
        logModalDebug('openModal:failedMissingElement', { modal: context });
        return;
    }

    const wasHidden = element.classList.contains('hidden');
    element.classList.remove('hidden');
    logModalDebug('openModal:success', {
        modal: context,
        wasHidden,
        nowHidden: element.classList.contains('hidden')
    });

    const style = window.getComputedStyle(element);
    logModalDebug('openModal:styleAfterOpen', {
        modal: context,
        display: style.display,
        visibility: style.visibility,
        opacity: style.opacity,
        zIndex: style.zIndex,
        position: style.position
    });

    requestAnimationFrame(() => {
        const rect = element.getBoundingClientRect();
        logModalDebug('openModal:rectAfterOpen', {
            modal: context,
            width: Math.round(rect.width),
            height: Math.round(rect.height),
            top: Math.round(rect.top),
            left: Math.round(rect.left)
        });
    });

    if (element === itemModal || element === itemConfirmModal) {
        syncItemQueueDockVisibility();
        updateItemQueueDockPosition();
    }
    if (element === deleteCharacterModal) {
        requestAnimationFrame(() => {
            if (developerCitizenIdInput) {
                developerCitizenIdInput.focus();
            }
        });
    }
    if (element === developerCharacterInfoModal) {
        requestAnimationFrame(() => {
            if (developerDeleteCharacterBtn) {
                developerDeleteCharacterBtn.focus();
            }
        });
    }
    if (element === criticalConfirmModal) {
        requestAnimationFrame(() => {
            if (criticalConfirmBtn) {
                criticalConfirmBtn.focus();
            }
        });
    }

    syncSupportActionSelection();
    syncFocusedModalMode();
}

function closeModal(element) {
    if (!element) {
        return;
    }

    element.classList.add('hidden');
    if (element === permissionRemoveConfirmModal) {
        state.permissionRemoveModal.license = '';
    }
    if (element === removeJobConfirmModal) {
        state.removeJobModal.jobName = '';
        state.removeJobModal.jobs = [];
    }
    if (element === criticalConfirmModal) {
        state.criticalConfirm = buildDefaultCriticalConfirmState();
    }
    if (element === deleteCharacterModal) {
        resetDeveloperCharacterState();
        renderDeveloperCharacterPanel();
    }
    if (element === developerCharacterInfoModal) {
        renderDeveloperCharacterPanel();
    }
    if (element === itemModal || element === itemConfirmModal) {
        syncItemQueueDockVisibility();
        updateItemQueueDockPosition();
    }

    syncSupportActionSelection();
    syncFocusedModalMode();
}

function renderJobModalGrades() {
    const job = state.catalog.jobs.find((entry) => entry.name === state.jobModal.selectedJobName);
    if (!job) {
        jobModalGradeSelect.innerHTML = '';
        syncCustomSelect(jobModalGradeSelect);
        return;
    }

    jobModalGradeSelect.innerHTML = job.grades.map((grade) => {
        return `<option value="${grade.level}">${grade.level} - ${escapeHtml(grade.name)}</option>`;
    }).join('');
    syncCustomSelect(jobModalGradeSelect);
}

function renderJobModalList() {
    const query = state.jobModal.search.trim().toLowerCase();
    let jobs = state.catalog.jobs;

    if (query) {
        jobs = jobs.filter((job) => `${job.name} ${job.label}`.toLowerCase().includes(query));
    }

    if (!jobs.length) {
        jobModalList.innerHTML = `<div class="modal-card"><strong>${escapeHtml(t('empty_no_job_found', {}, 'Nenhum job encontrado'))}</strong></div>`;
        return;
    }

    jobModalList.innerHTML = jobs.map((job) => {
        const active = state.jobModal.selectedJobName === job.name ? 'active' : '';
        return `
            <button type="button" class="modal-card ${active}" data-job-name="${escapeHtml(job.name)}">
                <strong>${escapeHtml(job.label)}</strong>
                <small>${escapeHtml(job.name)}</small>
            </button>
        `;
    }).join('');
}

function getSelectedPlayerMultijobEntries() {
    const player = getSelectedPlayer();
    if (!player || !Array.isArray(player.jobs)) {
        return [];
    }

    return player.jobs.map((entry) => {
        const name = String(valueOr(entry.name, valueOr(entry.job, ''))).trim();
        const label = String(valueOr(entry.label, valueOr(entry.jobLabel, name))).trim() || name;
        const grade = Number(valueOr(entry.grade, 0));
        const gradeLabel = String(valueOr(entry.gradeName, valueOr(entry.gradeLabel, `#${grade}`))).trim() || `#${grade}`;
        const onduty = entry.onduty === true;
        return {
            name,
            label,
            grade: Number.isFinite(grade) ? Math.floor(grade) : 0,
            gradeLabel,
            onduty
        };
    }).filter((entry) => entry.name.length > 0);
}

function renderJobModalMultijob() {
    if (!jobMultijobList || !jobMultijobInfo) {
        return;
    }

    const rows = getSelectedPlayerMultijobEntries();
    if (!rows.length) {
        jobMultijobInfo.textContent = t('modal_multijob_unavailable', {}, 'Nenhum job encontrado na multijob deste jogador.');
        jobMultijobList.innerHTML = `<div class="history-empty">${escapeHtml(t('modal_multijob_unavailable', {}, 'Nenhum job encontrado na multijob deste jogador.'))}</div>`;
        return;
    }

    jobMultijobInfo.textContent = t('modal_multijob_count', { count: rows.length }, '{count} jobs cadastrados.');
    jobMultijobList.innerHTML = rows.map((entry) => {
        const dutyLabel = entry.onduty ? t('value_on', {}, 'ON') : t('value_off', {}, 'OFF');
        return `
            <article class="history-entry">
                <div class="history-entry-head">
                    <strong>${escapeHtml(entry.label)}</strong>
                    <span>${escapeHtml(entry.name)}</span>
                </div>
                <small>${escapeHtml(t('field_grade', {}, 'Grade'))}: ${entry.grade} - ${escapeHtml(entry.gradeLabel)}</small>
                <small>${escapeHtml(t('field_duty', {}, 'Duty'))}: ${escapeHtml(dutyLabel)}</small>
            </article>
        `;
    }).join('');
}

function openJobModal() {
    logModalDebug('openJobModal:request', {
        selectedSource: state.selectedSource,
        jobsCatalogSize: Array.isArray(state.catalog.jobs) ? state.catalog.jobs.length : 0
    });

    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_job', {}, 'Selecione um jogador para aplicar o job.'), 'warn');
        logModalDebug('openJobModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    if (!state.catalog.jobs.length) {
        setStatus(t('status_catalog_jobs_empty', {}, 'Catalogo de jobs vazio.'), 'error');
        logModalDebug('openJobModal:catalogEmpty', {});
        return;
    }

    state.jobModal.search = '';
    state.jobModal.setActive = true;
    const playerJob = player && player.job ? player.job : {};
    state.jobModal.selectedJobName = playerJob.name || state.catalog.jobs[0].name;
    jobSearchInput.value = '';
    if (jobModalSetActiveInput) {
        jobModalSetActiveInput.checked = true;
    }
    if (jobCurrentInfo) {
        jobCurrentInfo.textContent = t('modal_job_current', {
            label: playerJob.label || t('value_na', {}, 'N/A'),
            name: playerJob.name || t('value_na', {}, 'N/A')
        }, 'Job atual: {label} ({name})');
    }

    renderJobModalList();
    renderJobModalGrades();
    if (playerJob.name === state.jobModal.selectedJobName && jobModalGradeSelect) {
        jobModalGradeSelect.value = String(valueOr(playerJob.grade, 0));
        syncCustomSelect(jobModalGradeSelect);
    }
    renderJobModalMultijob();
    openModal(jobModal, 'setJob');
}

function openRemoveJobConfirmModal() {
    logModalDebug('openRemoveJobConfirmModal:request', {
        selectedSource: state.selectedSource
    });

    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_remove_job', {}, 'Selecione um jogador para remover o job.'), 'warn');
        logModalDebug('openRemoveJobConfirmModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    const playerJob = player && player.job ? player.job : {};
    const currentLabel = String(valueOr(playerJob.label, t('value_na', {}, 'N/A')));
    const currentName = String(valueOr(playerJob.name, t('value_na', {}, 'N/A')));
    const currentJobName = String(valueOr(playerJob.name, '')).trim().toLowerCase();

    const jobsRaw = Array.isArray(player && player.jobs) ? player.jobs : [];
    const jobsMap = new Map();
    jobsRaw.forEach((entry) => {
        if (!entry || typeof entry !== 'object') {
            return;
        }

        const name = String(valueOr(entry.name, valueOr(entry.job, ''))).trim().toLowerCase();
        if (!name.length || jobsMap.has(name)) {
            return;
        }

        jobsMap.set(name, {
            name,
            label: String(valueOr(entry.label, valueOr(entry.jobLabel, name))).trim() || name
        });
    });

    const currentKey = currentName.trim().toLowerCase();
    if (currentKey.length && !jobsMap.has(currentKey)) {
        jobsMap.set(currentKey, {
            name: currentName,
            label: currentLabel
        });
    }

    const jobsList = Array.from(jobsMap.values()).sort((left, right) => left.label.localeCompare(right.label, 'pt-BR'));
    const hasMultipleJobs = jobsList.length > 1;
    const selectedRemoveJob = String(valueOr(state.removeJobModal.jobName, '')).trim().toLowerCase();
    state.removeJobModal.jobs = jobsList;

    const selectedExists = jobsList.some((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === selectedRemoveJob);
    if (!selectedExists) {
        if (currentJobName.length && jobsList.some((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === currentJobName)) {
            state.removeJobModal.jobName = currentJobName;
        } else {
            state.removeJobModal.jobName = String(valueOr(jobsList[0] && jobsList[0].name, '')).trim().toLowerCase();
        }
    }

    if (removeJobCurrentInfo) {
        removeJobCurrentInfo.innerHTML = `
            <span>${escapeHtml(t('modal_remove_job_current_label', {}, 'Job atual'))}</span>
            <strong>${escapeHtml(currentLabel)}</strong>
            <small>${escapeHtml(currentName)}</small>
        `;
    }

    if (removeJobModalList) {
        if (!jobsList.length) {
            removeJobModalList.innerHTML = '';
        } else {
            removeJobModalList.innerHTML = jobsList.map((entry) => {
                const normalizedName = String(valueOr(entry.name, '')).trim().toLowerCase();
                const selectedClass = normalizedName === String(valueOr(state.removeJobModal.jobName, '')).trim().toLowerCase() ? 'active' : '';
                return `
                    <button type="button" class="modal-card remove-job-card ${selectedClass}" data-select-remove-job-name="${escapeHtml(entry.name)}">
                        <strong>${escapeHtml(entry.label)}</strong>
                        <small>${escapeHtml(entry.name)}</small>
                    </button>
                `;
            }).join('');
        }
    }

    if (removeJobModalHint) {
        removeJobModalHint.textContent = t('modal_remove_job_select_hint', {}, 'Escolha um cargo abaixo e confirme a remocao.');
    }

    if (removeJobConfirmBtn) {
        removeJobConfirmBtn.style.display = '';
        removeJobConfirmBtn.disabled = !state.removeJobModal.jobName.length;
    }
    if (removeJobCancelBtn) {
        removeJobCancelBtn.textContent = t('modal_back', {}, 'Voltar');
    }

    openModal(removeJobConfirmModal, 'removeJob');
}

function getItemImageUrl(item) {
    if (!item || !item.image) {
        return '';
    }

    return `https://cfx-nui-rsg-inventory/html/images/${item.image}`;
}

function formatItemTypeLabel(itemType) {
    const normalized = String(valueOr(itemType, 'item')).trim().toLowerCase();
    if (!normalized) {
        return t('field_type', {}, 'Tipo');
    }

    return normalized
        .replace(/[_-]+/g, ' ')
        .replace(/\b\w/g, (character) => character.toUpperCase());
}

function getItemCategoryKey(item) {
    const category = String(valueOr(item && item.category, '')).trim().toLowerCase();
    if (category.length) {
        return category;
    }
    const normalized = String(valueOr(item && item.itemType, 'item')).trim().toLowerCase();
    return normalized.length ? normalized : 'item';
}

function getItemCategories() {
    const counts = new Map();
    state.catalog.items.forEach((item) => {
        const key = getItemCategoryKey(item);
        counts.set(key, (counts.get(key) || 0) + 1);
    });

    return Array.from(counts.entries())
        .map(([key, count]) => ({ key, count, label: formatItemTypeLabel(key) }))
        .sort((a, b) => a.label.localeCompare(b.label));
}

function renderItemCategoryList() {
    if (!itemCategoryList) {
        return;
    }

    const categories = getItemCategories();
    if (categories.length <= 1) {
        itemCategoryList.innerHTML = '';
        itemCategoryList.classList.add('hidden');
        return;
    }

    itemCategoryList.classList.remove('hidden');
    const activeKey = state.itemModal.category || 'all';
    const allActive = activeKey === 'all' ? ' active' : '';

    const chips = [
        `<button type="button" class="item-category-chip${allActive}" data-item-category="all"><span>${escapeHtml(t('item_category_all', {}, 'Todos'))}</span><small>${state.catalog.items.length}</small></button>`
    ];

    categories.forEach((category) => {
        const isActive = activeKey === category.key ? ' active' : '';
        chips.push(`<button type="button" class="item-category-chip${isActive}" data-item-category="${escapeHtml(category.key)}"><span>${escapeHtml(category.label)}</span><small>${category.count}</small></button>`);
    });

    itemCategoryList.innerHTML = chips.join('');
}

function renderItemModalList() {
    const query = state.itemModal.search.trim().toLowerCase();
    const activeCategory = state.itemModal.category || 'all';
    let items = state.catalog.items;

    if (activeCategory !== 'all') {
        items = items.filter((item) => getItemCategoryKey(item) === activeCategory);
    }

    if (query) {
        items = items.filter((item) => `${item.name} ${item.label} ${valueOr(item.description, '')} ${getItemCategoryKey(item)}`.toLowerCase().includes(query));
    }

    if (itemModalCount) {
        itemModalCount.textContent = t('item_browser_count', { count: items.length }, '{count} itens');
    }

    if (!items.length) {
        itemModalList.innerHTML = `<div class="item-browser-empty">${escapeHtml(t('empty_no_item_found', {}, 'Nenhum item encontrado'))}</div>`;
        return;
    }

    // The category tag is only useful when several categories are mixed in the list.
    const showCategory = activeCategory === 'all';
    itemModalList.innerHTML = items.map((item) => {
        const active = state.itemModal.selectedItemName === item.name ? ' active' : '';
        const imageUrl = getItemImageUrl(item);
        const description = String(valueOr(item.description, '')).trim();
        const itemType = String(valueOr(item.itemType, 'item')).trim().toLowerCase();
        const weightLabel = formatKgFromUnits(valueOr(item.weight, 0));
        const thumb = imageUrl
            ? `<img src="${escapeHtml(imageUrl)}" alt="" onerror="this.style.opacity='0.2'" />`
            : '';
        const tags = [];
        if (showCategory) {
            tags.push(`<span class="item-tile-tag">${escapeHtml(formatItemTypeLabel(getItemCategoryKey(item)))}</span>`);
        }
        if (itemType && itemType !== 'item') {
            tags.push(`<span class="item-tile-tag is-type">${escapeHtml(formatItemTypeLabel(itemType))}</span>`);
        }

        return `
            <div class="item-tile${active}" role="button" tabindex="0" data-item-name="${escapeHtml(item.name)}" title="${escapeHtml(description)}">
                <span class="item-tile-thumb">${thumb}</span>
                <span class="item-tile-body">
                    <strong class="item-tile-label">${escapeHtml(item.label || item.name)}</strong>
                    <small class="item-tile-code">${escapeHtml(item.name)}</small>
                    ${tags.length ? `<span class="item-tile-tags">${tags.join('')}</span>` : ''}
                </span>
                <span class="item-tile-weight">${escapeHtml(weightLabel)}</span>
            </div>
        `;
    }).join('');
}

function openItemModal() {
    logModalDebug('openItemModal:request', {
        selectedSource: state.selectedSource,
        itemsCatalogSize: Array.isArray(state.catalog.items) ? state.catalog.items.length : 0
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_items', {}, 'Selecione um jogador para enviar os itens.'), 'warn');
        logModalDebug('openItemModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    if (!state.catalog.items.length) {
        setStatus(t('status_catalog_items_empty', {}, 'Catalogo de itens vazio.'), 'error');
        logModalDebug('openItemModal:catalogEmpty', {});
        return;
    }

    state.itemModal.search = '';
    state.itemModal.category = 'all';
    state.itemModal.selectedItemName = state.catalog.items[0].name;
    state.itemModal.queue = [];
    state.itemModal.sending = false;
    state.itemModal.lastCapacity = null;
    itemSearchInput.value = '';

    renderItemCategoryList();
    renderItemModalList();
    renderItemQueue();
    closeModal(itemConfirmModal);
    openModal(itemModal, 'addItem');
}

function addSelectedItemToQueue(showError = true) {
    const itemName = state.itemModal.selectedItemName;
    const amount = 1;
    if (!itemName) {
        if (showError) {
            setStatus(t('status_select_item', {}, 'Selecione um item para adicionar na lista.'), 'error');
        }
        return;
    }

    const itemData = state.catalog.items.find((entry) => entry.name === itemName);
    if (!itemData) {
        if (showError) {
            setStatus(t('status_invalid_selected_item', {}, 'Item selecionado invalido.'), 'error');
        }
        return;
    }

    const found = state.itemModal.queue.find((entry) => entry.name === itemName);
    if (found) {
        found.amount = Math.min(1000, found.amount + amount);
    } else {
        state.itemModal.queue.push({
            name: itemName,
            label: itemData.label || itemName,
            image: itemData.image || '',
            amount
        });
    }

    renderItemQueue();
    if (isVisible(itemConfirmModal)) {
        renderItemConfirmationList();
    }
}

function openItemConfirmFlow() {
    if (!state.itemModal.queue.length) {
        addSelectedItemToQueue(false);
    }

    if (!state.itemModal.queue.length) {
        setStatus(t('status_add_item_min_one', {}, 'Adicione pelo menos um item na lista.'), 'error');
        return;
    }

    state.itemModal.lastCapacity = null;
    renderItemConfirmationList();
    openModal(itemConfirmModal);
}

function clearItemQueueAndClose() {
    state.itemModal.queue = [];
    state.itemModal.lastCapacity = null;
    renderItemQueue();
    renderItemCapacityStatus(null);
    closeModal(itemConfirmModal);
    closeModal(itemModal);
}

function openMoneyModal(mode) {
    logModalDebug('openMoneyModal:request', {
        mode,
        selectedSource: state.selectedSource,
        moneyTypesSize: getMoneyTypes().length
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_money', {}, 'Selecione um jogador para alterar dinheiro.'), 'warn');
        logModalDebug('openMoneyModal:noPlayerSelected', { selectedSource: state.selectedSource, mode });
        return;
    }

    if (!getMoneyTypes().length) {
        setStatus(t('status_catalog_money_empty', {}, 'Catalogo de tipos de dinheiro vazio.'), 'error');
        logModalDebug('openMoneyModal:catalogEmpty', { mode });
        return;
    }

    state.moneyModal.mode = mode === 'remove' ? 'remove' : 'add';
    moneyModalTitle.textContent = state.moneyModal.mode === 'remove'
        ? t('modal_remove_money_title', {}, 'Remover Money')
        : t('modal_add_money_title', {}, 'Adicionar Money');
    moneyModalApplyBtn.textContent = state.moneyModal.mode === 'remove'
        ? t('modal_money_apply_remove', {}, 'Remover')
        : t('modal_money_apply_add', {}, 'Adicionar');
    moneyAmountInput.value = '1';

    renderMoneyTypeSelect();
    if (!moneyTypeSelect.value && getMoneyTypes().length) {
        moneyTypeSelect.value = getMoneyTypes()[0].key;
    }
    renderMoneyModalInfo();
    openModal(moneyModal, mode === 'remove' ? 'removeMoney' : 'addMoney');
}

function openSupportAdjustModal(mode) {
    logModalDebug('openSupportAdjustModal:request', {
        mode,
        selectedSource: state.selectedSource
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_support_adjust', {}, 'Selecione um jogador para ajustar peso ou slots.'), 'warn');
        return;
    }

    state.supportAdjustModal.mode = mode === 'slots' ? 'slots' : 'weight';
    if (supportAdjustAmountInput) {
        supportAdjustAmountInput.value = '1';
    }

    renderSupportAdjustModalInfo();
    openModal(supportAdjustModal, state.supportAdjustModal.mode === 'slots' ? 'addSlots' : 'addWeight');
}

function openRenamePlayerModal() {
    logModalDebug('openRenamePlayerModal:request', {
        selectedSource: state.selectedSource
    });

    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_rename', {}, 'Selecione um jogador para trocar nome e sobrenome.'), 'warn');
        return;
    }

    const nameParts = getSelectedPlayerNameParts();
    if (renamePlayerFirstNameInput) {
        renamePlayerFirstNameInput.value = nameParts.firstName;
    }
    if (renamePlayerLastNameInput) {
        renamePlayerLastNameInput.value = nameParts.lastName;
    }

    renderRenamePlayerModalInfo();
    openModal(renamePlayerModal, 'renameCharacter');
}

function openMessageModal() {
    logModalDebug('openMessageModal:request', {
        selectedSource: state.selectedSource
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_message', {}, 'Selecione um jogador para enviar mensagem.'), 'warn');
        logModalDebug('openMessageModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    if (messageModalInput) {
        messageModalInput.value = '';
    }
    renderMessageModalInfo();
    openModal(messageModal, 'privateMessage');
}

function openKickModal() {
    logModalDebug('openKickModal:request', {
        selectedSource: state.selectedSource
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_kick', {}, 'Selecione um jogador para aplicar kick.'), 'warn');
        logModalDebug('openKickModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    if (kickModalReason) {
        kickModalReason.value = '';
    }
    renderKickModalInfo();
    openModal(kickModal, 'kick');
}

function openBanModal() {
    logModalDebug('openBanModal:request', {
        selectedSource: state.selectedSource
    });

    if (!getSelectedPlayer()) {
        setStatus(t('status_select_player_ban', {}, 'Selecione um jogador para banir.'), 'warn');
        logModalDebug('openBanModal:noPlayerSelected', { selectedSource: state.selectedSource });
        return;
    }

    renderBanModeSelect();
    state.banModal.mode = banModeSelect ? (banModeSelect.value || '1') : '1';
    if (banModeSelect) {
        banModeSelect.value = state.banModal.mode;
    }
    if (banReasonInput) {
        banReasonInput.value = '';
    }
    renderBanModalInfo();
    openModal(banModal, 'ban');
}

function openEditBanModal(banId) {
    const banEntry = getBannedPlayerById(banId);
    if (!banEntry) {
        setStatus(t('status_ban_not_found', {}, 'Banimento nao encontrado.'), 'error');
        return;
    }

    state.editBanModal.banId = Number(banEntry.id);
    state.editBanModal.mode = '1';
    renderEditBanModeSelect();
    renderEditBanModalInfo();
    openModal(editBanModal, 'editBan');
}

function openCompanyStashModal() {
    const rows = Array.isArray(state.catalog.companyStashes) ? state.catalog.companyStashes : [];
    if (!rows.length) {
        setStatus(t('status_company_stash_catalog_empty', {}, 'Nenhum bau encontrado no catalogo do rsg-bossmenu.'), 'warn');
        return;
    }

    state.companyStashModal.search = '';
    if (companyStashSearchInput) {
        companyStashSearchInput.value = '';
    }

    const selectedExists = rows.some((entry) => String(valueOr(entry.stashName, '')).trim() === String(valueOr(state.companyStashModal.selectedStashName, '')).trim());
    if (!selectedExists) {
        state.companyStashModal.selectedStashName = String(valueOr(rows[0].stashName, '')).trim();
    }

    renderCompanyStashModalList();
    openModal(companyStashModal, 'companyStash');
}

function openHorseModal() {
    const rows = getAdminHorseRows();
    if (!rows.length) {
        setStatus(t('status_horse_catalog_empty', {}, 'Catalogo de cavalos vazio.'), 'warn');
        return;
    }

    const selectedExists = rows.some((entry) => String(valueOr(entry.id, '')).trim() === String(valueOr(state.horseModal.selectedHorseId, '')).trim());
    if (!selectedExists) {
        state.horseModal.selectedHorseId = String(valueOr(rows[0].id, '')).trim();
    }

    renderHorseModalList();
    openModal(horseModal, 'horse');
}

function openPermissionAddModal() {
    const canManage = state.permissions && state.permissions.canManage === true;
    if (!canManage) {
        setStatus(t('permissions_manage_disabled', {}, 'Somente GOD ou quem possui "Gerenciar Permissoes" pode editar.'), 'error');
        return;
    }

    const online = state.permissions && Array.isArray(state.permissions.onlinePlayers) ? state.permissions.onlinePlayers : [];
    if (!online.length) {
        setStatus(t('permissions_empty_online', {}, 'Nenhum player online encontrado.'), 'warn');
        return;
    }

    state.permissionAddModal.presetKey = '';
    state.permissionAddModal.permissions = buildEmptyPermissionFlags();
    const selectedExists = online.some((entry) => Number(entry.source || 0) === Number(state.permissionAddModal.selectedSource || 0));
    if (!selectedExists) {
        state.permissionAddModal.selectedSource = Number(online[0].source || 0);
    }

    renderPermissionAddModal();
    openModal(permissionAddModal, 'permissionAdd');
}

function openPermissionEditModalByLicense(license) {
    const entry = getPermissionEntryByLicense(license);
    if (!entry) {
        setStatus('Permissao nao encontrada para esta citizenid.', 'error');
        return;
    }

    state.permissionEditModal.license = String(valueOr(entry.citzenid, '')).trim();
    state.permissionEditModal.targetSource = Number(entry.source || 0);
    state.permissionEditModal.name = entry.name || '';
    state.permissionEditModal.accessType = entry.accessType || 'custom';
    state.permissionEditModal.presetKey = entry.presetKey || '';
    state.permissionEditModal.editable = entry.editable === true;
    state.permissionEditModal.permissions = normalizePermissionFlags(entry.permissions || {});

    renderPermissionEditModal();
    openModal(permissionEditModal, 'permissionEdit');
}

function renderPermissionRemoveConfirmModal() {
    const license = String(valueOr(state.permissionRemoveModal.license, '')).trim();
    const entry = getPermissionEntryByLicense(license);
    const sourceValue = entry ? Number(entry.source || 0) : 0;
    const sourceLabel = sourceValue > 0 ? String(sourceValue) : t('value_na', {}, 'N/A');

    if (permissionRemoveConfirmCurrentInfo) {
        permissionRemoveConfirmCurrentInfo.innerHTML = `
            <span>${escapeHtml(t('permissions_remove_modal_target_label', {}, 'Permissao selecionada'))}</span>
            <strong>${escapeHtml(entry && entry.name ? entry.name : `ID: ${sourceLabel}`)}</strong>
            <small>${escapeHtml(license || t('value_na', {}, 'N/A'))}</small>
        `;
    }

    if (permissionRemoveConfirmBtn) {
        permissionRemoveConfirmBtn.disabled = !license.length;
    }
}

function openPermissionRemoveConfirmModal(license) {
    const normalizedLicense = String(valueOr(license, '')).trim();
    if (!normalizedLicense.length) {
        setStatus('Citizenid invalida.', 'error');
        return;
    }

    const entry = getPermissionEntryByLicense(normalizedLicense);
    if (!entry) {
        setStatus('Permissao nao encontrada para esta citizenid.', 'error');
        return;
    }

    state.permissionRemoveModal.license = normalizedLicense;
    renderPermissionRemoveConfirmModal();
    openModal(permissionRemoveConfirmModal, 'permissionRemove');
}

async function submitPermissionRemove() {
    const license = String(valueOr(state.permissionRemoveModal.license, '')).trim();
    if (!license.length) {
        setStatus('Citizenid invalida.', 'error');
        return;
    }

    const response = await executeGlobalAction('permissionRemovePlayer', { citzenid: license });
    if (!response.ok) {
        return;
    }

    closeModal(permissionRemoveConfirmModal);
    if (isVisible(permissionEditModal) && String(valueOr(state.permissionEditModal.license, '')).trim() === license) {
        closeModal(permissionEditModal);
    }
}

async function togglePlayerBlips() {
    await executeGlobalAction('togglePlayerBlips', {}, { silentSuccess: true });
}

async function togglePlayerWall() {
    await executeGlobalAction('togglePlayerWall', {}, { silentSuccess: true });
}

async function toggleNoclip() {
    await executeGlobalAction('toggleNoclip');
}

async function openCoordsModal() {
    try {
        const response = await postNui('getCurrentCoords');
        if (!response || response.ok !== true || !response.data) {
            setStatus((response && response.message) || t('status_coords_fetch_fail', {}, 'Falha ao pegar coordenadas.'), 'error');
            return;
        }

        const payload = buildCoordsPayload(response.data);
        fillCoordsModalValues(payload);
        openModal(coordsModal, 'coords');
    } catch (_error) {
        setStatus(t('status_coords_fetch_fail', {}, 'Falha ao pegar coordenadas.'), 'error');
    }
}

async function copyCoordsField(fieldKey) {
    const fieldMap = getCoordsFieldMap();
    const field = fieldMap[fieldKey];
    const value = getCoordsFieldValue(field);
    if (!value) {
        return;
    }

    const copied = await copyTextToClipboard(value);
    if (!copied) {
        setStatus(t('status_coords_copy_fail', {}, 'Falha ao copiar.'), 'error');
        return;
    }

    const labelByKey = {
        vector1: t('modal_coords_vector1', {}, 'Vector1'),
        vector2: t('modal_coords_vector2', {}, 'Vector2'),
        vector3: t('modal_coords_vector3', {}, 'Vector3'),
        vector4: t('modal_coords_vector4', {}, 'Vector4'),
        heading: t('modal_coords_heading', {}, 'Heading')
    };
    const label = labelByKey[fieldKey] || fieldKey;
    setStatus(t('status_coords_copy_success', { label }, '{label} copiado.'), 'ok');
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'bilto_admin:toggle') {
        state.open = data.open === true;
        applyLocalePayload(data.locale);
        panelTitle.textContent = data.title || t('panel_title', {}, 'Bitinho Admin');
        applyStaticTranslations();
        syncAppVisibility();

        if (state.open) {
            setStatus('', 'info');
            setActivePanel(state.activePanel);
        } else {
            state.activePanel = 'dashboard';
            state.selectedSource = null;
            state.supportUnlocked = false;
            state.support.spectateTargetSource = 0;
            state.filter = '';
            setActivePanel('dashboard');
            renderPlayers();
            closeModal(jobModal);
            closeModal(removeJobConfirmModal);
            closeModal(itemModal);
            closeModal(itemConfirmModal);
            closeModal(moneyModal);
            closeModal(supportAdjustModal);
            closeModal(renamePlayerModal);
            closeModal(heightPlayerModal);
            closeModal(coordsModal);
            closeModal(deleteCharacterModal);
            closeModal(developerCharacterInfoModal);
            closeModal(messageModal);
            closeModal(kickModal);
            closeModal(banModal);
            closeModal(editBanModal);
            closeModal(companyStashModal);
            closeModal(horseModal);
            closeModal(permissionAddModal);
            closeModal(permissionEditModal);
            closeModal(permissionRemoveConfirmModal);
            closeModal(permissionPresetEditModal);
            closeModal(criticalConfirmModal);
        }

        return;
    }

    if (data.action === 'bilto_admin:updateState') {
        applyPayload(data.payload || {});
        return;
    }

    if (data.action === 'bilto_admin:toast') {
        const payload = data.payload || {};
        pushToast(payload.message || '', payload.type || 'info', payload.duration || 4200, payload.title || '');
    }
});

bindEvent(playersBody, 'click', (event) => {
    const actionButton = event.target.closest('[data-player-action][data-player-source]');
    if (actionButton) {
        const targetSource = Number(actionButton.dataset.playerSource || 0);
        const actionName = String(valueOr(actionButton.dataset.playerAction, '')).trim();
        if (targetSource > 0) {
            state.selectedSource = targetSource;
            state.supportUnlocked = true;
            renderAll();
            if (actionName === 'goto' || actionName === 'bring') {
                executeAction(actionName);
            }
        }
        return;
    }

    const row = event.target.closest('tr[data-source]');
    if (!row) {
        return;
    }

    focusSupportTarget(Number(row.dataset.source), 'support');
});

bindEvent(permissionsBody, 'click', async (event) => {
    const button = event.target.closest('[data-permission-action][data-permission-license]');
    if (!button) {
        return;
    }

    const action = String(valueOr(button.dataset.permissionAction, '')).trim();
    const license = String(valueOr(button.dataset.permissionLicense, '')).trim();
    if (!license.length) {
        setStatus('Citizenid invalida.', 'error');
        return;
    }

    if (action === 'edit') {
        openPermissionEditModalByLicense(license);
        return;
    }

    if (action === 'remove') {
        openPermissionRemoveConfirmModal(license);
    }
});

bindEvent(bannedPlayersBody, 'click', async (event) => {
    const button = event.target.closest('[data-ban-action][data-ban-id]');
    if (!button) {
        return;
    }

    const action = String(valueOr(button.dataset.banAction, '')).trim();
    const banId = Number(button.dataset.banId || 0);
    if (!Number.isFinite(banId) || banId <= 0) {
        setStatus(t('status_ban_invalid_id', {}, 'ID de banimento invalido.'), 'error');
        return;
    }

    if (action === 'edit') {
        openEditBanModal(banId);
        return;
    }

    if (action === 'remove') {
        const response = await executeGlobalAction('removeBan', { banId });
        if (response.ok && Number(state.editBanModal.banId || 0) === banId) {
            closeModal(editBanModal);
        }
    }
});

bindEvent(searchInput, 'input', (event) => {
    state.filter = event.target.value || '';
    renderPlayers();
});

bindEvent(teleportSearchInput, 'input', (event) => {
    state.teleports.search = event.target.value || '';
    renderTeleports();
});

bindEvent(teleportCategoryFilter, 'change', (event) => {
    state.teleports.category = event.target.value || 'all';
    renderTeleports();
});

bindEvent(teleportsGrid, 'click', (event) => {
    const goBtn = event.target.closest('[data-teleport-go]');
    if (goBtn) {
        const locId = goBtn.dataset.teleportGo;
        const loc = getAllTeleportLocations().find((entry) => String(entry.id) === locId);
        if (loc) {
            teleportToLocation(loc);
        }
        return;
    }

    const deleteBtn = event.target.closest('[data-teleport-delete]');
    if (deleteBtn) {
        const locId = deleteBtn.dataset.teleportDelete;
        const loc = getAllTeleportLocations().find((entry) => String(entry.id) === locId);
        if (loc) {
            confirmDeleteTeleportLocation(loc);
        }
    }
});

bindEvent(openCustomTeleportModalBtn, 'click', openCustomTeleportModal);
bindEvent(customTeleportModalCloseBtn, 'click', () => closeModal(customTeleportModal));
bindEvent(customTeleportModalApplyBtn, 'click', submitCustomTeleport);
bindEvent(customTeleportModal, 'click', (event) => {
    if (event.target === customTeleportModal) {
        closeModal(customTeleportModal);
    }
});

bindEvent(openAddTeleportModalBtn, 'click', openAddTeleportModal);
bindEvent(addTeleportModalCloseBtn, 'click', () => closeModal(addTeleportModal));
bindEvent(addTeleportUseCurrentBtn, 'click', useCurrentLocationForAddTeleport);
bindEvent(addTeleportModalApplyBtn, 'click', submitAddTeleport);
bindEvent(addTeleportModal, 'click', (event) => {
    if (event.target === addTeleportModal) {
        closeModal(addTeleportModal);
    }
});

bindEvent(developerCitizenIdInput, 'input', (event) => {
    state.developerCharacter.citizenid = String(valueOr(event.target && event.target.value, '')).trim();
    state.developerCharacter.lookup = null;
    state.developerCharacter.selectedCitizenid = '';
    renderDeveloperCharacterPanel();
});

bindEvent(developerCharacterResult, 'click', (event) => {
    const infoTrigger = event.target.closest('[data-developer-character-select="true"]');
    if (infoTrigger) {
        openDeveloperCharacterInfoModal();
        return;
    }

    return;
});

navButtons.forEach((button) => {
    button.addEventListener('click', async () => {
        const target = button.dataset.panelTarget;
        const permissionKey = PANEL_PERMISSION_BY_TARGET[target];
        if (permissionKey) {
            const permissionCheck = await canExecutePanelAction(permissionKey);
            if (!permissionCheck.ok) {
                setStatus(permissionCheck.message || t('permission_action_denied_specific', {}, 'Sem permissao para executar esta acao.'), 'error');
                return;
            }
        }

        setActivePanel(target);
        if (target === 'teleports' && !state.teleports.loaded) {
            loadTeleportLocations();
        }
    });
});

actionButtons.forEach((button) => {
    button.addEventListener('click', () => {
        executeAction(button.dataset.action);
    });
});

bindEvent(openJobModalBtn, 'click', openJobModal);
bindEvent(removeJobBtn, 'click', openRemoveJobConfirmModal);
bindEvent(openItemModalBtn, 'click', openItemModal);
bindEvent(openAddMoneyModalBtn, 'click', () => openMoneyModal('add'));
bindEvent(openRemoveMoneyModalBtn, 'click', () => openMoneyModal('remove'));
bindEvent(openAddWeightModalBtn, 'click', () => openSupportAdjustModal('weight'));
bindEvent(openAddSlotsModalBtn, 'click', () => openSupportAdjustModal('slots'));
bindEvent(openRenamePlayerModalBtn, 'click', openRenamePlayerModal);
bindEvent(openHeightPlayerModalBtn, 'click', openHeightPlayerModal);
bindEvent(openMessageModalBtn, 'click', openMessageModal);
bindEvent(openKickModalBtn, 'click', openKickModal);
bindEvent(openBanModalBtn, 'click', openBanModal);
bindEvent(openCoordsModalBtn, 'click', openCoordsModal);
bindEvent(togglePlayerBlipsBtn, 'click', togglePlayerBlips);
bindEvent(togglePlayerWallBtn, 'click', togglePlayerWall);
bindEvent(toggleNoclipBtn, 'click', toggleNoclip);
bindEvent(openHorseModalBtnDashboard, 'click', openHorseModal);
bindEvent(openCompanyStashModalBtn, 'click', openCompanyStashModal);
bindEvent(openCompanyStashModalBtnSupport, 'click', openCompanyStashModal);
bindEvent(openDeleteCharacterModalBtn, 'click', openDeleteCharacterModal);
bindEvent(openPermissionAddModalBtn, 'click', openPermissionAddModal);
bindEvent(developerSearchBtn, 'click', searchDeveloperCharacterByCitizenid);
bindEvent(developerDeleteCharacterBtn, 'click', async () => {
    const lookup = getDeveloperCharacterLookup();
    if (!lookup || lookup.found !== true) {
        setStatus(t('developer_status_lookup_first', {}, 'Procure uma citizenid valida antes de deletar.'), 'warn');
        return;
    }
    if (!isDeveloperCharacterSelected(lookup)) {
        setStatus(t('developer_delete_character_pick', {}, 'Clique no personagem encontrado para habilitar a exclusao.'), 'warn');
        return;
    }

    const matchedTables = Array.isArray(lookup.matchedTables) ? lookup.matchedTables : [];
    const detailLines = [
        `${t('field_citizenid', {}, 'Citizenid')}: ${lookup.citizenid || '-'}`,
        `${t('modal_player_label', {}, 'Jogador')}: ${lookup.fullname || lookup.citizenid || '-'}`,
        `${t('developer_result_rows', {}, 'Registros')}: ${Number(valueOr(lookup.totalRows, 0))}`,
        `${t('developer_result_tables', {}, 'Tabelas afetadas')}: ${matchedTables.length}`
    ];
    matchedTables.slice(0, 8).forEach((entry) => {
        detailLines.push(`${String(valueOr(entry.tableName, '-')).trim() || '-'}: ${Number(valueOr(entry.matchCount, 0))}`);
    });

    openCriticalConfirmModal({
        title: t('developer_delete_character', {}, 'Deletar Character'),
        summary: lookup.online === true
            ? t('critical_delete_character_online_summary', {}, 'O jogador sera kickado em 5 segundos. Cinco segundos depois, o personagem sera removido do banco de dados.')
            : t('critical_delete_character_summary', {}, 'Esta acao remove permanentemente o personagem offline de todas as tabelas que usam citizenid.'),
        variant: 'ban',
        badge: 'DEL',
        confirmLabel: t('developer_delete_character_confirm', {}, 'Confirmar Delecao'),
        details: detailLines,
        onConfirm: async () => {
            const response = await executeGlobalAction('deleteCharacterByCitizenid', {
                citizenid: lookup.citizenid
            }, { silentSuccess: true });
            if (response.ok) {
                resetDeveloperCharacterState();
                renderDeveloperCharacterPanel();
                closeModal(deleteCharacterModal);
                setStatus(
                    response.result && response.result.message
                        ? response.result.message
                        : t('developer_delete_success', {}, 'Personagem deletado com sucesso.'),
                    'ok'
                );
            }
            return response;
        }
    });
});

bindEvent(backToPlayersBtn, 'click', () => {
    setActivePanel('players');
});

bindEvent(messageModalSendBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_message', {}, 'Selecione um jogador para enviar mensagem.'), 'warn');
        return;
    }

    const message = String(valueOr(messageModalInput && messageModalInput.value, '')).trim();
    openCriticalConfirmModal({
        title: t('modal_private_message_title', {}, 'Mensagem Privada'),
        summary: `Voce gostaria de enviar uma mensagem privada para ${getSelectedPlayerDisplayName()}?`,
        badge: 'MSG',
        confirmLabel: t('modal_send_message', {}, 'Enviar Mensagem'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_message_label', {}, 'Mensagem')}: ${truncateText(message, 180) || '-'}`
        ],
        onConfirm: () => executeAction('privateMessage', { message }),
        closeOnSuccess: [messageModal]
    });
});

bindEvent(messageModalCloseBtn, 'click', () => {
    closeModal(messageModal);
});

bindEvent(deleteCharacterModalCloseBtn, 'click', () => {
    closeModal(deleteCharacterModal);
});

bindEvent(developerCharacterInfoModalCloseBtn, 'click', () => {
    closeModal(developerCharacterInfoModal);
});

bindEvent(kickModalApplyBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_kick', {}, 'Selecione um jogador para aplicar kick.'), 'warn');
        return;
    }

    const reasonValue = String(valueOr(kickModalReason && kickModalReason.value, '')).trim();
    openCriticalConfirmModal({
        title: t('critical_kick_title', {}, 'Confirmar Kick'),
        summary: t('critical_kick_summary', {}, 'Voce esta prestes a remover um jogador do servidor.'),
        variant: 'kick',
        badge: 'KICK',
        confirmLabel: t('modal_apply_kick', {}, 'Aplicar Kick'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_reason_label', {}, 'Motivo')}: ${reasonValue || t('kick_default_reason', {}, 'Removido pela administracao.')}`
        ],
        onConfirm: () => executeAction('kick', { reason: reasonValue }),
        closeOnSuccess: [kickModal]
    });
});

bindEvent(kickModalCloseBtn, 'click', () => {
    closeModal(kickModal);
});

bindEvent(banModeSelect, 'change', () => {
    state.banModal.mode = banModeSelect.value || '1';
    renderBanModalInfo();
});

bindEvent(banModalApplyBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_ban', {}, 'Selecione um jogador para banir.'), 'warn');
        return;
    }

    const selection = getBanModalSelectionInfo();
    if (!selection.isPermanent && (!Number.isFinite(selection.banAmount) || selection.banAmount <= 0)) {
        setStatus(t('ban_amount_invalid_temporary', {}, 'Quantidade invalida para ban temporario.'), 'error');
        return;
    }

    const reason = String(valueOr(banReasonInput && banReasonInput.value, '')).trim();
    openCriticalConfirmModal({
        title: t('critical_ban_title', {}, 'Confirmar Banimento'),
        summary: t('critical_ban_summary', {}, 'Voce esta prestes a banir um jogador. Revise os dados com cuidado.'),
        variant: 'ban',
        badge: 'BAN',
        confirmLabel: t('modal_confirm_ban', {}, 'Confirmar Banimento'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_ban_type_label', {}, 'Tipo')}: ${selection.typeLabel}`,
            `${t('modal_ban_summary_label', {}, 'Resumo')}: ${selection.summary}`,
            `${t('modal_reason_label', {}, 'Motivo')}: ${reason || t('ban_default_reason', {}, 'Banido pela administracao.')}`
        ],
        onConfirm: () => executeAction('banPlayer', {
            banMode: selection.isPermanent ? 'permanent' : 'days',
            banAmount: selection.banAmount,
            reason
        }),
        closeOnSuccess: [banModal]
    });
});

bindEvent(banModalCloseBtn, 'click', () => {
    closeModal(banModal);
});

bindEvent(editBanModeSelect, 'change', () => {
    state.editBanModal.mode = editBanModeSelect.value || '1';
});

bindEvent(editBanModalApplyBtn, 'click', async () => {
    const banId = Number(state.editBanModal.banId || 0);
    if (!Number.isFinite(banId) || banId <= 0) {
        setStatus(t('status_ban_invalid_id', {}, 'ID de banimento invalido.'), 'error');
        return;
    }

    const selectedDuration = String(valueOr(editBanModeSelect && editBanModeSelect.value, state.editBanModal.mode || '1')).trim();
    const isPermanent = selectedDuration === 'permanent';
    const banAmount = isPermanent ? 0 : Number(selectedDuration || 0);
    if (!isPermanent && (!Number.isFinite(banAmount) || banAmount <= 0)) {
        setStatus(t('ban_amount_invalid_temporary', {}, 'Quantidade invalida para ban temporario.'), 'error');
        return;
    }

    const banEntry = getBannedPlayerById(banId);
    const summary = isPermanent
        ? t('modal_ban_summary_permanent', {}, 'Banimento permanente')
        : t('modal_ban_summary_days', { days: banAmount }, '{days} dia(s)');

    openCriticalConfirmModal({
        title: t('modal_edit_ban_title', {}, 'Editar Banimento'),
        summary: `Voce gostaria de atualizar o banimento #${banId}?`,
        badge: 'BAN',
        confirmLabel: t('modal_apply_ban_edit', {}, 'Salvar Alteracao'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${banEntry && banEntry.name ? banEntry.name : `Ban #${banId}`}`,
            `${t('modal_ban_summary_label', {}, 'Resumo')}: ${summary}`
        ],
        onConfirm: () => executeGlobalAction('editBan', {
            banId,
            banMode: isPermanent ? 'permanent' : 'days',
            banAmount
        }),
        closeOnSuccess: [editBanModal]
    });
});

bindEvent(editBanModalCloseBtn, 'click', () => {
    closeModal(editBanModal);
});

bindEvent(companyStashModalCloseBtn, 'click', () => {
    closeModal(companyStashModal);
});

bindEvent(companyStashSearchInput, 'input', (event) => {
    state.companyStashModal.search = event.target.value || '';
    renderCompanyStashModalList();
});

bindEvent(companyStashModalList, 'click', (event) => {
    const button = event.target.closest('[data-company-stash-name]');
    if (!button) {
        return;
    }

    state.companyStashModal.selectedStashName = String(valueOr(button.dataset.companyStashName, '')).trim();
    renderCompanyStashModalList();
});

bindEvent(companyStashModalOpenBtn, 'click', async () => {
    const stashName = String(valueOr(state.companyStashModal.selectedStashName, '')).trim();
    if (!stashName.length) {
        setStatus(t('status_company_stash_select', {}, 'Selecione um bau de empresa.'), 'warn');
        return;
    }

    const selected = (state.catalog.companyStashes || []).find((entry) => String(valueOr(entry.stashName, '')).trim() === stashName);
    const stashLabel = String(valueOr(selected && selected.label, stashName)).trim() || stashName;
    openCriticalConfirmModal({
        title: t('modal_company_stash_title', {}, 'Baus de Empresas'),
        summary: `Voce gostaria de abrir o bau ${stashLabel}?`,
        badge: 'STASH',
        confirmLabel: t('modal_company_stash_open', {}, 'Abrir Bau Selecionado'),
        details: [
            `${t('modal_selected_label', {}, 'Selecionado')}: ${stashLabel}`,
            `Stash: ${stashName}`
        ],
        onConfirm: () => executeGlobalAction('openCompanyStash', { stashName }),
        closeOnSuccess: [companyStashModal]
    });
});

bindEvent(horseModalCloseBtn, 'click', () => {
    closeModal(horseModal);
});

bindEvent(horseModalList, 'click', (event) => {
    const button = event.target.closest('[data-horse-id]');
    if (!button) {
        return;
    }

    state.horseModal.selectedHorseId = String(valueOr(button.dataset.horseId, '')).trim();
    renderHorseModalList();
});

bindEvent(horseModalSpawnBtn, 'click', async () => {
    const horseId = String(valueOr(state.horseModal.selectedHorseId, '')).trim();
    if (!horseId.length) {
        setStatus(t('status_horse_select', {}, 'Selecione um cavalo.'), 'warn');
        return;
    }

    const selected = getAdminHorseRows().find((entry) => String(valueOr(entry.id, '')).trim() === horseId);
    const horseLabel = String(valueOr(selected && selected.label, valueOr(selected && selected.model, horseId))).trim() || horseId;
    openCriticalConfirmModal({
        title: t('modal_horse_title', {}, 'Spawnar Cavalo'),
        summary: `Voce gostaria de spawnar o cavalo ${horseLabel}?`,
        badge: 'HORSE',
        confirmLabel: t('modal_horse_spawn', {}, 'Spawnar Cavalo Selecionado'),
        details: [
            `${t('modal_selected_label', {}, 'Selecionado')}: ${horseLabel}`,
            `ID: ${horseId}`
        ],
        onConfirm: () => executeGlobalAction('spawnAdminHorse', { horseId }),
        closeOnSuccess: [horseModal]
    });
});

bindEvent(permissionAddModalCloseBtn, 'click', () => {
    closeModal(permissionAddModal);
});

bindEvent(permissionAddCancelBtn, 'click', () => {
    closeModal(permissionAddModal);
});

bindEvent(permissionAddOnlineList, 'click', (event) => {
    const row = event.target.closest('[data-permission-add-source]');
    if (!row) {
        return;
    }

    state.permissionAddModal.selectedSource = Number(row.dataset.permissionAddSource || 0);
    renderPermissionAddModal();
});

bindEvent(permissionAddAllInput, 'change', () => {
    syncPermissionAllToggle('add');
});

bindEvent(permissionAddPresetSelect, 'change', (event) => {
    applyPermissionPresetToMode('add', event.target.value || '');
});

bindEvent(permissionAddOptions, 'click', (event) => {
    const card = event.target.closest('[data-permission-add-key]');
    if (!card || !permissionAddOptions.contains(card)) {
        return;
    }

    togglePermissionCard('add', card);
});

bindEvent(permissionAddConfirmBtn, 'click', async () => {
    const selected = getOnlinePermissionCandidateBySource(state.permissionAddModal.selectedSource);
    if (!selected) {
        setStatus(t('permissions_select_online_player', {}, 'Selecione um player online.'), 'warn');
        return;
    }

    const permissions = readPermissionFlagsFromInputs('add');
    const presetKey = String(valueOr(state.permissionAddModal.presetKey, '')).trim();
    const presetEntry = getPermissionPresetByKey(presetKey);
    if (!presetEntry) {
        setStatus(t('permissions_role_select_placeholder', {}, 'Selecione um cargo'), 'warn');
        return;
    }
    openCriticalConfirmModal({
        title: t('permissions_add_modal_title', {}, 'Adicionar Permissao'),
        summary: `Voce gostaria de adicionar permissoes para ${selected.fullname || selected.name || `ID ${selected.source}`}?`,
        badge: 'PERM',
        confirmLabel: t('permissions_add_confirm', {}, 'Adicionar Permissao'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${selected.fullname || selected.name || '-'} [${selected.source}]`,
            `${t('permissions_role_label', {}, 'Cargo')}: ${getPermissionPresetLabel(presetEntry || presetKey)}`,
            `Permissoes: ${countEnabledPermissionFlags(permissions)}`
        ],
        onConfirm: async () => {
            const response = await executeGlobalAction('permissionAddPlayer', {
                targetSource: selected.source,
                presetKey,
                permissions
            });
            if (!response.ok) {
                return response;
            }

            closeModal(permissionAddModal);
            return response;
        }
    });
});

bindEvent(permissionEditModalCloseBtn, 'click', () => {
    closeModal(permissionEditModal);
});

bindEvent(permissionEditAllInput, 'change', () => {
    syncPermissionAllToggle('edit');
});

bindEvent(permissionEditPresetSelect, 'change', (event) => {
    applyPermissionPresetToMode('edit', event.target.value || '');
});

bindEvent(permissionEditOptions, 'click', (event) => {
    const card = event.target.closest('[data-permission-edit-key]');
    if (!card || !permissionEditOptions.contains(card)) {
        return;
    }

    togglePermissionCard('edit', card);
});

bindEvent(permissionEditSaveBtn, 'click', async () => {
    const license = String(valueOr(state.permissionEditModal.license, '')).trim();
    if (!license.length) {
        setStatus('Citizenid invalida.', 'error');
        return;
    }

    const presetKey = String(valueOr(state.permissionEditModal.presetKey, '')).trim();
    const presetEntry = getPermissionPresetByKey(presetKey);
    if (!presetEntry) {
        setStatus(t('permissions_role_select_placeholder', {}, 'Selecione um cargo'), 'warn');
        return;
    }
    const permissions = normalizePermissionFlags(presetEntry.permissions || {});
    const payload = {
        citzenid: license,
        presetKey,
        permissions,
        name: state.permissionEditModal.name || ''
    };
    if (Number(state.permissionEditModal.targetSource || 0) > 0) {
        payload.targetSource = Number(state.permissionEditModal.targetSource || 0);
    }

    openCriticalConfirmModal({
        title: t('permissions_edit_modal_title', {}, 'Editar Permissao'),
        summary: `Voce gostaria de salvar as permissoes de ${state.permissionEditModal.name || license}?`,
        badge: 'PERM',
        confirmLabel: t('permissions_save_btn', {}, 'Salvar Permissao'),
        details: [
            `Citizenid: ${license}`,
            `${t('permissions_role_label', {}, 'Cargo')}: ${presetKey ? getPermissionPresetLabel(presetEntry || presetKey) : t('permissions_role_custom', {}, 'Custom')}`,
            `Permissoes: ${countEnabledPermissionFlags(permissions)}`
        ],
        onConfirm: () => executeGlobalAction('permissionUpdatePlayer', payload),
        closeOnSuccess: [permissionEditModal]
    });
});

bindEvent(permissionPresetList, 'click', (event) => {
    const button = event.target.closest('[data-permission-preset-edit]');
    if (!button) {
        return;
    }

    openPermissionPresetEditModal(String(valueOr(button.dataset.permissionPresetEdit, '')).trim());
});

bindEvent(permissionPresetEditModalCloseBtn, 'click', () => {
    closeModal(permissionPresetEditModal);
});

bindEvent(permissionPresetEditAllInput, 'change', () => {
    syncPermissionAllToggle('preset');
});

bindEvent(permissionPresetEditOptions, 'click', (event) => {
    const card = event.target.closest('[data-permission-preset-key]');
    if (!card || !permissionPresetEditOptions.contains(card)) {
        return;
    }

    togglePermissionCard('preset', card);
});

bindEvent(permissionPresetEditSaveBtn, 'click', async () => {
    const presetKey = String(valueOr(state.permissionPresetEditModal.key, '')).trim();
    if (!presetKey.length) {
        return;
    }

    const permissions = readPermissionFlagsFromInputs('preset');
    const preset = getPermissionPresetByKey(presetKey);
    openCriticalConfirmModal({
        title: t('permissions_role_edit_title', {}, 'Editar Cargo'),
        summary: `Voce gostaria de salvar as permissoes do cargo ${getPermissionPresetLabel(preset || presetKey)}?`,
        badge: 'ROLE',
        confirmLabel: t('permissions_role_save_btn', {}, 'Salvar Cargo'),
        details: [
            `${t('permissions_role_label', {}, 'Cargo')}: ${getPermissionPresetLabel(preset || presetKey)}`,
            `Permissoes: ${countEnabledPermissionFlags(permissions)}`
        ],
        onConfirm: () => executeGlobalAction('permissionPresetUpdate', {
            presetKey,
            permissions
        }),
        closeOnSuccess: [permissionPresetEditModal]
    });
});

bindEvent(permissionRemoveConfirmCancelBtn, 'click', () => {
    closeModal(permissionRemoveConfirmModal);
});

bindEvent(permissionRemoveConfirmCloseBtn, 'click', () => {
    closeModal(permissionRemoveConfirmModal);
});

bindEvent(permissionRemoveConfirmBtn, 'click', async () => {
    const license = String(valueOr(state.permissionRemoveModal.license, '')).trim();
    const entry = getPermissionEntryByLicense(license);
    openCriticalConfirmModal({
        title: t('permissions_remove_modal_title', {}, 'Confirmar Remocao de Permissao'),
        summary: `Voce gostaria de remover esta permissao${entry && entry.name ? ` de ${entry.name}` : ''}?`,
        badge: 'PERM',
        confirmLabel: t('modal_confirm_remove', {}, 'Confirmar Remocao'),
        details: [
            `${t('permissions_remove_modal_target_label', {}, 'Permissao selecionada')}: ${entry && entry.name ? entry.name : '-'} `,
            `Citizenid: ${license || '-'}`
        ],
        onConfirm: submitPermissionRemove,
        closeOnSuccess: [permissionRemoveConfirmModal]
    });
});

bindEvent(criticalConfirmCancelBtn, 'click', () => {
    if (state.criticalConfirm.loading === true) {
        return;
    }
    closeModal(criticalConfirmModal);
});

bindEvent(criticalConfirmCloseBtn, 'click', () => {
    if (state.criticalConfirm.loading === true) {
        return;
    }
    closeModal(criticalConfirmModal);
});

bindEvent(criticalConfirmBtn, 'click', async () => {
    if (state.criticalConfirm.loading === true) {
        return;
    }

    const handler = state.criticalConfirm.onConfirm;
    if (typeof handler !== 'function') {
        return;
    }

    state.criticalConfirm.loading = true;
    setCriticalConfirmButtonState();

    let response = null;
    try {
        response = await handler();
    } catch (_error) {
        setStatus(t('status_action_fail', {}, 'Falha ao executar acao.'), 'error');
    }

    state.criticalConfirm.loading = false;
    if (response && response.ok === true) {
        const closeOnSuccess = Array.isArray(state.criticalConfirm.closeOnSuccess)
            ? [...state.criticalConfirm.closeOnSuccess]
            : [];
        closeModal(criticalConfirmModal);
        closeOnSuccess.forEach((modalElement) => {
            closeModal(modalElement);
        });
        return;
    }

    setCriticalConfirmButtonState();
});

bindEvent(jobSearchInput, 'input', (event) => {
    state.jobModal.search = event.target.value || '';
    renderJobModalList();
});

bindEvent(jobModalList, 'click', (event) => {
    const button = event.target.closest('[data-job-name]');
    if (!button) {
        return;
    }

    state.jobModal.selectedJobName = button.dataset.jobName;
    renderJobModalList();
    renderJobModalGrades();
});

bindEvent(jobModalSetActiveInput, 'change', (event) => {
    state.jobModal.setActive = event.target && event.target.checked === true;
});

bindEvent(jobModalApplyBtn, 'click', async () => {
    const jobName = state.jobModal.selectedJobName;
    const grade = Number(jobModalGradeSelect.value || 0);
    if (!jobName) {
        setStatus(t('status_select_job', {}, 'Selecione um job.'), 'error');
        return;
    }

    const jobEntry = state.catalog.jobs.find((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === String(jobName).trim().toLowerCase()) || null;
    const gradeEntry = jobEntry && Array.isArray(jobEntry.grades)
        ? jobEntry.grades.find((entry) => Number(entry.level || 0) === grade)
        : null;
    const jobLabel = String(valueOr(jobEntry && jobEntry.label, jobName)).trim() || jobName;
    const gradeLabel = gradeEntry && gradeEntry.name ? `${grade} - ${gradeEntry.name}` : String(grade);

    openCriticalConfirmModal({
        title: t('modal_set_job_title', {}, 'Setar Job'),
        summary: `Voce gostaria de aplicar o job ${jobLabel} para ${getSelectedPlayerDisplayName()}?`,
        badge: 'JOB',
        confirmLabel: t('modal_apply_job', {}, 'Aplicar Job no Jogador'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('field_job', {}, 'Job')}: ${jobLabel}`,
            `${t('modal_grade_label', {}, 'Grade')}: ${gradeLabel}`
        ],
        onConfirm: () => executeAction('setJob', { jobName, grade }),
        closeOnSuccess: [jobModal]
    });
});

bindEvent(jobModalMultijobApplyBtn, 'click', async () => {
    const jobName = state.jobModal.selectedJobName;
    const grade = Number(jobModalGradeSelect.value || 0);
    if (!jobName) {
        setStatus(t('status_select_job', {}, 'Selecione um job.'), 'error');
        return;
    }

    const setActive = jobModalSetActiveInput && jobModalSetActiveInput.checked === true;
    const jobEntry = state.catalog.jobs.find((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === String(jobName).trim().toLowerCase()) || null;
    const gradeEntry = jobEntry && Array.isArray(jobEntry.grades)
        ? jobEntry.grades.find((entry) => Number(entry.level || 0) === grade)
        : null;
    const jobLabel = String(valueOr(jobEntry && jobEntry.label, jobName)).trim() || jobName;
    const gradeLabel = gradeEntry && gradeEntry.name ? `${grade} - ${gradeEntry.name}` : String(grade);

    openCriticalConfirmModal({
        title: t('modal_apply_multijob', {}, 'Salvar na Multijob'),
        summary: `Voce gostaria de salvar o job ${jobLabel} na multijob de ${getSelectedPlayerDisplayName()}?`,
        badge: 'MULTI',
        confirmLabel: t('modal_apply_multijob', {}, 'Salvar na Multijob'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('field_job', {}, 'Job')}: ${jobLabel}`,
            `${t('modal_grade_label', {}, 'Grade')}: ${gradeLabel}`,
            `${t('modal_job_set_active', {}, 'Definir como job ativo')}: ${setActive ? 'Sim' : 'Nao'}`
        ],
        onConfirm: async () => {
            const response = await executeAction('upsertMultijobJob', { jobName, grade, setActive });
            if (response.ok) {
                upsertSelectedPlayerMultijobEntry(jobName, grade, setActive);
                renderJobModalMultijob();
            }
            return response;
        }
    });
});

bindEvent(jobModalCloseBtn, 'click', () => {
    closeModal(jobModal);
});

bindEvent(removeJobCancelBtn, 'click', () => {
    closeModal(removeJobConfirmModal);
});

bindEvent(removeJobConfirmCloseBtn, 'click', () => {
    closeModal(removeJobConfirmModal);
});

bindEvent(removeJobConfirmBtn, 'click', async () => {
    const jobName = String(valueOr(state.removeJobModal.jobName, '')).trim();
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_remove_job', {}, 'Selecione um jogador para remover o job.'), 'warn');
        return;
    }

    if (!jobName.length) {
        setStatus(t('status_remove_job_missing', {}, 'Selecione um job para remover.'), 'warn');
        return;
    }

    const selectedEntry = Array.isArray(state.removeJobModal.jobs)
        ? state.removeJobModal.jobs.find((entry) => String(valueOr(entry.name, '')).trim().toLowerCase() === jobName.toLowerCase())
        : null;
    const jobLabel = String(valueOr(selectedEntry && selectedEntry.label, jobName)).trim() || jobName;
    const playerName = getSelectedPlayerDisplayName();

    openCriticalConfirmModal({
        title: t('critical_remove_job_title', {}, 'Confirmar Remocao de Job'),
        summary: t('critical_remove_job_prompt', {
            job: jobLabel,
            player: playerName
        }, 'Voce gostaria de remover o job {job} do player {player}?'),
        variant: 'remove-job',
        badge: 'JOB',
        confirmLabel: t('modal_confirm_remove', {}, 'Confirmar Remocao'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${playerName}`,
            `${t('field_job', {}, 'Job')}: ${jobLabel}`,
            `${t('field_id', {}, 'ID')}: ${jobName}`
        ],
        onConfirm: () => executeAction('removeJob', { jobName }),
        closeOnSuccess: [removeJobConfirmModal]
    });
});

bindEvent(itemSearchInput, 'input', (event) => {
    state.itemModal.search = event.target.value || '';
    renderItemModalList();
});

bindEvent(itemCategoryList, 'click', (event) => {
    const button = event.target.closest('[data-item-category]');
    if (!button) {
        return;
    }

    state.itemModal.category = button.dataset.itemCategory;
    renderItemCategoryList();
    renderItemModalList();
});

bindEvent(itemModalList, 'click', (event) => {
    const button = event.target.closest('[data-item-name]');
    if (!button) {
        return;
    }

    state.itemModal.selectedItemName = button.dataset.itemName;
    renderItemModalList();
    addSelectedItemToQueue(false);
});

bindEvent(itemModalList, 'keydown', (event) => {
    if ((event.key === 'Enter' || event.key === ' ') && event.target.closest('[data-item-name]')) {
        event.preventDefault();
        event.target.click();
    }
});

bindEvent(itemQueueList, 'click', (event) => {
    const actionButton = event.target.closest('[data-queue-action]');
    if (!actionButton) {
        return;
    }

    const row = event.target.closest('[data-queue-item]');
    if (!row) {
        return;
    }

    const itemName = row.dataset.queueItem;
    const entry = state.itemModal.queue.find((item) => item.name === itemName);
    if (!entry) {
        return;
    }

    const action = actionButton.dataset.queueAction;
    if (action === 'remove') {
        state.itemModal.queue = state.itemModal.queue.filter((item) => item.name !== itemName);
    }

    renderItemQueue();
    if (isVisible(itemConfirmModal)) {
        renderItemConfirmationList();
    }
});

bindEvent(itemQueueList, 'change', (event) => {
    const amountInput = event.target.closest('[data-queue-amount-input]');
    if (!amountInput) {
        return;
    }

    const row = amountInput.closest('[data-queue-item]');
    if (!row) {
        return;
    }

    const itemName = row.dataset.queueItem;
    const entry = state.itemModal.queue.find((item) => item.name === itemName);
    if (!entry) {
        return;
    }

    let amount = Math.floor(Number(amountInput.value || 1));
    if (!Number.isFinite(amount) || amount < 1) {
        amount = 1;
    }
    if (amount > 1000) {
        amount = 1000;
    }

    entry.amount = amount;
    renderItemQueue();
    if (isVisible(itemConfirmModal)) {
        renderItemConfirmationList();
    }
});

bindEvent(itemQueueClearBtn, 'click', () => {
    clearItemQueueAndClose();
});

bindEvent(itemQueueConfirmBtn, 'click', () => {
    if (itemQueueConfirmBtn && itemQueueConfirmBtn.disabled) {
        return;
    }
    openItemConfirmFlow();
});

bindEvent(itemModalCloseBtn, 'click', () => {
    state.itemModal.lastCapacity = null;
    renderItemCapacityStatus(null);
    closeModal(itemModal);
    closeModal(itemConfirmModal);
});

bindEvent(itemConfirmCancelBtn, 'click', () => {
    closeModal(itemConfirmModal);
});

bindEvent(itemConfirmCloseBtn, 'click', () => {
    closeModal(itemConfirmModal);
});

bindEvent(itemConfirmSendBtn, 'click', async () => {
    if (!state.itemModal.queue.length) {
        setStatus(t('status_add_item_min_one', {}, 'Adicione pelo menos um item na lista.'), 'error');
        closeModal(itemConfirmModal);
        return;
    }

    if (state.itemModal.sending) {
        return;
    }

    const response = await submitItemQueueConfirmed();
    if (response && response.ok === true) {
        closeModal(itemConfirmModal);
        closeModal(itemModal);
    }
});

bindEvent(moneyModalApplyBtn, 'click', async () => {
    const action = state.moneyModal.mode === 'remove' ? 'removeMoney' : 'addMoney';
    const moneyType = moneyTypeSelect.value;
    const amount = Number(moneyAmountInput.value || 0);
    const payload = {
        moneyType,
        amount
    };

    if (action === 'removeMoney') {
        const player = getSelectedPlayer();
        if (!player) {
            setStatus(t('status_select_player_money', {}, 'Selecione um jogador para alterar dinheiro.'), 'warn');
            return;
        }

        const moneyTypes = getMoneyTypes();
        const entry = moneyTypes.find((item) => item.key === moneyType);
        const typeLabel = entry && entry.label ? entry.label : moneyType;

        openCriticalConfirmModal({
            title: t('critical_remove_money_title', {}, 'Confirmar Remocao de Dinheiro'),
            summary: t('critical_remove_money_summary', {}, 'Esta acao remove dinheiro do jogador selecionado.'),
            variant: 'remove-money',
            badge: 'MONEY',
            confirmLabel: t('modal_money_apply_remove', {}, 'Remover'),
            details: [
                `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
                `${t('modal_money_type_label', {}, 'Tipo de Dinheiro')}: ${typeLabel}`,
                `${t('modal_amount_label', {}, 'Valor')}: ${formatMoney(amount)}`
            ],
            onConfirm: () => executeAction(action, payload),
            closeOnSuccess: [moneyModal]
        });
        return;
    }

    const moneyTypes = getMoneyTypes();
    const entry = moneyTypes.find((item) => item.key === moneyType);
    const typeLabel = entry && entry.label ? entry.label : moneyType;
    openCriticalConfirmModal({
        title: t('modal_add_money_title', {}, 'Adicionar Money'),
        summary: `Voce gostaria de adicionar dinheiro para ${getSelectedPlayerDisplayName()}?`,
        badge: 'MONEY',
        confirmLabel: t('modal_money_apply_add', {}, 'Adicionar'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_money_type_label', {}, 'Tipo de Dinheiro')}: ${typeLabel}`,
            `${t('modal_amount_label', {}, 'Valor')}: ${formatMoney(amount)}`
        ],
        onConfirm: () => executeAction(action, payload),
        closeOnSuccess: [moneyModal]
    });
});

bindEvent(moneyModalCloseBtn, 'click', () => {
    closeModal(moneyModal);
});

bindEvent(supportAdjustModalCloseBtn, 'click', () => {
    closeModal(supportAdjustModal);
});

bindEvent(supportAdjustModalApplyBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_support_adjust', {}, 'Selecione um jogador para ajustar peso ou slots.'), 'warn');
        return;
    }

    const mode = state.supportAdjustModal && state.supportAdjustModal.mode === 'slots' ? 'slots' : 'weight';
    const amount = Math.floor(Number(supportAdjustAmountInput && supportAdjustAmountInput.value ? supportAdjustAmountInput.value : 0));
    if (!Number.isFinite(amount) || amount <= 0) {
        setStatus(
            mode === 'slots'
                ? t('status_slots_amount_invalid', {}, 'Informe uma quantidade valida de slots.')
                : t('status_weight_amount_invalid', {}, 'Informe uma quantidade valida de peso.'),
            'error'
        );
        return;
    }

    const inventory = player.inventory || {};
    if (mode === 'slots') {
        openCriticalConfirmModal({
            title: t('modal_add_slots_title', {}, 'Adicionar Slots'),
            summary: `Voce gostaria de adicionar slots para ${getSelectedPlayerDisplayName()}?`,
            badge: 'SLOTS',
            confirmLabel: t('modal_add_slots_apply', {}, 'Adicionar Slots'),
            details: [
                `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
                `${t('field_slots_total', {}, 'Slots Totais')}: ${formatInteger(valueOr(inventory.maxSlots, 0))}`,
                `${t('modal_amount_label', {}, 'Valor')}: ${formatInteger(amount)}`
            ],
            onConfirm: () => executeAction('addSlots', { amount }),
            closeOnSuccess: [supportAdjustModal]
        });
        return;
    }

    openCriticalConfirmModal({
        title: t('modal_add_weight_title', {}, 'Adicionar Peso'),
        summary: `Voce gostaria de adicionar peso para ${getSelectedPlayerDisplayName()}?`,
        badge: 'KG',
        confirmLabel: t('modal_add_weight_apply', {}, 'Adicionar Peso'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('field_kg_total', {}, 'KG Total')}: ${formatKgFromUnits(valueOr(inventory.maxWeight, 0))}`,
            `${t('modal_amount_label', {}, 'Valor')}: ${formatKgFromUnits(amount)}`
        ],
        onConfirm: () => executeAction('addWeight', { amount }),
        closeOnSuccess: [supportAdjustModal]
    });
});

bindEvent(renamePlayerModalCloseBtn, 'click', () => {
    closeModal(renamePlayerModal);
});

bindEvent(heightPlayerModalCloseBtn, 'click', () => {
    closeModal(heightPlayerModal);
});

bindEvent(heightPlayerPresetGrid, 'click', (event) => {
    const button = event.target.closest('[data-height-preset]');
    if (!button) {
        return;
    }

    state.heightPlayerModal.preset = String(valueOr(button.dataset.heightPreset, '100')).trim() || '100';
    renderHeightPlayerPresetOptions(state.heightPlayerModal.preset);
    syncHeightPlayerCustomInput();
});

bindEvent(renamePlayerModalApplyBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_rename', {}, 'Selecione um jogador para trocar nome e sobrenome.'), 'warn');
        return;
    }

    const firstName = String(valueOr(renamePlayerFirstNameInput && renamePlayerFirstNameInput.value, '')).trim();
    const lastName = String(valueOr(renamePlayerLastNameInput && renamePlayerLastNameInput.value, '')).trim();

    if (!firstName.length) {
        setStatus(t('status_first_name_invalid', {}, 'Informe um nome valido.'), 'error');
        return;
    }

    if (!lastName.length) {
        setStatus(t('status_last_name_invalid', {}, 'Informe um sobrenome valido.'), 'error');
        return;
    }

    openCriticalConfirmModal({
        title: t('modal_rename_player_title', {}, 'Trocar Nome / Sobrenome'),
        summary: t('critical_rename_player_summary', {}, 'O nome sera alterado no banco de dados e o jogador sera kickado automaticamente em 5 segundos para relogar.'),
        badge: 'NAME',
        confirmLabel: t('modal_rename_player_apply', {}, 'Salvar e Kickar'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_first_name_label', {}, 'Nome')}: ${firstName}`,
            `${t('modal_last_name_label', {}, 'Sobrenome')}: ${lastName}`
        ],
        onConfirm: () => executeAction('renameCharacter', {
            firstName,
            lastName
        }),
        closeOnSuccess: [renamePlayerModal]
    });
});

bindEvent(heightPlayerModalApplyBtn, 'click', async () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_change_height', {}, 'Selecione um jogador para alterar a altura.'), 'warn');
        return;
    }

    const presetValue = String(valueOr(state.heightPlayerModal.preset, '100')).trim() || '100';
    const isCustom = presetValue === 'custom';
    const rawValue = isCustom
        ? String(valueOr(heightPlayerCustomInput && heightPlayerCustomInput.value, '')).trim()
        : presetValue;
    const heightValue = Number(rawValue);

    if (!Number.isFinite(heightValue) || heightValue <= 0) {
        setStatus(t('status_height_invalid', {}, 'Informe uma altura valida maior que zero.'), 'error');
        return;
    }

    const formattedHeight = formatHeightValue(heightValue);
    openCriticalConfirmModal({
        title: t('modal_change_height_title', {}, 'Alterar Altura'),
        summary: t('critical_change_height_summary', {}, 'A altura sera alterada no banco de dados e o jogador sera kickado automaticamente em 5 segundos para relogar.'),
        badge: 'SIZE',
        confirmLabel: t('modal_change_height_apply', {}, 'Salvar e Kickar'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('modal_height_label', {}, 'Altura')}: ${formattedHeight}`,
            `${t('modal_height_preset_label', {}, 'Altura Padrao')}: ${isCustom ? t('modal_height_preset_custom', {}, 'Personalizada') : getHeightPresetLabel(presetValue)}`
        ],
        onConfirm: () => executeAction('changeHeight', {
            height: Math.round(heightValue * 10) / 10
        }),
        closeOnSuccess: [heightPlayerModal]
    });
});

bindEvent(clearInventoryBtn, 'click', () => {
    const player = getSelectedPlayer();
    if (!player) {
        setStatus(t('status_select_player_clear_inventory', {}, 'Selecione um jogador para limpar o inventario.'), 'warn');
        return;
    }

    openCriticalConfirmModal({
        title: t('critical_clear_inventory_title', {}, 'Limpar Inventario'),
        summary: t('critical_clear_inventory_summary', {}, 'Esta acao remove todos os itens do inventario do jogador selecionado.'),
        badge: 'INV',
        confirmLabel: t('action_clear_inventory', {}, 'Limpar Inventario'),
        details: [
            `${t('modal_player_label', {}, 'Jogador')}: ${getSelectedPlayerIdentityLabel()}`,
            `${t('field_slots_total', {}, 'Slots Totais')}: ${formatInteger(valueOr(player.inventory && player.inventory.maxSlots, 0))}`,
            `${t('field_kg_used', {}, 'KG em Uso')}: ${formatKgFromUnits(valueOr(player.inventory && player.inventory.usedWeight, 0))}`
        ],
        onConfirm: () => executeAction('clearInventory'),
        closeOnSuccess: []
    });
});

bindEvent(coordsModalCloseBtn, 'click', () => {
    closeModal(coordsModal);
});

bindEvent(coordsModalGrid, 'click', (event) => {
    const copyField = event.target.closest('[data-coords-copy-field]');
    if (!copyField) {
        return;
    }

    const fieldKey = copyField.dataset.coordsCopyField || '';
    copyCoordsField(fieldKey);
});

bindEvent(moneyTypeSelect, 'change', () => {
    renderMoneyModalInfo();
});

bindEvent(refreshBtn, 'click', async () => {
    try {
        const result = await postNui('refresh');
        if (!result || result.ok !== true) {
            setStatus((result && result.message) || t('status_refresh_fail', {}, 'Falha ao atualizar.'), 'error');
            return;
        }

        setStatus(t('status_panel_updated', {}, 'Painel atualizado.'), 'ok');
    } catch (_error) {
        setStatus(t('status_refresh_panel_fail', {}, 'Falha ao atualizar painel.'), 'error');
    }
});

bindEvent(closeBtn, 'click', () => {
    postNui('close').catch(() => {
        setStatus(t('status_close_fail', {}, 'Falha ao fechar painel.'), 'error');
    });
});

window.addEventListener('keydown', (event) => {
    if (event.key !== 'Escape') {
        return;
    }

    if (isVisible(jobModal)) {
        closeModal(jobModal);
        return;
    }

    if (isVisible(removeJobConfirmModal)) {
        closeModal(removeJobConfirmModal);
        return;
    }

    if (isVisible(itemConfirmModal)) {
        closeModal(itemConfirmModal);
        return;
    }

    if (isVisible(itemModal)) {
        closeModal(itemModal);
        return;
    }

    if (isVisible(moneyModal)) {
        closeModal(moneyModal);
        return;
    }

    if (isVisible(supportAdjustModal)) {
        closeModal(supportAdjustModal);
        return;
    }

    if (isVisible(coordsModal)) {
        closeModal(coordsModal);
        return;
    }

    if (isVisible(developerCharacterInfoModal)) {
        closeModal(developerCharacterInfoModal);
        return;
    }

    if (isVisible(deleteCharacterModal)) {
        closeModal(deleteCharacterModal);
        return;
    }

    if (isVisible(criticalConfirmModal)) {
        if (state.criticalConfirm.loading === true) {
            return;
        }
        closeModal(criticalConfirmModal);
        return;
    }

    if (isVisible(messageModal)) {
        closeModal(messageModal);
        return;
    }

    if (isVisible(kickModal)) {
        closeModal(kickModal);
        return;
    }

    if (isVisible(companyStashModal)) {
        closeModal(companyStashModal);
        return;
    }

    if (isVisible(horseModal)) {
        closeModal(horseModal);
        return;
    }

    if (isVisible(permissionAddModal)) {
        closeModal(permissionAddModal);
        return;
    }

    if (isVisible(permissionEditModal)) {
        closeModal(permissionEditModal);
        return;
    }

    if (isVisible(permissionRemoveConfirmModal)) {
        closeModal(permissionRemoveConfirmModal);
        return;
    }

    if (isVisible(permissionPresetEditModal)) {
        closeModal(permissionPresetEditModal);
        return;
    }

    if (state.open) {
        postNui('close').catch(() => {
            setStatus(t('status_close_fail', {}, 'Falha ao fechar painel.'), 'error');
        });
        return;
    }

});

window.addEventListener('resize', () => {
    updateItemQueueDockPosition();
});

bindEvent(jobModal, 'click', (event) => {
    if (event.target === jobModal) {
        closeModal(jobModal);
    }
});

bindEvent(removeJobConfirmModal, 'click', (event) => {
    const selectEntryBtn = event.target.closest('[data-select-remove-job-name]');
    if (selectEntryBtn) {
        const jobName = String(valueOr(selectEntryBtn.dataset.selectRemoveJobName, '')).trim();
        if (!jobName.length) {
            return;
        }

        state.removeJobModal.jobName = jobName.toLowerCase();
        openRemoveJobConfirmModal();
        return;
    }

    if (event.target === removeJobConfirmModal) {
        closeModal(removeJobConfirmModal);
    }
});

bindEvent(itemModal, 'click', (event) => {
    if (event.target === itemModal) {
        closeModal(itemModal);
    }
});

bindEvent(itemConfirmModal, 'click', (event) => {
    if (event.target === itemConfirmModal) {
        closeModal(itemConfirmModal);
    }
});

bindEvent(moneyModal, 'click', (event) => {
    if (event.target === moneyModal) {
        closeModal(moneyModal);
    }
});

bindEvent(supportAdjustModal, 'click', (event) => {
    if (event.target === supportAdjustModal) {
        closeModal(supportAdjustModal);
    }
});

bindEvent(renamePlayerModal, 'click', (event) => {
    if (event.target === renamePlayerModal) {
        closeModal(renamePlayerModal);
    }
});

bindEvent(heightPlayerModal, 'click', (event) => {
    if (event.target === heightPlayerModal) {
        closeModal(heightPlayerModal);
    }
});

bindEvent(coordsModal, 'click', (event) => {
    if (event.target === coordsModal) {
        closeModal(coordsModal);
    }
});

bindEvent(deleteCharacterModal, 'click', (event) => {
    if (event.target === deleteCharacterModal) {
        closeModal(deleteCharacterModal);
    }
});

bindEvent(developerCharacterInfoModal, 'click', (event) => {
    if (event.target === developerCharacterInfoModal) {
        closeModal(developerCharacterInfoModal);
    }
});

bindEvent(messageModal, 'click', (event) => {
    if (event.target === messageModal) {
        closeModal(messageModal);
    }
});

bindEvent(kickModal, 'click', (event) => {
    if (event.target === kickModal) {
        closeModal(kickModal);
    }
});

bindEvent(companyStashModal, 'click', (event) => {
    if (event.target === companyStashModal) {
        closeModal(companyStashModal);
    }
});

bindEvent(horseModal, 'click', (event) => {
    if (event.target === horseModal) {
        closeModal(horseModal);
    }
});

bindEvent(permissionAddModal, 'click', (event) => {
    if (event.target === permissionAddModal) {
        closeModal(permissionAddModal);
    }
});

bindEvent(permissionEditModal, 'click', (event) => {
    if (event.target === permissionEditModal) {
        closeModal(permissionEditModal);
    }
});

bindEvent(permissionRemoveConfirmModal, 'click', (event) => {
    if (event.target === permissionRemoveConfirmModal) {
        closeModal(permissionRemoveConfirmModal);
    }
});

bindEvent(permissionPresetEditModal, 'click', (event) => {
    if (event.target === permissionPresetEditModal) {
        closeModal(permissionPresetEditModal);
    }
});

bindEvent(criticalConfirmModal, 'click', (event) => {
    if (event.target === criticalConfirmModal) {
        if (state.criticalConfirm.loading === true) {
            return;
        }
        closeModal(criticalConfirmModal);
    }
});

bindEvent(document, 'click', (event) => {
    if (event.target.closest('.option-button-group')) {
        return;
    }

    closeAllCustomSelects();
});

setupCustomSelects();
renderTeleportCategoryOptions();
renderTeleports();
setActivePanel('dashboard');
applyStaticTranslations();
syncAppVisibility();
postNui('ready').catch(() => {
    setStatus(t('status_init_fail', {}, 'Falha ao inicializar NUI.'), 'error');
});


