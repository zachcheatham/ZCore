ZCore = {}

if SERVER then
	AddCSLuaFile("zcore/sh_permissions.lua")

	include("zcore/sv_config.lua")
	include("zcore/sv_mysql.lua")
	include("zcore/sv_ulx.lua")
	include("zcore/sv_util.lua")
end

include ("zcore/sh_permissions.lua")

hook.Call("ZCore_PostInit")