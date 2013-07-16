function gadget:GetInfo()
	return {
		name = "Take Manager",
		desc = "Handles players AFK and drops",
		author = "BD",
		date = "2012",
		license = "WTFPL",
		layer = 1,
		enabled = true
	}
end

local maxIdleTreshold = 10 --in seconds
local maxPing = 30 -- in seconds
local finishedResumingPing = 2 --in seconds
local takeCommand = "take2"

local AFKMessage = 'idleplayers '
local AFKMessageSize = #AFKMessage
if ( not gadgetHandler:IsSyncedCode()) then
-- UNSYNCED code

	local GetLastUpdateSeconds = Spring.GetLastUpdateSeconds
	local SendLuaRulesMsg = Spring.SendLuaRulesMsg
	local GetMouseState = Spring.GetMouseState
	
	local nameEnclosingPatterns = {{""," added point"},{"<","> "},{"> <","> "},{"[","] "}}
	local myPlayerName = Spring.GetPlayerInfo(Spring.GetMyPlayerID())
	local lastActionTime = 0
	local timer = 0 
	local updateTimer = 0
	local isIdle = false
	local updateRefreshTime = 1 --in seconds 

	local mx,my = GetMouseState()

	function WentIdle()
		if not isIdle then
			SendLuaRulesMsg(AFKMessage .. "1")
			isIdle = true
		end
	end

	function NotIdle()
		lastActionTime = timer
		if isIdle then
			SendLuaRulesMsg(AFKMessage .. "0")
			isIdle = false
		end
	end

	function gadget:Update()
		local dt = GetLastUpdateSeconds()
		timer = timer+dt
		updateTimer = updateTimer + dt
		if updateTimer < updateRefreshTime then
			return
		end
		updateTimer = 0
		-- ugly code to check if the mouse moved since the call-in doesn't work
		local x,y = GetMouseState()
		if mx ~= x or my ~= y then
			NotIdle()
		end
		my = y
		mx = x

		if timer-lastActionTime > maxIdleTreshold then
			WentIdle()
		end
	end

	-- MouseMove isn't called either??!
	function gadget:MouseMove()
		NotIdle()
	end

	function gadget:MousePress()
		NotIdle()
	end

	function gadget:MouseWheel()
		NotIdle()
	end

	function gadget:KeyPress()
		NotIdle()
	end
	
	-- extract a player name from a text message
	function getPlayerName(playerMessage)
		local pos
		local retVal = ""
		for index,pattern in pairs(nameEnclosingPatterns) do
			local prefix = pattern[1]
			local suffix = pattern[2]
			local prefixstart,prefixend
			local suffixstart,suffixend
			if prefix ~= "" then
				prefixstart,prefixend = playerMessage:find(prefix,1,true) 
			end
			prefixend = (prefixend or 0 ) + 1
			if suffix ~= "" then
				suffixstart,suffixend = playerMessage:find(suffix,prefixend,true)
			end
			if suffixstart then
				suffixstart = suffixstart - 1
				return playerMessage:sub(prefixend,suffixstart)
			end
		end
		return ""
	end
	
	function gadget:AddConsoleLine(line)
		if line:len() == 0 then
			return
		end
		if getPlayerName(line) == myPlayerName then
			NotIdle()
		end
	end

else

-- SYNCED code
	local playerInfoTable = {}
	local TeamToRemainingPlayers = {}

	local TransferUnit = Spring.TransferUnit
	local GetPlayerList = Spring.GetPlayerList
	local ShareTeamResource = Spring.ShareTeamResource
	local GetTeamResources = Spring.GetTeamResources
	local GetPlayerInfo = Spring.GetPlayerInfo
	local GetTeamList = Spring.GetTeamList
	local GetTeamLuaAI = Spring.GetTeamLuaAI
	local GetAIInfo = Spring.GetAIInfo
	local SetTeamRulesParam = Spring.SetTeamRulesParam
	local GetTeamRulesParam = Spring.GetTeamRulesParam
	local GetTeamUnits = Spring.GetTeamUnits
	local SetTeamShareLevel = Spring.SetTeamShareLevel
	local GetTeamInfo = Spring.GetTeamInfo
	local GetTeamList = Spring.GetTeamList
	local Echo = Spring.Echo
	
	local resourceList = {"metal","energy"}
	local gaiaTeamID = Spring.GetGaiaTeamID()
	
	local min = math.min

	local function CheckPlayerState(playerID)
		local newval = playerInfoTable[playerID]
		if not newval then
			return false
		end
		local ok = true
		ok = ok and newval.connected
		ok = ok and newval.player
		ok = ok and newval.pingOK
		ok = ok and newval.present
		return ok
	end

	function gadget:PlayerChanged()
		UpdatePlayerInfos()
	end

	local function UpdatePlayerInfos()
		TeamToRemainingPlayers = {} -- reset active teams table
		local aiOwners = {}
		for _,teamID in ipairs(GetTeamList()) do -- sum all AI first
			local _, _, _, isAI = GetTeamInfo(teamID)
			if isAI then
				--store who hosts that engine ai, team will be controlled if player is present
				local aiHost = select(3,GetAIInfo(teamID))
				local hostedAis = aiOwners[aiHost] or {}
				hostedAis[#hostedAis+1] = teamID
				aiOwners[aiHost] = hostedAis
			end
			--is luaai or is gaia
			if GetTeamLuaAI(teamID) ~= "" or teamID == gaiaTeamID then
				TeamToRemainingPlayers[teamID] = 1
			else
				TeamToRemainingPlayers[teamID] = 0
			end
		end
		for _,playerID in ipairs(GetPlayerList()) do -- update player infos
			local _,active,spectator,teamID,allyTeamID,ping = GetPlayerInfo(playerID)
			local playerInfoTableEntry = playerInfoTable[playerID] or {}
			playerInfoTableEntry.connected = active
			playerInfoTableEntry.player = not spectator
			local pingTreshold = maxPing
			local oldPingOk = playerInfoTableEntry.pingOK
			if oldPingOk == false then
				pingTreshold = finishedResumingPing --use smaller treshold to determine finished resuming
			end 
			playerInfoTableEntry.pingOK = ping < pingTreshold
			if oldPingOk and not playerInfoTableEntry.pingOK then
				Echo("Player " .. GetPlayerInfo(playerID) .. " is lagging behind")
			elseif oldPingOk == false and playerInfoTableEntry.pingOK then
				Echo("Player " .. GetPlayerInfo(playerID) .. " has finished resuming")
			end
			if playerInfoTableEntry.present == nil then
				playerInfoTableEntry.present = true -- initialize to not afk
			end
			playerInfoTable[playerID] = playerInfoTableEntry
			
			--mark hosted ais as controlled
			local hostedAis = aiOwners[aiHost]
			if hostedAis then
				local hostingOk = playerInfoTableEntry.connected  and playerInfoTableEntry.pingOK
				if hostingOk then
					for _,aiTeamID in ipairs(hostedAis) do
						TeamToRemainingPlayers[teamID] = TeamToRemainingPlayers[teamID] +1
					end
				end
			end
			
			if CheckPlayerState(playerID) then -- bump amount of active players in a team
				TeamToRemainingPlayers[teamID] = TeamToRemainingPlayers[teamID] + 1
			end
		end

		for teamID,teamCount in ipairs(TeamToRemainingPlayers) do
			-- set to a public readble value that there's nobody controlling the team
			SetTeamRulesParam(teamID, "numActivePlayers", teamCount )
		end
	end

	function gadget:Initialize()
  		gadgetHandler:AddChatAction(takeCommand, TakeTeam, "Take control of units and resouces from inactive players")
  		UpdatePlayerInfos()
	end

	function gadget:Shutdown()
		gadgetHandler:RemoveChatAction(takeCommand)
	end

	function gadget:GameStart()
		UpdatePlayerInfos()
	end

	function gadget:GameFrame(currentFrame)
		if currentFrame%16 ~= 0 then
			return
		end
		UpdatePlayerInfos()
	end

	function gadget:RecvLuaMsg(msg, playerID)
		if msg:sub(1,AFKMessageSize) ~= AFKMessage then --invalid message
			return
		end
		local afk = tonumber(msg:sub(AFKMessageSize+1))
		local playerInfoTableEntry = playerInfoTable[playerID] or {}
		playerInfoTableEntry.present = afk == 0
		playerInfoTable[playerID] = playerInfoTableEntry
		if not playerInfoTableEntry.present then
			Echo("Player " .. GetPlayerInfo(playerID) .. " went AFK")
		else
			Echo("Player " .. GetPlayerInfo(playerID) .. " came back")
		end
	end

	function gadget:AllowResourceTransfer(teamID, restype, level)
		-- prevent resources to leak to uncontrolled teams
		return GetTeamRulesParam(teamID,"numActivePlayers") ~= 0
	end


	function TakeTeam(cmd, line, words, playerID)
		if not CheckPlayerState(playerID) then
			return -- exclude taking rights from lagged players, etc
		end
		local _,_,_,takerID,allyTeamID = GetPlayerInfo(playerID)
		local teamList = GetTeamList(allyTeamID)
		for teamID in ipairs(teamList) do
			if GetTeamRulesParam(teamID,"numActivePlayers") == 0 then
				-- transfer all units
				local unitList = GetTeamUnits(teamID)
				for _,unitID in ipairs(unitList) do
					TransferUnit(unitID,takerID)
				end
				--send all resources en-block to the taker
				for _,resourceName in ipairs(resourceList) do
					local shareAmount = GetTeamResources( teamID, resourceName)
					local current,storage = GetTeamResources(takerID,resourceName)
					shareAmount = min(shareAmount,current-storage)
					ShareTeamResource( teamID, takerID, resourceName, shareAmount )
				end
			end
		end
	end
end
