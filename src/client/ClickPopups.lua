-- Cosmetic, non-interactive screen rewards; never sends currency to the server.
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

return function(playerGui, imageId)
	local previous = playerGui:FindFirstChild("CookieClickPopups")
	if previous then previous:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "CookieClickPopups"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 30
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = false
	gui.Parent = playerGui
	local layer = Instance.new("Frame")
	layer.Name = "SafeArea"
	layer.Size = UDim2.fromScale(1, 1)
	layer.BackgroundTransparency = 1
	layer.Active = false
	layer.Parent = gui
	local random = Random.new()
	local active = {}
	local destroyed = false
	-- Non-blocking preload; clicks and sound never wait for an image download.
	task.spawn(function() pcall(function() ContentProvider:PreloadAsync({imageId}) end) end)

	local function show(amount)
		if destroyed or type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then return end
		local viewport = layer.AbsoluteSize
		if viewport.X < 100 or viewport.Y < 100 then return end
		while #active >= 18 do table.remove(active, 1):Destroy() end
		local iconSize = math.clamp(math.min(viewport.X, viewport.Y) * 0.14, 48, 86)
		local width = math.min(iconSize + 130, viewport.X - 24)
		local height = iconSize
		local rise = math.min(55, viewport.Y * 0.1)
		local xMin, xMax = width / 2 + 12, viewport.X - width / 2 - 12
		local yMin, yMax = height / 2 + rise + 12, viewport.Y - height / 2 - 12
		local x = xMax > xMin and random:NextNumber(xMin, xMax) or viewport.X / 2
		local y = yMax > yMin and random:NextNumber(yMin, yMax) or viewport.Y / 2
		local popup = Instance.new("Frame")
		popup.Name = "CookieReward"
		popup:SetAttribute("Amount", amount)
		popup.AnchorPoint = Vector2.new(0.5, 0.5)
		popup.Position = UDim2.fromOffset(x, y)
		popup.Size = UDim2.fromOffset(width, height)
		popup.BackgroundTransparency = 1
		popup.Active = false
		popup.Parent = layer
		table.insert(active, popup)
		local scale = Instance.new("UIScale")
		scale.Scale = 0.55; scale.Parent = popup
		local image = Instance.new("ImageLabel")
		image.Name = "CookieIcon"
		image.BackgroundTransparency = 1
		image.Size = UDim2.fromOffset(iconSize, iconSize)
		image.Image = imageId
		image.ScaleType = Enum.ScaleType.Fit
		image.Rotation = random:NextNumber(-16, 16)
		image.Active = false
		image.Parent = popup
		local text = Instance.new("TextLabel")
		text.Name = "Amount"
		text.BackgroundTransparency = 1
		text.Position = UDim2.fromOffset(iconSize + 2, 0)
		text.Size = UDim2.new(1, -iconSize - 2, 1, 0)
		text.Text = "+" .. string.format("%.0f", amount)
		text.Font = Enum.Font.GothamBlack
		text.TextColor3 = Color3.fromRGB(255, 223, 139)
		text.TextStrokeColor3 = Color3.fromRGB(64, 32, 17)
		text.TextStrokeTransparency = 0.12
		text.TextScaled = true
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Active = false
		text.Parent = popup
		local fontLimit = Instance.new("UITextSizeConstraint")
		fontLimit.MaxTextSize = 42; fontLimit.MinTextSize = 10; fontLimit.Parent = text
		TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
		TweenService:Create(popup, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(x, y - rise)}):Play()
		task.delay(0.42, function()
			if destroyed or not popup.Parent then return end
			local fade = TweenInfo.new(0.48, Enum.EasingStyle.Quad)
			TweenService:Create(image, fade, {ImageTransparency = 1}):Play()
			TweenService:Create(text, fade, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		end)
		task.delay(0.95, function()
			local index = table.find(active, popup)
			if index then table.remove(active, index) end
			popup:Destroy()
		end)
	end
	return {
		show = show,
		destroy = function()
			destroyed = true
			gui:Destroy()
			table.clear(active)
		end,
	}
end
