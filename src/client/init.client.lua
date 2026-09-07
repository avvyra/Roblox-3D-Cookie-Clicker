local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("CookieClickerUI")
if old then old:Destroy() end

-- First paint doesn't wait for the bakery, cookie geometry, textures, or saved data.
local hud = require(script:WaitForChild("CookieHUD"))(playerGui)
local store = require(script:WaitForChild("ClientState"))()
local hudConnection = store.Changed:Connect(hud.update)
hud.update(store.current)
local closed = false
local popups, cleanupScene

task.spawn(function()
	local assets = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("ui"))
	if closed then return end
	hud.setImage(assets["cookie-pop.png"])
	popups = require(script:WaitForChild("ClickPopups"))(playerGui, assets["cookie-pop.png"])
	local cleanup = require(script:WaitForChild("ClientScene"))(store, popups)
	if closed then cleanup() else cleanupScene = cleanup end
end)
script.Destroying:Connect(function()
	closed = true
	hudConnection:Disconnect()
	if cleanupScene then cleanupScene() end
	if popups then popups.destroy() end
	store.destroy()
	hud.destroy()
end)
