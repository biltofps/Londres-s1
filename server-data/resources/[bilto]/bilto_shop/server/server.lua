local RSGCore = exports['rsg-core']:GetCoreObject()

-- as lojas vivem no rsg-inventory (InvCore.Inventories), este script so as registra e abre

local function ShopName(key) return 'bilto_' .. key end

local function Debug(msg, ...)
    if Config.Debug then print(('[bilto_shop] ' .. msg):format(...)) end
end

local function Notify(src, text, kind, title)
    exports['bilto_notify']:Notify(src, {
        title = title or Config.Text.shop_name, description = text, type = kind or 'error', duration = 5000,
    })
end

local function Money(n) return ('$%.2f'):format(n) end

local function ValidItem(key, name)
    if RSGCore.Shared.Items[name] then return true end
    print(('[bilto_shop] loja %s: item inexistente no rsg-core: %s'):format(key, tostring(name)))
    return false
end

-- categories (a venda) -> itens da grade do rsg-inventory
-- sem amount = estoque infinito, entao nao ha restock nem limite de estoque
local function BuildItems(key, shop)
    local items, labels, onSale = {}, {}, {}
    if not shop.canBuy then return items, labels, onSale end
    for i, cat in ipairs(shop.categories or {}) do
        local id = 'bilto_cat_' .. i
        for _, it in ipairs(cat.items or {}) do
            if it.price and ValidItem(key, it.name) then
                labels[id] = cat.label
                onSale[it.name] = it.price
                items[#items + 1] = { name = it.name, price = it.price, category = id }
            end
        end
    end
    return items, labels, onSale
end

-- buys (a loja compra) -> lista separada, fora da grade; so compra o que estiver listado aqui
-- item a venda tambem pode estar aqui, desde que a loja pague MENOS do que cobra
-- (estoque infinito: pagar igual ou mais deixaria comprar e revender sem parar)
local function BuildBuys(key, shop, onSale)
    local buys = {}
    if not shop.canSell then return buys end
    for _, it in ipairs(shop.buys or {}) do
        local salePrice = onSale[it.name]
        if salePrice and it.price and it.price >= salePrice then
            print(('[bilto_shop] loja %s: %s paga %.2f mas vende por %.2f; a compra precisa ser menor que a venda, removido da lista de compra')
                :format(key, it.name, it.price, salePrice))
        elseif it.price and ValidItem(key, it.name) then
            buys[#buys + 1] = { name = it.name, buyPrice = it.price, minQuality = it.minQuality }
        end
    end
    return buys
end

local function RegisterShops()
    for key, shop in pairs(Config.Shops) do
        local items, labels, onSale = BuildItems(key, shop)
        local buys = BuildBuys(key, shop, onSale)
        exports['rsg-inventory']:CreateShop({
            name = ShopName(key),
            label = shop.label,
            coords = shop.coords.xyz,
            currency = shop.currency or 'cash',
            items = items,
            categoryLabels = labels,
            buys = buys,
            buysLabel = shop.buysLabel or Config.Text.buys_tab,
            subtitle = Config.Text.hint,
        })
        Debug('loja registrada: %s (%s a venda, %s comprando)', key, #items, #buys)
    end
end

local function HasJob(src, jobs)
    if not jobs then return true end
    local Player = RSGCore.Functions.GetPlayer(src)
    local job = Player and Player.PlayerData.job and Player.PlayerData.job.name
    for _, name in ipairs(jobs) do
        if name == job then return true end
    end
    return false
end

RegisterNetEvent('bilto_shop:server:open', function(key)
    local src = source
    local shop = type(key) == 'string' and Config.Shops[key]
    if not shop then return end
    if not HasJob(src, shop.jobs) then return Notify(src, Config.Text.no_job) end
    -- OpenShop confere a distancia (10.0 das coords da loja)
    if not exports['rsg-inventory']:OpenShop(src, ShopName(key)) then
        return Notify(src, Config.Text.too_far)
    end
    TriggerClientEvent('bilto_shop:client:sound', src, key, 'open')
    TriggerClientEvent('bilto_shop:client:opened', src, key) -- camera no NPC
end)

-- recibo da compra/venda (disparado pelo rsg-inventory depois do dinheiro mudar)
AddEventHandler('rsg-inventory:server:shopTransaction', function(src, t)
    local key = t.shop and t.shop:match('^bilto_(.+)$')
    local shop = key and Config.Shops[key]
    if not shop then return end
    local text = t.kind == 'buy' and Config.Text.bought or Config.Text.sold
    Notify(src, text:format(t.amount, t.label or t.item, Money(t.total)), 'success', shop.label)
    TriggerClientEvent('bilto_shop:client:sound', src, key, t.kind) -- 'buy' | 'sell'
    -- fecha a NUI do inventario: cada compra/venda exige abrir a loja de novo
    if (t.kind == 'buy' and Config.CloseOnBuy) or (t.kind == 'sell' and Config.CloseOnSell) then
        exports['rsg-inventory']:CloseInventory(src)
    end
end)

AddEventHandler('onResourceStart', function(res)
    -- o rsg-inventory reiniciado perde as lojas: registra de novo
    if res == GetCurrentResourceName() or res == 'rsg-inventory' then RegisterShops() end
end)
