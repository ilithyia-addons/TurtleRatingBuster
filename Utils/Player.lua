if not TurtleRatingBuster.enabled then
	return
end

TurtleRatingBuster.Utils.Player = {}

local playerClass = nil
local playerClassUpper = nil

function TurtleRatingBuster.Utils.Player.GetClass()
	if not playerClass then
		playerClass, playerClassUpper = UnitClass("player")
	end

	return playerClass, playerClassUpper
end

function TurtleRatingBuster.Utils.Player.GetStats()
	local meleeHaste, spellHaste = BCS:GetHaste()
	local totalHaste = meleeHaste + spellHaste

	local damageAndHealing, _, _, damageOnly = BCS:GetSpellPower()
	local hit, hitFire, hitFrost, hitArcane, hitShadow, hitHoly = BCS:GetSpellHitRating()

	local spellCritChance = BCS:GetSpellCritChance()

	return {
		STR = select(2, UnitStat("player", 1)),
		AGI = select(2, UnitStat("player", 2)),
		STA = select(2, UnitStat("player", 3)),
		INT = select(2, UnitStat("player", 4)),
		SPI = select(2, UnitStat("player", 5)),

		MELEE_AP = select(1, UnitAttackPower("player")),
		MELEE_HIT = BCS:GetHitRating(),
		MELEE_CRIT = BCS:GetCritChance(),
		MELEE_HASTE = meleeHaste,

		ARMOR_PEN = BCS:GetArmorPen(),

		RANGED_AP = 0, -- FIXME
		RANGED_HIT = 0, -- FIXME
		RANGED_CRIT = 0, -- FIXME

		TOTAL_HASTE = totalHaste,

		SPELL_POWER = damageAndHealing + damageOnly,
		SPELL_POWER_FIRE = BCS:GetSpellPower("Fire"),
		SPELL_POWER_FROST = BCS:GetSpellPower("Frost"),
		SPELL_POWER_ARCANE = BCS:GetSpellPower("Arcane"),
		SPELL_POWER_SHADOW = BCS:GetSpellPower("Shadow"),
		SPELL_POWER_HOLY = BCS:GetSpellPower("Holy"),
		SPELL_POWER_NATURE = BCS:GetSpellPower("Nature"),

		SPELL_HIT = hit,
		SPELL_HIT_FIRE = hitFire,
		SPELL_HIT_FROST = hitFrost,
		SPELL_HIT_ARCANE = hitArcane,
		SPELL_HIT_SHADOW = hitShadow,
		SPELL_HIT_HOLY = hitHoly,

		SPELL_CRIT = spellCritChance,
		SPELL_CRIT_FIRE = spellCritChance,
		SPELL_CRIT_FROST = spellCritChance,
		SPELL_CRIT_ARCANE = spellCritChance,
		SPELL_CRIT_SHADOW = spellCritChance,
		SPELL_CRIT_HOLY = spellCritChance,

		SPELL_HASTE = spellHaste,

		SPELL_PEN = BCS:GetSpellPen() or 0,

		HEALING_POWER = 0, -- FIXME

		MANA_REGEN = 0, -- FIXME
	}
end
