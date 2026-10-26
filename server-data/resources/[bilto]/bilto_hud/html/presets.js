// Elementos disponiveis na HUD.
//   kind: stat (0-100) | voice | flag (so aparece quando ativo) | info (texto)
//   inverse: quanto maior, pior (estresse)
//   mountOnly: so aparece montado
//   icons: icones que o jogador pode escolher para esse elemento (so do mesmo tema)
window.ELEMENTS = {
    health:        { label: 'Vida',              group: 'player', kind: 'stat',  icon: 'heart',     color: '#e5484d',
                     icons: ['heart', 'heartpulse', 'heartplus', 'heartfill', 'heartcrack', 'cross', 'medkit', 'bandage', 'syringe', 'shield'] },
    stamina:       { label: 'Stamina',           group: 'player', kind: 'stat',  icon: 'bolt',      color: '#f5d90a',
                     icons: ['bolt', 'boltcircle', 'activity', 'wind', 'footprints', 'gauge', 'battery', 'flame'] },
    hunger:        { label: 'Fome',              group: 'player', kind: 'stat',  icon: 'drumstick', color: '#f76b15',
                     icons: ['drumstick', 'utensils', 'apple', 'bread', 'beef', 'carrot', 'fish', 'soup'] },
    thirst:        { label: 'Sede',              group: 'player', kind: 'stat',  icon: 'drop',      color: '#3b9eff',
                     icons: ['drop', 'droplets', 'glass', 'beer', 'wine', 'bottle', 'coffee', 'canteen'] },
    cleanliness:   { label: 'Higiene',           group: 'player', kind: 'stat',  icon: 'sparkles',  color: '#7ce2fe',
                     icons: ['sparkles', 'bath', 'bubbles', 'shower', 'bucket', 'drop'] },
    stress:        { label: 'Estresse',          group: 'player', kind: 'stat',  icon: 'frown',     color: '#d6409f', inverse: true,
                     icons: ['frown', 'angry', 'brain', 'storm', 'alert', 'flame', 'skull'] },
    voice:         { label: 'Voz',               group: 'player', kind: 'voice', icon: 'mic',       color: '#ffffff',
                     icons: ['mic', 'volume', 'megaphone', 'waves', 'speech', 'ear'] },
    horse_health:  { label: 'Vida do cavalo',    group: 'horse',  kind: 'stat',  icon: 'horse',     color: '#c27c2c', mountOnly: true,
                     icons: ['horse', 'heart', 'heartpulse', 'heartplus', 'cross', 'medkit'] },
    horse_stamina: { label: 'Stamina do cavalo', group: 'horse',  kind: 'stat',  icon: 'horseshoe', color: '#e0a84f', mountOnly: true,
                     icons: ['horseshoe', 'bolt', 'boltcircle', 'wind', 'activity', 'gauge'] },
    horse_clean:   { label: 'Higiene do cavalo', group: 'horse',  kind: 'stat',  icon: 'brush',     color: '#a58a66', mountOnly: true,
                     icons: ['brush', 'sparkles', 'bubbles', 'bath', 'bucket', 'drop'] },
    cash:          { label: 'Dinheiro',          group: 'info',   kind: 'info',  icon: 'dollar',    color: '#4cc38a',
                     icons: ['dollar', 'banknote', 'wallet', 'coins', 'moneybag'] },
    gold:          { label: 'Ouro',              group: 'info',   kind: 'info',  icon: 'goldbars',  color: '#f1c21b',
                     icons: ['goldbars', 'coins', 'gem', 'crown', 'moneybag'] },
    bank:          { label: 'Banco',             group: 'info',   kind: 'info',  icon: 'bank',      color: '#8da4ef', hidden: true,
                     icons: ['bank', 'vault', 'wallet', 'banknote', 'moneybag'] },
    bloodmoney:    { label: 'Dinheiro sujo',     group: 'info',   kind: 'info',  icon: 'coins',     color: '#e5484d', hidden: true,
                     icons: ['coins', 'banknote', 'moneybag', 'wallet', 'skull', 'drop'] },
    id:            { label: 'Seu ID',            group: 'info',   kind: 'info',  icon: 'idcard',    color: '#ffffff',
                     icons: ['idcard', 'user', 'hash', 'sheriff'] },
    clock:         { label: 'Horario',           group: 'info',   kind: 'info',  icon: 'clock',     color: '#ffffff',
                     icons: ['clock', 'pocketwatch', 'hourglass', 'sun', 'moon'] },
    temp:          { label: 'Temperatura',       group: 'info',   kind: 'info',  icon: 'thermo',    color: '#ffb224',
                     icons: ['thermo', 'sun', 'snow', 'cloudsun', 'flame', 'wind'] },
    mail:          { label: 'Telegrama',         group: 'info',   kind: 'flag',  icon: 'mail',      color: '#f1c21b',
                     icons: ['mail', 'mailopen', 'scroll', 'feather', 'bell'] },
    outlaw:        { label: 'Procurado',         group: 'info',   kind: 'flag',  icon: 'star',      color: '#e5484d',
                     icons: ['star', 'sheriff', 'target', 'skull', 'alert'] },
    // imagem do servidor (Config.LogoUrl ou html/assets/logo.png); posicao escolhida por botoes no topo
    logo:          { label: 'Logo do servidor',  group: 'server', kind: 'logo',  icon: 'image',     color: '#ffffff',
                     icons: ['image'] },
};

window.GROUPS = {
    player: 'Jogador',
    horse: 'Cavalo',
    info: 'Informacoes',
    server: 'Servidor',
};

// posicoes da logo (sempre no topo). x usa a ancora proporcional: 0 = borda esquerda, 50 = centro, 100 = borda direita
window.LOGO_POSITIONS = {
    left:   { label: 'Esquerda', x: 0 },
    center: { label: 'Centro',   x: 50 },
    right:  { label: 'Direita',  x: 100 },
};

window.STAT_STYLES = {
    crystal:   'Cristal',
    ring:      'Circulo',
    arc:       'Medidor',
    diamond:   'Diamante',
    hex:       'Hexagono',
    octagon:   'Octogono',
    square:    'Quadrado',
    shield:    'Brasao',
    star:      'Estrela',
    orb:       'Orbe',
    tile:      'Bloco',
    dots:       'Pontinhos',
    segring:    'Anel',
    sunburst:   'Raios',
    hexseg:     'Colmeia',
    diamondseg: 'Losango',
    corners:    'Mira',
    blades:     'Turbina',
    compass:    'Bussola',
    dotrow:    'Bolinhas',
    squares:   'Quadradinhos',
    battery:   'Bateria',
    pips:      'Segmentos',
    bar:       'Barra',
    vbar:      'Vertical',
    minimal:   'Minimalista',
};

window.INFO_STYLES = {
    pill:  'Capsula',
    card:  'Cartao',
    plain: 'Simples',
};

window.SWATCHES = [
    '#ffffff', '#e5484d', '#f76b15', '#ffb224', '#f5d90a', '#4cc38a',
    '#3b9eff', '#7ce2fe', '#8e4ec6', '#d6409f', '#c27c2c', '#8a7360',
];

const PLAYER = ['health', 'stamina', 'hunger', 'thirst', 'cleanliness', 'stress', 'voice'];
const HORSE = ['horse_health', 'horse_stamina', 'horse_clean'];
const INFO = ['cash', 'gold', 'bank', 'bloodmoney', 'id', 'clock', 'temp'];
const FLAGS = ['mail', 'outlaw'];

// Posicao padrao de todos os modelos: status no centro inferior, cavalo logo acima,
// informacoes no canto superior direito e alertas no topo central.
//   dir: row | col      origem (em rem): l / r / x(centro) e t / b / y(centro)
// Um rem equivale a ~1.48% da altura da tela, entao funciona em qualquer resolucao.
function centerBottom(opts) {
    opts = opts || {};
    const gap = opts.gap != null ? opts.gap : 0.5;
    const horseB = opts.horseB != null ? opts.horseB : 5.6;
    return [
        { keys: PLAYER, dir: 'row', x: 0, b: 1.4, gap },
        { keys: HORSE, dir: 'row', x: 0, b: horseB, gap },
        { keys: INFO, dir: 'col', r: 1.4, t: 1.4, gap: opts.infoGap != null ? opts.infoGap : 0.5 },
        // alertas logo abaixo da logo do servidor (que fica no topo central)
        { keys: FLAGS, dir: 'row', x: 0, t: 8, gap: 0.6 },
    ];
}

const WESTERN_PALETTE = {
    health: '#b8432f', stamina: '#d9a441', hunger: '#a86a3a', thirst: '#6f8fa6',
    cleanliness: '#9fb4a0', stress: '#8c3b52', voice: '#efe3c8',
    horse_health: '#b8432f', horse_stamina: '#d9a441', horse_clean: '#9fb4a0',
    cash: '#d9a441', gold: '#e8c15a', id: '#efe3c8', clock: '#efe3c8', temp: '#d9a441',
};

// cores vivas para os modelos modernos
const NEON_PALETTE = {
    health: '#ff3b6b', stamina: '#ffe14d', hunger: '#ff8a3d', thirst: '#3dd6ff',
    cleanliness: '#7dffb3', stress: '#c86bff', voice: '#ffffff',
    horse_health: '#ff3b6b', horse_stamina: '#ffe14d', horse_clean: '#7dffb3',
};

window.PRESETS = {
    cristal:    { label: 'Cristal',      desc: 'Vidro escuro com liquido animado e borda que brilha.', stat: 'crystal',  info: 'card',  groups: centerBottom({ gap: 0.55 }) },
    classico:   { label: 'Classico',     desc: 'Circulos com a borda que se preenche.',              stat: 'ring',      info: 'pill',  groups: centerBottom() },
    western:    { label: 'Western',      desc: 'Diamantes em tons de couro e ouro.',                 stat: 'diamond',   info: 'card',  groups: centerBottom({ gap: 0.9, horseB: 6 }), palette: WESTERN_PALETTE, iconColor: '#f4ead2' },
    xerife:     { label: 'Xerife',       desc: 'Estrelas de distintivo em tons de latao.',           stat: 'star',      info: 'card',  groups: centerBottom(), palette: WESTERN_PALETTE, iconColor: '#f6ecd4' },
    brasao:     { label: 'Brasao',       desc: 'Escudos lado a lado.',                               stat: 'shield',    info: 'pill',  groups: centerBottom({ gap: 0.6, horseB: 5.8 }) },
    hexagonal:  { label: 'Hexagonal',    desc: 'Hexagonos encaixados.',                              stat: 'hex',       info: 'pill',  groups: centerBottom({ gap: 0.4 }) },
    octogonal:  { label: 'Octogonal',    desc: 'Octogonos com borda grossa.',                        stat: 'octagon',   info: 'pill',  groups: centerBottom() },
    quadrado:   { label: 'Quadrado',     desc: 'Quadrados arredondados.',                            stat: 'square',    info: 'pill',  groups: centerBottom() },
    medidor:    { label: 'Medidor',      desc: 'Ponteiros em arco, como um painel de instrumentos.', stat: 'arc',       info: 'pill',  groups: centerBottom() },
    orbes:      { label: 'Orbes',        desc: 'Bolhas que enchem como liquido.',                    stat: 'orb',       info: 'plain', groups: centerBottom({ gap: 0.6, infoGap: 0.3 }) },
    blocos:     { label: 'Blocos',       desc: 'Quadradinhos com barra embaixo.',                    stat: 'tile',      info: 'card',  groups: centerBottom({ gap: 0.4 }) },
    pontilhado: { label: 'Pontilhado',   desc: 'Anel de pontinhos que apagam conforme o status cai.', stat: 'dots',     info: 'pill',  groups: centerBottom() },
    anel:       { label: 'Anel',         desc: 'Anel cortado em gomos que apagam um a um.',          stat: 'segring',   info: 'pill',  groups: centerBottom() },
    raios:      { label: 'Raios',        desc: 'Tracinhos radiais, como um mostrador de relogio.',   stat: 'sunburst',  info: 'pill',  groups: centerBottom() },
    colmeia:    { label: 'Colmeia',      desc: 'Hexagono com a borda em segmentos.',                 stat: 'hexseg',    info: 'pill',  groups: centerBottom() },
    losango:    { label: 'Losango',      desc: 'Losango com a borda em segmentos.',                  stat: 'diamondseg', info: 'card', groups: centerBottom({ gap: 0.7 }), palette: WESTERN_PALETTE, iconColor: '#f4ead2' },
    mira:       { label: 'Mira',         desc: 'Cantoneiras de mira em volta do icone.',             stat: 'corners',   info: 'pill',  groups: centerBottom() },
    turbina:    { label: 'Turbina',      desc: 'Laminas inclinadas em cores neon.',                  stat: 'blades',    info: 'pill',  groups: centerBottom(), palette: NEON_PALETTE },
    bussola:    { label: 'Bussola',      desc: 'Setas apontando para fora, como uma rosa dos ventos.', stat: 'compass', info: 'card',  groups: centerBottom({ gap: 0.6 }), palette: WESTERN_PALETTE, iconColor: '#f4ead2' },
    bolinhas:   { label: 'Bolinhas',     desc: 'Selo com cinco bolinhas embaixo.',                   stat: 'dotrow',    info: 'pill',  groups: centerBottom({ gap: 0.4, horseB: 5.4 }) },
    quadradinhos: { label: 'Quadradinhos', desc: 'Selo com cinco quadradinhos embaixo.',             stat: 'squares',   info: 'pill',  groups: centerBottom({ gap: 0.4, horseB: 5.4 }) },
    bateria:    { label: 'Bateria',      desc: 'Selo com uma pilha que descarrega em gomos.',        stat: 'battery',   info: 'pill',  groups: centerBottom({ gap: 0.5, horseB: 5.4 }) },
    segmentos:  { label: 'Segmentos',    desc: 'Selo com tracinhos embaixo.',                        stat: 'pips',      info: 'pill',  groups: centerBottom({ gap: 0.4, horseB: 5.4 }) },
    barras:     { label: 'Barras',       desc: 'Selo com uma barrinha embaixo.',                stat: 'bar',       info: 'pill',  groups: centerBottom({ gap: 0.4, horseB: 5.4 }) },
    minimal:    { label: 'Minimalista',  desc: 'So os icones, que se enchem conforme o status.',     stat: 'minimal',   info: 'plain', groups: centerBottom({ gap: 0.8, horseB: 5, infoGap: 0.2 }), autoHide: true },
};
