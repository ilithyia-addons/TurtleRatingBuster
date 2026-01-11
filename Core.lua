if not TurtleRatingBuster.enabled then
	return
end

local slots = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11, -- Also 12, but let's just use one slot for now
	INVTYPE_TRINKET = 13, -- Also 14
	INVTYPE_WEAPON = 16, -- one hand Also 17 in case of dual wield
	INVTYPE_SHIELD = 17,
	INVTYPE_RANGED = 18,
	INVTYPE_CLOAK = 15,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_TABARD = 19,
	INVTYPE_ROBE = 5,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17,
	INVTYPE_THROWN = 18,
	INVTYPE_RANGEDRIGHT = 18,
	INVTYPE_RELIC = 18,
}

local classColors = {
	Druid = { r = 1, g = 0.49, b = 0.04 },
	Hunter = { r = 0.67, g = 0.83, b = 0.45 },
	Mage = { r = 0.25, g = 0.78, b = 0.92 },
	Paladin = { r = 0.96, g = 0.55, b = 0.73 },
	Priest = { r = 1, g = 1, b = 1 },
	Rogue = { r = 1, g = 0.96, b = 0.41 },
	Shaman = { r = 0, g = 0.44, b = 0.87 },
	Warlock = { r = 0.53, g = 0.53, b = 0.93 },
	Warrior = { r = 0.78, g = 0.61, b = 0.43 },
}

local scanTooltip = CreateFrame("GameTooltip", "TRBScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

TurtleRatingBuster.Core = {}

local function SetItemLinkInScanTooltip(itemLink)
	-- Generate a generic item link to make sur enchantments etc are not present on the item
	itemLink = TurtleRatingBuster.Utils.Item.MakeGenericItemLink(itemLink)

	scanTooltip:ClearLines()
	scanTooltip:SetHyperlink(itemLink)
end

local function SetInventorySlotInScanTooltip(slot)
	if scanTooltip:SetInventoryItem("player", slot) then
		local _, _, itemLink = strfind(GetInventoryItemLink("player", slot), "(item:%d+:%d+:%d+:%d+)")
		-- Generate a generic item link to make sur enchantments etc are not present on the item
		itemLink = TurtleRatingBuster.Utils.Item.MakeGenericItemLink(itemLink)

		if itemLink then
			scanTooltip:ClearLines()
			scanTooltip:SetHyperlink(itemLink)
		end
	end
end

local function AddTooltipLine(frame, scaleName, scaleValue)
	local class = TurtleRatingBuster.Utils.Player.GetClass()

	frame:AddDoubleLine(
		scaleName,
		scaleValue,
		classColors[class].r,
		classColors[class].g,
		classColors[class].b,
		classColors[class].r,
		classColors[class].g,
		classColors[class].b
	)
end

local function AddScaleValuesToTooltip(frame, scaleValues)
	for scale, value in pairs(scaleValues) do
		if value > 0 then
			AddTooltipLine(frame, scale, value)
		end
	end
end

local function HookTooltips()
	local onShowFactory = function(frame, getItemLinkFn)
		local scannedItemLink = nil
		local itemBonuses = nil
		local currentlyEquippedBonuses = nil
		local scaleValues = nil

		local onShow = function()
			local itemLink = getItemLinkFn()

			if not itemLink then
				TurtleRatingBuster:Debug("Unable to find an itemLink in tooltip OnShow hook")
				return
			end

			if itemLink == scannedItemLink then
				-- If it is re-invoked for the same item, we simply add the lines to the tooltip again
				AddScaleValuesToTooltip(frame, scaleValues)
				return
			end

			scannedItemLink = itemLink

			TurtleRatingBuster:Debug("Found item link: %s", itemLink)

			local itemID = TurtleRatingBuster.Utils.Item.GetItemIDFromItemLink(itemLink)
			if not itemID then
				return
			end

			-- Get bonuses of item
			local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture =
				GetItemInfo(itemID)
			local _, _, itemLink = strfind(itemLink, "(item:%d+:%d+:%d+:%d+)")
			SetItemLinkInScanTooltip(itemLink)
			itemBonuses = TurtleRatingBuster.Scanner.ScanTooltip(scanTooltip)

			if TurtleRatingBuster:IsDebugging() then
				TurtleRatingBuster:Debug("===============")
				TurtleRatingBuster:Debug("Item bonuses")
				for k, v in itemBonuses do
					if v > 0 then
						TurtleRatingBuster:Debug("%s = %s", k, v)
					end
				end
			end

			-- Get player stats without the currently equipped item
			local playerStats = TurtleRatingBuster.Utils.Player.GetStats()
			local slot = slots[itemEquipLoc]
			if slot then
				SetInventorySlotInScanTooltip(slot)
				currentlyEquippedBonuses = TurtleRatingBuster.Scanner.ScanTooltip(scanTooltip)

				if TurtleRatingBuster:IsDebugging() then
					TurtleRatingBuster:Debug("===============")
					TurtleRatingBuster:Debug("Currently equipped item bonuses")
					for k, v in itemBonuses do
						if v > 0 then
							TurtleRatingBuster:Debug("%s = %s", k, v)
						end
					end
				end

				-- Substract from the current stats the bonuses given by the currently equipped item
				for key, value in pairs(currentlyEquippedBonuses) do
					playerStats[key] = playerStats[key] - value
				end
			end

			scaleValues = TurtleRatingBuster.Weighter.WeightBonuses(itemBonuses)
			AddScaleValuesToTooltip(frame, scaleValues)
			frame:Show()
		end

		return onShow
	end

	-- Hook GameTooltip
	TurtleRatingBuster:HookScript(
		GameTooltip,
		"OnShow",
		onShowFactory(GameTooltip, function()
			return TurtleRatingBuster.Utils.GameTooltip.GetItemLink()
		end)
	)

	-- Hook ItemRefTooltip
	local itemRefTooltipItemLink = nil
	local itemRefOnShow = onShowFactory(ItemRefTooltip, function()
		return itemRefTooltipItemLink
	end)
	TurtleRatingBuster:SecureHook("SetItemRef", function(itemLink)
		itemRefTooltipItemLink = itemLink
		itemRefOnShow()
	end)

	-- Hook AtlasLootTooltip
	if IsAddOnLoaded("AtlasLoot") then
		local atlasLootTooltipItemLink = nil
		local atlastLootTooltipOnShow = onShowFactory(AtlasLootTooltip, function()
			return atlasLootTooltipItemLink
		end)
		TurtleRatingBuster:SecureHook(AtlasLootTooltip, "SetHyperlink", function(self, itemLink)
			atlasLootTooltipItemLink = itemLink
			atlastLootTooltipOnShow()
		end)
	end
end

function TurtleRatingBuster.Core.Enable()
	-- Force BCS to populate all stats into its cache
	BCS.needScanGear = true
	BCS.needScanTalents = true
	BCS.needScanAuras = true
	BCS.needScanSkills = true

	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_BASE_STATS")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_MELEE_COMBAT")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_MELEE_BOSS")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_RANGED_COMBAT")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_SPELL_COMBAT")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_SPELL_SCHOOLS")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_DEFENSES")
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", "PLAYERSTAT_DEFENSES_BOSS")

	BCS.needScanGear = false
	BCS.needScanTalents = false
	BCS.needScanAuras = false
	BCS.needScanSkills = false

	HookTooltips()
end
