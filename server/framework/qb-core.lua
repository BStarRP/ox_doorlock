local resourceName = 'qb-core'

if not GetResourceState(resourceName):find('start') then return end

SetTimeout(0, function()
    local QB = exports[resourceName]:GetCoreObject()

    GetPlayer = QB.Functions.GetPlayer

	if GetResourceState('ox_inventory') == 'missing' then
		function RemoveItem(playerId, item, slot)
            local player = GetPlayer(playerId)

            if player then player.Functions.RemoveItem(item, 1, slot) end
		end

		---@param player table
		---@param items string[] | { name: string, remove?: boolean, metadata?: string }[]
		---@param removeItem? boolean
		---@return string?
		function DoesPlayerHaveItem(player, items, removeItem)
			local foundItems = {}
		
			for i = 1, #items do
				local item = items[i]
				local itemName = item.name or item
		
				local data = nil
				if item.metadata then
					local playerItems = player.Functions.GetItemsByName(itemName)
					for j = 1, #playerItems do
						local currentItem = playerItems[j]
						if currentItem.info and currentItem.info.type == item.metadata then
							data = currentItem
							break
						end
					end
				else
					data = player.Functions.GetItemByName(itemName)
				end
		
				if data then
					local quality = data.info and data.info.quality or 100
					if quality < 1 then 
						-- Do nothing bitch
					else
						table.insert(foundItems, itemName)
						if removeItem or item.remove then
							player.Functions.RemoveItem(itemName, 1, data.slot)
						end
					end
				end
			end
		
			if #foundItems > 0 then
				return foundItems
			else
				return false
			end
		end
    end
end)

function GetCharacterId(player)
	return player.PlayerData.citizenid
end

local groups = { 'job', 'gang' }

function IsPlayerInGroup(player, filter)
	local type = type(filter)

	if type == 'string' then
		for i = 1, #groups do
			local data = player.PlayerData[groups[i]]

			if data.name == filter then
				return data.name, data.grade.level
			end
		end
	else
		local tabletype = table.type(filter)

		if tabletype == 'hash' then
			for i = 1, #groups do
				local data = player.PlayerData[groups[i]]
				local grade = filter[data.name]

				if grade and grade <= data.grade.level then
					return data.name, data.grade.level
				end
			end
		elseif tabletype == 'array' then
			for i = 1, #filter do
				local group = filter[i]

				for j = 1, #groups do
					local data = player.PlayerData[groups[j]]

					if data.name == group then
						return data.name, data.grade.level
					end
				end
			end
		end
	end
end
