Config = {}

Config.VapeItem  = "vape"
Config.MaxHits   = 50
Config.VapeModel = "xm3_prop_xm3_vape_01a"        

Config.RefillItems = {
    ["vape_refill_strawberry"]   = { amount = 50, uses = 5 },
    ["vape_refill_reallyberry"]  = { amount = 50, uses = 5 },
    ["vape_refill_coconutlimeade"]= { amount = 50, uses = 5 },
    ["vape_refill_mint"]         = { amount = 50, uses = 5 },
    ["vape_refill_mango"]        = { amount = 50, uses = 5 },
    ["vape_refill_apple"]        = { amount = 50, uses = 5 },
    ["vape_refill_pineapple"]    = { amount = 50, uses = 5 },
    ["vape_refill_lavaflow"]     = { amount = 50, uses = 5 },
    ["vape_refill_allmelon"]     = { amount = 50, uses = 5 },
    ["vape_refill_lemon"]        = { amount = 50, uses = 5 },
    ["vape_refill_peach"]        = { amount = 50, uses = 5 },
}



Config.SmokeParticle = "exp_grd_bzgas_smoke"
Config.SmokeAsset    = "core"

Config.Animation = {
    dict = "mp_player_int_uppersmoke",
    anim = "mp_player_int_smoke"
}

Config.KeyHit      = 38   -- E
Config.KeyPutAway  = 73   -- X
Config.UseCooldown = 2    -- seconds between hits


Config.DisposableItems = {
    vape_elfbar_blueberry  = { label = "Elfbar Blueberry",  model = "elfbar_blueberry",  maxHits = 500 },
    vape_elfbar_cola       = { label = "Elfbar Cola",       model = "elfbar_cola",       maxHits = 500 },
    vape_elfbar_grape      = { label = "Elfbar Grape",      model = "elfbar_grape",      maxHits = 500 },
    vape_elfbar_kiwi       = { label = "Elfbar Kiwi",       model = "elfbar_kiwi",       maxHits = 500 },
    vape_elfbar_mango      = { label = "Elfbar Mango",      model = "elfbar_mango",      maxHits = 500 },
    vape_elfbar_melon      = { label = "Elfbar Melon",      model = "elfbar_melon",      maxHits = 500 },
    vape_elfbar_strawberry = { label = "Elfbar Strawberry", model = "elfbar_strawberry", maxHits = 500 },
}

Config.DisposableAttach = {
    bone = 28422,
    pos  = vec3(-0.055, -0.05, 0.025), 
    rot  = vec3(-34.0, 90.0, 0.00)
}


Config.TextUI = {
    position = "right-center",
    icon = "smoking",
    style = {
        borderRadius = 8,
        backgroundColor = "#222",
        color = "white"
    }
}
