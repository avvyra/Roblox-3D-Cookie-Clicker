# Cookie Clicker — Product Context

## Product summary

Cookie Clicker is a multiplayer Roblox incremental game set in a shared 3D bakery. Each player receives a personal cookie station and earns coins by clicking or tapping its cookie. Reaching a coin quota triggers an automatic rebirth, increases future click value, and evolves the cookie's appearance.

The first release focuses on a short, understandable loop:

1. Click the personal cookie.
2. Receive coins immediately.
3. Buy upgrades that accelerate progress.
4. Reach the current quota.
5. Rebirth automatically.
6. Unlock a stronger cookie appearance and repeat.

## Product goals

- Make the first click understandable without a tutorial.
- Make every accepted click feel responsive through animation, sound, particles, and floating reward text.
- Give the player a visible goal through a persistent quota bar.
- Make rebirths feel rewarding rather than punitive.
- Support desktop, mobile, and gamepad input.
- Preserve meaningful progression across sessions.
- Keep all currency and progression decisions secure on the server.

## Player experience

Players spawn in a shared bakery containing a limited number of personal stations. The server assigns an available station to each player. Only that player can earn coins from the assigned cookie, although other players can see its visual evolution and effects.

The primary HUD displays:

- Current coins
- Coins earned per manual click
- Current rebirth count
- Current quota and progress bar
- Passive coins per second when producers are unlocked
- Active boost indicators
- Save status only when saving is delayed or unavailable

The cookie must support mouse click, screen tap, and gamepad interaction. A valid interaction produces local feedback immediately while the server validates and awards the actual currency.

## Core economy

### Manual clicks

The initial base value is one coin per accepted click.

```text
baseClickValue = 2 ^ rebirthCount
coinsPerClick = floor(baseClickValue × permanentMultiplier × temporaryMultiplier)
```

Ordinary click upgrades may add a separate upgrade multiplier after the core release. The server is the only authority allowed to calculate and grant the reward.

### Automatic rebirth

The first quota is 100 coins. Every later quota increases to prevent rebirths from becoming progressively faster solely because click value doubles.

```text
rebirthQuota = 100 × (5 ^ rebirthCount)
```

Examples:

- Rebirth 0 → quota 100, base click value 1
- Rebirth 1 → quota 500, base click value 2
- Rebirth 2 → quota 2,500, base click value 4
- Rebirth 3 → quota 12,500, base click value 8

When the balance reaches or exceeds the quota, the server:

1. Subtracts the completed quota and preserves overflow coins.
2. Increments the rebirth count.
3. Recalculates click value and the next quota.
4. Resets ordinary upgrades and passive producers.
5. Preserves permanent bonuses, unlocked cosmetics, statistics, and achievements.
6. Applies the cookie visual for the new tier.
7. broadcasts a rebirth animation and updated state.

The server repeats the check if one unusually large reward is enough to cross multiple quotas.

## Cookie visual progression

The approved direction is **Classic Evolution**. The cookies are 3D models built from Roblox parts and meshes, with effects that can be rendered consistently across supported devices.

### Tier 1 — Chocolate Chip Cookie

- Active at rebirth 0
- Warm baked-brown base with raised chocolate chips
- Small squash-and-return animation per click
- Crumb particles and a soft baking sound

### Tier 2 — Golden Cookie

- Unlocked at rebirth 1
- Gold material, brighter edge, and subtle sparkle particles
- Stronger click flash and richer reward sound
- Short gold burst when the tier is unlocked

### Tier 3 — Cosmic Cookie

- Unlocked at rebirth 2 and retained for later rebirths
- Blue-violet cosmic surface with emissive highlights
- Orbiting crumbs or stars and a restrained glow
- Strongest click pulse and a cosmic rebirth burst

Later rebirths vary the Cosmic Cookie through aura colors, orbit speed, and particle intensity. They do not require additional base cookie models.

## Progression beyond the core loop

These systems extend normal cookie-clicker mechanics without changing the core economy contract:

1. **Click upgrades** — increase manual click rewards until the next rebirth.
2. **Passive producers** — cursors, ovens, bakeries, and factories that generate coins per second.
3. **Permanent upgrades** — purchased with a rebirth-derived resource or awarded at milestones.
4. **Timed boosts** — short server-controlled multipliers with visible remaining duration.
5. **Achievements** — based on lifetime clicks, lifetime coins, rebirths, and producer milestones.
6. **Leaderboards** — rebirth count and lifetime coins, with ties resolved by the earliest achievement time.
7. **Cosmetics** — trails, station themes, and cookie auras that never provide hidden power.

Click upgrades and producers are reset by rebirth. Permanent upgrades, achievements, and cosmetics persist.

## Release scope

### Minimum viable release

- Shared 3D bakery
- Personal station assignment
- Three approved cookie visuals
- Mouse, touch, and gamepad clicking
- Server-authoritative coin rewards
- Currency and quota HUD
- Automatic scaled rebirths
- Visual evolution after rebirth
- Persistent player data
- Basic click rate validation
- Rebirth and lifetime-coin leaderstats

### Follow-up release

- Click upgrade shop
- Passive producers
- Permanent rebirth upgrades
- Timed boosts
- Achievements
- Expanded cosmetics and social effects

### Out of scope

- Player-to-player currency trading
- Shared ownership of one cookie
- Competitive combat
- User-generated cookie models
- Paid advantages that bypass server economy rules
- More than three base cookie models in the initial release

## Success criteria

- A new player can click, find the coin count, and understand the quota within 30 seconds.
- The first rebirth occurs at exactly 100 earned coins unless a configured boost changes click rewards.
- A rebirth updates currency, click power, quota, and visual tier as one server transaction.
- Rejoining restores the last successfully saved progression state.
- Clicking another player's station never grants currency.
- Remote-event spam or client-supplied currency values cannot increase progression.
- Core UI and interaction remain usable on desktop, mobile, and gamepad.
