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
				ZCore.Util.sendZachAnError("Connection to MySQL has been lost.")
				hook.Call("ZCore_MySQL_Disconnected")
				connect()
			end
		end)

		hook.Call("ZCore_MySQL_Connected", _, not previouslyConnected)
		previouslyConnected = true
	end

	database:connect()
end
if string.len(ZCore.Config.SQL.hostname) > 0 then
    connect()
else
    ServerLog("[ZCore] In order to use MySQL, please set the configuration in data/zcore/config_mysql.txt\n")
end

function ZCore.MySQL.query(sql, callback)
	if not connected then
		ServerLog("[ZCore] Caching query while MySQL is down...\n")
		table.insert(queryCache, {sql, callback})
	else
		local q = database:query(sql)
		function q:onSuccess(data)
			if callback then
				callback(ZCore.MySQL.cleanSQLArray(data), q:lastInsert())
			end
		end

		function q:onError(err)
			if err == "MySQL server has gone away" then
				ServerLog("[ZCore] Caching query while MySQL is down...\n")
				table.insert(queryCache, {sql, callback})
			else
				local errStr = "Query failed: " .. err .. ". Query:\n" ..  sql
				ZCore.Util.sendZachAnError(errStr)
				ErrorNoHalt(errStr .. "\n")
			end
		end

		q:start()
	end
end

function ZCore.MySQL.queryRow(sql, callback)
	ZCore.MySQL.query(sql, function(data)
		if table.Count(data) > 0 then
			callback(ZCore.MySQL.cleanSQLRow(data[1]))
		else
			callback(false)
		end
	end)
end

function ZCore.MySQL.escapeStr(str)
	return database:escape(tostring(str))
end

function ZCore.MySQL.cleanSQLArray(data)
	if not type(data) == "table" then return data end

	local newData = {}

	for k, v in pairs(data) do
		newData[k] = ZCore.MySQL.cleanSQLRow(v)
	end

	return newData
end

function ZCore.MySQL.cleanSQLRow(data)
	if not data then return data end

	local newData = table.Copy(data)

	-- REMOVE NULLS
	local toRemove = {}
	for k,v in pairs(newData) do
		if v == "NULL" then
			table.insert(toRemove, k)
		end
	end

	for _,k in ipairs(toRemove) do
		newData[k] = nil
	end

	-- TURN NUMBERS INTO NUMBERS!
	for k,v in pairs(newData) do
		if tonumber(v) ~= nil then
			newData[k] = tonumber(v)
		end
	end

	return newData
end
