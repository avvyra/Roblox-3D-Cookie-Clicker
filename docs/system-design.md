# Cookie Clicker — System Design

## Architecture

The game uses a server-authoritative Roblox client/server architecture. Clients own input collection, interface rendering, and immediate cosmetic feedback. The server owns station assignment, click validation, currency, purchases, rebirths, passive production, and persistent data.

The client never sends a reward amount, multiplier, price, rebirth count, or save payload. A manual-click request means only: "I interacted with my assigned station." The server derives every economic result from server-owned state and configuration.

## Suggested project structure

```text
ReplicatedStorage/
  Shared/
    Config/
      BalanceConfig.luau
      CookieConfig.luau
      UpgradeConfig.luau
    Types/
      PlayerDataTypes.luau
    Util/
      EconomyMath.luau
  Remotes/
    RequestCookieClick
    RequestPurchase
    PlayerStateUpdated
    RebirthOccurred

ServerScriptService/
  Bootstrap.server.luau
  Services/
    PlayerDataService.luau
    StationService.luau
    EconomyService.luau
    RebirthService.luau
    ProductionService.luau

StarterPlayer/
  StarterPlayerScripts/
    Controllers/
      ClickController.client.luau
      HUDController.client.luau
      StationVisualController.client.luau
      EffectsController.client.luau

StarterGui/
  MainHUD/
  UpgradeShop/

ServerStorage/
  CookieModels/
    ChocolateChip/
    Golden/
    Cosmic/

Workspace/
  Stations/
    StationSpawnPoints/
```

`ProductionService`, the upgrade shop, and related configuration belong to the follow-up release. Keeping them behind service interfaces allows them to be omitted without changing the click and rebirth flow.

## Shared configuration

All balance values live in read-only configuration modules. Services consume these values instead of embedding constants.

`BalanceConfig` contains:

- Initial click value: `1`
- Initial rebirth quota: `100`
- Rebirth quota growth factor: `5`
- Rebirth click multiplier: `2`
- Maximum normal manual click rate
- Interaction distance
- Autosave interval
- DataStore retry and backoff settings

`CookieConfig` maps progression to visuals:

- Rebirth 0 → Chocolate Chip
- Rebirth 1 → Golden
- Rebirth 2 or greater → Cosmic

For rebirths above two, it also maps milestone ranges to Cosmic aura color, particle intensity, and orbit speed.

## Server components

### PlayerDataService

Responsibilities:

- Load one server-owned profile when a player joins.
- Apply schema migrations and missing default fields.
- Prevent two live servers from writing the same profile concurrently.
- Expose controlled read and mutation APIs to other server services.
- Autosave dirty profiles at a staggered interval.
- Save on player removal and during `BindToClose`.
- Retry transient DataStore failures with bounded exponential backoff.
- Release session ownership after a successful final save or timeout.

Other services do not call DataStore APIs directly.

### StationService

Responsibilities:

- Discover configured station spawn points at server startup.
- Assign one free station to each joining player.
- Associate the station with the player's `UserId` on the server.
- Spawn the correct cookie visual for the player's current tier.
- Validate that a click refers to the player's assigned station.
- Verify the player's character is within the allowed interaction distance.
- Release and reset the station when the player leaves.

If no station is available, the player enters a queue or receives a temporary dynamically spawned station. The server must never assign one station to two players simultaneously.

### EconomyService

Responsibilities:

- Receive manual-click requests.
- Reject malformed, too-fast, distant, dead-character, or wrong-station requests.
- Calculate click rewards from server-owned data.
- Apply rewards through `PlayerDataService`.
- Trigger `RebirthService` after a balance mutation.
- Publish compact state updates to the owning client.
- Validate and execute upgrade purchases in the follow-up release.

The click rate limiter should use a token-bucket or sliding-window strategy. The chosen limit must allow expected human input and accessibility devices while making RemoteEvent spam ineffective. Rejected requests do not generate economy state updates.

### RebirthService

Responsibilities:

- Calculate the current quota.
- Detect when a currency mutation reaches the quota.
- Apply one or more automatic rebirths in a single mutation.
- Preserve overflow coins.
- Reset ordinary upgrades and passive producers.
- Preserve permanent progression.
- Resolve and apply the new cookie visual tier.
- Fire a sanitized rebirth event for UI and effects.

The entire rebirth mutation occurs before state is replicated so clients never render a partially updated balance, multiplier, or visual tier.

### ProductionService

Follow-up-release responsibilities:

- Aggregate passive production rates from owned producers.
- Award passive coins in batches rather than one DataStore or RemoteEvent operation per producer.
- Trigger the same rebirth check used by manual clicks.
- Recalculate production after purchases, boosts, and rebirths.

Passive income uses server time. Clients may animate estimated earnings but cannot award them.

## Client components

### ClickController

- Detect mouse, touch, and gamepad interaction with the assigned cookie.
- Ensure the local target is the assigned station before sending a request.
- Play a small speculative click animation immediately.
- Send one request without an economic payload.
- Avoid generating requests while menus capture input.

Speculative feedback must not display an authoritative balance. The HUD updates from the server response.

### HUDController

- Render coins, click value, rebirth count, quota, progress, and passive rate.
- Animate from the previous confirmed state to the newest confirmed state.
- Show boost timers based on server timestamps.
- Display a non-blocking warning when saving remains degraded.

### StationVisualController

- Render the tier confirmed by the server.
- Swap or enable the Chocolate Chip, Golden, and Cosmic models.
- Apply later Cosmic aura variants.
- Reconcile the local model after respawn, reassignment, or rebirth.

### EffectsController

- Play local click squash, particles, sound, and floating text.
- Play the stronger rebirth sequence from a server event.
- Apply quality scaling so mobile devices can reduce particle density.
- Keep effects cosmetic and independent from economy calculations.

## Remote-event contracts

### `RequestCookieClick`

Direction: client to server.

Payload: none, or a non-authoritative station identifier if station discovery requires it.

Server checks:

1. The player has a loaded profile.
2. The player has an assigned station.
3. The supplied target, if any, equals that station.
4. The character is alive and within interaction range.
5. The rate limiter permits the request.

### `RequestPurchase`

Direction: client to server.

Payload: configured upgrade identifier only.

The server resolves the price, verifies prerequisites and balance, performs the mutation, and returns state through `PlayerStateUpdated`.

### `PlayerStateUpdated`

Direction: server to owning client.

Payload:

- Monotonic state revision
- Coin balance
- Coins per click
- Passive coins per second
- Rebirth count
- Current quota
- Cookie visual tier
- Active boost summaries
- Relevant upgrade counts

Clients ignore state revisions older than the latest one rendered.

### `RebirthOccurred`

Direction: server to the owning client and nearby observers.

Payload:

- Player identifier
- New rebirth count
- New visual tier
- Cosmetic effect identifier

No private save data or authoritative formulas are sent.

## Persistent data model

```text
PlayerProfile
  schemaVersion: number
  coins: number
  rebirths: number
  lifetimeCoins: number
  lifetimeClicks: number
  ordinaryUpgrades: map<string, number>
  producers: map<string, number>
  permanentUpgrades: map<string, number>
  unlockedCosmetics: map<string, boolean>
  equippedCosmetics: map<string, string>
  achievements: map<string, number>
  activeBoosts: array<BoostRecord>
  lastSaveUnix: number
```

Economic values must be finite, non-negative, and bounded to the supported numeric range before saving. Data migrations are sequential and idempotent. Unknown configured items are ignored during calculation but retained when safe, allowing temporarily disabled content to return without deleting ownership.

Leaderstats mirror selected profile values for Roblox display. They are never the source of truth.

## Economy calculations

```text
baseClickValue = 2 ^ rebirths
coinsPerClick =
  floor(baseClickValue
    × permanentMultiplier
    × ordinaryUpgradeMultiplier
    × temporaryMultiplier)

rebirthQuota = 100 × (5 ^ rebirths)
```

All multipliers default to `1`. Intermediate and final results are checked for invalid or excessively large values.

Automatic rebirth uses the following transaction:

```text
while coins >= rebirthQuota(rebirths):
  coins -= rebirthQuota(rebirths)
  rebirths += 1
  reset ordinary upgrades
  reset producers

recalculate click value, production, quota, and visual tier
increment state revision
mark profile dirty
replicate one complete state snapshot
```

Resetting producers inside a multiple-rebirth loop is idempotent. A configured safety cap limits rebirth iterations per transaction and records an alert if reached.

## Manual-click data flow

1. The player clicks or taps the assigned 3D cookie.
2. `ClickController` plays immediate cosmetic feedback.
3. The client fires `RequestCookieClick`.
4. `EconomyService` validates profile state, station ownership, range, character state, and request rate.
5. The server calculates and adds the click reward.
6. `RebirthService` applies any automatic rebirths.
7. The server increments the profile revision and marks it dirty.
8. `PlayerStateUpdated` sends the complete confirmed state to that player.
9. `RebirthOccurred` plays rebirth effects when applicable.
10. The HUD and station visual reconcile to the confirmed state.

## Persistence lifecycle

### Join

1. Mark the player as loading and do not accept economy requests.
2. Load the profile using `UpdateAsync` and obtain session ownership.
3. Migrate and validate loaded data.
4. Initialize default data if no profile exists.
5. Assign a station and spawn the correct cookie tier.
6. Send the first complete state snapshot.
7. Enable interaction.

### Autosave

- Save only profiles marked dirty.
- Stagger players to avoid request spikes.
- Use `UpdateAsync` with session metadata and the current schema.
- Clear the dirty flag only after a confirmed save of the current revision.
- If data changes during a save, keep the newer revision dirty.

### Leave and shutdown

- Disable new economy mutations for the leaving player.
- Attempt a final save with bounded retries.
- Release session ownership.
- Release the station.
- During shutdown, save profiles concurrently within conservative DataStore limits and Roblox's shutdown deadline.

## Security controls

- Never accept currency amounts, prices, multipliers, or progression state from clients.
- Rate-limit every client-to-server RemoteEvent independently.
- Validate type, configured identifier, ownership, character state, and range.
- Keep server-only models, configuration secrets, and persistence code outside client containers.
- Use server timestamps for boosts and cooldowns.
- Log repeated invalid requests with sampling to avoid log flooding.
- Do not automatically ban on one anomaly; reject the request and collect evidence.
- Revalidate all balances and prerequisites inside the purchase mutation.
- Treat leaderstats and client HUD values as presentation only.

## Failure handling

- **Data fails to load:** retry transient errors; if the profile cannot be loaded safely, do not enable progression and return the player to a clear retry flow rather than overwriting data.
- **Autosave fails:** retain dirty state, retry with backoff, and show a non-blocking delayed-save indicator after a configured duration.
- **Final save fails:** exhaust bounded retries, record structured diagnostics, and rely on session-lock expiry without writing guessed state.
- **Station is unavailable:** queue the player or create a temporary station; never let players share economy ownership accidentally.
- **Remote request is invalid:** reject it without changing state and record sampled telemetry.
- **Cookie model fails to load:** use the Chocolate Chip fallback while retaining the correct authoritative tier.
- **Client misses an event:** the next complete versioned state snapshot reconciles HUD and visual state.

## Testing strategy

### Unit tests

- Click-value calculation at multiple rebirth counts
- Quota calculation and configured growth
- Exact-threshold and overflow rebirth behavior
- Multiple rebirths from one large reward
- Reset versus persistent progression fields
- Cookie visual tier mapping
- Invalid numeric value rejection
- Data migration idempotency
- Rate-limiter boundary behavior

### Server integration tests

- Join → profile load → station assignment → first state snapshot
- Click → reward → HUD state update
- Click at quota → automatic rebirth → model swap → save
- Save → leave → rejoin → restore
- Upgrade purchase with sufficient and insufficient balance
- Two players attempting the same station
- Passive reward triggering a rebirth
- Autosave revision changing during an in-flight save

### Exploit tests

- RemoteEvent spam
- Click requests from excessive distance
- Requests targeting another player's station
- Fabricated upgrade identifiers
- Negative, infinite, non-numeric, or oversized payload values
- Replay of stale requests and state revisions

### Playtests

- Desktop mouse interaction
- Mobile tapping and HUD scaling
- Gamepad focus and activation
- Multiplayer station visibility and ownership
- Respawn and station reassignment
- Low-quality particle settings
- Temporary DataStore degradation in Studio test infrastructure

## Observability

Track aggregated, non-sensitive metrics:

- Accepted and rejected clicks
- Rejection reasons
- Coins earned by source
- Rebirths per session
- Time to first rebirth
- Save attempts, latency, and failures
- Profile load failures
- Station allocation failures

Structured logs include a server identifier, player `UserId`, state revision, operation name, and sanitized error category. They must not contain full profile payloads.

## Delivery order

1. Shared configuration, types, and economy math
2. Player profile loading, migration, and saving
3. Personal station assignment
4. Server-authoritative manual clicking
5. HUD and cross-platform input
6. Automatic rebirth transaction
7. Three cookie visuals and effects
8. Security validation and telemetry
9. Unit, integration, exploit, and device testing
10. Follow-up upgrades, producers, boosts, achievements, and cosmetics
