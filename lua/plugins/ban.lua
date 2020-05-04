class "Ban" extends "Plugin" {
	public {
		__construct = function(self, strName, iType)
			self.Plugin(strName, iType)
		end;

		canPlayerUse = function(self, objPl)
			return objPl:isMod()
		end;

		canTarget = function(self, objPl, objTarget)
			if(objPl == objTarget or (not IsValid(objPl) and IsValid(objTarget))) then
				return true
			end

			return objPl:isMod()
		end;

		-- server

		onServerLoad = function(self)
			kontrol.log.add("KickBan")

			kontrol.commands.add("ban", function(objPl, strCmd, tblArgs)
				if(not self:canRunCommand(objPl, strCmd, tblArgs)) then return end

				local objTarget = player.GetByUniqueID(tblArgs[1])

				if(not objTarget or not IsValid(objTarget)) then
					objPl:sendMessage(true, colorx.red, "Player not found")
					return false
				end

				if(not self:canTarget(objPl, objTarget)) then
					objPl:sendMessage(true, colorx.red, "You aren't permitted to do that to ", kontrol.getNick(objTarget, {["colors"] = true}))
					return false
				end

				local iTime = tonumber(tblArgs[2] or 5)
				table.remove(tblArgs, 1)
				table.remove(tblArgs, 1)

				local strReason = "No reason specified"

				if(tblArgs and #tblArgs > 0) then
					strReason = table.concat(tblArgs, " ")
				end

				kontrol.log.add(kontrol.log.get("KickBan"), {
					["message"] = {
						{["log"] = kontrol.getNick(objPl), ["chat"] = kontrol.getNick(objPl, {["colors"] = true, ["simple"] = true})},
						{["log"] = " banned "},
						{["log"] = kontrol.getNick(objTarget), ["chat"] = kontrol.getNick(objTarget, {["colors"] = true})},
						{["log"] = " for "},
						{["log"] = time.simple(iTime * 60), ["chat"] = {colorx.pink, time.simple(iTime * 60)}},
						{["log"] = " ("..strReason..")", ["chat"] = {" (", colorx.lime, strReason, color_white, ")"}},
					}
				})

				frank.bans.add(objTarget:SteamID(), iTime, strReason, objPl:SteamID())
			end)

			kontrol.commands.add("banid", function(objPl, strCmd, tblArgs)
				if(not self:canRunCommand(objPl, strCmd, tblArgs)) then return false end

				local strSteamID = string.upper(tblArgs[1])

				if(not string.isSteamID(strSteamID)) then
					objPl:sendMessage(true, colorx.red, "Invalid SteamID!")
					return false
				end

				local iTime = tonumber(tblArgs[2] or 5)
				table.remove(tblArgs, 1)
				table.remove(tblArgs, 1)

				local strReason = "No reason specified"

				if(tblArgs and #tblArgs > 0) then
					strReason = table.concat(tblArgs, " ")
				end

				kontrol.log.add(kontrol.log.get("KickBan"), {
					["message"] = {
						{["log"] = kontrol.getNick(objPl), ["chat"] = kontrol.getNick(objPl, false, true, true)},
						{["log"] = " banned "},
						{["log"] = strSteamID, ["chat"] = {colorx.pink, strSteamID}},
						{["log"] = " for "},
						{["log"] = time.simple(iTime * 60), ["chat"] = {colorx.coolblue, time.simple(iTime * 60)}},
						{["log"] = " ("..strReason..")", ["chat"] = {" (", colorx.lime, strReason, color_white, ")"}},
					}
				})

				frank.bans.add(strSteamID, iTime, strReason, objPl:SteamID())
			end)

			kontrol.commands.add("unban", function(objPl, strCmd, tblArgs)
				if(not self:canRunCommand(objPl, strCmd, tblArgs)) then return false end

				local strSteamID = string.upper(tblArgs[1])

				if(not string.isSteamID(strSteamID)) then
					objPl:sendMessage(true, colorx.red, "Invalid SteamID!")
					return false
				end

				kontrol.log.add(kontrol.log.get("KickBan"), {
					["message"] = {
						{["log"] = kontrol.getNick(objPl), ["chat"] = kontrol.getNick(objPl, false, true, true)},
						{["log"] = " un-banned "},
						{["log"] = strSteamID, ["chat"] = {colorx.pink, strSteamID}},
					}
				})

				frank.bans.remove(strSteamID)
			end)
		end;

		-- client

		onClientLoad = function(self)
			self:setIcon("exclamation")
		end;

		onMenuClick = function(self, objPl)
			local iUniqueID = objPl:UniqueID()

			local objFrame = vgui.Create("KFrame2")
			objFrame:SetSize(300, 112)
			objFrame:SetPos(ScrW() / 2 - 150, ScrH() / 2 - 56)
			objFrame:SetTitle("Ban "..objPl:Nick())
			objFrame:SetDraggable(true)
			objFrame:ShowCloseButton(true)
			objFrame:SetSizable(false)
			objFrame:SetScreenLock(true)
			objFrame:MakePopup()

			local objReason = vgui.Create("DTextEntry", objFrame)
			objReason:SetSize(250, 20)
			objReason:SetPos(10, 32)
			objReason:SetValue("Consider this a warning...")

			local objReasonSelect = vgui.Create("KButton", objFrame)
			objReasonSelect:SetSize(25, 20)
			objReasonSelect:SetPos(15 + objReason:GetWide(), 32.5)
			objReasonSelect:SetText(">")
			function objReasonSelect:DoClick()
				local objReasonDropdown = DermaMenu()
				for k,v in pairs(kontrol.banReasons) do
					objReasonDropdown:AddOption(v, function()
						objReason:SetValue(v)
					end)
				end
				objReasonDropdown:Open()
			end

			local strChoice = time.simple(5 * 60)
			local objLength = vgui.Create("DComboBox", objFrame)
			objLength:SetPos(10, 57)
			objLength:SetSize(280, 20)
			objLength:SetText(strChoice)
			function objLength:OnSelect(objPanel, strValue)
				strChoice = strValue
			end

			for k,v in pairs(kontrol.banTimes) do
				objLength:AddChoice(v.Word)
			end
			objLength:AddChoice("Permanent")

			local objAccept = vgui.Create("KButton", objFrame)
			objAccept:SetSize(objFrame:GetWide() - 20, 20)
			objAccept:SetPos(10, objFrame:GetTall() - objAccept:GetTall() - 10)
			objAccept:SetText("Ban "..objPl:Nick())
			function objAccept:DoClick()
				local strReason = objReason:GetValue()
				kontrol:AddBanReason(strReason)
				RunConsoleCommand("kontrol_ban", iUniqueID, kontrol.banTimesConvert[strChoice] or "5", strReason)

				objFrame:Close()
			end
		end;
	};
}

kontrol.plugins.add(Ban.new("Ban", kontrol.PLUGIN_PUNISH))