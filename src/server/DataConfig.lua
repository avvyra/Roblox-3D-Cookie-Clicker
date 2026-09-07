return {
	-- Never rename the live store casually: doing so starts a separate save history.
	LiveStoreName = "CookieClicker_PlayerData_v1",
	StudioStoreName = "CookieClicker_PlayerData_Studio_v1",
	-- Studio tests cannot modify live player saves. Real Studio saving requires
	-- Game Settings > Security > Enable Studio Access to API Services.
	UseMockInStudio = false, -- Opt-in only. Mock sessions DO NOT survive restarting Studio.
	AutoSaveSeconds = 60,
	LoadTimeoutSeconds = 90,
}
