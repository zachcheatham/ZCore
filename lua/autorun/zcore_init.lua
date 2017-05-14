ZCore = {}

if SERVER then
	include("zcore/sv_config.lua")
	include("zcore/sv_mysql.lua")
	include("zcore/sv_ulx.lua")
	include("zcore/sv_util.lua")
end

hook.Call("ZCore_PostInit")
