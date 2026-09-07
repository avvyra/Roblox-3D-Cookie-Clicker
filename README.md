# CookieClicker

Roblox Studio project synced with [Rojo](https://rojo.space/).

## Connect to Roblox Studio

1. Install the Rojo Roblox Studio plugin if you do not already have it.
2. Open this folder in a terminal:
   ```sh
   cd CookieClicker
   ```
3. Start the Rojo server:
   ```sh
   rojo serve
   ```
4. In Roblox Studio, open/create a place, open the Rojo plugin, and click **Connect**.

The repo maps into Studio using `default.project.json`:

- `src/shared` -> `ReplicatedStorage.Shared`
- `src/server` -> `ServerScriptService.Server`
- `src/client` -> `StarterPlayer.StarterPlayerScripts.Client`

## 3D cookie interaction and safe spawn

- Click/tap the actual 3D cookie. `src/server/CookieScene.server.lua` creates only the shared pedestal and invisible validation anchor. Cookie artwork appears during Play, not in the edit-mode pedestal.
- `src/client/ClientScene.lua` creates a private local cookie and ClickDetector. Clicks request a server-validated reward; the server checks life, distance, click rate, and the active ProfileStore session. The pedestal is not clickable.
- Local cookie effects include hover highlighting, bounce/wobble, and bite sounds. Other players cannot see this client's cookie appearance or animation.
- Sound ID, volume, excerpt duration, click rate, and interaction distance are configurable in `src/shared/Config.lua`. Bite audio uses a short excerpt of Creator Store **Eating crunchy** by himynamemate (`7029475752`); loading was verified in Studio. Rebirth uses a bundled Roblox chime.
- `default.project.json` includes the anchored floor and spawn. The server returns falling players to spawn.
- `src/server/BakeryBuilder.lua` builds the surrounding bakery (roof, windows, pastry counters, ovens and lamps) and physical upgrade/rebirth posts. It can also be run in edit mode through MCP.
- World-space signs show your own Cookies, click power, passive rate, upgrade costs, and rebirth progress. A small 160x42 bottom-center HUD shows the cookie logo and your balance, respecting the screen inset. Accepted manual clicks briefly show the transparent cookie icon plus the server-confirmed reward at a random safe screen position. Popups float/fade in under one second, scale for phone/desktop screens, pass input through, and are capped at 18 at once.
- Click-power upgrades start at 10 cookies and scale by 1.65 per level; ovens start at 25 and scale by 1.7. Costs are floored. Each power level adds one base cookie per click; each oven produces one base cookie per second. Rebirth multiplies both by `2^rebirths`.
- **Rebirth is manual:** at `100 * 5^rebirths` cookies, the rebirth sign turns ready. Click the board or its button to advance exactly one tier: deduct the goal, keep overflow, reset upgrades/ovens, and double base power. Earnings never trigger a reset. The cookie evolves from chocolate chip to golden to cosmic with sparkle/chime feedback.
- All rewards/purchases/rebirths are server-owned, range-checked and rate-limited. Click/tap **BUY CLICK POWER**, **BUY AUTO OVEN**, or the rebirth sign via ClickDetectors. There are no proximity prompts.
- `src/shared/CookieVisualBuilder.lua` builds curved dough and chocolate chunks locally. Touch devices use fewer decorative parts, and cookie animation updates are capped at 30 Hz on touch / 60 Hz on desktop.
- **Progress is private:** no public currency/rebirth leaderstats or replicated BakeryState attribute. Explicit snapshots go only to the owning player through `BakeryStateUpdated`; signs and HUD consume that local cache. ProfileStore still owns/saves the real economy on the server. Each player sees only their own cookie and progression.
- Economy safeguards cap rebirths at 16, each upgrade at 50, and currency at 9e15. Tests: `require(game.ServerScriptService.Server.Tests["BakeryEconomy.spec"])()`.

To verify: sync Rojo, press Play, walk near the cookie, and click/tap its face. Check that Cookies increase with bounce/audio, that rapid clicking settles back to the original pose, and that clicking the pedestal or from beyond 40 studs grants no reward. Reset should respawn safely.

## Join/mobile optimization

- The bottom-center HUD is constructed before waiting for scene geometry or textures. `ClientState.lua` subscribes early and requests a snapshot, preventing missed first-load messages.
- Profile loads begin before the server waits for/builds the bakery. Client scene generation proceeds independently from data receipt and HUD rendering.
- Detailed cookie parts are no longer replicated from the server. Reduced-detail local generation helps touch devices.
- State/sign updates are coalesced to at most 10 Hz per player. Passive production runs once per second and void recovery at 5 Hz, rather than scanning/updating everything every frame.
- These changes reduce surrounding startup/render/network work; Roblox DataStore latency and ProfileStore session-lock waits remain. No defaults are granted before a successful load, and lock safety is unchanged.
- This optimization/client-cookie/HUD revision was not playtested, per request.

## Player saves (ProfileStore)

- `src/server/Packages/ProfileStore.lua` is the official MAD STUDIO implementation, pinned with its MIT license and upstream commit recorded alongside it.
- `PlayerDataService.lua` owns profile sessions; the economy mutates the active `Profile.Data` table directly. Profiles reconcile missing fields and validate numbers/schema before gameplay is enabled. Failed loads never start a fresh disposable profile or reset balances.
- Autosave every 60 seconds, final save on leaving, and shutdown waiting/session locks/retries are handled by ProfileStore. A lost session disables interactions and asks the player to rejoin.
- The upgrade board displays loading, unsaved changes, saving, saved, or delayed-save status. Passive production runs only while the player has an active session; there is no offline-income catch-up.
- Settings: `src/server/DataConfig.lua`. Live store: `CookieClicker_PlayerData_v1`. Studio store: `CookieClicker_PlayerData_Studio_v1`. **Studio and live saves are intentionally separate.** Keys are `Player_<UserId>`. Do not rename the live store without a migration plan.
- Studio requires a published place and **Game Settings > Security > Enable Studio Access to API Services**. This was already enabled during testing. An explicit `UseMockInStudio` option permits temporary testing, clearly marked NOT SAVED; it is off by default. No Open Cloud API key is needed for ProfileStore.
- Tests: `require(game.ServerScriptService.Server.Tests["ProfileStore.spec"])()` in a server VM. Tests cover all four saved fields, release/reload, missing fields, cancellation preflight, invalid numbers and unsupported schemas. A separate real-cloud smoke record was saved, restored after a server restart, then deleted successfully.
- Saving starts with this version; progress lost from earlier session-only builds cannot be recovered.

## Cookie popup artwork / Asphalt

- Original: `cookieclicker-ui/Codex Image Sep 5, 2026, 11_36_31 PM.png` (preserved).
- Roblox-ready transparent icon: `cookieclicker-ui/processed/cookie-pop.png` (512x512).
- Regenerate with `python scripts/prepare_cookie_icon.py` (requires Pillow).
- Upload using `node scripts/asphalt.mjs sync cloud`; the wrapper reads the ignored `.env` key. `asphalt.toml` is configured for the verified place owner, user `8317746400`.
- Asphalt generates `src/shared/Assets/ui.luau` and `asphalt.lock.toml`. Commit both; never commit `.env`.
- Current uploaded image: `rbxassetid://82865308343031` (display verified in Studio).
- `src/client/ClickPopups.lua` renders the effect. The server sends the actual credited amount, so upgrades/rebirths and the currency cap are reflected correctly; passive income and rejected clicks do not spawn popups.

## Build a place file

```sh
rojo build -o CookieClicker.rbxlx
```
