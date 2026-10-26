# Changelog

## 2026-06-15

### Added
- Self-check estatico de NUI em `bilto_admin_selfcheck`, validando `document.getElementById(...)` contra os `id=` reais do `ui/index.html`.
- `VALIDATION.md` com roteiro de regressao cobrindo painel, permissoes, runtime client e cenarios de restart/reload.

### Changed
- `ui/script.js` agora usa um caminho unico e deterministico para clipboard via callback NUI `copyToClipboard`.
- `client/main.lua` deixou de enviar atualizacoes NUI de mapa inexistente enquanto o painel esta aberto.
- `client/main.lua` deixou de manter polling de `getBlipPlayers` quando nem wall nem blips estao ativos.
- `README.md` e `AUDIT_REPORT.md` foram atualizados para refletir o runtime atual do recurso.

### Removed
- Pipeline morto de mapa na NUI (`bilto_admin:updateMapPlayers`, estado `mapPlayers`, zoom/pan, handlers de modal e CSS associado).
- Estilo morto `modal-focus-permission` que nao possuia mais acionamento no JavaScript.
- Fallbacks de clipboard em browser (`navigator.clipboard` / `execCommand`) que competiam com o caminho principal do recurso.
- `Config.Client.tracking.panelIntervalMs`, que ficou sem uso apos a remocao do mapa NUI.

## 2026-03-19

### Added
- Registro real do comando do painel via `Config.Command`.
- Self-check em console com `bilto_admin_selfcheck`.
- Dependencia explicita de `rsg-multijob` no `fxmanifest.lua`.
- Defaults completos de `Config.Noclip` no `config.lua`.

### Changed
- `server/main.lua` passou a usar somente `player.Functions.*` para `SetJob`, `AddMoney` e `RemoveMoney`.
- Fluxos de multijob passaram a usar somente exports de `rsg-multijob`.
- O self-check passou a validar dependencias obrigatorias, conflitos de comando, permissoes ausentes e handlers obrigatorios.
- `buildPlayerEntry` reaproveita o mesmo fluxo estrito de leitura de multijob usado nas acoes administrativas.
- `client/noclip.lua` deixou de gravar KVPs sem leitura correspondente.

### Removed
- Compatibilidade manual para APIs antigas de money/job.
- Persistencia paralela em `player_jobs` fora do contrato do `rsg-multijob`.
