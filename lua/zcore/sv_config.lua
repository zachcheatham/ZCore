ZCore.Config = {}

-- MySQL Settings --
ZCore.Config.SQL = {}
ZCore.Config.SQL.hostname 	= ""
ZCore.Config.SQL.username	= ""
ZCore.Config.SQL.password	= ""
ZCore.Config.SQL.database	= ""

if not ULib.fileExists("data/zcore/config_mysql.txt") then
    ULib.fileCreateDir("data/zcore")
    ULib.fileWrite("data/zcore/config_mysql.txt", ULib.makeKeyValues(ZCore.Config.SQL))
else
    ZCore.Config.SQL = ULib.parseKeyValues(ULib.fileRead("data/zcore/config_mysql.txt"))
end
