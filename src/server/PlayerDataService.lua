local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProfileStore = require(script.Parent.Packages.ProfileStore)
local Schema = require(script.Parent.ProfileSchema)
local Config = require(script.Parent.DataConfig)
ProfileStore.SetConstant("AUTO_SAVE_PERIOD", Config.AutoSaveSeconds)
local isStudio = RunService:IsStudio()
local mock = isStudio and Config.UseMockInStudio
local storeName = isStudio and Config.StudioStoreName or Config.LiveStoreName
local store = ProfileStore.New(storeName, Schema.template())
if mock then store = store.Mock end
local sessions, loading, byKey = {}, {}, {}
local Service = {}

local function status(player, value)
	if player.Parent == Players then player:SetAttribute("SaveStatus", mock and "Mock (NOT SAVED)" or value) end
end
local function fail(player, message)
	player:SetAttribute("DataReady", false)
	if player.Parent == Players and not ProfileStore.IsClosing then player:Kick(message) end
end
function Service.IsActive(player)
	local profile = sessions[player]
	return not ProfileStore.IsClosing and player.Parent == Players and profile ~= nil and profile:IsActive()
end
function Service.Load(player)
	if loading[player] or sessions[player] then return nil end
	loading[player] = true
	player:SetAttribute("DataReady", false)
	status(player, "Loading")
	local started = os.clock()
	local function cancelled()
		return player.Parent ~= Players or ProfileStore.IsClosing or os.clock() - started >= Config.LoadTimeoutSeconds
	end
	-- ProfileStore intentionally mocks when Studio API access is unavailable.
	-- Refuse that silent fallback: never claim a non-persistent session is saved.
	while ProfileStore.DataStoreState == "NotReady" and not cancelled() do task.wait(0.1) end
	if cancelled() or (not mock and ProfileStore.DataStoreState ~= "Access") then
		loading[player] = nil
		fail(player, isStudio and "Saving unavailable. Publish this place and enable Game Settings > Security > Studio Access to API Services, then retry. No progress was reset."
			or "Player data is unavailable. Please rejoin shortly. Your saved progress has not been reset.")
		return nil
	end
	local key = "Player_" .. player.UserId
	local ok, profile = pcall(function() return store:StartSessionAsync(key, {Cancel = cancelled}) end)
	loading[player] = nil
	if not ok or not profile then
		fail(player, "Could not safely load your progress. Please rejoin. Your saved data has not been reset.")
		return nil
	end
	if cancelled() then
		profile:EndSession()
		fail(player, "Loading timed out or the server is closing. Please rejoin; no progress was reset.")
		return nil
	end
	-- Refuse unknown future versions before applying defaults.
	if type(profile.Data) ~= "table" or (profile.Data.schemaVersion ~= nil and profile.Data.schemaVersion ~= 1) then
		profile:EndSession(); fail(player, "Unsupported save version. Please try a newer server; no reset was performed."); return nil
	end
	profile:Reconcile()
	local valid = Schema.validate(profile.Data)
	if not valid then
		profile:EndSession(); fail(player, "Your save needs repair. Please contact the developer; no reset was performed."); return nil
	end
	profile:AddUserId(player.UserId)
	profile.OnSessionEnd:Connect(function()
		if sessions[player] == profile then
			sessions[player] = nil; byKey[key] = nil
			fail(player, "Your data session ended or was opened on another server. Please rejoin.")
		end
	end)
	profile.OnSave:Connect(function()
		if sessions[player] == profile then status(player, "Saving") end
	end)
	profile.OnAfterSave:Connect(function(saved)
		if sessions[player] == profile and Service.IsActive(player) then
			player:SetAttribute("LastSaveTime", os.time())
			status(player, Schema.sameProgress(profile.Data, saved) and "Saved" or "Unsaved changes")
		end
	end)
	-- No yields between the final check and publishing the session reference.
	if player.Parent ~= Players or not profile:IsActive() or ProfileStore.IsClosing then profile:EndSession(); return nil end
	sessions[player] = profile; byKey[key] = player
	status(player, "Loaded • autosave on")
	return profile.Data -- Economy edits this exact ProfileStore-owned table.
end
function Service.MarkDirty(player)
	if Service.IsActive(player) then status(player, "Unsaved changes") end
end
function Service.Release(player)
	player:SetAttribute("DataReady", false)
	local profile = sessions[player]
	if not profile then return end
	-- Remove the reference before EndSession so a normal leave doesn't kick.
	sessions[player] = nil; byKey[profile.Key] = nil
	profile:EndSession()
end
ProfileStore.OnError:Connect(function(_message, name, key)
	if name ~= storeName then return end
	local player = byKey[key]
	if player then status(player, "Save delayed • retrying") end
end)
-- ProfileStore itself handles retries, staggered autosaves, session locking,
-- and BindToClose (including waiting for pending loads/final saves).
return Service
