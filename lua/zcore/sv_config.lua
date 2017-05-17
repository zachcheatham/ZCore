ZCore.Config = {}

-- DON'T FILL THESE OUT!
-- EDIT garrysmod/data/zcore/config_mysql.txt!
ZCore.Config.SQL = {
    hostname = "",
    username = "",
    password = "",
    database = "",
}
if not ULib.fileExists("data/zcore/config_mysql.txt") then
    ULib.fileCreateDir("data/zcore")
    ULib.fileWrite("data/zcore/config_mysql.txt", ULib.makeKeyValues(ZCore.Config.SQL))
else
    ZCore.Config.SQL = ULib.parseKeyValues(ULib.fileRead("data/zcore/config_mysql.txt"))
end
