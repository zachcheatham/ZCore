ZCore.Util = {}

function ZCore.Util.getServerIP()
	local hostip = tonumber(GetConVarString("hostip"))
	
	local ip = {}
	ip[1] = bit.rshift(bit.band( hostip, 0xFF000000 ), 24)
	ip[2] = bit.rshift(bit.band( hostip, 0x00FF0000 ), 16)
	ip[3] = bit.rshift(bit.band( hostip, 0x0000FF00 ), 8)
	ip[4] = bit.band(hostip, 0x000000FF)
	
	local ipaddress = table.concat(ip, ".")
	local hostport = tonumber(GetConVarString("hostport"))
	
	return (ipaddress .. ":" .. hostport)
end

function ZCore.Util.removePortFromIP(address)
	local i = string.find(address, ":")
	if not i then return address end
	return string.sub(address, 1, i-1)
end

function ZCore.Util.sendZachAnError(text)
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID() == "STEAM_0:0:31424517" then
			ply:PrintMessage(HUD_PRINTTALK, "[ZCore Error] " .. text)
			break
		end
	end
end