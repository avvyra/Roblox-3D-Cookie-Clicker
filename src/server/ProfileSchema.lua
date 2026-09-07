local Economy = require(game:GetService("ReplicatedStorage").Shared.Economy)
local Config = require(game.ReplicatedStorage.Shared.Config)
local Schema = {}
function Schema.template()
	local data = Economy.new()
	data.cookies = Config.InitialCookies
	data.schemaVersion = 1
	return data
end
function Schema.validate(data)
	if type(data) ~= "table" or data.schemaVersion ~= 1 then return false, "Unsupported save schema" end
	for field, maximum in pairs({cookies = Economy.MaxCurrency, rebirths = Economy.MaxRebirths, power = Economy.MaxUpgrades, ovens = Economy.MaxUpgrades}) do
		local value = data[field]
		if type(value) ~= "number" or value ~= value or value < 0 or value > maximum or value % 1 ~= 0 then
			return false, "Invalid saved " .. field
		end
	end
	return true
end
function Schema.sameProgress(a, b)
	for _, field in ipairs({"schemaVersion", "cookies", "rebirths", "power", "ovens"}) do
		if a[field] ~= b[field] then return false end
	end
	return true
end
return Schema
