return function(EconomyMath)
	assert(EconomyMath.baseClickValue(0) == 1, "rebirth 0 must award one coin")
	assert(EconomyMath.baseClickValue(1) == 2, "rebirth 1 must award two coins")
	assert(EconomyMath.baseClickValue(3) == 8, "click value must double each rebirth")

	assert(EconomyMath.rebirthQuota(0) == 100, "first rebirth quota must be 100")
	assert(EconomyMath.rebirthQuota(1) == 500, "second rebirth quota must be 500")
	assert(EconomyMath.rebirthQuota(2) == 2500, "quota must scale by five")

	assert(EconomyMath.visualTier(0) == "Chocolate Chip", "initial visual must be chocolate chip")
	assert(EconomyMath.visualTier(1) == "Golden Cookie", "first rebirth must unlock gold")
	assert(EconomyMath.visualTier(2) == "Cosmic Cookie", "second rebirth must unlock cosmic")
	assert(EconomyMath.visualTier(12) == "Cosmic Cookie", "later rebirths must retain cosmic")

	local profile = {
		Coins = 110,
		Rebirths = 0,
	}
	local completed = EconomyMath.applyAutomaticRebirths(profile)
	assert(completed == 1, "110 coins must complete one rebirth")
	assert(profile.Coins == 10, "rebirth must preserve overflow")
	assert(profile.Rebirths == 1, "rebirth count must increment")
end
