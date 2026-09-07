-- Private owner-only state stream; never reads other players' attributes/stats.
return function()
	local changed = Instance.new("BindableEvent")
	local store = {current = {ready=false, saveStatus="Loading...", revision=-1}, Changed=changed.Event}
	local stopped = false
	local connection
	task.spawn(function()
		local rs = game:GetService("ReplicatedStorage")
		local event = rs:WaitForChild("BakeryStateUpdated")
		local request = rs:WaitForChild("RequestBakeryState")
		if stopped then return end
		connection = event.OnClientEvent:Connect(function(packet)
			if stopped or type(packet) ~= "table" or type(packet.revision) ~= "number" then return end
			if packet.revision <= store.current.revision then return end
			store.current = packet
			changed:Fire(packet)
		end)
		-- Listen first, then request a snapshot so fast server loads cannot be missed.
		repeat
			request:FireServer()
			task.wait(3)
		until stopped or store.current.ready
	end)
	function store.destroy()
		stopped = true
		if connection then connection:Disconnect() end
		changed:Destroy()
	end
	return store
end
