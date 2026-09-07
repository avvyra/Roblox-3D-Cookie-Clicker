local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Economy = require(ReplicatedStorage.Shared:WaitForChild("Economy"))
local DataService = require(script:WaitForChild("PlayerDataService"))
local function remote(name)
	local r = ReplicatedStorage:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name; r.Parent = ReplicatedStorage
	return r
end
local feedback = remote("CookieClickFeedback")
local stateEvent = remote("BakeryStateUpdated")
local stateRequest = remote("RequestBakeryState")
local clickRequest = remote("RequestCookieClick")
local profiles, pending, revisions, lastClick, lastPurchase, lastRequest, connections = {}, {}, {}, {}, {}, {}, {}
local function sendState(player)
	if player.Parent ~= Players then pending[player] = nil; return end
	local s = profiles[player]
	local ready = s ~= nil and DataService.IsActive(player)
	revisions[player] = (revisions[player] or 0) + 1
	-- No player attributes or leaderstats contain balances. Only the owner receives this.
	stateEvent:FireClient(player, {
		revision = revisions[player], ready = ready,
		state = ready and {cookies=s.cookies,rebirths=s.rebirths,power=s.power,ovens=s.ovens} or nil,
		saveStatus = player:GetAttribute("SaveStatus") or "Loading",
	})
	pending[player] = nil
end
local function publish(player, dirty)
	if dirty then DataService.MarkDirty(player) end
	pending[player] = true -- Coalesce sign/HUD updates to at most 10 per second.
end
local function setup(player)
	if connections[player] then return end
	player:SetAttribute("BakeryState", nil)
	local stats = player:FindFirstChild("leaderstats")
	if stats then stats:Destroy() end
	connections[player] = {
		player:GetAttributeChangedSignal("SaveStatus"):Connect(function() pending[player] = true end),
		player:GetAttributeChangedSignal("DataReady"):Connect(function() pending[player] = true end),
	}
	local spawn = workspace:FindFirstChild("CookieClickerSpawn")
	if spawn then player.RespawnLocation = spawn end
	local s = DataService.Load(player)
	if not s or not DataService.IsActive(player) then return end
	profiles[player] = s
	player:SetAttribute("DataReady", true)
	sendState(player)
end
Players.PlayerAdded:Connect(setup)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(setup, player) end
Players.PlayerRemoving:Connect(function(player)
	profiles[player] = nil; pending[player] = nil; revisions[player] = nil
	lastClick[player] = nil; lastPurchase[player] = nil; lastRequest[player] = nil
	for _, c in ipairs(connections[player] or {}) do c:Disconnect() end
	connections[player] = nil
	DataService.Release(player)
end)
stateRequest.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if now - (lastRequest[player] or -math.huge) < 1 then return end
	lastRequest[player] = now
	sendState(player) -- Ready handshake: covers clients that missed the initial snapshot.
end)

-- Loading starts above, before waiting for/generating the shared environment.
local bakery = require(script:WaitForChild("BakeryBuilder"))()
local spawn = workspace:WaitForChild("CookieClickerSpawn")
local cookie = workspace:WaitForChild("ProceduralCookie")
local anchor = cookie:WaitForChild("CookieAnchor")
for _, player in ipairs(Players:GetPlayers()) do player.RespawnLocation = spawn end
local function nearby(player, part, distance)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	return profiles[player] and DataService.IsActive(player) and root and hum and hum.Health > 0 and (root.Position-part.Position).Magnitude <= distance
end
local function award(player, amount, clicked)
	if not DataService.IsActive(player) then return end
	local before = profiles[player].cookies
	Economy.award(profiles[player], amount)
	local granted = profiles[player].cookies - before
	publish(player, granted > 0)
	if clicked then feedback:FireClient(player, "click", 0, granted) end
end
-- The local cookie requests an interaction, never a reward amount or new balance.
clickRequest.OnServerEvent:Connect(function(player)
	if not nearby(player, anchor, Config.InteractionDistance) then return end
	local now = os.clock()
	if now - (lastClick[player] or -math.huge) < 1/Config.MaxClicksPerSecond then return end
	lastClick[player] = now
	award(player, Economy.clickValue(profiles[player]), true)
end)
local function purchase(player, button, kind)
	if not nearby(player, button, Config.PostInteractionDistance) then return end
	local now = os.clock()
	if now - (lastPurchase[player] or -math.huge) < 0.25 then return end
	lastPurchase[player] = now
	local ok, message = Economy.purchase(profiles[player], kind)
	if ok then publish(player, true) end
	feedback:FireClient(player, "notice", message)
end
for _, post in ipairs({bakery.UpgradePost, bakery.RebirthPost}) do
	for _, obj in ipairs(post:GetDescendants()) do
		if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then obj:Destroy() end
	end
end
local function clickable(part, handler)
	local click = Instance.new("ClickDetector")
	click.Name="SignClickDetector"; click.MaxActivationDistance=Config.PostInteractionDistance; click.Parent=part
	click.MouseClick:Connect(handler)
end
for _, spec in ipairs({{"PowerButton","power"},{"OvenButton","ovens"}}) do
	local button = bakery.UpgradePost[spec[1]]
	clickable(button, function(player) purchase(player,button,spec[2]) end)
end
local function rebirth(player, button)
	if not nearby(player, button, Config.PostInteractionDistance) then return end
	local now = os.clock()
	if now - (lastPurchase[player] or -math.huge) < 0.4 then return end
	lastPurchase[player] = now
	local ok, message = Economy.rebirth(profiles[player])
	if ok then publish(player,true); feedback:FireClient(player,"rebirth",1)
	else feedback:FireClient(player,"notice",message) end
end
for _, button in ipairs({bakery.RebirthPost.InfoButton,bakery.RebirthPost.Board}) do
	clickable(button,function(player) rebirth(player,button) end)
end
local passiveElapsed, networkElapsed, rescueElapsed = 0, 0, 0
RunService.Heartbeat:Connect(function(dt)
	passiveElapsed += dt; networkElapsed += dt; rescueElapsed += dt
	local ticks = math.floor(passiveElapsed)
	if ticks>0 then passiveElapsed-=ticks end
	local rescue = rescueElapsed>=0.2
	if rescue then rescueElapsed=0 end
	if ticks>0 or rescue then
		for player,s in pairs(profiles) do
			if not DataService.IsActive(player) then continue end
			if ticks>0 then
				local rate=Economy.passiveRate(s)
				if rate>0 then award(player,rate*math.min(ticks,10),false) end
			end
			if rescue then
				local character=player.Character
				local root=character and character:FindFirstChild("HumanoidRootPart")
				if root and root.Position.Y < -30 then
					character:PivotTo(spawn.CFrame+Vector3.new(0,5,0))
					root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
				end
			end
		end
	end
	if networkElapsed>=0.1 then
		networkElapsed=0
		for player in pairs(pending) do sendState(player) end
	end
end)
