local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cookies = Instance.new("IntValue")
	cookies.Name = "Cookies"
	cookies.Value = Config.InitialCookies
	cookies.Parent = leaderstats
end)
