TurtleRatingBuster = AceLibrary("AceAddon-2.0"):new(
	"AceEvent-2.0",
	"AceDebug-2.0",
	"AceModuleCore-2.0",
	"AceConsole-2.0",
	"AceDB-2.0",
	"AceHook-2.1"
)
TurtleRatingBuster:SetDebugging(false)
TurtleRatingBuster.enabled = true

local notify = CreateFrame("Frame", "TurtleRatingBusterMissingDeps", UIParent)

local betterCharacterStatsFound = type(BCS) == "table"
if not betterCharacterStatsFound then
	notify:SetScript("OnUpdate", function()
		DEFAULT_CHAT_FRAME:AddMessage(
			"|cffff0000TurtleRatingBuster: The addon BetterCharacterStats is required for this addon to work. Please install it in the Turtle WoW launcher.|r"
		)
		this:Hide()
	end)

	TurtleRatingBuster.enabled = false
end

function TurtleRatingBuster:OnEnable()
	if not self.enabled then
		return
	end

	local playerClass = TurtleRatingBuster.Utils.Player.GetClass()
	if not TurtleRatingBuster.Weighter.HasScalesForClass(playerClass) then
		DEFAULT_CHAT_FRAME:AddMessage(
			L["|cffffcc00TurtleRatingBuster|cffffaaaa No data for class " .. playerClass .. "|r"]
		)
		return
	end

	TurtleRatingBuster.Core.Enable()

	DEFAULT_CHAT_FRAME:AddMessage(L["|cffffcc00TurtleRatingBuster|cffffaaaa Loaded|r"])
end
