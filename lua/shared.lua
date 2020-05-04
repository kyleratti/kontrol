AddCSLuaFile("plugin.lua")
include("plugin.lua")

local meta = FindMetaTable("Player")

kontrol = kontrol or {}

kontrol["PLUGIN_PUNISH"] = 1
kontrol["PLUGIN_TOOL"] = 2

kontrol.plugins = {
	[kontrol.PLUGIN_PUNISH] = {},
	[kontrol.PLUGIN_TOOL] = {},
}
kontrol.ranks = {}
kontrol.hooks = {}
kontrol.log = {}
kontrol.commands = {}
kontrol.banTimes = {}

for k,v in pairs({5, 15, 30, 60, 120, 360, 720, 1440, 1440 * 2, 1440 * 5, 1440 * 7, 1440 * 14, 1440 * 30}) do
	table.insert(kontrol.banTimes, {["Word"] = time.simple(v * 60), ["Time"] = v})
end
table.SortByMember(kontrol.banTimes, "Time", true)
kontrol.banTimesConvert = {}
kontrol.banTimesConvert["Permanent"] = 0
for k,v in pairs(kontrol.banTimes) do
	kontrol.banTimesConvert[v.Word] = v.Time
end

function kontrol.log.add(strName)
	kontrol["LOG_"..string.upper(strName)] = strName
end

function kontrol.log.get(strName)
	return strName
end

function kontrol.hooks.add(strHook, strInfo, objCallback)
	hook.Add(strHook, "kontrol."..strInfo, objCallback)

	kontrol.hooks[strHook] = kontrol.hooks[strHook] or {}
	kontrol.hooks[strHook][strHook] = objCallback
end

function kontrol.commands.add(strCmd, objCallback)
	concommand.Add("kontrol_"..strCmd, objCallback)

	kontrol.commands[strCmd] = objCallback
end

function kontrol.getNick(objPl, tblOptions)
	if(not IsValid(objPl)) then
		debug.getinfo(1)
		error("Invalid player passed to kontrol.getNick")
	end

	tblOptions = tblOptions or {}

	if(tblOptions.colors) then
		if(tblOptions.simple) then
			local tblData = {
				team.GetColor(objPl:Team()),
				objPl:Nick(),
			}

			return tblData
		end

		local tblData = {
			team.GetColor(objPl:Team()),
			objPl:Nick().." ",
			color_white,
			"(",
			colorx.gold,
			objPl:SteamID(),
			color_white,
			" | ",
		}

		if(tblOptions.team) then
			table.insert(tblData, colorx.red)
			table.insert(tblData, team.GetName(objPl:Team()))
		else
			table.insert(tblData, colorx[objPl:getRank().ID])
			table.insert(tblData, objPl:getRank().Name)
		end

		table.insert(tblData, color_white)
		table.insert(tblData, ")")

		return tblData
	end

	return '"'..objPl:Nick().."\" ("..objPl:SteamID().." | "..(tblOptions.team and team.GetName(objPl:Team()) or objPl:getRank().Name)..")"
end

local iNum = 1
function kontrol.ranks.add(tblName, objColor)
	local iTmp = iNum
	for k,v in pairs(tblName) do
		local strStripped = string.Replace(v, " ", "")

		kontrol["RANK_"..string.upper(strStripped)] = iNum
		kontrol.ranks[iNum] = {["ID"] = iNum, ["Name"] = v}

		meta["is"..strStripped] = function(self)
			return self:getNWVar("Rank", kontrol.ranks[1].ID) >= iTmp
		end
	end
	colorx[iNum] = objColor

	iNum = iNum + 1
end

kontrol.ranks.add({"Guest"}, Color(0, 189, 0, 255))
kontrol.ranks.add({"Mod", "Moderator"}, Color(250, 120, 0, 255))
kontrol.ranks.add({"Admin"}, Color(221, 13, 166, 255))
kontrol.ranks.add({"Super Admin", "Lead Admin"}, Color(255, 0, 0, 255))
kontrol.ranks.add({"Manager", "Owner"}, Color(0, 153, 255, 255))

kontrol.log.add("Admin")

kontrol.plugins.current = nil

function kontrol.plugins.add(objPlugin)
	kontrol.plugins[objPlugin:getType()][objPlugin:getName()] = objPlugin

	table.SortByKey(kontrol.plugins[objPlugin:getType()])

	if(CLIENT) then
		objPlugin:onClientLoad()
	else
		objPlugin:onServerLoad()
	end
end

function kontrol.plugins.get(strName, iType)
	if(kontrol.plugins[iType]) then
		return kontrol.plugins[iType][strName]
	end

	error("Unknown plugin type "..iType)
end

do -- start loading plugins
	local tblFiles, _ = file.Find("plugins/*.lua", "LUA")
	for k,v in pairs(tblFiles) do
		if(string.sub(v, 1, 2) ~= "__") then
			if(SERVER) then
				AddCSLuaFile("plugins/"..v)
			end

			include("plugins/"..v)
		end
	end
end -- end loading plugins

--[[local function LoadFiles(strFolder)
	for k,v in SortedPairs(file.Find("kontrol/plugins/"..strFolder.."/*.lua", "LUA")) do
		if(SERVER) then
			AddCSLuaFile("kontrol/plugins/"..strFolder.."/"..v)
		else
			include("kontrol/plugins/"..strFolder.."/"..v)
		end
	end

	for k,v in SortedPairs(file.Find("kontrol/plugins/"..strFolder.."/*.lua", "LUA")) do
		if(SERVER) then
			AddCSLuaFile("kontrol/plugins/"..strFolder.."/"..v)
		end

		include("kontrol/plugins/"..strFolder.."/"..v)
	end

	for k,v in SortedPairs(file.Find("kontrol/plugins/"..strFolder.."/*.lua", "LUA")) do
		if(SERVER) then
			include("kontrol/plugins/"..strFolder.."/"..v)
		end
	end
end

function kontrol.LoadFolder(strFolder)
	LoadFiles(strFolder)
end

hook.Add("Initialize", "load_plugins_gm", function()
	--print("\n< kontrol gamemode plugins loading >\n")
	local strFolder = ""
	if(GAMEMODE:IsDarkRP()) then
		strFolder = "darkrp"
	elseif(GAMEMODE:IsPERP()) then
		strFolder = "perp"
	end
	if(strFolder and strFolder ~= "") then
		for k,v in pairs(file.Find("plugins/"..strFolder.."/*.lua", "LUA")) do
			if(SERVER) then
				include("plugins/"..strFolder.."/"..v)
				AddCSLuaFile("plugins/"..strFolder.."/"..v)
			else
				include("plugins/"..strFolder.."/"..v)
			end
		end
	end
end)]]--

function meta:getRank()
	return !self:isMod() and self:isVIP() and "VIP" or kontrol.ranks[self:getNWVar("Rank", kontrol.RANK_GUEST)]
end

function meta:getLevel()
	return self:getNWVar("Rank", kontrol.RANK_GUEST)
end

meta.GetAdminLevel = meta.GetLevel -- PERP's GetLevel is for skills :(

function meta:CanAffect(objPl)
	if(not IsValid(objPl)) then return false end -- seems to be called without a valid player in this arg? :(

	return self == objPl or self:getNWVar("Rank", kontrol.RANK_GUEST) >= objPl:getNWVar("Rank", kontrol.RANK_GUEST)
end