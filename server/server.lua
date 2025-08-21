local ox_inventory = exports.ox_inventory

RegisterServerEvent('skr-vape:initVapeMeta', function()
    local src = source
    local item = ox_inventory:GetSlotWithItem(src, Config.VapeItem)
    if not item then return end

    local meta = item.metadata or {}
    if tonumber(meta.hits) == nil then
        meta.hits = Config.MaxHits
        ox_inventory:SetMetadata(src, item.slot, meta)
    end
end)


RegisterServerEvent('skr-vape:initDisposableMeta', function(itemName, slot)
    local src = source
    local cfg = Config.DisposableItems and Config.DisposableItems[itemName]
    if not cfg then return end

    local it = slot and ox_inventory:GetSlot(src, slot) or ox_inventory:GetSlotWithItem(src, itemName)
    if not it then return end

    local meta = it.metadata or {}
    if tonumber(meta.hits) == nil then
        meta.hits = tonumber(cfg.maxHits) or 500
        ox_inventory:SetMetadata(src, it.slot, meta)
    end
end)


RegisterServerEvent("skr-vape:useHit", function(itemName, slot)
    local src = source
    itemName = itemName or Config.VapeItem

    local isReusable   = (itemName == Config.VapeItem)
    local isDisposable = (not isReusable) and (Config.DisposableItems and Config.DisposableItems[itemName] ~= nil)

    local item
    if slot then
        item = ox_inventory:GetSlot(src, slot)
        if item and item.name ~= itemName then
            item = nil
        end
    end
    if not item then
        item = ox_inventory:GetSlotWithItem(src, itemName)
    end
    if not item then return end

    local meta = item.metadata or {}
    local maxHits = isReusable and Config.MaxHits or ((Config.DisposableItems and Config.DisposableItems[itemName] and tonumber(Config.DisposableItems[itemName].maxHits)) or 500)
    local hits = tonumber(meta.hits) or maxHits

  
    if hits <= 0 then
        if isReusable then
            TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "Your vape is empty. Refill it." })
        else
            ox_inventory:RemoveItem(src, item.name, 1, nil, item.slot)
        end
        return
    end

  
    hits = hits - 1

    if isReusable then
        meta.hits = math.max(hits, 0)
        ox_inventory:SetMetadata(src, item.slot, meta)
        if hits == 0 then
            TriggerClientEvent("ox_lib:notify", src, { type = "inform", description = "Your vape is empty. Use a refill bottle." })
        end
    else
       
        if hits <= 0 then
            ox_inventory:RemoveItem(src, item.name, 1, nil, item.slot)
            TriggerClientEvent("ox_lib:notify", src, { type = "inform", description = "Your disposable vape is finished." })
        else
            meta.hits = hits
            ox_inventory:SetMetadata(src, item.slot, meta)
        end
    end
end)


lib.callback.register("skr-vape:refill", function(source, refillItem, refillSlot)
    local player = source

    
    local refillCfg = Config.RefillItems and Config.RefillItems[refillItem]
    if not refillCfg then
        return false, "Invalid refill type."
    end

    
    local vape = ox_inventory:GetSlotWithItem(player, Config.VapeItem)
    if not vape then
        return false, "You don't have a vape."
    end

    local vMeta = vape.metadata or {}
    local currentHits = tonumber(vMeta.hits) or 0

    if currentHits >= Config.MaxHits then
        return false, "Your vape is already full."
    end

    
    local refill
    if refillSlot then
        refill = ox_inventory:GetSlot(player, refillSlot)
        if refill and refill.name ~= refillItem then
            refill = nil
        end
    end
    if not refill then
        refill = ox_inventory:GetSlotWithItem(player, refillItem)
    end
    if not refill then
        return false, "You don't have that refill."
    end

    local rMeta = refill.metadata or {}
    local uses  = tonumber(rMeta.uses) or tonumber(refillCfg.uses) or 1
    if uses <= 0 then
        return false, "That bottle is empty."
    end

    local amount  = tonumber(refillCfg.amount) or 0
    local newHits = currentHits + amount
    if newHits > Config.MaxHits then newHits = Config.MaxHits end

    
    vMeta.hits = newHits
    ox_inventory:SetMetadata(player, vape.slot, vMeta)

    
    uses = uses - 1
    if uses > 0 then
        rMeta.uses = uses
        ox_inventory:SetMetadata(player, refill.slot, rMeta)
    else
        ox_inventory:RemoveItem(player, refillItem, 1, nil, refill.slot)
    end

    return true, ("Refilled. Hits: %d/%d"):format(newHits, Config.MaxHits)
end)


local resourceName = GetCurrentResourceName()
local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

CreateThread(function()
    PerformHttpRequest("https://raw.githubusercontent.com/shreddykr/skr-vape/main/versions.txt", function(code, res, _)
        if code == 200 then
            local latestVersion = res:match("%S+")
            if currentVersion ~= latestVersion then
                print(("^3[%s]^0 Update available! ^1(%s → %s)^0"):format(resourceName, currentVersion, latestVersion))
                print("^3[" .. resourceName .. "]^0 Download latest: ^5https://github.com/shreddykr/skr-vape^0")
            else
                print("^2[" .. resourceName .. "]^0 is up to date. (^2" .. currentVersion .. "^0)")
            end
        else
            print("^1[" .. resourceName .. "]^0 Version check failed. Could not reach GitHub.")
        end
    end, "GET", "", {})
end)
