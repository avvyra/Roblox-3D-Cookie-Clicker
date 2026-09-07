-- Only the shared pedestal and invisible validation anchor exist on the server.
-- Detailed cookie artwork is built locally by src/client/ClientScene.lua.
local function part(parent, name, size, cf, color)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
	p.Anchored = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local ground = workspace:FindFirstChild("CookieClickerGround")
if not ground then
	ground = part(workspace, "CookieClickerGround", Vector3.new(512,4,512), CFrame.new(0,-2,0), Color3.new(0.32,0.46,0.36))
	ground.Material = Enum.Material.Grass; ground.Locked = true
end
local spawn = workspace:FindFirstChild("CookieClickerSpawn")
if not spawn then
	spawn = Instance.new("SpawnLocation"); spawn.Name = "CookieClickerSpawn"
	spawn.Size = Vector3.new(12,1,12); spawn.Position = Vector3.new(0,0.5,0)
	spawn.Color = Color3.new(0.85,0.66,0.38); spawn.Anchored = true; spawn.Neutral = true; spawn.Duration = 0; spawn.Parent = workspace
end
local cookie = workspace:FindFirstChild("ProceduralCookie")
if not cookie then
	cookie = Instance.new("Model"); cookie.Name = "ProceduralCookie"
	for _, spec in ipairs({
		{"PedestalFoot",0.3,0.6,18,Color3.fromRGB(65,40,31)},
		{"Pedestal",1.9,2.6,15,Color3.fromRGB(99,60,39)},
		{"GoldRim",3.3,0.25,17,Color3.fromRGB(206,149,64)},
		{"ServingPlate",3.55,0.3,16.5,Color3.fromRGB(249,230,196)},
	}) do
		local p = part(cookie,spec[1],Vector3.new(spec[3],spec[4],spec[4]),CFrame.new(0,spec[2],-20)*CFrame.Angles(0,0,math.pi/2),spec[5])
		p.Shape = Enum.PartType.Cylinder
	end
	local sign = part(cookie,"BakerySign",Vector3.new(9,1.5,0.3),CFrame.new(0,1.9,-12.35),Color3.fromRGB(55,34,26))
	local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Back; gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud = 65; gui.Parent = sign
	local text = Instance.new("TextLabel"); text.BackgroundTransparency = 1; text.Size = UDim2.fromScale(1,1); text.Text = "FRESHLY BAKED"
	text.Font = Enum.Font.GothamBold; text.TextScaled = true; text.TextColor3 = Color3.fromRGB(255,218,146); text.Parent = gui
	cookie.Parent = workspace
end
local visual = cookie:FindFirstChild("CookieVisual")
if visual then visual:Destroy() end
local anchor = cookie:FindFirstChild("CookieAnchor")
if not anchor then
	anchor = part(cookie,"CookieAnchor",Vector3.new(1,1,1),CFrame.new(0,10,-20),Color3.new(1,1,1))
	anchor.Transparency = 1; anchor.CanCollide = false; anchor.CanTouch = false; anchor.CanQuery = false; anchor.CastShadow = false
end
cookie.PrimaryPart = anchor
