local isVaping        = false
local isHitting       = false
local vapeProp        = nil
local currentFx       = nil
local lastVapeUse     = 0

-- Vape timing (ms)
local HIT_TOTAL_MS      = 7000   -- full “hit” length
local SMOKE_START_MS    = 5500   -- when smoke starts
local SMOKE_DURATION_MS = 1800   -- smoke length
local IDLE_REPEAT_MS    = 1200   -- mini hold/idle loop interval while equipped

-- Force-load DLC IPL commonly tied to mpxm3 (helps on some builds)
CreateThread(function()
    RequestIpl("xm3")
end)

-- Show these metadata keys in ox_inventory tooltips
CreateThread(function()
    -- key = metadata table key, value = label shown in tooltip
    exports.ox_inventory:displayMetadata('hits', 'Hits Left')
    exports.ox_inventory:displayMetadata('uses', 'Uses Left')
end)

-- === EVENTS ===
RegisterNetEvent("skr-vape:toggleVapeFromItem", function()
    if isVaping then
        putAwayVape()
    else
        -- ensure vape has initial hits metadata so it displays in inventory
        TriggerServerEvent('skr-vape:initVapeMeta')

        isVaping = true
        attachVapeProp()
        showVapeUI(true)
        startIdleLoop()
    end
end)

-- NOTE: now accepts (itemName, slot) so server can modify the exact bottle
RegisterNetEvent("skr-vape:tryRefill", function(itemName, slot)
    if not exports["skr-vape"]:isVapeEquipped() then
        TriggerEvent("ox_lib:notify", {type = "error", description = "You need to have your vape in-hand to refill!"})
        return
    end

    lib.callback("skr-vape:refill", false, function(success, msg)
        if success then
            TriggerEvent("ox_lib:notify", {type = "success", description = msg or "Vape refilled!"})
        else
            TriggerEvent("ox_lib:notify", {type = "error", description = msg or "Refill failed!"})
        end
    end, itemName, slot)
end)

-- === MAIN INPUT LOOP (hit / put away) ===
CreateThread(function()
    while true do
        Wait(0)
        if isVaping then
            if IsControlJustPressed(0, Config.KeyHit) then
                local now = GetGameTimer()
                if now - lastVapeUse >= Config.UseCooldown * 1000 then
                    lastVapeUse = now
                    TriggerServerEvent("skr-vape:useHit")
                    playVapeHit()  -- full 7s sequence, smoke at 5.5s
                end
            end
            if IsControlJustPressed(0, Config.KeyPutAway) then
                putAwayVape()
            end
        end
    end
end)

-- === PROP ATTACH (your emote placement) ===
local PROP_MODEL = "xm3_prop_xm3_vape_01a"
local PROP_BONE  = 28422
local PROP_POS   = vector3(-0.02, -0.02, 0.02)
local PROP_ROT   = vector3(58.0, 110.0, 10.0)

function attachVapeProp()
    if vapeProp and DoesEntityExist(vapeProp) then return end

    local modelHash = joaat(PROP_MODEL)
    if not IsModelInCdimage(modelHash) or not IsModelValid(modelHash) then
        TriggerEvent("ox_lib:notify", { type = "error", description = "Vape model not available on this build." })
        return
    end

    RequestModel(modelHash)
    local t0 = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Wait(10)
        if GetGameTimer() - t0 > 5000 then
            TriggerEvent("ox_lib:notify", { type = "error", description = "Vape model failed to load." })
            return
        end
    end

    local ped = PlayerPedId()
    vapeProp = CreateObject(modelHash, GetEntityCoords(ped), true, true, false)
    if not DoesEntityExist(vapeProp) then
        TriggerEvent("ox_lib:notify", { type = "error", description = "Could not create vape prop." })
        return
    end

    AttachEntityToEntity(
        vapeProp, ped, GetPedBoneIndex(ped, PROP_BONE),
        PROP_POS.x, PROP_POS.y, PROP_POS.z,
        PROP_ROT.x, PROP_ROT.y, PROP_ROT.z,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
end

function removeVapeProp()
    if vapeProp and DoesEntityExist(vapeProp) then DeleteEntity(vapeProp) end
    vapeProp = nil
end

-- === IDLE LOOP (subtle upper-body hold, every 1.2s) ===
local EMOTE_DICT = "amb@world_human_smoking@male@male_b@base"
local EMOTE_CLIP = "base"

function startIdleLoop()
    CreateThread(function()
        RequestAnimDict(EMOTE_DICT)
        while not HasAnimDictLoaded(EMOTE_DICT) do Wait(10) end

        while isVaping do
            if not isHitting then
                -- short, upper-body-only replay to keep a subtle stance
                TaskPlayAnim(PlayerPedId(), EMOTE_DICT, EMOTE_CLIP, 1.0, -1.0, IDLE_REPEAT_MS, 48, 0, false, false, false)
            end
            Wait(IDLE_REPEAT_MS)
        end
        -- When exiting vaping, we’ll clear anim in putAwayVape()
    end)
end

-- === FULL HIT: smoke at 5.5s, stop anim at 7.0s; keep prop in hand ===
local PTFX_ASSET = "scr_agencyheistb"
local PTFX_NAME  = "scr_agency3b_elec_box"
local PTFX_SCALE = 1.4

function playVapeHit()
    local ped = PlayerPedId()
    isHitting = true

    -- ensure anim dict is ready
    RequestAnimDict(EMOTE_DICT)
    local a0 = GetGameTimer()
    while not HasAnimDictLoaded(EMOTE_DICT) do
        Wait(10)
        if GetGameTimer() - a0 > 5000 then
            isHitting = false
            return
        end
    end

    -- Play the upper-body anim for the full duration
    TaskPlayAnim(ped, EMOTE_DICT, EMOTE_CLIP, 8.0, -8.0, HIT_TOTAL_MS, 48, 0, false, false, false)

    -- Schedule smoke start at 5.5s
    CreateThread(function()
        Wait(SMOKE_START_MS)

        RequestNamedPtfxAsset(PTFX_ASSET)
        while not HasNamedPtfxAssetLoaded(PTFX_ASSET) do Wait(10) end
        UseParticleFxAssetNextCall(PTFX_ASSET)

        -- IMPORTANT: use the *actual* head bone index, not the raw ID
        local headBoneIndex = GetPedBoneIndex(ped, 31086) -- SKEL_Head
        if currentFx then StopParticleFxLooped(currentFx, false) end

        -- Offsets are relative to the bone — X=fwd/back, Y=right/left, Z=up
        -- Move forward & up so it emits from mouth/nose.
        local offX, offY, offZ = 0.00, 0.30, 0.02
        local rotX, rotY, rotZ = 0.0, 0.0, 0.0

        currentFx = StartParticleFxLoopedOnEntityBone(
            PTFX_NAME, ped,
            offX, offY, offZ,
            rotX, rotY, rotZ,
            headBoneIndex,
            PTFX_SCALE, false, false, false
        )

        Wait(SMOKE_DURATION_MS)
        if currentFx then StopParticleFxLooped(currentFx, false) end
        currentFx = nil
    end)

    -- Stop the hit anim after 7s, resume idle loop
    CreateThread(function()
        Wait(HIT_TOTAL_MS)
        ClearPedSecondaryTask(ped) -- stops the hit anim, not the prop
        isHitting = false
    end)
end

-- === UI ===
function showVapeUI(show)
    if show then
        lib.showTextUI("[E] Hit Vape\n[X] Put Away", {
            position = "right-center",
            icon = "smoking",
            style = { borderRadius = 8, backgroundColor = '#222', color = 'white' }
        })
    else
        lib.hideTextUI()
    end
end

function putAwayVape()
    isVaping = false
    isHitting = false
    if currentFx then StopParticleFxLooped(currentFx, false) end
    currentFx = nil
    removeVapeProp()
    ClearPedSecondaryTask(PlayerPedId())
    showVapeUI(false)
end

-- === EXPORTS REQUIRED BY OX INVENTORY ITEMS ===
exports("isVapeEquipped", function() return isVaping end)

-- toggleVapeFromItem may receive an item table from ox_inventory; we don't need it for toggling
exports("toggleVapeFromItem", function(_item)
    TriggerEvent("skr-vape:toggleVapeFromItem")
end)

-- IMPORTANT: tryRefill MUST accept the item table; forward name+slot to the event
exports("tryRefill", function(item)
    local name, slot = nil, nil
    if type(item) == "table" then
        name = item.name
        slot = item.slot
    else
        name = item -- fallback
    end
    TriggerEvent("skr-vape:tryRefill", name, slot)
end)
