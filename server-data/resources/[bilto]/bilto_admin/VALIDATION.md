# Validation Checklist

Data: 2026-06-15

## 1. Self-test obrigatorio

1. Inicie o recurso.
2. Rode `bilto_admin_selfcheck` no console do servidor.
3. Resultado esperado:
- `ok=true`
- zero issues

Esse self-test valida:
- dependencias obrigatorias online
- conflitos de comandos
- mapa de acoes/permissoes
- consistencia entre `ui/script.js` e `ui/index.html`
- correspondencia entre `data-panel-target` e `data-panel`

## 2. Acesso e permissao

1. Entrar com um player sem permissao.
2. Executar `/admin`.
3. Resultado esperado:
- painel nao abre
- toast/comando informa negacao

4. Entrar com um player autorizado.
5. Executar `/admin`.
6. Resultado esperado:
- painel abre
- Dashboard renderiza
- nenhuma aba fica vazia por erro de JS

## 3. Dashboard / Players

1. Confirmar metricas online, slots, staff, mortos e ping.
2. Confirmar totais globais de money.
3. Buscar player por nome, source e citizenid.
4. Selecionar player e entrar em Support.

## 4. Support actions

Executar em um alvo online:
- `goto`
- `bring`
- `spectate` on/off
- `revive`
- `heal`
- `toggleFreeze`

Resultado esperado:
- feedback na NUI
- efeito real no alvo
- spectate limpa corretamente ao desligar

## 5. Inventory / economy / job

Executar:
- `openInventory`
- `addItem`
- `checkItemCapacity`
- `addMoney`
- `removeMoney`
- `addWeight`
- `addSlots`
- `setJob`
- `upsertMultijobJob`
- `removeJob`
- `clearInventory`

Resultado esperado:
- limites respeitados
- mensagens de erro coerentes para entradas invalidas
- alteracoes persistem conforme o contrato do framework

## 6. Character maintenance

Executar:
- `renameCharacter`
- `changeHeight`
- `findCharacterByCitizenid`
- `deleteCharacterByCitizenid`

Cobrir:
- personagem offline
- personagem online
- citizenid invalida

Resultado esperado:
- rename/height kickam o alvo e persistem
- delete offline limpa tabelas elegiveis
- delete online agenda kick + limpeza

## 7. Moderation

Executar:
- `privateMessage`
- `kick`
- `banPlayer`
- `editBan`
- `removeBan`

Resultado esperado:
- target recebe PM
- kick remove do servidor
- ban aparece na lista
- edicao altera expiracao
- remocao tira o registro ativo

## 8. Utilities / runtime client

Executar:
- `copyCoords`
- `togglePlayerBlips`
- `togglePlayerWall`
- `toggleNoclip`
- `spawnAdminHorse`
- `openCompanyStash`

Resultado esperado:
- clipboard copia via callback NUI
- blips e wall podem ligar/desligar repetidamente
- noclip liga/desliga sem deixar entidade presa
- cavalo spawnado corretamente
- stash abre no admin

## 9. Permissions

Executar:
- `permissionAddPlayer`
- `permissionUpdatePlayer`
- `permissionRemovePlayer`
- `permissionPresetUpdate`

Cobrir:
- usuario com `manage_permissions`
- usuario sem `manage_permissions`

Resultado esperado:
- ACL customizada aplica/remove corretamente
- presets refletem na UI
- negacoes de permissao bloqueiam acao no server

## 10. Restart / reload / cleanup

1. Abrir painel.
2. Ativar wall, blips, noclip e spectate.
3. Reiniciar o resource.
4. Resultado esperado:
- foco NUI liberado
- spectate desligado
- freeze local limpo
- blips removidos
- wall state resetado

## 11. Entradas maliciosas / edge cases

Testar:
- strings acima do limite em PM, kick, ban, rename
- valores negativos/zero para item, money, peso e slots
- targetSource invalido
- action inexistente via callback NUI
- abrir duas acoes criticas rapidamente

Resultado esperado:
- server rejeita payload
- lock de acao impede corrida do mesmo admin
- nenhuma acao executa fora da permissao esperada
