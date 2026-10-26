# rsg-banking

Cada banco é um tipo de dinheiro do RSG-Core (mesma lista do `bilto_admin` → `Config.MoneyTypes`).
O dinheiro depositado num banco fica nesse banco e só pode ser sacado lá.

| Banco            | Tipo de dinheiro |
|------------------|------------------|
| Valentine Bank   | `valbank`        |
| Armadillo Bank   | `armbank`        |
| Rhodes Bank      | `rhobank`        |
| Blackwater Bank  | `blkbank`        |
| Saint Denis Bank | `bank`           |

## Conta
- Sem conta no banco, a NUI abre a **ficha de abertura** (taxa `Config.Account.openFee`, paga em dinheiro em mãos).
  Depois de abrir, aparece o comprovante e em seguida a NUI completa.
- A cada `Config.Account.maintenanceDays` dias reais é cobrada a **taxa de manutenção** (`maintenanceFee`) do saldo daquele banco;
  se o saldo não cobrir, cobra o que houver.
- Cada banco pode sobrescrever `openFee` / `maintenanceFee` em `Config.Banks`.
- Na primeira inicialização (quando a tabela é criada), quem já tinha saldo num banco ganha a conta aberta, sem taxa.
  Depois disso a conta só existe se estiver em `rsg_bank_opened`.
- Admin: `/fecharconta [citizenid] [banco]` fecha a conta (sem o banco, fecha todas). O saldo é mantido.
- Contas abertas ficam na tabela `rsg_bank_opened` (criada automaticamente).

## Operações
- **Depósito**: dinheiro em mãos → saldo do banco atual.
- **Saque**: saldo do banco atual → dinheiro em mãos.
- **Transferência**: saldo do banco atual → conta do destinatário (por Citizen ID) **no mesmo banco**. Funciona com o destinatário offline;
  ele precisa ter conta naquele banco.

Salários (rsg-core) caem em `bank` (Saint Denis).

## Migração
Na primeira inicialização, se existir a tabela antiga `rsg_bank_accounts` (v3), os saldos são devolvidos aos tipos de dinheiro acima
(Strawberry → `valbank`), as contas antigas continuam abertas, e a tabela é renomeada para `rsg_bank_accounts_old` como backup.
