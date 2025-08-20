local isVaping        = false
local isHitting       = false
local vapeProp        = nil
local currentFx       = nil
local lastVapeUse     = 0

-- Timing (ms)
local HIT_TOTAL_MS       = 7000   -- full hit length
local SMOKE_START_MS     = 5500   -- when smoke begins
local SMOKE_DURATION_MS  = 1800   -- smoke length
local IDLE_POSE_TIME     = 0.0    -- freeze on the very first frame

-- Buzz/alien screen effect
local BUZZ_IN_MS         = 400    -- fade-in
local BUZZ_HOLD_MS       = 2000   -- hold at peak
local BUZZ_OUT_MS        = 500    -- fade-out
local BUZZ_TCMOD         = "drug_flying_base" -- green-ish vibe

-- Stress relief per hit (adjust for your server)
local STRESS_RELIEF      = 10

-- Force-load DLC IPL commonly tied to mpxm3 (helps on some builds)
CreateThread(function()
    RequestIpl("xm3")
end)

-- Show metadata in ox_inventory tooltips
CreateThread(function()
    exports.ox_inventory:displayMetadata('hits', 'Hits Left')
    exports.ox_inventory:displayMetadata('uses', 'Uses Left')
end)

-- === EVENTS ===
RegisterNetEvent("skr-vape:toggleVapeFromItem", function()
    if isVaping then
        putAwayVape()
    else
        TriggerServerEvent('skr-vape:initVapeMeta') -- seed hits if missing
        isVaping = true
        attachVapeProp()
        showVapeUI(true)
        startIdlePose() -- freeze first frame
    end
end)

-- NOTE: accepts (itemName, slot) so server can modify the exact bottle
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
                    playVapeHit()  -- 7s, smoke at 5.5s, buzz, stress relief
                end
            end
            if IsControlJustPressed(0, Config.KeyPutAway) then
                putAwayVape()
            end
        end
    end
end)

-- === PROP ATTACH (UNCHANGED placement) ===
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

-- === IDLE POSE (freeze first frame, no loop) ===
local EMOTE_DICT = "amb@world_human_smoking@male@male_b@base"
local EMOTE_CLIP = "base"

local function refreezeIdlePose()
    local ped = PlayerPedId()
    RequestAnimDict(EMOTE_DICT)
    local t0 = GetGameTimer()
    while not HasAnimDictLoaded(EMOTE_DICT) do
        Wait(10)
        if GetGameTimer() - t0 > 5000 then return end
    end

    TaskPlayAnim(ped, EMOTE_DICT, EMOTE_CLIP, 1.0, -1.0, -1, 48, 0, false, false, false)
    Wait(0)
    SetEntityAnimCurrentTime(ped, EMOTE_DICT, EMOTE_CLIP, IDLE_POSE_TIME) -- 0.0
    SetEntityAnimSpeed(ped, EMOTE_DICT, EMOTE_CLIP, 0.0)
end

function startIdlePose()
    CreateThread(function()
        refreezeIdlePose()
        while isVaping and not isHitting do
            SetEntityAnimSpeed(PlayerPedId(), EMOTE_DICT, EMOTE_CLIP, 0.0)
            Wait(500)
        end
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

    -- let the anim play naturally for the hit
    SetEntityAnimSpeed(ped, EMOTE_DICT, EMOTE_CLIP, 1.0)
    TaskPlayAnim(ped, EMOTE_DICT, EMOTE_CLIP, 8.0, -8.0, HIT_TOTAL_MS, 48, 0, false, false, false)

    -- start smoke at 5.5s + buzz + stress
    CreateThread(function()
        Wait(SMOKE_START_MS)

        -- smoke (UNCHANGED OFFSETS)
        RequestNamedPtfxAsset(PTFX_ASSET)
        while not HasNamedPtfxAssetLoaded(PTFX_ASSET) do Wait(10) end
        UseParticleFxAssetNextCall(PTFX_ASSET)

        local headBoneIndex = GetPedBoneIndex(ped, 31086) -- SKEL_Head
        if currentFx then StopParticleFxLooped(currentFx, false) end

        -- DO NOT CHANGE these offsets per your request
        local offX, offY, offZ = 0.00, 0.30, 0.02
        local rotX, rotY, rotZ = 0.0, 0.0, 0.0

        currentFx = StartParticleFxLoopedOnEntityBone(
            PTFX_NAME, ped,
            offX, offY, offZ,
            rotX, rotY, rotZ,
            headBoneIndex,
            PTFX_SCALE, false, false, false
        )

        -- buzz effect + stress relief
        applyBuzzEffect()
        relieveStress(STRESS_RELIEF)

        Wait(SMOKE_DURATION_MS)
        if currentFx then StopParticleFxLooped(currentFx, false) end
        currentFx = nil
    end)

    -- stop hit at 7s and return to frozen pose
    CreateThread(function()
        Wait(HIT_TOTAL_MS)
        ClearPedSecondaryTask(ped)
        isHitting = false
        if isVaping then
            startIdlePose()
        end
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
    ClearTimecycleModifier()
end

-- === SCREEN EFFECT (green buzz/alien) — half strength & smoothly spread ===
function applyBuzzEffect()
    SetTimecycleModifier(BUZZ_TCMOD)

    local steps = 20
    local maxStrength = 0.5 -- half strength

    -- fade in (smooth)
    for i = 1, steps do
        local strength = (i / steps) * maxStrength
        SetTimecycleModifierStrength(strength)
        Wait(math.floor(BUZZ_IN_MS / steps))
    end
    SetTimecycleModifierStrength(maxStrength)

    -- hold
    Wait(BUZZ_HOLD_MS)

    -- fade out (smooth)
    for i = steps, 0, -1 do
        local strength = (i / steps) * maxStrength
        SetTimecycleModifierStrength(strength)
        Wait(math.floor(BUZZ_OUT_MS / steps))
    end
    ClearTimecycleModifier()
end

-- === STRESS RELIEF (QBCore / ESX auto-detect) ===
local function resourceActive(name)
    local state = GetResourceState(name)
    return state == "starting" or state == "started"
end

function relieveStress(amount)
    -- QBCore HUD
    if resourceActive('qb-hud') then
        TriggerServerEvent('hud:server:RelieveStress', amount)
        return
    end
    -- ps-hud
    if resourceActive('ps-hud') then
        TriggerServerEvent('hud:server:RelieveStress', amount)
        return
    end
    -- ESX status
    if resourceActive('esx_status') then
        TriggerEvent('esx_status:add', 'stress', -math.abs(amount))
        return
    end
    -- Fallback: add your own here if using custom system
    -- TriggerServerEvent('your_hud:relieveStress', amount)
end

-- === WATCHDOG: re-freeze & reattach after doors/interior changes ===
CreateThread(function()
    local lastInterior = -1
    while true do
        Wait(300)
        if isVaping and not isHitting then
            local ped = PlayerPedId()
            local interior = GetInteriorFromEntity(ped)
            if interior ~= lastInterior then
                lastInterior = interior
                Wait(150)
                if not vapeProp or not DoesEntityExist(vapeProp) or not IsEntityAttachedToEntity(vapeProp, ped) then
                    attachVapeProp()  -- uses your unchanged offsets/rotations
                end
                refreezeIdlePose()
            end

            -- if anim got cleared (doors/physics), re-freeze
            if not IsEntityPlayingAnim(ped, EMOTE_DICT, EMOTE_CLIP, 3) then
                refreezeIdlePose()
            else
                SetEntityAnimSpeed(ped, EMOTE_DICT, EMOTE_CLIP, 0.0)
            end
        end
    end
end)

-- === EXPORTS (ox_inventory) ===
exports("isVapeEquipped", function() return isVaping end)

exports("toggleVapeFromItem", function(_item)
    TriggerEvent("skr-vape:toggleVapeFromItem")
end)

exports("tryRefill", function(item)
    local name, slot = nil, nil
    if type(item) == "table" then
        name = item.name
        slot = item.slot
    else
        name = item
    end
    TriggerEvent("skr-vape:tryRefill", name, slot)
end)
