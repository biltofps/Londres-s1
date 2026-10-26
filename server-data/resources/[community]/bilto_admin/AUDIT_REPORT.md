# Auditoria e Mapa Final - bilto_admin

Data: 2026-06-15

## 1. Escopo auditado

Arquivos de runtime e documentacao auditados:
- `fxmanifest.lua`
- `config.lua`
- `locale.lua`
- `version.lua`
- `client/main.lua`
- `client/noclip.lua`
- `client/wall.lua`
- `server/main.lua`
- `ui/index.html`
- `ui/script.js`
- `ui/style.css`
- `ui/images/.gitkeep`
- `README.md`
- `CHANGELOG.md`
- `VALIDATION.md`
- `AUDIT_REPORT.md`

## 2. Inventario e proposito

- `fxmanifest.lua`: manifesta o recurso, shared scripts, scripts client/server, NUI e dependencias.
- `config.lua`: configuracao declarativa e limites operacionais.
- `locale.lua`: catalogo de textos PT-BR/EN para UI, client e server.
- `version.lua`: versao do recurso.
- `client/main.lua`: foco/NUI, callbacks, toasts, spectate, blips, wall tracking e ciclo de vida do painel.
- `client/noclip.lua`: controle de noclip, HUD, movimento e limpeza de estado.
- `client/wall.lua`: resolucao de coords, arma, vida e linhas desenhadas no wall.
- `server/main.lua`: autorizacao, callbacks RPC, acoes admin, persistencia, cache, logs e self-check.
- `ui/index.html`: layout da SPA, navegacao, tabelas e modais.
- `ui/script.js`: store da NUI, renderizacao, acoes, validacoes e modais.
- `ui/style.css`: layout, responsividade e tema.
- `ui/images/.gitkeep`: pasta reservada, sem assets utilizados em runtime.
- `README.md`: setup e uso.
- `CHANGELOG.md`: historico consolidado da refatoracao.
- `VALIDATION.md`: checklist de regressao.
- `AUDIT_REPORT.md`: mapa tecnico final.

## 3. Fronteiras do sistema

### Server
- Autoridade total de permissao e autorizacao.
- Persistencia em `bilto_admin_permissions`, `bilto_admin_permission_presets` e `bans`.
- Leitura de dados framework/inventory/multijob.
- Execucao real das acoes administrativas.

### Client
- Foco NUI, toasts, callbacks NUI.
- Runtime de spectate, wall, blips e noclip.
- Coleta de estado efemero para wall weapon state.

### UI
- Navegacao do painel.
- Tabelas e modais.
- Validacao de entrada antes do RPC.

## 4. Handler / endpoint graph

### Server handlers
- `RegisterNetEvent`
  - `bilto_admin:server:updateWallWeaponState`
- `lib.callback.register`
  - `bilto_admin:server:getPanelState`
  - `bilto_admin:server:getBlipPlayers`
  - `bilto_admin:server:canExecutePanelAction`
  - `bilto_admin:server:performAction`
- `AddEventHandler`
  - `playerDropped`
  - `onResourceStart`
- `RSGCore.Commands.Add`
  - `${Config.Command}` (`/admin`)
  - `${Config.Noclip.command}` (`/nc`)
- `RegisterCommand`
  - `bilto_admin_selfcheck`

### Client handlers
- `RegisterNetEvent`
  - `bilto_admin:client:openPanel`
  - `bilto_admin:client:teleportTo`
  - `bilto_admin:client:setFrozen`
  - `bilto_admin:client:receiveStaffMessage`
  - `bilto_admin:client:showToast`
  - `bilto_admin:client:restoreStamina`
  - `bilto_admin:client:togglePlayerBlips`
  - `bilto_admin:client:togglePlayerWall`
  - `bilto_admin:client:spawnAdminHorse`
  - `bilto_admin:client:spectate:setState`
  - `bilto_admin:client:noclip:setEnabled`
- `RegisterNUICallback`
  - `ready`
  - `refresh`
  - `getCurrentCoords`
  - `canExecutePanelAction`
  - `copyToClipboard`
  - `performAction`
  - `openInventoryFast`
  - `close`
- `AddEventHandler`
  - `onResourceStop`

### NUI messages
- `SendNUIMessage` do client para UI
  - `bilto_admin:toggle`
  - `bilto_admin:updateState`
  - `bilto_admin:toast`
- Rotas `fetch` da UI para o client
  - `ready`
  - `refresh`
  - `getCurrentCoords`
  - `canExecutePanelAction`
  - `copyToClipboard`
  - `performAction`
  - `openInventoryFast`
  - `close`

### Exports publicos
- Nenhum `client_export` ou `server_export` no `fxmanifest.lua`.

## 5. Grafo de acoes (`performAction`)

### Acoes executaveis
- `goto`
- `bring`
- `revive`
- `heal`
- `toggleFreeze`
- `spectate`
- `openInventory`
- `openCompanyStash`
- `togglePlayerBlips`
- `togglePlayerWall`
- `toggleNoclip`
- `spawnAdminHorse`
- `kick`
- `privateMessage`
- `setJob`
- `upsertMultijobJob`
- `removeJob`
- `banPlayer`
- `editBan`
- `removeBan`
- `addItem`
- `checkItemCapacity`
- `addMoney`
- `removeMoney`
- `addWeight`
- `addSlots`
- `renameCharacter`
- `changeHeight`
- `clearInventory`
- `findCharacterByCitizenid`
- `deleteCharacterByCitizenid`
- `permissionAddPlayer`
- `permissionUpdatePlayer`
- `permissionRemovePlayer`
- `permissionPresetUpdate`

### Permissoes view-only sem handler
- `copyCoords`
- `viewBannedPlayers`
- `viewUtilitiesPanel`
- `viewDeveloperPanel`
- `manage_permissions`

## 6. Event / message flow

### Client -> Server
- `TriggerServerEvent('bilto_admin:server:updateWallWeaponState', payload)`
- `lib.callback.await('bilto_admin:server:getPanelState')`
- `lib.callback.await('bilto_admin:server:getBlipPlayers')`
- `lib.callback.await('bilto_admin:server:canExecutePanelAction', action)`
- `lib.callback.await('bilto_admin:server:performAction', payload)`

### Server -> Client
- `bilto_admin:client:*`
- `rsg-medic:client:adminRevive`
- `rsg-medic:client:adminHeal`
- `hud:client:UpdateNeeds`
- `hud:client:UpdateStress`
- `rsg-inventory:client:openInventory`

### Client -> UI
- `bilto_admin:toggle`
- `bilto_admin:updateState`
- `bilto_admin:toast`

## 7. Loops / threads / schedulers

### Client
- `client/main.lua`
  - wall weapon state sync: `180ms` armado / `450ms` desarmado.
  - tecla de toggle do painel: loop por frame (`Wait(0)`).
  - spectate thread: `180ms` entre iteracoes, timeout de perda de alvo em 12 ciclos com `250ms`.
  - tracking de players para wall/blips: `500ms`, apenas quando wall ou blips estao ativos.
  - restore stamina: thread curta com atrasos `0, 150, 350, 700, 1200, 1800, 2600ms`.
- `client/noclip.lua`
  - HUD: por frame enquanto o HUD esta ativo.
  - loop principal: `IdleWaitMs` em idle (`400ms` padrao), `Wait(0)` em uso.

### Server
- `SetTimeout(5000)` e `SetTimeout(10000)` no fluxo de delecao de personagem online.

## 8. Dependencias e acoplamentos

- `ox_lib`: callbacks client/server.
- `oxmysql`: persistencia SQL e bootstrap de tabelas.
- `rsg-core`: players, jobs, money, comandos e catalogos.
- `rsg-medic`: revive/heal.
- `rsg-inventory`: inventario, capacidade, stash e clear inventory.
- `rsg-bossmenu`: catalogo de company stashes.
- `rsg-multijob`: leitura, upsert e remocao de multijob.

## 9. Estados e persistencia

### Transitarios
- server
  - `freezeState`
  - `noclipState`
  - `wallWeaponState`
  - `wallWeaponStateUpdateAt`
  - `spectateTargetByAdmin`
  - `actionInFlightBySource`
  - `panelStateCacheBySource`
  - `blipPlayersCache`
  - `globalMoneyCache`
- client
  - `panelOpen`
  - `frozenByAdmin`
  - `playerBlipsEnabled`
  - `playerWallEnabled`
  - `lastTrackedPlayers`
  - `spectateState`
  - store da NUI

### Persistidos
- `bilto_admin_permissions`
- `bilto_admin_permission_presets`
- `bans`

### Controles de fluxo
- cache de painel por source (`Config.Security.panelStateCacheMs`)
- cache de blips (`Config.Performance.blipPlayersCacheMs`)
- cache de money global (`Config.Performance.globalMoneyCacheMs`)
- lock por admin para evitar dupla execucao (`Config.Security.actionLockEnabled`)
- throttle de `updateWallWeaponState` (`Config.Security.wallWeaponStateMinIntervalMs`)

## 10. Entendimento semantico

### Autorizacao
- Toda permissao sensivel e validada no servidor.
- A NUI so consulta `canExecutePanelAction`; a autorizacao real continua em `performAction`.
- A ACL customizada complementa a permissao base do framework.

### Validacao de entrada
- Texto sanitizado por tamanho e trim.
- IDs de alvo convertidos e verificados no server.
- Money, peso, slots e quantidade de item passam por limites declarativos.
- Acoes em player offline falham cedo com mensagem explicita.

### Concorrencia e previsibilidade
- `actionInFlightBySource` evita dupla execucao concorrente pelo mesmo staff.
- `playerDropped` limpa estados efemeros.
- `onResourceStop` client limpa spectate, freeze local, wall state e blips.

## 11. Problemas criticos encontrados

### Corrigidos nesta etapa
- O JS da NUI mantinha um subsistema inteiro de mapa sem elementos correspondentes no HTML e sem asset em `ui/images`.
- O client ainda emitia `bilto_admin:updateMapPlayers` para a NUI, gerando chatter continuo sem qualquer consumidor real.
- O clipboard tinha tres caminhos competindo entre si; agora existe um unico caminho principal via callback NUI.
- O self-check nao validava a consistencia estatica entre `ui/script.js` e `ui/index.html`.

### Riscos residuais conhecidos
- `server/main.lua` e `ui/script.js` continuam grandes e monoliticos, embora o fluxo morto tenha sido removido.
- O noclip e o wall continuam com loop por frame quando ativos, o que e esperado pela natureza do recurso; o controle principal continua sendo via toggle e tracking cacheado.

## 12. Resultado da refatoracao

- Caminho principal unico para clipboard.
- Remocao completa do pipeline morto de mapa da NUI.
- Menos mensagens client->NUI e menos polling `getBlipPlayers` sem consumidor real.
- Self-check capaz de barrar regressao estrutural de IDs/paineis da NUI antes de uso.
- Documentacao alinhada com os arquivos reais do recurso.

## 13. Arquivos removidos / enxugados

### Arquivos fisicos removidos
- Nenhum. O runtime continua usando a mesma superficie de arquivos.

### Blocos removidos
- `ui/script.js`
  - estado `mapPlayers`
  - zoom/pan do mapa
  - handlers do modal de mapa
  - branch `bilto_admin:updateMapPlayers`
  - fallbacks de clipboard em browser
- `client/main.lua`
  - `pushMapPlayersToUi`
  - envio de `bilto_admin:updateMapPlayers`
- `ui/style.css`
  - CSS do modal de mapa
  - CSS de `modal-focus-permission`

## 14. Checklist de regressao

Veja `VALIDATION.md` para o roteiro executavel completo.

Cobertura minima obrigatoria:
1. `bilto_admin_selfcheck` com `ok=true`.
2. Abertura e fechamento de `/admin`.
3. Dashboard, Players, Support, Utilities, Developer, Moderation e Permissions.
4. Support actions: goto, bring, spectate, revive, heal, freeze.
5. Inventory, items, money, peso, slots, job, multijob, rename, height e clear inventory.
6. PM, kick, ban, edit ban e remove ban.
7. Wall, blips, noclip, cavalo admin e company stash.
8. Permissoes customizadas e presets.
9. Restart/reload do resource.
10. `playerDropped` e limpeza de estado.

## 15. Pesquisa externa usada

- Cfx.re: Secure your events
  - https://docs.fivem.net/docs/developers/server-security/
- Cfx.re: NUI callbacks
  - https://docs.fivem.net/docs/scripting-manual/nui-development/nui-callbacks/
- Cfx.re: State bags
  - https://docs.fivem.net/docs/scripting-manual/networking/state-bags/
- ox_lib: callback server
  - https://overextended.dev/ox_lib/Modules/Callback/Lua/Server
- ox_lib: callback client
  - https://overextended.dev/ox_lib/Modules/Callback/Lua/Client

Aplicacao pratica:
- validacao sensivel mantida no servidor
- callbacks RPC preservados para request/response previsivel
- state bags mantidos apenas como estado efemero de arma para wall
- self-check ampliado para detectar regressao estrutural da NUI
