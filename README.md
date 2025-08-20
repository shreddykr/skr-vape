## SKR Vape

---
## Preview
	[Click Here](https://www.youtube.com/watch?v=ayYOvv_ZQE8)

## ✨ Features

- ✅ **Reusable Vape Kit** (200 hits per kit by default)  
- ✅ **Refillable with Vape Juice bottles** (configurable, each bottle has limited uses)  
- ✅ **Durability shown in ox_inventory tooltips** (`Hits Left`, `Uses Left`)  
- ✅ **Custom animations** (7s hit with smoke at 5.5s)  
- ✅ **Prop support** (Using Rockstars DLC)  
- ✅ **ox_lib UI overlay** — shows `[E] Hit Vape` / `[X] Put Away` when equipped  
- ✅ **OneSync compatible** — smoke and animations sync with nearby players  
- ✅ **Easy config** — add/remove refill bottles in `config.lua`
- ✅ **11 Defualt Juices** — create more in the config file `config.lua`

---

## 📦 Requirements

- [ox_inventory](https://github.com/overextended/ox_inventory)  
- [ox_lib](https://github.com/overextended/ox_lib)  
- OneSync (Infinity or Legacy) **enabled**

---

## 🔧 Installation

1. Download and extract then rename the folder to skr-vape
2. Install items and images to ox inventory
3. ensure skr-vape in server cfg after the inventory and ox lib

## 🔧 Items List(OX)

		['vape'] = {
			label = 'Vape Kit',
			weight = 100,
			stack = false,
			close = true,
			description = 'A reusable vape kit with 200 hits. Refillable with vape juice.',
			client = {
				export = 'skr-vape.toggleVapeFromItem',
			}
		},
		['vape_refill_strawberry'] = {
			label = 'Strawberry Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_reallyberry'] = {
			label = 'Really Berry Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_coconutlimeade'] = {
			label = 'Coconut Limeade Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_mint'] = {
			label = 'Mint Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_mango'] = {
			label = 'Mango Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_apple'] = {
			label = 'Apple Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_pineapple'] = {
			label = 'Pineapple Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_lavaflow'] = {
			label = 'Lava Flow Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_allmelon'] = {
			label = 'All Melon Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_lemon'] = {
			label = 'Lemon Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},
		['vape_refill_peach'] = {
			label = 'Peach Vape Juice',
			weight = 20,
			stack = false,
			close = true,
			description = 'Refills 50 hits per use.',
			client = {
				export = 'skr-vape.tryRefill',
			}
		},

