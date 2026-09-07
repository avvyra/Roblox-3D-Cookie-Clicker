<div align="center">
  <img src="./cookieclicker-ui/processed/cookie-pop.png" alt="Pixel-art chocolate chip cookie" width="180" />
  <h1>Cookie Clicker</h1>
  <p><strong>Click. Upgrade. Rebirth. Evolve.</strong></p>
  <p>Build your cookie empire inside the Cookie House.</p>
  [Play Cookie Clicker on Roblox](https://www.roblox.com/share?code=294d3df91670bd47ae3077d8368436bb&type=ExperienceDetails&stamp=1788797085685)
</div>

---

## How to Play

Cookie Clicker is a 3D incremental game set in a cozy bakery. Click your cookie, grow your balance, buy upgrades, and rebirth to become stronger.

1. Click or tap the 3D cookie to earn cookies.
2. Buy **Click Power** to increase the reward from every click.
3. Buy **Auto Ovens** to earn cookies passively.
4. Reach the current rebirth goal.
5. Click the rebirth board to reset temporary upgrades and increase your power.
6. Continue upgrading and evolve your cookie from chocolate chip to golden to cosmic.

Your cookie, effects, HUD, and progression are private to you, while the bakery is shared with other players.

<table>
  <tr>
    <td align="center" width="33%">
      <img src="./docs/screenshots/+1%20Cookie%20Clicker%20Icon.png" alt="Cookie Clicker game icon" width="280" />
      <br /><sub><strong>Game icon</strong><br />Cookie Clicker promotional artwork</sub>
    </td>
    <td align="center" width="33%">
      <img src="./docs/screenshots/+1%20Cookie%20Clicker%20Thumbnail.png" alt="Cookie Clicker game thumbnail" width="280" />
      <br /><sub><strong>Game thumbnail</strong><br />Click, bake, upgrade, and expand</sub>
    </td>
    <td align="center" width="33%">
      <img src="./docs/screenshots/3d%20cookie%20clicker%20stand.jpg" alt="3D cookie clicking stand inside the bakery" width="280" />
      <br /><sub><strong>Cookie stand</strong><br />The 3D cookie station and bakery kiosks</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="./docs/screenshots/3d%20landscape.jpg" alt="Exterior landscape surrounding the Cookie House" width="280" />
      <br /><sub><strong>3D landscape</strong><br />The Cookie House and surrounding world</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20clicker.jpg" alt="Cookie Clicker gameplay with the cosmic cookie and HUD" width="280" />
      <br /><sub><strong>Gameplay</strong><br />Cosmic cookie, HUD, and upgrade board</sub>
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
      <br /><sub><strong>Rebirth</strong><br />Progress and rebirth requirements</sub>
    </td>
    <td align="center">
      <img src="./docs/screenshots/cookie%20upgrade.jpg" alt="Baker upgrades board showing click power and auto oven upgrades" width="280" />
      <br /><sub><strong>Upgrades</strong><br />Click Power and Auto Oven purchases</sub>
    </td>
  </tr>
</table>

## Persistence and Security

- Player progress is saved across sessions with session locking and automatic saves.
- Progress is saved during autosaves, when leaving, and during server shutdown.
- There is no offline-income catch-up.
- Failed loads never overwrite or reset existing progress; the player is asked to rejoin safely.
- Rewards, purchases, rebirths, and balances are calculated and controlled by the server.
- The client sends only an interaction request—it cannot provide its own reward, price, balance, or progression values.
- The server validates the player's save session, life state, distance from the interaction, and click rate.
- Each player's economy and progression are private and are not exposed through public leaderboards.

## Economy

| Rule | Current behavior |
| --- | --- |
| Click value | `(1 + Click Power level) × 2^rebirths` |
| Auto Oven | Adds `2^rebirths` cookies per second |
| Click Power cost | `floor(10 × 1.65^current level)` |
| Auto Oven cost | `floor(25 × 1.7^current level)` |
| Rebirth goal | `100 × 5^current rebirths` cookies |
| Rebirth effect | Keeps overflow, resets Click Power and Ovens, and doubles base scaling |
| Safety limits | 16 rebirths, 50 levels per upgrade, and `9e15` cookies |

Rebirth is **manual**. Earning cookies never resets your progress automatically; activate the rebirth board when the goal is reached. The first goals are 100, 500, 2,500, and 12,500 cookies.

| Rebirth | Cookie tier |
| ---: | --- |
| 0 | Chocolate Chip |
| 1 | Golden Cookie |
| 2+ | Cosmic Cookie |
