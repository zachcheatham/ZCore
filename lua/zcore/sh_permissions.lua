ZCore.Perms = {}

ZCore.Perms.PERMISSION_USER = 0
ZCore.Perms.PERMISSION_ADMIM = 1
ZCore.Perms.PERMISSION_SUPERADMIN = 2

ZCore.Perms.permissions = {}
local permissions = ZCore.Perms.permissions

function ZCore.Perms.hasPerm(ply, permission)
	if ply.query then
		return ply:query(permission)
	else
		local default = permissions[permission].default
		
		if default == ZCore.Perms.PERMISSION_USER then
			return true
		elseif default == ZCore.Perms.PERMISSION_ADMIN then
			return ply:IsAdmin()
		elseif default == ZCore.Perms.PERMISSION_SUPERADMIN then
			return ply:IsSuperAdmin()
		else
			return false
		end
	end
end

function ZCore.Perms.playersWithPerm(permission)
	local players = {}
	
	for _, ply in ipairs(player.GetAll()) do
		if ZCore.Perms.hasPerm(ply, permission) then
			table.insert(players, ply)
		end
	end
		
	return players
end

function ZCore.Perms.registerPermission(permission, category, default)
	local perm = {}
	perm.default = default
	perm.category = category
	perm.id = permission
	
	permissions[permission] = perm
end

if SERVER then
	if ULib then
		local function registerULXPermissions()
			for id, perm in pairs(permissions) do
				local defaultAccess
				if default == ZCore.Perms.PERMISSION_SUPERADMIN then
					defaultAccess = ULib.ACCESS_SUPERADMIN
				elseif default == ZCore.Perms.PERMISSION_ADMIN then
					defaultAccess = ULib.ACCESS_ADMIN
				else
					defaultAccess = ULib.ACCESS_ALL
				end
				
				ULib.ucl.registerAccess(id, defaultAccess, "", perm.category)
			end
		end
		hook.Add(ulx.HOOK_ULXDONELOADING, "ZCore_InitializeULXPermissions", registerULXPermissions)
	end
end