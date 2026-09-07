<div align="center">
  <img src="./cookieclicker-ui/processed/cookie-pop.png" alt="Pixel-art chocolate chip cookie" width="192" />
  <h1>Cookie Clicker</h1>
  <p><strong>Click. Upgrade. Rebirth. Evolve.</strong></p>
  <p>A server-authoritative 3D Roblox clicker set inside a cozy procedural bakery.</p>
  <p>
    <a href="#quick-start">Quick start</a> ·
    <a href="#screenshots--visuals">Screenshots</a> ·
    <a href="#how-to-play">How to play</a> ·
    <a href="#project-structure">Project structure</a>
  </p>
</div>

---

> [!NOTE]
> **Project status:** playable prototype. The core click, upgrade, rebirth, visual progression, and persistence loops are implemented. Gameplay screenshots can be added using the guide below.

## At a glance

| | |
| --- | --- |
| **Engine** | Roblox Studio |
| **Language** | Luau |
| **Project sync** | [Rojo](https://rojo.space/) 7.7 |
| **Persistence** | [ProfileStore](https://madstudioroblox.github.io/ProfileStore/) |
| **Input** | Mouse and touch |
| **World** | Procedural 3D bakery |

## Screenshots & visuals

The project now includes nine visual references, arranged below from promotional artwork to in-game views. The cookie icon in the page header is the transparent UI asset used by the HUD and click-reward popups.

<table>
  <tr>
    <td align="center" width="33%">
      <img src="./docs/screenshots/+1%20Cookie%20Clicker%20Icon.png" alt="Cookie Clicker game icon" width="280" />
      <br /><sub><strong>Game icon</strong><br />Promotional Cookie Clicker icon artwork</sub>
    </td>
    <td align="center" width="33%">
      <img src="./docs/screenshots/+1%20Cookie%20Clicker%20Thumbnail.png" alt="Cookie Clicker game thumbnail" width="280" />
      <br /><sub><strong>Game thumbnail</strong><br />Click, bake, upgrade, and expand</sub>
    </td>
    <td align="center" width="33%">
      <img src="./docs/screenshots/3d%20cookie%20clicker%20stand.jpg" alt="3D cookie clicking stand inside the bakery" width="280" />
      <br /><sub><strong>3D cookie stand</strong><br />The local cookie station and bakery kiosks</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="./docs/screenshots/3d%20landscape.jpg" alt="Exterior landscape surrounding the Cookie House" width="280" />
      <br /><sub><strong>3D landscape</strong><br />The Cookie House in its surrounding world</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20clicker.jpg" alt="Cookie Clicker gameplay with the cosmic cookie and HUD" width="280" />
      <br /><sub><strong>Gameplay</strong><br />Cosmic cookie, player HUD, and upgrade board</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20house%20frontview.jpg" alt="Front view of the Cookie House bakery" width="280" />
      <br /><sub><strong>Cookie House</strong><br />Front exterior view of the bakery</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="./docs/screenshots/cookie%20notif%20popup.jpg" alt="Floating cookie reward notification showing plus 304" width="280" />
      <br /><sub><strong>Click feedback</strong><br />Floating cookie reward popup</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20rebirth.jpg" alt="Cookie rebirth board showing progress toward the next rebirth" width="280" />
      <br /><sub><strong>Rebirth board</strong><br />Progress, tier, and rebirth requirements</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20upgrade.jpg" alt="Baker upgrades board showing click power and auto oven upgrades" width="280" />
      <br /><sub><strong>Upgrade board</strong><br />Click Power and Auto Oven purchases</sub>
    </td>
  </tr>
</table>

### Adding more screenshots

To add future visuals:

1. Capture the view in Roblox Studio while the game is running.
2. Save the image inside the repository's `docs/screenshots/` folder.
3. Use a clear filename without spaces, such as `mobile-hud.png` or `golden-cookie.png`.
4. Add an `<img>` element to the gallery above, using a path relative to `README.md` and descriptive `alt` text.
5. Commit and push both the image and `README.md`. GitHub will not display a local image until the image file is part of the repository.

The existing filenames contain spaces, so their links use `%20` in the URL. Avoiding spaces makes future links easier to maintain.

## What is the game?

Cookie Clicker is a multiplayer Roblox incremental game built around a simple loop:

1. Click or tap your local 3D cookie.
2. Earn cookies from server-approved interactions.
3. Buy **Click Power** and **Auto Ovens** at the bakery kiosk.
4. Reach the current rebirth goal.
5. Manually activate **Cookie Rebirth** to reset temporary upgrades and double your base power.
6. Watch the cookie evolve from chocolate chip to golden to cosmic.

Each player sees their own cookie and progression. The bakery environment is shared, while the cookie artwork, feedback, signs, and HUD state are private to the owning player.

## Feature highlights

- **Procedural bakery:** roof, tiled floor, glazed windows, counters, pastries, ovens, lamps, signs, and upgrade/rebirth kiosks are generated in Luau.
- **Responsive clicking:** the cookie highlights on hover and reacts with a bounce, wobble, bite sound, sparkles, and floating reward feedback.
- **Cookie evolution:** chocolate chip, golden, and cosmic tiers are driven by rebirth progress.
- **Server-authoritative economy:** the server validates life state, distance, click rate, purchases, rebirths, and active save sessions.
- **Private progression:** economy snapshots are sent only to the owning player; currency is not exposed through public leaderstats or replicated attributes.
- **Persistent saves:** ProfileStore handles session locking, autosaves, final saves, retries, and safe failure behavior.
- **Mobile-aware rendering:** touch devices use fewer decorative cookie parts and a lower animation update rate.
- **Safe recovery:** the anchored spawn and void recovery return falling players to a safe location.

> **Audio note:** click feedback uses a short excerpt of Creator Store **Eating crunchy** by himynamemate (`7029475752`). Rebirth feedback uses a bundled Roblox chime.

## Quick start

### Prerequisites

- Roblox Studio
- The [Rojo Studio plugin](https://www.roblox.com/library/13916111004/Rojo) or an equivalent Rojo installation
- [Rokit](https://github.com/rojo-rbx/rokit) (recommended; the repository pins the tool versions)
- A published Roblox place with Studio API access enabled if you want to test real saving

### 1. Install the project tools

From the repository root:

```sh
rokit install
```

If Rojo is already installed independently, this step is optional.

### 2. Start Rojo

```sh
rojo serve
```

Keep this terminal open. Rojo will normally listen on `localhost:34872`.

### 3. Connect Roblox Studio

1. Open `CookieClicker-baseline.rbxlx` or create/open the place you want to use.
2. Open the Rojo plugin in Studio.
3. Connect to the server shown by the plugin.
4. Press **Play**.

The project is mapped into Studio by [`default.project.json`](./default.project.json):

| Repository path | Roblox location |
| --- | --- |
| `src/shared` | `ReplicatedStorage.Shared` |
| `src/server` | `ServerScriptService.Server` |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Client` |

## How to play

1. Walk near the central cookie station.
2. Click or tap the **3D cookie face**—the pedestal itself is not a reward target.
3. Visit **BAKER UPGRADES** to buy click power or automatic ovens.
4. When the rebirth goal is met, click the **COOKIE REBIRTH** board or button.
5. Rebirth keeps overflow cookies, resets click-power and oven levels, and increases base power.

| Action | Result |
| --- | --- |
| Click the cookie | Awards the server-calculated click value and shows local feedback |
| Buy Click Power | Adds one base cookie to each accepted click |
| Buy Auto Oven | Adds one base cookie per second before rebirth scaling |
| Click the rebirth board | Advances one rebirth tier when the goal is met |
| Click the pedestal or click from too far away | No reward is granted |
| Reset or fall below the map | Respawns safely at the configured spawn |

## Economy

The economy is implemented in [`src/shared/Economy.lua`](./src/shared/Economy.lua). Current values are:

| Rule | Formula / value |
| --- | --- |
| Base click value | `(1 + power level) × 2^rebirths` |
| Passive rate | `oven count × 2^rebirths` cookies/second |
| Click Power cost | `floor(10 × 1.65^current level)` |
| Auto Oven cost | `floor(25 × 1.7^current level)` |
| Rebirth goal | `100 × 5^current rebirths` cookies |
| Rebirth effect | Keeps overflow, resets power/ovens, doubles base scaling |
| Safety limits | 16 rebirths, 50 levels per upgrade, `9e15` cookies |

Rebirth is **manual**, not automatic. Earning cookies never silently resets progress; the player must activate the rebirth board. The first goal is 100 cookies, followed by 500, 2,500, and so on.

### Visual progression

| Rebirth | Cookie tier | Feedback |
| ---: | --- | --- |
| 0 | Chocolate Chip | Warm baked-brown cookie with chips |
| 1 | Golden Cookie | Metallic gold finish and brighter feedback |
| 2+ | Cosmic Cookie | Blue-violet cosmic finish with stronger celebration effects |

## Persistence and security

- [`PlayerDataService.lua`](./src/server/PlayerDataService.lua) owns ProfileStore sessions and saves the active data table directly.
- Studio and live environments intentionally use separate stores:
  - Studio: `CookieClicker_PlayerData_Studio_v1`
  - Live: `CookieClicker_PlayerData_v1`
- Profile keys use the format `Player_<UserId>`.
- Autosave runs every 60 seconds. ProfileStore also handles leaving, shutdown, retries, and session locks.
- There is no offline-income catch-up.
- Failed loads do not create a disposable replacement profile or reset a player's balance.
- The client sends an interaction request—not a reward, price, balance, multiplier, or progression payload.
- The server checks active sessions, character health, interaction distance, and request rate before changing data.

### Enable saving in Studio

1. Publish the place to Roblox.
2. Open **Game Settings → Security**.
3. Enable **Allow Studio Access to API Services**.
4. Keep [`UseMockInStudio`](./src/server/DataConfig.lua) set to `false` for real Studio saves.

Mock sessions are available for temporary tests, but they are explicitly marked **NOT SAVED** and do not survive a Studio restart. Use a test place/account when working with real DataStores.

## Project structure

```text
.
├── cookieclicker-ui/
│   ├── Codex Image Sep 5, 2026, 11_36_31 PM.png  # Original artwork
│   └── processed/cookie-pop.png                   # Roblox-ready transparent icon
├── docs/
│   ├── context.md                                 # Product context
│   └── system-design.md                            # Architecture and contracts
├── scripts/
│   ├── prepare_cookie_icon.py                     # Normalize artwork
│   └── asphalt.mjs                                # Upload wrapper
├── src/
│   ├── client/                                    # Local cookie, HUD, effects
│   ├── server/                                    # Bakery, economy, saves, tests
│   └── shared/                                    # Config, economy, generated assets
├── default.project.json                           # Rojo mapping
├── rokit.toml                                     # Tool versions
└── README.md
```

Useful entry points:

| File | Responsibility |
| --- | --- |
| `src/server/BakeryBuilder.lua` | Builds the shared bakery and kiosks |
| `src/server/init.server.lua` | Creates remotes and owns server interactions |
| `src/client/ClientScene.lua` | Builds the private cookie and click feedback |
| `src/client/CookieHUD.lua` | Renders the bottom-center cookie counter |
| `src/shared/Economy.lua` | Calculates rewards, costs, goals, and mutations |
| `src/server/PlayerDataService.lua` | Loads, validates, saves, and releases profiles |
| `src/shared/Config.lua` | Click rate, range, sound, and interaction settings |

## Tests and build

Run the following from a **server** context in Roblox Studio, not from a client `LocalScript`:

```lua
require(game.ServerScriptService.Server.Tests["BakeryEconomy.spec"])()
require(game.ServerScriptService.Server.Tests["ProfileStore.spec"])()
```

Build a standalone place file with:

```sh
rojo build -o CookieClicker.rbxlx
```

The generated place file is ignored by Git so it can be built locally without adding output to the repository.

## Updating the cookie artwork

The source image is preserved at [`cookieclicker-ui/`](./cookieclicker-ui/). To regenerate the Roblox-ready icon:

```sh
python scripts/prepare_cookie_icon.py
```

The script requires [Pillow](https://pypi.org/project/Pillow/). To upload the processed image through Asphalt:

1. Copy `.env.example` to `.env`.
2. Put your Asphalt API key in `.env` as `ASPHALT_API_KEY=...`.
3. Confirm the creator type and ID in [`asphalt.toml`](./asphalt.toml).
4. Run:

   ```sh
   node scripts/asphalt.mjs sync cloud
   ```

Commit the generated [`src/shared/Assets/ui.luau`](./src/shared/Assets/ui.luau) and `asphalt.lock.toml`. Never commit `.env` or expose the API key.

## Performance notes

- The HUD is created before the scene and texture load, so the first UI paint is not blocked.
- Cookie geometry is generated locally and uses reduced detail on touch devices.
- Cookie animation is capped at 30 Hz on touch and 60 Hz on desktop.
- State updates are coalesced to at most 10 Hz per player; passive production runs once per second.
- Roblox DataStore latency and ProfileStore session-lock waits can still affect startup.

> **Testing note:** verify the current client-cookie, HUD, and optimization revision on desktop and mobile before publishing.

## Related documentation

- [`docs/context.md`](./docs/context.md) — product goals and player experience
- [`docs/system-design.md`](./docs/system-design.md) — architecture, security, persistence, and testing strategy
- [`default.project.json`](./default.project.json) — Rojo project mapping
