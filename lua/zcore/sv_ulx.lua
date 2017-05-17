ZCore.ULX = {}

function ZCore.ULX.getPlayersWithPermission(permission)
	local players = {}
	for _, ply in ipairs(player.GetAll()) do
		if ply:query(permission) then
			table.insert(players, ply)
		end
	end
	return players
end

function ZCore.ULX.filterPlayersWithPermission(plys, permission)
    local playersWithPermission = {}
    local playersWithoutPermission = {}
    for _, ply in ipairs(plys) do
        if ply:query(permission) then
            table.insert(playersWithPermission, ply)
        else
            table.insert(playersWithoutPermission, ply)
        end
    end

    return playersWithPermission, playersWithoutPermission
end

function ZCore.ULX.tsayPlayersWithPermission(message, permission)
	for _, ply in ipairs(ZCore.ULX.getPlayersWithPermission(permission)) do
		ULib.tsay(ply, message)
	end
end

function ZCore.ULX.tsayColorPlayersWithPermission(permission, wait, ...)
	for _, ply in ipairs(ZCore.ULX.getPlayersWithPermission(permission)) do
		ULib.tsayColor(ply, wait, ...)
	end
end
