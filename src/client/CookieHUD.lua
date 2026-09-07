-- Small, persistent bottom-center counter, built before the world/artwork loads.
return function(playerGui)
	local old = playerGui:FindFirstChild("CookieHUD")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name="CookieHUD"; gui.ResetOnSpawn=false; gui.DisplayOrder=20
	gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=playerGui
	local pill=Instance.new("Frame")
	pill.Name="Counter"; pill.AnchorPoint=Vector2.new(0.5,1)
	pill.Position=UDim2.new(0.5,0,1,-8); pill.Size=UDim2.fromOffset(160,42)
	pill.BackgroundColor3=Color3.fromRGB(53,32,23); pill.BackgroundTransparency=0.12
	pill.BorderSizePixel=0; pill.Active=false; pill.Parent=gui
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0.5,0); corner.Parent=pill
	local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(207,151,76); stroke.Transparency=0.3; stroke.Thickness=1; stroke.Parent=pill
	local icon=Instance.new("ImageLabel")
	icon.Name="CookieLogo"; icon.BackgroundTransparency=1; icon.Size=UDim2.fromOffset(34,34)
	icon.Position=UDim2.fromOffset(8,4); icon.ScaleType=Enum.ScaleType.Fit; icon.Parent=pill
	local amount=Instance.new("TextLabel")
	amount.Name="Cookies"; amount.BackgroundTransparency=1
	amount.Position=UDim2.fromOffset(47,4); amount.Size=UDim2.new(1,-57,1,-8)
	amount.Font=Enum.Font.GothamBold; amount.TextColor3=Color3.fromRGB(255,230,176)
	amount.TextScaled=true; amount.TextXAlignment=Enum.TextXAlignment.Center
	amount.Text="Loading..."; amount.Parent=pill
	local limit=Instance.new("UITextSizeConstraint"); limit.MaxTextSize=24; limit.MinTextSize=11; limit.Parent=amount
	local function format(n)
		for _,u in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
			if n>=u[1] then return string.format("%.1f%s",n/u[1],u[2]) end
		end
		return tostring(math.floor(n))
	end
	return {
		setImage=function(id) icon.Image=id end,
		update=function(packet)
			if packet.ready and packet.state then
				amount.Text=format(packet.state.cookies)
				gui:SetAttribute("DisplayedCookies",packet.state.cookies)
			else
				amount.Text="Loading..."
				gui:SetAttribute("DisplayedCookies",nil)
			end
		end,
		destroy=function() gui:Destroy() end,
	}
end
