if not TurtleRatingBuster.enabled then
	return
end

---Extracts the itemID from an itemLink
---@param itemLink string
---@return number?
local function GetItemIDFromLink(itemLink)
	if not itemLink then
		return
	end

	local _, _, itemID = string.find(itemLink, "item:(%d+):")

	if not itemID then
		return
	end

	return tonumber(itemID)
end

TurtleRatingBuster.Utils.GameTooltip = {}

---Returns the itemID of the item displayed by the GameTooltip
---@return number?
function TurtleRatingBuster.Utils.GameTooltip.GetItemID()
	if GameTooltip.itemLink then
		return GetItemIDFromLink(GameTooltip.itemLink)
	end
end

function TurtleRatingBuster.Utils.GameTooltip.GetItemLink(frame)
	return GameTooltip.itemLink
end
