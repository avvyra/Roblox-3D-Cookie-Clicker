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

## Build a place file

```sh
rojo build -o CookieClicker.rbxlx
```
