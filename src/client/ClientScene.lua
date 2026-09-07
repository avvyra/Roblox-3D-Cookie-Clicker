return function(store, popups)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local oldUI = playerGui:FindFirstChild("CookieClickerUI")
if oldUI then oldUI:Destroy() end
local shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(shared:WaitForChild("Config"))
local Economy = require(shared:WaitForChild("Economy"))
local pedestal = workspace:WaitForChild("ProceduralCookie")
local anchor = pedestal:WaitForChild("CookieAnchor")
local cookie = Instance.new("Model")
cookie.Name = "LocalCookie"
cookie:SetAttribute("OwnerUserId", player.UserId)
cookie.Parent = workspace
local visual = require(shared:WaitForChild("CookieVisualBuilder"))(cookie, {
	ReducedDetail = UserInputService.TouchEnabled,
	Center = anchor.Position,
})
local body = visual:WaitForChild("GoldenBakedEdge")
local detector = Instance.new("ClickDetector")
detector.Name = "CookieClickDetector"; detector.MaxActivationDistance = Config.InteractionDistance; detector.Parent = visual
local clickRequest = ReplicatedStorage:WaitForChild("RequestCookieClick")
local lastRequest = -math.huge
local clickConnection = detector.MouseClick:Connect(function()
	if not store.current.ready then return end
	local now = os.clock()
	if now - lastRequest < 1 / Config.MaxClicksPerSecond then return end
	lastRequest = now
	clickRequest:FireServer() -- Server independently validates distance/life/rate/reward.
end)
local bakery = workspace:WaitForChild("CookieBakery")
local upgrade = bakery:WaitForChild("UpgradePost")
local rebirth = bakery:WaitForChild("RebirthPost")
local feedback = ReplicatedStorage:WaitForChild("CookieClickFeedback")
local function fmt(n)
	if n == math.huge then return "MAX" end
	for _, unit in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
		if n >= unit[1] then return string.format("%.1f%s", n / unit[1], unit[2]) end
	end
	return tostring(math.floor(n))
end
local function sign(post, part)
	return post:WaitForChild(part):WaitForChild("WorldSign"):WaitForChild("Text")
end
local upgradeText, rebirthText = sign(upgrade, "Board"), sign(rebirth, "Board")
local powerText, ovenText = sign(upgrade, "PowerButton"), sign(upgrade, "OvenButton")
local rebirthButtonText = sign(rebirth, "InfoButton")
rebirthText.Size = UDim2.fromScale(0.94, 0.76)
local track = Instance.new("Frame")
track.Name = "GoalProgress"; track.Position = UDim2.fromScale(0.05, 0.86); track.Size = UDim2.fromScale(0.9, 0.06)
track.BorderSizePixel = 0; track.BackgroundColor3 = Color3.fromRGB(45, 29, 59); track.Parent = rebirthText.Parent
local fill = Instance.new("Frame")
fill.Name = "Fill"; fill.Size = UDim2.fromScale(0, 1); fill.BorderSizePixel = 0
fill.BackgroundColor3 = Color3.fromRGB(255, 201, 100); fill.Parent = track
local defaults = {}
for _, p in ipairs(visual:GetChildren()) do
	if p:IsA("BasePart") then defaults[p] = { color = p.Color, material = p.Material } end
end
local lastTier = -1
local state = Economy.new()
local notice, noticeUntil = "", 0
local stopped = false
local function refresh()
	if stopped then return end
	local packet = store.current
	if not packet.ready or not packet.state then
		upgradeText.Text = "BAKER UPGRADES\nLoading your saved bakery...\n" .. (packet.saveStatus or "Connecting")
		rebirthText.Text = "COOKIE REBIRTH\nWaiting for saved progress..."
		powerText.Text = "LOADING DATA..."; ovenText.Text = "LOADING DATA..."
		rebirthButtonText.Text = "LOADING DATA..."
		fill.Size = UDim2.fromScale(0, 1)
		return
	end
	state = packet.state
	local s = state
	upgradeText.Text = "BAKER UPGRADES\n" .. fmt(s.cookies) .. " COOKIES\n" .. fmt(Economy.clickValue(s)) .. " / click  |  " .. fmt(Economy.passiveRate(s)) .. " / sec\nPower level " .. s.power .. "  |  Ovens " .. s.ovens .. "\n" .. (os.clock() < noticeUntil and notice or "Click a button below to buy\n" .. (packet.saveStatus or "Autosave on"))
	powerText.Text = "BUY CLICK POWER\n" .. fmt(Economy.cost(s,"power")) .. " cookies"
	ovenText.Text = "BUY AUTO OVEN\n" .. fmt(Economy.cost(s,"ovens")) .. " cookies"
	local tier = math.min(s.rebirths, 2)
	local tierName = ({"CHOCOLATE CHIP", "GOLDEN COOKIE", "COSMIC COOKIE"})[tier + 1]
	local goal = Economy.goal(s)
	local ready = goal ~= math.huge and s.cookies >= goal
	rebirthText.Text = "CLICK TO REBIRTH\n" .. tierName .. "  |  Rebirth " .. s.rebirths .. "\n" .. fmt(s.cookies) .. " / " .. fmt(goal) .. " cookies\n" .. (goal == math.huge and "Maximum rebirth tier reached" or "Next: x2 base click power") .. "\nUpgrades & ovens reset\nOverflow cookies are kept"
	rebirthButtonText.Text = goal == math.huge and "MAX REBIRTHS" or (ready and "READY! CLICK TO REBIRTH" or "REBIRTH • NEED " .. fmt(goal - s.cookies))
	rebirth.InfoButton.Color = ready and Color3.fromRGB(51, 137, 91) or Color3.fromRGB(110, 64, 137)
	fill.Size = UDim2.fromScale(Economy.goal(s) == math.huge and 1 or math.clamp(s.cookies / Economy.goal(s), 0, 1), 1)
	if tier ~= lastTier then
		lastTier = tier
		for p, original in pairs(defaults) do
			local chip = p.Name:match("^ChocolateChip") or p.Name:match("^ChipHighlight")
			p.Material = tier == 0 and original.material or (tier == 1 and Enum.Material.Metal or Enum.Material.SmoothPlastic)
			p.Color = tier == 0 and original.color or (tier == 1 and (chip and Color3.fromRGB(146,83,21) or Color3.fromRGB(255,196,54)) or (chip and Color3.fromRGB(131,234,255) or Color3.fromRGB(109,73,183)))
		end
	end
end
local stateConnection = store.Changed:Connect(refresh)
refresh()
local highlight = Instance.new("Highlight")
highlight.Name = "CookieHover"; highlight.Adornee = visual; highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(255,219,142); highlight.OutlineTransparency = 0.25
highlight.DepthMode = Enum.HighlightDepthMode.Occluded; highlight.Enabled = false; highlight.Parent = visual
detector.MouseHoverEnter:Connect(function(who) if who == player then highlight.Enabled = true end end)
detector.MouseHoverLeave:Connect(function(who) if who == player then highlight.Enabled = false end end)
local sounds, generations = {}, {}
for i = 1, 4 do
	local sound = Instance.new("Sound")
	sound.Name = "CookieBite" .. i; sound.SoundId = Config.ClickSoundId; sound.Volume = Config.ClickSoundVolume
	sound.RollOffMinDistance = 10; sound.RollOffMaxDistance = 65; sound.Parent = body
	sounds[i] = sound; generations[i] = 0
end
local chime = Instance.new("Sound")
chime.Name = "RebirthChime"; chime.SoundId = "rbxasset://sounds/electronicpingshort.wav"
chime.Volume = 0.55; chime.Parent = body
local attachment = Instance.new("Attachment"); attachment.Name = "CookieCelebration"; attachment.Parent = body
local burst = Instance.new("ParticleEmitter")
burst.Name = "RebirthSparkles"; burst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
burst.Rate = 0; burst.Lifetime = NumberRange.new(0.5, 1.4); burst.Speed = NumberRange.new(5, 13)
burst.SpreadAngle = Vector2.new(180,180); burst.Color = ColorSequence.new(Color3.fromRGB(255,211,108), Color3.fromRGB(142,226,255))
burst.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,0)})
burst.LightEmission = 0.8; burst.Parent = attachment
local basePivot, baseScale = visual:GetPivot(), visual:GetScale()
local elapsed, duration, direction, soundIndex = math.huge, 0.3, 1, 0
local rng = Random.new()
local feedbackConnection = feedback.OnClientEvent:Connect(function(kind, detail, earned)
	if kind == "notice" then
		notice = tostring(detail); noticeUntil = os.clock() + 4; refresh()
		task.delay(4.1, refresh)
		return
	end
	if kind == "click" then
		popups.show(earned)
		elapsed = 0; direction = -direction; soundIndex = soundIndex % #sounds + 1
		local i = soundIndex; local sound = sounds[i]
		generations[i] += 1; local generation = generations[i]
		sound:Stop(); sound.TimePosition = 0; sound.PlaybackSpeed = rng:NextNumber(0.94, 1.07); sound:Play()
		task.delay(Config.ClickSoundDuration, function() if generations[i] == generation then sound:Stop() end end)
	end
	if kind == "rebirth" or (type(detail) == "number" and detail > 0) then
		burst:Emit(65); chime.PlaybackSpeed = 1.3; chime:Play()
		notice = "REBIRTH! Your base power doubled!"; noticeUntil = os.clock() + 4; refresh(); task.delay(4.1, refresh)
	end
end)
local frameBudget = UserInputService.TouchEnabled and 1/30 or 1/60
local frameElapsed = 0
local animation = RunService.RenderStepped:Connect(function(dt)
	if elapsed >= duration then frameElapsed = 0; return end
	frameElapsed += dt
	if frameElapsed < frameBudget then return end
	elapsed = math.min(elapsed + frameElapsed, duration)
	frameElapsed = 0
	local t = elapsed / duration; local wave = math.sin(t * math.pi * 3) * (1-t)^2
	visual:ScaleTo(baseScale * (1 - 0.09 * wave))
	visual:PivotTo(CFrame.new(basePivot.Position + Vector3.new(0,0.3*math.sin(t*math.pi),0)) * CFrame.Angles(0,0,direction*0.035*wave) * basePivot.Rotation)
	if elapsed >= duration then visual:ScaleTo(baseScale); visual:PivotTo(basePivot) end
end)
return function()
	stopped = true
	animation:Disconnect(); stateConnection:Disconnect(); feedbackConnection:Disconnect(); clickConnection:Disconnect()
	track:Destroy()
	cookie:Destroy()
end
end
