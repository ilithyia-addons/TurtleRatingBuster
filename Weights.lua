-- From BonusScanner
-- types = {
--   "STR",      -- strength
--   "AGI",      -- agility
--   "STA",      -- stamina
--   "INT",      -- intellect
--   "SPI",      -- spirit
--   "ARMOR",    -- reinforced armor (not base armor)

--   "ARCANERES",  -- arcane resistance
--   "FIRERES",    -- fire resistance
--   "NATURERES",  -- nature resistance
--   "FROSTRES",   -- frost resistance
--   "SHADOWRES",  -- shadow resistance

--   "FISHING",    -- fishing skill
--   "MINING",   -- mining skill
--   "HERBALISM",  -- herbalism skill
--   "SKINNING",   -- skinning skill
--   "DEFENSE",    -- defense skill

--   "BLOCK",      -- chance to block
--   "DODGE",    -- chance to dodge
--   "PARRY",    -- chance to parry
--   "ATTACKPOWER",  -- attack power
--   "ATTACKPOWERUNDEAD", -- attack power against undead

--   "CRIT",     -- chance to get a critical strike
--   "RANGEDATTACKPOWER", -- ranged attack power
--   "RANGEDCRIT", -- chance to get a crit with ranged weapons
--   "TOHIT",    -- chance to hit

--   "DMG",      -- spell damage
--   "DMGUNDEAD",  -- spell damage against undead

--   "ARCANEDMG",  -- arcane spell damage
--   "FIREDMG",    -- fire spell damage
--   "FROSTDMG",   -- frost spell damage
--   "HOLYDMG",    -- holy spell damage
--   "NATUREDMG",  -- nature spell damage
--   "SHADOWDMG",  -- shadow spell damage
--   "SPELLCRIT",  -- chance to crit with spells
--   "HEAL",     -- healing
--   "HOLYCRIT",   -- chance to crit with holy spells
--   "SPELLTOHIT",   -- Chance to Hit with spells

--   "SPELLPEN",   -- amount of spell resist reduction

--   "HEALTHREG",  -- health regeneration per 5 sec.
--   "MANAREG",    -- mana regeneration per 5 sec.
--   "HEALTH",   -- health points
--   "MANA",     -- mana points
-- };

-- Warriot
--	Might be able to generate weights based on https://thrunk112.github.io/WarriorSim-TurtleWoW/turtle.html
-- Hunter
--	https://docs.google.com/spreadsheets/d/e/2PACX-1vRC0daeaPoRNLD9vYQCUjaTrYD5zizB-dPGswtZKbnxEh4Fyhjbe9bbWo1GFL15bMwJIbJ14Jos2VBc/pubhtml#gid=205173481
--	https://docs.google.com/spreadsheets/d/1uwIMjtOPwNNYS9hxekeqT22zRktOVIwMoa1NnKXnG8o/edit?gid=1052592649#gid=1052592649 <--- probably better
-- Druid
--	https://docs.google.com/spreadsheets/d/19IALSBVKyTY1Gd63AQ-Bkbvv4I2KspxdPVWi6YtN1xA/edit?gid=1815312333#gid=1815312333 (Tank)
-- Rogue
--	https://discord.com/channels/466622455805378571/810850711318822923/1459973777566863585
--
--
-- Otherwise
--	https://pbrigade.gitlab.io/gear-planner/

local scales = {
	Druid = {
		FeralCat = {
			AP = 1,
			STR = 2.64,
			AGI = 2.76,
			MELEE_HIT = 31.85,
			MELEE_CRIT = 30.13,
			MELEE_HASTE = 13.6,
			ARMOR_PEN = 0.5,
		},
	},
	Shaman = {
		Enhancement = {
			AP = 1,
			STR = 2.32,
			AGI = 1.41,
			INT = 0.11,
			MELEE_CRIT = 24.43,
			MELEE_HIT = 42.52,
			MELEE_HASTE = 17.43,
			ARMOR_PEN = 0.49,
			SPELL_POWER = 0.67,
			SPELL_POWER_NATURE = 0.31,
			SPELL_POWER_FIRE = 0.35,
			SPELL_CRIT = 5.9,
			SPELL_HIT = 8.61,
			SPELL_PEN = 1.29,
		},
	},
}

local function calculateValueOfBonuses(bonuses, scale)
	local weights = {}
	for stat, value in bonuses do
		local x = scale[stat] or 0
		if scale[stat] then
			table.insert(weights, value * scale[stat])
		end
	end

	local sum = 0
	for _, x in ipairs(weights) do
		sum = sum + x
	end

	return sum
end

TurtleRatingBuster.Weighter = {}

function TurtleRatingBuster.Weighter.HasScalesForClass(class)
	return scales[class] ~= nil
end

function TurtleRatingBuster.Weighter.WeightBonuses(bonuses)
	local class = TurtleRatingBuster.Utils.Player.GetClass()
	local scaleValues = {}

	for i, scale in scales[class] do
		scaleValues[i] = calculateValueOfBonuses(bonuses, scale)
	end

	return scaleValues
end
