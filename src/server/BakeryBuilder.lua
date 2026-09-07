-- Procedural edit/runtime bakery. Run require(...BakeryBuilder)() via MCP.
return function()
	local old = workspace:FindFirstChild("CookieBakery")
	if old then return old end
	local model = Instance.new("Model")
	model.Name = "CookieBakery"
	model:SetAttribute("Generator", "Bakery-v1")
	local cream = Color3.fromRGB(247, 224, 184)
	local wood = Color3.fromRGB(100, 57, 39)
	local teal = Color3.fromRGB(48, 106, 102)
	local gold = Color3.fromRGB(220, 168, 78)
	local function part(name, size, pos, color, material, parent)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.Position = pos; p.Color = color
		p.Anchored = true; p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = parent or model
		return p
	end
	local function textSign(parent, name, size, pos, title, color)
		local board = part(name, size, pos, color or wood, nil, parent)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "WorldSign"; gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud = 50
		gui.LightInfluence = 0; gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Name = "Text"; label.Size = UDim2.fromScale(0.94, 0.9)
		label.Position = UDim2.fromScale(0.03, 0.05); label.BackgroundTransparency = 1
		label.Text = title; label.TextScaled = true; label.TextWrapped = true
		label.Font = Enum.Font.GothamBold; label.TextColor3 = cream; label.Parent = gui
		return board
	end
	-- Open entrance, glazed side windows, solid rear wall, and a high beamed roof.
	part("Foundation", Vector3.new(76, 0.25, 64), Vector3.new(0, 0.125, -19), wood, Enum.Material.WoodPlanks)
	for x = -34, 34, 4 do for z = -47, 9, 4 do
		local even = (math.floor((x + 34) / 4) + math.floor((z + 47) / 4)) % 2 == 0
		part("FloorTile", Vector3.new(3.94, 0.12, 3.94), Vector3.new(x, 0.31, z), even and cream or Color3.fromRGB(195, 152, 109), Enum.Material.Marble)
	end end
	part("RearWall", Vector3.new(76, 25, 1), Vector3.new(0, 12.5, -51), cream, Enum.Material.Brick)
	for _, x in ipairs({-38, 38}) do
		part("WindowSillWall", Vector3.new(1, 5, 64), Vector3.new(x, 2.5, -19), teal, Enum.Material.WoodPlanks)
		part("WindowHeader", Vector3.new(1, 4, 64), Vector3.new(x, 23, -19), cream)
		for z = -47, 9, 14 do
			part("WindowPost", Vector3.new(1.5, 20, 1.4), Vector3.new(x, 12, z), wood, Enum.Material.Wood)
			if z < 9 then
				local glass = part("BakeryWindow", Vector3.new(0.3, 16, 12.6), Vector3.new(x, 13, z + 7), Color3.fromRGB(173, 222, 225), Enum.Material.Glass)
				glass.Transparency = 0.72
				part("WindowCrossbar", Vector3.new(1, 0.35, 12.6), Vector3.new(x, 13, z + 7), wood)
			end
		end
	end
	for _, x in ipairs({-30, 30}) do
		part("EntrancePillar", Vector3.new(15, 25, 1), Vector3.new(x, 12.5, 13), teal, Enum.Material.WoodPlanks)
	end
	part("EntranceHeader", Vector3.new(76, 5, 1.5), Vector3.new(0, 23, 13), wood)
	textSign(model, "BakeryTitle", Vector3.new(36, 3.4, 0.3), Vector3.new(0, 23, 13.9), "THE COOKIE HOUSE", teal)
	textSign(model, "BackTitle", Vector3.new(35, 3, 0.3), Vector3.new(0, 20, -50.3), "BAKED WITH LOVE", teal)
	part("Roof", Vector3.new(79, 0.8, 67), Vector3.new(0, 26, -19), Color3.fromRGB(82, 46, 34), Enum.Material.WoodPlanks)
	for z = -45, 11, 14 do part("CeilingBeam", Vector3.new(76, 1.1, 1), Vector3.new(0, 24.8, z), wood, Enum.Material.Wood) end
	for _, x in ipairs({-21, 21}) do for _, z in ipairs({-35, -6}) do
		part("LampStem", Vector3.new(0.15, 4, 0.15), Vector3.new(x, 23, z), wood, Enum.Material.Metal)
		local lamp = part("WarmPendant", Vector3.new(3, 0.6, 3), Vector3.new(x, 21, z), Color3.fromRGB(255, 220, 162), Enum.Material.Neon)
		local light = Instance.new("PointLight"); light.Color = Color3.fromRGB(255, 221, 174)
		light.Range = 32; light.Brightness = 0.5; light.Shadows = false; light.Parent = lamp
	end end
	-- Bakery counters, pastry trays, flour sacks and tiled ovens at the back.
	for _, x in ipairs({-26, 26}) do
		part("PastryCounter", Vector3.new(13, 4, 25), Vector3.new(x, 2.4, -29), teal, Enum.Material.WoodPlanks)
		part("Countertop", Vector3.new(14, 0.5, 26), Vector3.new(x, 4.65, -29), cream, Enum.Material.Marble)
		for _, z in ipairs({-37, -28, -19}) do
			part("BakingTray", Vector3.new(9, 0.2, 6), Vector3.new(x, 4.98, z), Color3.fromRGB(90, 94, 101), Enum.Material.Metal)
			for j = -1, 1 do for k = -1, 1 do
				local bun = part("FreshBread", Vector3.new(1.8, 1.1, 1.45), Vector3.new(x + j * 2.5, 5.6, z + k * 1.6), Color3.fromRGB(216, 153, 78))
				bun.Shape = Enum.PartType.Ball
			end end
		end
	end
	for _, x in ipairs({-25, 25}) do
		part("BrickOven", Vector3.new(12, 10, 5), Vector3.new(x, 5.4, -47), Color3.fromRGB(152, 86, 57), Enum.Material.Brick)
		part("OvenOpening", Vector3.new(8, 5, 0.2), Vector3.new(x, 4.5, -44.4), Color3.fromRGB(32, 25, 25))
		part("OvenGlow", Vector3.new(6, 0.5, 0.3), Vector3.new(x, 2.5, -44.15), Color3.fromRGB(255, 144, 43), Enum.Material.Neon)
		textSign(model, "OvenLabel", Vector3.new(9, 1.6, 0.2), Vector3.new(x, 8.4, -44.3), "FRESH EVERY DAY")
	end
	-- Two physical kiosks beside the central cookie. GUI text is personalized locally.
	for _, spec in ipairs({{"UpgradePost", -12, teal, "BAKER UPGRADES"}, {"RebirthPost", 12, Color3.fromRGB(110, 64, 137), "COOKIE REBIRTH"}}) do
		local post = Instance.new("Model"); post.Name = spec[1]; post.Parent = model
		local x = spec[2]
		part("Foot", Vector3.new(8, 0.6, 6), Vector3.new(x, 0.7, -10), wood, nil, post)
		part("Post", Vector3.new(1.2, 6, 1.2), Vector3.new(x, 3.8, -10.5), gold, Enum.Material.Metal, post)
		textSign(post, "Board", Vector3.new(9, 7, 0.6), Vector3.new(x, 8, -10), spec[4] .. (spec[1] == "UpgradePost" and "\nCLICK POWER +1\nAUTO OVENS +1 / SEC\nUse the buttons below" or "\nCLICK TO REBIRTH\nFIRST GOAL: 100 COOKIES\nUpgrades reset • overflow kept"), spec[3])
		if spec[1] == "UpgradePost" then
			for i, item in ipairs({{"PowerButton", "BUY CLICK POWER", -2.15}, {"OvenButton", "BUY AUTO OVEN", 2.15}}) do
				textSign(post, item[1], Vector3.new(4.15, 1.8, 1), Vector3.new(x + item[3], 3.5, -8.8), item[2], spec[3])
			end
			-- Decorative rolling pin topper.
			local pin = part("RollingPin", Vector3.new(6, 0.8, 0.8), Vector3.new(x, 12.2, -10), Color3.fromRGB(221, 170, 103), nil, post)
			pin.Shape = Enum.PartType.Cylinder
		else
			textSign(post, "InfoButton", Vector3.new(7, 1.8, 1), Vector3.new(x, 3.5, -8.8), "CLICK TO REBIRTH", spec[3])
			local star = part("RebirthGem", Vector3.new(1.8, 1.8, 1.8), Vector3.new(x, 12.3, -10), gold, Enum.Material.Neon, post)
			star.Orientation = Vector3.new(0, 0, 45)
		end
	end
	model.Parent = workspace
	return model
end
