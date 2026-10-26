# bilto_admin

Painel administrativo NUI para RedM/RSG, focado em suporte, moderacao, utilidades operacionais e manutencao de contas/personagens.

## Dependencias obrigatorias
- `ox_lib`
- `oxmysql`
- `rsg-core`
- `rsg-medic`
- `rsg-inventory`
- `rsg-bossmenu`
- `rsg-multijob`

O recurso trabalha apenas com o caminho principal do framework. Nao ha compat layer para APIs antigas de job/money.

## Startup
1. Garanta `ensure [BILTO]` no boot do servidor.
2. Reinicie o servidor ou rode `ensure bilto_admin`.
3. Execute `bilto_admin_selfcheck` no console do servidor.
4. Abra `/admin` com um staff autorizado.

## Comandos
- `/admin`: abre o painel.
- `/nc`: alterna o noclip administrativo.
- `bilto_admin_selfcheck`: valida dependencias, comandos, handlers, acoes, IDs da NUI e rotas de painel.

## Controle de acesso
- Acesso pelos grupos da framework (`god`, `headadmin`, `developer`, `admin`, `mod`, `helper`). O GOD edita as permissoes de cada cargo na aba Permissoes (salvo em `bilto_admin_role_permissions`) e da o cargo aos jogadores (salvo por citizenid; o grupo `rsgcore.<cargo>` e aplicado no login). `Config.FrameworkRoles` so define o valor inicial. A NUI so mostra as opcoes liberadas.
- ACL granular via tabela `bilto_admin_permissions`.
- Permissoes view-only e permissoes executaveis usam o mesmo catalogo entregue pelo servidor.

## Estrutura do recurso
- `fxmanifest.lua`: manifesto, ordem de carga e dependencias.
- `config.lua`: configuracao declarativa.
- `locale.lua`: strings PT-BR/EN.
- `version.lua`: metadados de versao.
- `client/main.lua`: bridge NUI, foco, blips, wall, spectate, callbacks e toasts.
- `client/noclip.lua`: runtime do noclip.
- `client/wall.lua`: renderizacao do wall e leitura do estado de arma.
- `server/main.lua`: ACL, RPC, acoes administrativas, persistencia, cache, observabilidade e self-check.
- `ui/index.html`: shell da NUI e modais.
- `ui/script.js`: store da SPA, render, modais e execucao de acoes.
- `ui/style.css`: layout, tema e responsividade.
- `ui/images/.gitkeep`: pasta reservada; sem assets de runtime.
- `AUDIT_REPORT.md`: inventario, grafos e mapa final.
- `VALIDATION.md`: roteiro de regressao e cenarios de teste.
- `CHANGELOG.md`: historico da refatoracao.

## Modulos funcionais
- Dashboard: metricas online, distribuicao por job e totais globais de money.
- Players: busca, selecao e entrada no fluxo de suporte.
- Support: goto, bring, spectate, revive, heal, freeze, inventory, job, multijob, item, money, peso, slots, rename, height, clear inventory, PM, kick e ban.
- Utilities: copiar coordenadas, blips, wall, noclip, cavalo admin e bau de empresa.
- Developer: busca e delecao de personagem por citizenid.
- Moderation: lista de bans ativos, edicao de expiracao e remocao.
- Permissions: ACL customizada por citizenid/license e presets de cargo.

## Persistencia
- `bilto_admin_permissions`: ACL customizada do painel.
- `bilto_admin_permission_presets`: presets editaveis de permissao.
- `bans`: banimentos ativos/historico operacional.

## Validacao rapida
1. Rode `bilto_admin_selfcheck` e confirme `ok=true`.
2. Abra `/admin`.
3. Valide Dashboard, Players, Support, Utilities, Developer, Moderation e Permissions.
4. Reinicie o resource e confirme limpeza de foco, spectate, freeze, wall e blips.
5. Siga o checklist completo em `VALIDATION.md`.
