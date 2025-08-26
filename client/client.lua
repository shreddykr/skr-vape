local isVaping        = false
local isHitting       = false
local vapeProp        = nil
local currentFx       = nil
local lastVapeUse     = 0


local activeItem      = nil

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
local BUZZ_STEPS         = 20
local BUZZ_MAX_STRENGTH  = 0.5

-- Stress relief per hit (adjust for your server)
local STRESS_RELIEF      = 10

CreateThread(function()
    RequestIpl("xm3")
end)

CreateThread(function()
    exports.ox_inventory:displayMetadata('hits', 'Hits Left')
    exports.ox_inventory:displayMetadata('uses', 'Uses Left')
end)

local function equipCommon(itemName, slot, itemType)
    activeItem = { name = itemName, slot = slot, type = itemType }

    if itemType == 'reusable' then
        TriggerServerEvent('skr-vape:initVapeMeta')
    else
        TriggerServerEvent('skr-vape:initDisposableMeta', itemName, slot)
    end

    isVaping = true
    attachVapeProp(itemName, itemType)
    showVapeUI(true)
    startIdlePose() 
end


RegisterNetEvent("skr-vape:toggleVapeFromItem", function(itemName, slot)
    if isVaping then
        putAwayVape()
    else
        equipCommon(itemName or Config.VapeItem, slot, 'reusable')
    end
end)


RegisterNetEvent("skr-vape:toggleDisposableFromItem", function(itemName, slot)
    if isVaping then
        putAwayVape()
    else
        equipCommon(itemName, slot, 'disposable')
    end
end)


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


CreateThread(function()
    while true do
        Wait(0)
        if isVaping then
            if IsControlJustPressed(0, Config.KeyHit) then
                local now = GetGameTimer()
                if now - lastVapeUse >= Config.UseCooldown * 1000 then
                    lastVapeUse = now
                    
                    if activeItem then
                        TriggerServerEvent("skr-vape:useHit", activeItem.name, activeItem.slot)
                    else
                        
                        TriggerServerEvent("skr-vape:useHit", Config.VapeItem, nil)
                    end

                    
                    playVapeHit()

                    
                    TriggerServerEvent("skr-vape:smokeNow")
                end
            end

            if IsControlJustPressed(0, Config.KeyPutAway) then
                putAwayVape()
            end
        end
    end
end)


RegisterNetEvent('skr-vape:playSmoke', function(serverId)
    local tgt = GetPlayerFromServerId(serverId)
    if tgt == -1 then return end

    local ped = GetPlayerPed(tgt)

    CreateThread(function()
        Wait(SMOKE_START_MS)

        local asset = "scr_agencyheistb"
        local name  = "scr_agency3b_elec_box"
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do Wait(0) end
        UseParticleFxAssetNextCall(asset)

        local head = GetPedBoneIndex(ped, 31086) 

        local offX, offY, offZ = 0.00, 0.30, 0.02
        local rotX, rotY, rotZ = 0.0, 0.0, 0.0
        local scale = 1.4
        local duration = 1800

        local fx = StartParticleFxLoopedOnEntityBone(
            name, ped,
            offX, offY, offZ,
            rotX, rotY, rotZ,
            head,
            scale, false, false, false
        )

        Wait(duration)
        if fx then StopParticleFxLooped(fx, false) end
    end)
end)


local function getModelForItem(itemName, itemType)
    if itemType == 'reusable' then
        return Config.VapeModel or "xm3_prop_xm3_vape_01a"
    end
    local d = Config.DisposableItems and Config.DisposableItems[itemName]
    if d and d.model and d.model ~= "" then
        return d.model
    end
    return Config.VapeModel or "xm3_prop_xm3_vape_01a"
end

function attachVapeProp(itemName, itemType)
    if vapeProp and DoesEntityExist(vapeProp) then return end

    local modelName = getModelForItem(itemName, itemType)
    local modelHash = joaat(modelName)

    print(("[skr-vape] Attach prop -> item: %s | type: %s | model: %s")
        :format(tostring(itemName), tostring(itemType), tostring(modelName)))

    if not IsModelInCdimage(modelHash) or not IsModelValid(modelHash) then
        TriggerEvent("ox_lib:notify", { type = "error", description = ("Vape model not available: %s"):format(modelName) })
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

    local bone, pos, rot
    if itemType == 'disposable' then
        local d = Config.DisposableItems and Config.DisposableItems[itemName]
        if d and d.attach then
            bone = d.attach.bone or 28422
            pos  = d.attach.pos  or vec3(-0.02, -0.02, 0.02)
            rot  = d.attach.rot  or vec3(58.0, 110.0, 10.0)
        else
            bone = Config.DisposableAttach and Config.DisposableAttach.bone or 28422
            pos  = Config.DisposableAttach and Config.DisposableAttach.pos  or vec3(-0.02, -0.02, 0.02)
            rot  = Config.DisposableAttach and Config.DisposableAttach.rot  or vec3(58.0, 110.0, 10.0)
        end
    else
        bone = 28422
        pos  = vec3(-0.02, -0.02, 0.02)        
        rot  = vec3(58.0, 110.0, 10.0)          
    end

    AttachEntityToEntity(
        vapeProp, ped, GetPedBoneIndex(ped, bone),
        pos.x, pos.y, pos.z,
        rot.x, rot.y, rot.z,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
end

function removeVapeProp()
    if vapeProp and DoesEntityExist(vapeProp) then DeleteEntity(vapeProp) end
    vapeProp = nil
end

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


local PTFX_ASSET = "scr_agencyheistb"
local PTFX_NAME  = "scr_agency3b_elec_box"
local PTFX_SCALE = 1.4

function playVapeHit()
    local ped = PlayerPedId()
    isHitting = true

    
    RequestAnimDict(EMOTE_DICT)
    local a0 = GetGameTimer()
    while not HasAnimDictLoaded(EMOTE_DICT) do
        Wait(10)
        if GetGameTimer() - a0 > 5000 then
            isHitting = false
            return
        end
    end


    SetEntityAnimSpeed(ped, EMOTE_DICT, EMOTE_CLIP, 1.0)
    TaskPlayAnim(ped, EMOTE_DICT, EMOTE_CLIP, 8.0, -8.0, HIT_TOTAL_MS, 48, 0, false, false, false)


    CreateThread(function()
        Wait(SMOKE_START_MS)


        RequestNamedPtfxAsset(PTFX_ASSET)
        while not HasNamedPtfxAssetLoaded(PTFX_ASSET) do Wait(10) end
        UseParticleFxAssetNextCall(PTFX_ASSET)

        local headBoneIndex = GetPedBoneIndex(ped, 31086) 
        if currentFx then StopParticleFxLooped(currentFx, false) end


        local offX, offY, offZ = 0.00, 0.30, 0.02
        local rotX, rotY, rotZ = 0.0, 0.0, 0.0

        currentFx = StartParticleFxLoopedOnEntityBone(
            PTFX_NAME, ped,
            offX, offY, offZ,
            rotX, rotY, rotZ,
            headBoneIndex,
            PTFX_SCALE, false, false, false
        )


        applyBuzzEffect()
        relieveStress(STRESS_RELIEF)

        Wait(SMOKE_DURATION_MS)
        if currentFx then StopParticleFxLooped(currentFx, false) end
        currentFx = nil
    end)

    
    CreateThread(function()
        Wait(HIT_TOTAL_MS)
        ClearPedSecondaryTask(ped)
        isHitting = false
        if isVaping then
            startIdlePose()
        end
    end)
end


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
    activeItem = nil
    if currentFx then StopParticleFxLooped(currentFx, false) end
    currentFx = nil
    removeVapeProp()
    ClearPedSecondaryTask(PlayerPedId())
    showVapeUI(false)
    ClearTimecycleModifier()
end


function applyBuzzEffect()
    SetTimecycleModifier(BUZZ_TCMOD)

    for i = 1, BUZZ_STEPS do
        local strength = (i / BUZZ_STEPS) * BUZZ_MAX_STRENGTH
        SetTimecycleModifierStrength(strength)
        Wait(math.floor(BUZZ_IN_MS / BUZZ_STEPS))
    end
    SetTimecycleModifierStrength(BUZZ_MAX_STRENGTH)

    Wait(BUZZ_HOLD_MS)

    for i = BUZZ_STEPS, 0, -1 do
        local strength = (i / BUZZ_STEPS) * BUZZ_MAX_STRENGTH
        SetTimecycleModifierStrength(strength)
        Wait(math.floor(BUZZ_OUT_MS / BUZZ_STEPS))
    end
    ClearTimecycleModifier()
end


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
end

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
                    local name = activeItem and activeItem.name or Config.VapeItem
                    local typ  = activeItem and activeItem.type or 'reusable'
                    attachVapeProp(name, typ)
                end
                refreezeIdlePose()
            end

            if not IsEntityPlayingAnim(ped, EMOTE_DICT, EMOTE_CLIP, 3) then
                refreezeIdlePose()
            else
                SetEntityAnimSpeed(ped, EMOTE_DICT, EMOTE_CLIP, 0.0)
            end
        end
    end
end)

exports("isVapeEquipped", function() return isVaping end)

exports("toggleVapeFromItem", function(item)
    local name, slot = Config.VapeItem, nil
    if type(item) == "table" then
        name = item.name
        slot = item.slot
    end
    TriggerEvent("skr-vape:toggleVapeFromItem", name, slot)
end)

exports("toggleDisposableFromItem", function(item)
    if type(item) ~= "table" then return end
    TriggerEvent("skr-vape:toggleDisposableFromItem", item.name, item.slot)
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
