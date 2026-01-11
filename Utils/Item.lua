if not TurtleRatingBuster.enabled then
	return
end

TurtleRatingBuster.Utils.Item = {}

---@param itemLink string
---@return number?
function TurtleRatingBuster.Utils.Item.GetItemIDFromItemLink(itemLink)
	if not itemLink then
		return
	end

	local _, _, itemID = string.find(itemLink, "item:(%d+)")

	if not itemID then
		return
	end

	return tonumber(itemID)
end

---@param itemLink string
---@return string?
function TurtleRatingBuster.Utils.Item.MakeGenericItemLink(itemLink)
	if not itemLink then
		return itemLink
	end

	local _, _, itemID = strfind(itemLink, "item:(%d+):")
	if itemID then
		itemLink = string.format("item:%s:0:0:0", itemID)
	end

	return itemLink
end
