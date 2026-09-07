-- Explicit mock store: verifies persistence logic without modifying real saves.
-- Run in a server VM: require(game.ServerScriptService.Server.Tests["ProfileStore.spec"])()
return function()
	local ProfileStore = require(script.Parent.Parent.Packages.ProfileStore)
	local Schema = require(script.Parent.Parent.ProfileSchema)
	local store = ProfileStore.New("CookieClicker_ProfileStoreTests", Schema.template()).Mock
	local key = "Test_" .. game:GetService("HttpService"):GenerateGUID(false)
	local function finish(profile)
		local saved = false
		profile.OnAfterSave:Connect(function() saved = true end)
		profile:EndSession()
		assert(not profile:IsActive(), "Session must reject further writes immediately")
		local deadline = os.clock() + 15
		repeat task.wait(0.05) until saved or os.clock() > deadline
		assert(saved, "Final save did not finish")
	end
	local first = assert(store:StartSessionAsync(key))
	first:AddUserId(1); first:Reconcile()
	assert(Schema.validate(first.Data))
	first.Data.cookies = 1234; first.Data.rebirths = 3; first.Data.power = 4; first.Data.ovens = 5
	finish(first)
	local second = assert(store:StartSessionAsync(key))
	second:Reconcile()
	assert(second.Data.cookies == 1234 and second.Data.rebirths == 3)
	assert(second.Data.power == 4 and second.Data.ovens == 5)
	assert(Schema.sameProgress(second.Data, first.LastSavedData))
	second.Data.ovens = nil -- Simulate an older save with a missing field.
	finish(second)
	local third = assert(store:StartSessionAsync(key))
	third:Reconcile()
	assert(third.Data.ovens == 0 and third.Data.cookies == 1234)
	assert(Schema.validate(third.Data))
	finish(third)
	-- Upstream Mock.StartSessionAsync doesn't forward Cancel. Test the real
	-- method's preflight instead; it returns before any datastore read/write.
	local cancelStore = ProfileStore.New("CookieClicker_CancelPreflightTest", Schema.template())
	assert(cancelStore:StartSessionAsync(key, {Cancel = function() return true end}) == nil)
	local invalid = Schema.template(); invalid.cookies = 0/0
	assert(not Schema.validate(invalid))
	invalid = Schema.template(); invalid.schemaVersion = 999
	assert(not Schema.validate(invalid))
	invalid = Schema.template(); invalid.rebirths = -1
	assert(not Schema.validate(invalid))
	store:RemoveAsync(key) -- Test-only mock key.
	return "PASS: ProfileStore final save/reload of all four fields, release, reconciliation, cancelled load, schema and numeric validation (MOCK)"
end
