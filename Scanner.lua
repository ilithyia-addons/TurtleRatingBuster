if not TurtleRatingBuster.enabled then
	return
end

-- Large portions of the code in here, especially the patterns, are taken from BonusScanner
-- and BetterCharacterStats. All credits go to their respective authors.

---@param stat string|string[]
---@return function
local function add(stat)
	if type(stat) == "string" then
		return function(bonuses, value)
			bonuses[stat] = bonuses[stat] + value
		end
	elseif type(stat) == "table" then
		return function(bonuses, value)
			for _, v in ipairs(stat) do
				bonuses[v] = bonuses[v] + value
			end
		end
	else
		TurtleRatingBuster:Debug("Scanner: unexpected argument #1 of add() function (type = %s)", type(stat))
		return function(bonuses, value) end
	end
end

---@param stat string|string[]
---@return function
local function subtract(stat)
	if type(stat) == "string" then
		return function(bonuses, value)
			bonuses[stat] = bonuses[stat] - value
		end
	elseif type(stat) == "table" then
		return function(bonuses, value)
			for _, v in ipairs(stat) do
				bonuses[v] = bonuses[v] - value
			end
		end
	else
		TurtleRatingBuster:Debug("Scanner: unexpected argument #1 of subtract() function (type = %s)", type(stat))
		return function(bonuses, value) end
	end
end

local function doNothing()
	return function(bonuses, value)
		return bonuses
	end
end

local passivePatterns = {
	{ pattern = "^Improves your chance to hit by (%d)%%", fn = add("MELEE_HIT") },
	{
		pattern = "^Improves your chance to hit with spells and attacks by (%d+)%%",
		fn = add({ "MELEE_HIT", "SPELL_HIT" }),
	},
	{ pattern = "^Improves your chance to hit with spells by (%d)%%", fn = add("SPELL_HIT") },
	{
		pattern = "^Improves your chance to hit and get a critical strike with spells by (%d+)%%",
		fn = add({ "SPELL_HIT", "SPELL_CRIT" }),
	},
	{ pattern = "^Improves your chance to get a critical strike by (%d+)%%", fn = add({ "MELEE_CRIT", "RANGED_CRIT" }) },
	{
		pattern = "^Improves your chance to get a critical strike with missile weapons by (%d+)%%",
		fn = add("RANGED_CRIT"),
	},
	{ pattern = "^Improves your chance to get a critical strike with spells by (%d+)%%", fn = add("SPELL_CRIT") },
	{
		pattern = "^Improves your chance to get a critical strike with Holy spells by (%d+)%%",
		fn = add("SPELL_CRIT_HOLY"),
	},
	{ pattern = "^Increases the critical effect chance of your Holy spells by (%d+)%%", fn = add("SPELL_CRIT_HOLY") },
	{
		pattern = "^Increases damage done by Arcane spells and effects by up to (%d+)%.",
		fn = add("SPELL_POWER_ARCANE"),
	},
	{ pattern = "^Increases damage done by Fire spells and effects by up to (%d+)%.", fn = add("SPELL_POWER_FIRE") },
	{ pattern = "^Increases damage done by Frost spells and effects by up to (%d+)%.", fn = add("SPELL_POWER_FROST") },
	{
		pattern = "^Increases damage done by Shadow spells and effects by up to (%d+)%.",
		fn = add("SPELL_POWER_SHADOW"),
	},
	{ pattern = "^Increases damage done by Holy spells and effects by up to (%d+)%.", fn = add("SPELL_POWER_HOLY") },
	{
		pattern = "^Increases damage done by Nature spells and effects by up to (%d+)%.",
		fn = add("SPELL_POWER_NATURE"),
	},
	{
		pattern = "^Increases damage and healing done by magical spells and effects by up to (%d+)%.",
		fn = add({ "SPELL_POWER", "HEALING_POWER" }),
	},
	{
		pattern = "^Increases your spell damage by up to (%d+) and your healing by up to (%d+)%.",
		fn = function(bonuses, spellPower, healingPower)
			bonuses.SPELL_POWER = bonuses.SPELL_POWER + spellPower
			bonuses.HEALING_POWER = bonuses.HEALING_POWER + healingPower
		end,
	},
	{ pattern = "^Increases damage done by magical spells and effects by up to (%d+)%.", fn = add("SPELL_POWER") },
	{ pattern = "^Increases healing done by spells and effects by up to (%d+)%.", fn = add("HEALING_POWER") },
	{ pattern = "^Restores (%d+) mana per 5 sec%.", fn = add("MANA_REGEN") },
	{ pattern = "^Restores (%d+) mana every 5 sec%.", fn = add("MANA_REGEN") },
	{
		pattern = "^Healing %+(%d+) and (%d+) mana per 5 sec.",
		fn = function(bonuses, healingValue, manaRegenValue)
			bonuses.HEALING_POWER = bonuses.HEALING_POWER + healingValue
			bonuses.MANA_REGEN = bonuses.MANA_REGEN + manaRegenValue
		end,
	},
	{ pattern = "^%+(%d+) mana every 5 sec%.", fn = add("MANA_REGEN") },
	{ pattern = "^Allows (%d+)%% of your Mana regeneration to continue while casting", fn = add("MANA_REGEN") },
	{ pattern = "^Increases your attack and casting speed by (%d+)%%", fn = add({ "SPELL_HASTE", "MELEE_HASTE" }) },
	{ pattern = "^Increases your casting speed by (%d+)%%", fn = add("SPELL_HASTE") },
	{ pattern = "^Your attacks ignore (%d+) of the target's armor", fn = add("ARMOR_PEN") },
	{ pattern = "^Decreases the magical resistances of your spell targets by (%d+)", fn = add("SPELL_PEN") },
	{ pattern = "^%+(%d+) Arcane Spell Damage", fn = add("SPELL_POWER_ARCANE") },
	{ pattern = "^%+(%d+) Fire Spell Damage", fn = add("SPELL_POWER_FIRE") },
	{ pattern = "^%+(%d+) Frost Spell Damage", fn = add("SPELL_POWER_FROST") },
	{ pattern = "^%+(%d+) Shadow Spell Damage", fn = add("SPELL_POWER_SHADOW") },
	{ pattern = "^%+(%d+) Holy Spell Damage", fn = add("SPELL_POWER_HOLY") },
	{ pattern = "^%+(%d+) Nature Spell Damage", fn = add("SPELL_POWER_NATURE") },
	{ pattern = "^%+(%d+) ranged Attack Power%.", fn = add("RANGED_AP") },
	{ pattern = "^%+(%d+) Attack Power%.", fn = add("MELEE_AP") },
	{
		pattern = "^%+(%d+) Attack Power in Cat, Bear, Dire Bear, and Moonkin forms only%.",
		fn = function(bonuses, value)
			local _, unitClass = TurtleRatingBuster.Utils.Player.GetClass()
			if unitClass == "DRUID" then
				bonuses.MELEE_AP = bonuses.MELEE_AP + value
			end
		end,
	},
	{ pattern = "^Increases your chance to block attacks with a shield by (%d+)%%%", fn = doNothing() },
	{ pattern = "^Increases your chance to dodge an attack by (%d+)%%", fn = doNothing() },
	{ pattern = "^Increases your chance to parry an attack by (%d+)%%", fn = doNothing() },
}

local genericPatterns = {
	{ pattern = "^%+(%d+) Strength", fn = add("STR") },
	{ pattern = "^%+(%d+) Agility", fn = add("AGI") },
	{ pattern = "^%+(%d+) Stamina", fn = add("STA") },
	{ pattern = "^%+(%d+) Intellect", fn = add("INT") },
	{ pattern = "^%+(%d+) Spirit", fn = add("SPI") },
	{ pattern = "^%+(%d+) All Stats", fn = add({ "STR", "AGI", "STA", "INT", "SPI" }) },
	{ pattern = "^%-(%d+) Strength", fn = subtract("STR") },
	{ pattern = "^%-(%d+) Agility", fn = subtract("AGI") },
	{ pattern = "^%-(%d+) Stamina", fn = subtract("STA") },
	{ pattern = "^%-(%d+) Intellect", fn = subtract("INT") },
	{ pattern = "^%-(%d+) Spirit", fn = subtract("SPI") },
	{ pattern = "^%-(%d+) All Stats", fn = subtract({ "STR", "AGI", "STA", "INT", "SPI" }) },
}

local function CheckGeneric(line, bonuses)
	local value, found

	found = false
	for _, p in ipairs(genericPatterns) do
		local _, _, value1, value2, value3, value4, value5 = string.find(line, p.pattern)
		if value1 then
			p.fn(bonuses, value1, value2, value3, value4, value5)
			found = true
			break
		end
	end

	if not found then
		TurtleRatingBuster:Debug("Scanner: No generic pattern was found for line %s", line)
	end
end

local function CheckPassive(line, bonuses)
	local value, found

	found = false
	for _, p in ipairs(passivePatterns) do
		local _, _, value1, value2, value3, value4, value5 = string.find(line, p.pattern)
		if value1 then
			p.fn(bonuses, value1, value2, value3, value4, value5)
			found = true
			break
		end
	end

	if not found then
		TurtleRatingBuster:Debug("Scanner: No passive pattern was found for line %s", line)
		CheckGeneric(line)
	end
end

local equipPrefix = "Equip: "
local setPrefix = "Set: "

---Scans a line of text against known patterns
---@param line string
---@param bonuses table
local function ScanLine(line, bonuses)
	local tmpStr, found
	-- Check for "Equip: "
	if string.sub(line, 0, string.len(equipPrefix)) == equipPrefix then
		tmpStr = string.sub(line, string.len(equipPrefix) + 1)
		CheckPassive(tmpStr, bonuses)
	-- Check for "Set: "
	-- elseif
	-- 	string.sub(line, 0, string.len(setPrefix)) == setPrefix
	-- then
	-- 	tmpStr = string.sub(line, string.len(setPrefix) + 1)
	-- 	BonusScanner:CheckPassive(tmpStr)
	else
		CheckGeneric(line, bonuses)
	end
end

TurtleRatingBuster.Scanner = {}

---@param frame GameTooltip
function TurtleRatingBuster.Scanner.ScanTooltip(frame)
	local bonuses = {
		STR = 0,
		AGI = 0,
		STA = 0,
		INT = 0,
		SPI = 0,

		MELEE_AP = 0,
		MELEE_HIT = 0,
		MELEE_CRIT = 0,
		MELEE_HASTE = 0,

		ARMOR_PEN = 0,

		RANGED_AP = 0,
		RANGED_HIT = 0,
		RANGED_CRIT = 0,

		TOTAL_HASTE = 0,

		SPELL_POWER = 0,
		SPELL_POWER_FIRE = 0,
		SPELL_POWER_FROST = 0,
		SPELL_POWER_ARCANE = 0,
		SPELL_POWER_SHADOW = 0,
		SPELL_POWER_HOLY = 0,
		SPELL_POWER_NATURE = 0,

		SPELL_HIT = 0,
		SPELL_HIT_FIRE = 0,
		SPELL_HIT_FROST = 0,
		SPELL_HIT_ARCANE = 0,
		SPELL_HIT_SHADOW = 0,
		SPELL_HIT_HOLY = 0,

		SPELL_CRIT = 0,
		SPELL_CRIT_FIRE = 0,
		SPELL_CRIT_FROST = 0,
		SPELL_CRIT_ARCANE = 0,
		SPELL_CRIT_SHADOW = 0,
		SPELL_CRIT_HOLY = 0,

		SPELL_HASTE = 0,

		SPELL_PEN = 0,

		HEALING_POWER = 0,

		MANA_REGEN = 0,
	}

	for line = 1, frame:NumLines() do
		local left = _G[frame:GetName() .. "TextLeft" .. line]
		local text = left:GetText()
		if text then
			ScanLine(text, bonuses)
		end
	end

	return bonuses
end
