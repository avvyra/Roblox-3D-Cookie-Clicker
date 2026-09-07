-- Rebuild only our procedural cookie artwork, leaving the bakery/pedestal intact.
return function(cookie, options)
	local reduced = options and options.ReducedDetail
	local previous = cookie:FindFirstChild("CookieVisual")
	if previous and previous:GetAttribute("ArtVersion") == 4 then return previous end
	local center = options and options.Center or Vector3.new(0, 10, -20)
	if previous and previous.PrimaryPart then center = previous.PrimaryPart.Position end
	local visual = Instance.new("Model")
	visual.Name = "CookieVisual"
	visual:SetAttribute("ArtVersion", 4)
	visual:SetAttribute("ClientOnly", true)
	local random = Random.new(48271)
	local function part(name, size, cf, color, shape, material)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
		p.Anchored = true; p.CanCollide = false; p.CanTouch = false
		p.CastShadow = name == "GoldenBakedEdge" or name == "SoftDough"
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		if shape == Enum.PartType.Ball then
			-- SpecialMesh permits true ellipsoids; PartType.Ball stays spherical.
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = p
		elseif shape then p.Shape = shape end
		p.Parent = visual
		return p
	end
	local edge = part("GoldenBakedEdge", Vector3.new(1.3, 11.85, 11.85), CFrame.new(center) * CFrame.Angles(0, math.pi / 2, 0), Color3.fromRGB(170, 100, 43), Enum.PartType.Cylinder)
	visual.PrimaryPart = edge
	part("SoftDough", Vector3.new(11.75, 11.65, 3.3), CFrame.new(center), Color3.fromRGB(214, 153, 79), Enum.PartType.Ball, Enum.Material.Sand)
	-- Hand-formed irregular edge, rather than a perfect machined disc.
	local rimCount = reduced and 24 or 35
	for i = 1, rimCount do
		local angle = i * math.pi * 2 / rimCount
		local r = random:NextNumber(5.43, 5.61)
		local size = random:NextNumber(0.67, 1.04)
		local color = Color3.fromRGB(random:NextInteger(180, 205), random:NextInteger(113, 133), 57)
		part("BakedRim" .. i, Vector3.new(size, size * 0.9, random:NextNumber(1.5, 1.8)), CFrame.new(center + Vector3.new(math.cos(angle) * r, math.sin(angle) * r, 0)), color, Enum.PartType.Ball, Enum.Material.Sand)
	end
	local function depth(x, y)
		return 1.65 * math.sqrt(math.max(0, 1 - (x / 5.875)^2 - (y / 5.825)^2))
	end
	-- Tangent-aligned toasted pores and dough flecks follow the curved surface.
	for i = 1, (reduced and 24 or 60) do
		local angle = random:NextNumber(0, math.pi * 2)
		local radius = math.sqrt(random:NextNumber()) * 5.5
		local x, y = math.cos(angle) * radius, math.sin(angle) * radius
		local z = depth(x, y)
		local normal = Vector3.new(x / 5.875^2, y / 5.825^2, z / 1.65^2).Unit
		local cf = CFrame.lookAt(center + Vector3.new(x, y, z + 0.008), center + Vector3.new(x, y, z + 0.008) + normal)
		local size = random:NextNumber(0.06, 0.22)
		local color = i % 3 == 0 and Color3.fromRGB(237, 184, 108) or Color3.fromRGB(171, 111, 53)
		part("BakedCrumb" .. i, Vector3.new(size, size * random:NextNumber(0.5, 1.2), 0.025), cf, color, Enum.PartType.Ball)
	end
	local positions = {}
	for attempt = 1, 600 do
		if #positions >= (reduced and 16 or 21) then break end
		local x, y = random:NextNumber(-4.9, 4.9), random:NextNumber(-4.9, 4.9)
		local valid = x*x + y*y < 24
		for _, point in ipairs(positions) do
			if (Vector2.new(x,y) - point).Magnitude < 1.55 then valid = false; break end
		end
		if valid then table.insert(positions, Vector2.new(x,y)) end
	end
	-- Large embedded chocolate chunks with rounded melted edges and angled tops.
	for i, point in ipairs(positions) do
		local size = random:NextNumber(0.8, 1.24)
		local pos = center + Vector3.new(point.X, point.Y, depth(point.X, point.Y) + 0.05)
		local angle = random:NextNumber(-math.pi, math.pi)
		local cf = CFrame.new(pos) * CFrame.Angles(random:NextNumber(-0.12, 0.12), random:NextNumber(-0.12, 0.12), angle)
		part("ChocolateChipMelt" .. i, Vector3.new(size * 1.18, size, 0.3), cf, Color3.fromRGB(94, 49, 27), Enum.PartType.Ball)
		local chunk = part("ChocolateChip" .. i, Vector3.new(size * 0.86, size * 0.67, random:NextNumber(0.3, 0.48)), cf * CFrame.new(0,0,0.13), Color3.fromRGB(random:NextInteger(63, 82), 35, 23))
		chunk.Reflectance = 0.035
		part("ChipHighlight" .. i, Vector3.new(size * 0.62, size * 0.12, 0.04), cf * CFrame.new(0,size * 0.22,0.36), Color3.fromRGB(119, 72, 42))
	end
	-- Swap only after construction succeeds. Preserve all unrelated scene parts.
	if previous then previous:Destroy() end
	for _, p in ipairs(cookie:GetChildren()) do
		if p:IsA("BasePart") and (p.Name == "GoldenBakedEdge" or p.Name == "SoftDough" or p.Name == "GoldenFace" or p.Name == "BackDough"
			or p.Name:match("^BakedRim") or p.Name:match("^ChocolateChip") or p.Name:match("^ChipHighlight") or p.Name:match("^BakedCrumb")) then p:Destroy() end
	end
	visual.Parent = cookie
	cookie.PrimaryPart = edge
	cookie:SetAttribute("Generator", "CookieScene-v4-local")
	return visual
end
