-- Pure server-used economy rules; also used by clients to format world signs.
local Economy = {}
Economy.MaxRebirths = 16
Economy.MaxUpgrades = 50
Economy.MaxCurrency = 9e15
function Economy.new()
	return { cookies = 0, rebirths = 0, power = 0, ovens = 0 }
end
function Economy.clickValue(s) return (1 + s.power) * 2 ^ s.rebirths end
function Economy.passiveRate(s) return s.ovens * 2 ^ s.rebirths end
function Economy.goal(s)
	if s.rebirths >= Economy.MaxRebirths then return math.huge end
	return 100 * 5 ^ s.rebirths
end
function Economy.cost(s, kind)
	local level = kind == "power" and s.power or s.ovens
	if level >= Economy.MaxUpgrades then return math.huge end
	return math.floor((kind == "power" and 10 or 25) * (kind == "power" and 1.65 or 1.7) ^ level)
end
function Economy.award(s, amount)
	if type(amount) ~= "number" or amount ~= amount or amount < 0 or amount == math.huge then return 0 end
	s.cookies = math.min(Economy.MaxCurrency, s.cookies + math.floor(amount))
	return 0 -- Earning cookies never automatically rebirths.
end
function Economy.rebirth(s)
	local goal = Economy.goal(s)
	if goal == math.huge then return false, "Maximum rebirth level reached" end
	if s.cookies < goal then return false, "Need " .. tostring(goal - s.cookies) .. " more cookies to rebirth" end
	s.cookies -= goal
	s.rebirths += 1
	s.power = 0; s.ovens = 0
	return true, "Rebirth complete! Base power doubled."
end
function Economy.purchase(s, kind)
	if kind ~= "power" and kind ~= "ovens" then return false, "Unknown upgrade" end
	local cost = Economy.cost(s, kind)
	if cost == math.huge then return false, "Upgrade at maximum level" end
	if s.cookies < cost then return false, "Need " .. tostring(cost - s.cookies) .. " more cookies" end
	s.cookies -= cost
	s[kind] += 1
	return true, kind == "power" and "Click power upgraded!" or "Automatic oven added!"
end
return Economy
