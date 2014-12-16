require("mysqloo")

ZCore.MySQL = {}

local database = nil
local connected = false
local previouslyConnected = false
local queryCache = {}

local function connect()
	if not mysqloo then Error("[ZCore] MySQLOO isn't installed properly. Unable to use MySQL functions.\n") end
	
	ServerLog("[ZCore] Connecting to MySQL...\n")
	database = mysqloo.connect(ZCore.Config.SQL.hostname, ZCore.Config.SQL.username, ZCore.Config.SQL.password, ZCore.Config.SQL.database)

	if timer.Exists("zcore_sql_connection_state") then timer.Destroy("zcore_sql_connection_state") end
	
	database.onConnectionFailed = function(_, msg)
		ErrorNoHalt("[ZCore] Failed to connect to MySQL! " .. tostring(msg) .. "\n")
		if previouslyConnected then
			ServerLog("[ZCore] Attempting MySQL reconnect in 30 seconds.\n")
			timer.Simple(30, connect)
		end
	end
	
	database.onConnected = function()
		connected = true
		ServerLog("[ZCore] Connected to MySQL.\n")

		for _, query in ipairs(queryCache) do
			ZCore.MySQL.query(query[1], query[2])
		end
		table.Empty(queryCache)
		
		timer.Create("zcore_sql_connection_state", 60, 0, function()
			if (database and database:status() == mysqloo.DATABASE_NOT_CONNECTED) then
				connected = false
				ErrorNoHalt("[ZCore] Lost connection to MySQL! Attempting reconnect...\n")
				hook.Call("ZCore_MySQL_Disconnected")
				connect()
			end
		end)
		
		hook.Call("ZCore_MySQL_Connected", nil, not previouslyConnected)
		previouslyConnected = true
	end
	
	database:connect()
end
connect() 

function ZCore.MySQL.query(sql, callback)
	if not connected then
		ServerLog("[ZCore] Caching query while MySQL is down...\n")
		table.insert(queryCache, {sql, callback})
	else
		local q = database:query(sql)
		function q:onSuccess(data)
			if callback then
				callback(data)
			end
		end
		
		function q:onError(err)
			if err == "MySQL server has gone away" then
				ServerLog("[ZCore] Caching query while MySQL is down...\n")
				table.insert(queryCache, {sql, callback})
			else
				ErrorNoHalt("Query failed: " .. err .. ". Query:\n" ..  sql .. "\n")
			end
		end
		
		q:start()
	end
end

function ZCore.MySQL.escapeStr(str)
	return database:escape(tostring(str))
end