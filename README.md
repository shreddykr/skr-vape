## ☁️ [OX] Advanced Vape Script | Vape Kit | Disposables | FiveM

---
## Preview
[Click Here](https://youtu.be/IMLfzVjicos?si=JRQNjh36chyK1dsU)

<img width="1165" height="488" alt="Screenshot 2025-08-20 234340" src="https://github.com/user-attachments/assets/1757e074-82b8-4ebd-bd98-87566af1a115" />
<img width="1167" height="486" alt="Screenshot 2025-08-20 234326" src="https://github.com/user-attachments/assets/1f3c42bc-12f8-4de9-b7a5-5bf1467c2a32" />
<img width="1167" height="487" alt="Screenshot 2025-08-20 234301" src="https://github.com/user-attachments/assets/cc70a2b8-ed87-4257-8e55-3ffa15f51e9a" />
<img width="1170" height="491" alt="Screenshot 2025-08-20 160331" src="https://github.com/user-attachments/assets/4cb3b73e-87a5-4c3a-a9e8-9451172221c5" />
<img width="1165" height="488" alt="Screenshot 2025-08-20 234413" src="https://github.com/user-attachments/assets/92f99765-4ffa-44e0-9f4d-2c37bf9ec252" />


## ✨ Features

✅ Reusable Vape Kit (50 hits till refill)

✅ 8 Custom Elfbar Props (500 hits auto removes from inventory)

✅ 11 Default Juices — create more in config.lua

✅ Durability in ox_inventory tooltips (Hits Left, Uses Left)

✅ Custom animation flow 

✅ Green “buzz/alien” screen effect

✅ Stress relief on hit — supports QBCore (qb-hud/ps-hud)

✅ Prop support — uses Rockstar DLC model & 8 Custom Elfbar Models

✅ ox_lib UI overlay — [E] Hit Vape / [X] Put Away

✅ OneSync compatible — smoke/animations visible to nearby players

✅ Auto re-freeze & reattach — fixes pose/prop after doors/interior changes

✅ Easy config — add/remove refill bottles in config.lua

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
		['vape_elfbar_blueberry'] = {
			label = 'Elfbar Blueberry (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_cola'] = {
			label = 'Elfbar Cola (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_grape'] = {
			label = 'Elfbar Grape (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_kiwi'] = {
			label = 'Elfbar Kiwi (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_mango'] = {
			label = 'Elfbar Mango (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_melon'] = {
			label = 'Elfbar Melon (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},
		['vape_elfbar_strawberry'] = {
			label = 'Elfbar Strawberry (Disposable)',
			weight = 50,
			stack = false,
			close = true,
			description = 'Disposable vape — 500 hits. Not refillable.',
			client = { export = 'skr-vape.toggleDisposableFromItem' },
		},


