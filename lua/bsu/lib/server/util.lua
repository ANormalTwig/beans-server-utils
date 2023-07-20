-- lib/server/util.lua

function BSU.LoadModules(dir)
	dir = dir or BSU.DIR_MODULES

	local svDir = dir .. "server/"
	local clDir = dir .. "client/"

	local shFiles, folders = file.Find(dir .. "*", "LUA")
	local svFiles = file.Find(svDir .. "*", "LUA")
	local clFiles = file.Find(clDir .. "*", "LUA")

	-- run server-side modules
	for _, v in ipairs(svFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(svDir .. v)
	end

	-- run/include shared modules
	for _, v in ipairs(shFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(dir .. v)
		AddCSLuaFile(dir .. v)
	end

	-- include client-side modules
	for _, v in ipairs(clFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		AddCSLuaFile(clDir .. v)
	end

	for _, v in ipairs(folders) do
		v = string.lower(v)
		if v == "server" or v == "client" then continue end
		BSU.LoadModules(dir .. v .. "/")
	end
end

local function sendSvConMsg(...)
	local vars = {}
	for _, v in ipairs({...}) do -- convert player entities to color tbl and name str so it looks correct in the server console
		if isentity(v) and v:IsPlayer() then
			table.Add(vars, { team.GetColor(v:Team()), v:Nick() })
		else
			table.insert(vars, v)
		end
	end
	MsgC(unpack(vars))
	MsgN()
end

-- send a console message to a player or list of players
-- or set target to NULL to send in the server console
function BSU.SendConMsg(plys, ...)
	if plys == NULL then
		sendSvConMsg(...)
		return
	end
	BSU.ClientRPC(plys, "BSU.SendConMsg", ...)
end

-- send a chat message to a player or list of players
-- or set target to NULL to send in the server console
function BSU.SendChatMsg(plys, ...)
	if plys == NULL then
		sendSvConMsg(...)
		return
	end
	BSU.ClientRPC(plys, "chat.AddText", ...)
end