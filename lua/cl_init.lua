include("shared.lua")
include("derma.lua")

kontrol.banReasons = {}

local tblDefaultReasons = {
	"Consider this a warning...",
	"Random Death Match (RDM)",
	"Mass Random Death Match (RDM)",
	"New Life Rule (NLR)",
	"General Troll/Doesn't want to be here",
}

function kontrol.ReloadBanReasons(bMessage)
	kontrol.banReasons = {}
	for k,v in pairs(tblDefaultReasons) do
		table.insert(kontrol.banReasons, v)
	end

	if(not file.Exists("kontrol/", "DATA")) then
		file.CreateDir("kontrol/")
	end

	if(file.Exists("kontrol/banReasons.txt", "DATA")) then
		local sTmp = file.Read("kontrol/banReasons.txt", "DATA")
		for k,v in pairs(string.Explode("\n", sTmp)) do
			v = string.Trim(v)
			if(not table.HasValue(kontrol.banReasons, v) and #v > 1) then
				table.insert(kontrol.banReasons, v)
			end
		end
	else
		file.Write("kontrol/banReasons.txt", "")
		kontrol.ReloadBanReasons(false)
	end
	if(bMessage) then
		Msg("< kontrol > Registered saved ban reasons: ")
		print(table.Count(kontrol.banReasons))
	end
end
kontrol.ReloadBanReasons() -- annoying when true

local tIcons = {}

local function FindIcon(sIco)
	if(not tIcons[sIco]) then
		tIcons[sIco] = Material(sIco)
	end
	return tIcons[sIco]
end

local function ModdedMenu(MENU) -- I stole this from ASSMod :(
	function DMenuOption_OnCursorEntered(self) 
 	
 		local m = self.SubMenu
 		if (self.BuildFunction) then
 	 		m = DermaMenu(self) 
	 		ASS_FixMenu(m)
 			m:SetVisible(false) 
 			m:SetParent(self:GetParent()) 
 			PCallError(self.BuildFunction, m)
		end
		
		self.ParentMenu:OpenSubMenu(self, m)
 	 
	end 	
	
	-- Menu item images!
	function DMenuOption_SetImage(self, img)
	
		self.Image = FindIcon(img)
	
	end
	
	-- Change the released hook so that if the click function
	-- returns a non-nil or non-false value then the menus
	-- get closed (this way menus can stay opened and be clicked
	-- several time).
	function DMenuOption_OnMouseReleased(self, mousecode) 

		DButton.OnMouseReleased(self, mousecode) 

		if (self.m_MenuClicking) then 

			self.m_MenuClicking = false 
			
			if (!self.ClickReturn) then
				CloseDermaMenus() 
			end

		end 

	end 
	
	-- Make sure we draw the image, should be done in the skin
	-- but this is a total hack, so meh.
	function DMenuOption_Paint(self, w, h)
	
		derma.SkinHook("Paint", "MenuOption", self, w, h)
		
		if (self.Image) then
	 		surface.SetMaterial(self.Image) 
 			surface.SetDrawColor(255, 255, 255, 255) 
 			surface.DrawTexturedRect(2, (self:GetTall() - 16) * 0.5, 16, 16)
 		end
		
		return false
	
	end

 	-- Make DMenuOptions implement our new functions above.
	-- Returns the new DMenuOption created.
	local function DMenu_AddOption(self, strText, funcFunction)

 		local pnl = vgui.Create("DMenuOption", self) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
 		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
  		pnl:SetText(strText) 
 		if (funcFunction) then 
 			pnl.DoClick = function(self) 
 					self.ClickReturn = funcFunction(pnl) 
 				end
 		end
 	 
 		self:AddPanel(pnl) 
 	 
 		return pnl 
 
 	end	

	-- Make DMenuOptions implement our new functions above.
	-- If we're creating the menu now, also register our
	-- hacked functions with it, so this hack propagates
	-- virus like among any DMenus spawned from this 
	-- parent DMenu.. muhaha
	-- Returns the new DMenu (if it exists), and the DMenuOption
	-- created.
	local function DMenu_AddSubMenu(self, strText, funcFunction, openFunction) 

	 	local SubMenu = nil
	 	if (!openFunction) then
	 		SubMenu = DermaMenu(self) 
	 		ASS_FixMenu(SubMenu)
 			SubMenu:SetVisible(false) 
 			SubMenu:SetParent(self) 
 		end
 	
 		local pnl = vgui.Create("DMenuOption", self) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
  		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
		pnl.BuildFunction = openFunction
		pnl:SetSubMenu(SubMenu) 
		pnl:SetText(strText) 
		if (funcFunction) then 
			pnl.DoClick = function() pnl.ClickReturn = funcFunction(pnl) end
		else 
			pnl.DoClick = function() pnl.ClickReturn = true end
		end

		self:AddPanel(pnl) 

		if (SubMenu) then
			return SubMenu, pnl
		else
			return pnl
		end

	end 
	
	-- Register our new hacked function. muhahah
	MENU.AddOption = DMenu_AddOption
	MENU.AddSubMenu = DMenu_AddSubMenu
end

local pList = nil

local function UpdateList()
	if(pList) then
		pList:InvalidateLayout()
		pList:Clear()
		local tPlayers = player.GetAll()
		table.sort(tPlayers, function(a, b)
			return string.lower(a:Nick()) < string.lower(b:Nick())
		end)
		table.remove(tPlayers, table.KeyFromValue(tPlayers, LocalPlayer()))
		table.insert(tPlayers, 1, LocalPlayer())
		local iNum = 1
		for k,v in pairs(tPlayers) do
			local iTmp = iNum
			local pTmp = vgui.Create("DPanel")
			pTmp:SetSize(0, 42.5)
			function pTmp:Paint(w, h)
				if(not IsValid(v)) then
					UpdateList()
					return
				end

				local tCol = team.GetColor(v:Team())
				local strInfoText = "HELP ME"

				--[[if(GAMEMODE:IsDarkRP()) then
					strInfoText = v.DarkRPVars and v.DarkRPVars.job or "Citizen"
				elseif(GAMEMODE:IsPERP()) then
					strInfoText = team.GetName(v:Team())
				else]]--
				if(TEAM_TERROR) then
					if(not v:Alive()) then
						strInfoText = "Dead"
						tCol = Color(205, 45, 45, 255)
					elseif(v:Team() == TEAM_SPECTATOR) then
						strInfoText = "Spectating"
						tCol = Color(134, 134, 134, 255)
					else
						strInfoText = "Alive"
						tCol = team.GetColor(v:Team())
					end
				else
					strInfoText = team.GetName(v:Team())
				end

				tCol.a = 155

				--draw.RoundedBox(4, 0, 0, pTmp:GetWide() - 4, pTmp:GetTall(), tCol)
				surface.SetDrawColor(tCol.r, tCol.g, tCol.b, 165)
				surface.DrawRect(1, 1, pTmp:GetWide() - 4, pTmp:GetTall() - 2)

				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawOutlinedRect(0, 0, pTmp:GetWide() - 2, pTmp:GetTall())

				draw.SimpleTextOutlined(strInfoText, "Trebuchet18", self:GetWide() - 8, self:GetTall() - 20.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, color_black)

				return true
			end

			if(not IsValid(v)) then
				--table.remove(tPlayers, table.KeyFromValue(v))
				UpdateList()
				return
			end

			local pAvatar = vgui.Create("AvatarImage", pTmp)
			pAvatar:SetSize(32, 32)
			pAvatar:SetPos(5, 5)
			pAvatar:SetPlayer(v)

			local pName = vgui.Create("DLabel", pTmp)
			pName:SetPos(42, 2.5)
			pName:SetTextColor(color_white)
			pName:SetFont("Trebuchet18")
			pName:SetText(v:Nick())
			pName:SizeToContents()
			pName:SetExpensiveShadow(1, Color(0, 0, 0, 255))

			local pSteam = vgui.Create("KButton", pTmp)
			pSteam:SetPos(42, 20)
			pSteam:SetSize(150, 17.5)
			pSteam:SetText(v:SteamID())
			pSteam:SetTextColor(color_white)
			function pSteam:DoClick()
				local pMenu = DermaMenu()
				ModdedMenu(pMenu)
				local pCopySteamID = pMenu:AddOption("Copy SteamID", function()
					SetClipboardText(v:SteamID())
					surface.PlaySound("buttons/button16.wav")
				end)
				pCopySteamID:SetImage("icon16/computer_go.png")
				--pMenu:AddSpacer()
				local pCopyProfile = pMenu:AddOption("Copy Profile URL", function()
					SetClipboardText("http://steamcommunity.com/profiles/"..util.SteamID64(v:SteamID()))
					surface.PlaySound("buttons/button16.wav")
				end)
				pCopyProfile:SetImage("icon16/layout.png")
				pMenu:Open()
			end

			if(LocalPlayer():isMod()) then
				local pPunish = vgui.Create("KListButton", pTmp)
				pPunish:SetSize(90, 17.5)
				pPunish:SetPos(pSteam:GetPos() + 153.5, 20.5)
				pPunish:SetText("Punishment")
				pPunish:SetTextColor(color_white)
				function pPunish:DoClick()
					local pMenu = DermaMenu()
					ModdedMenu(pMenu)

					for _,p in pairs(kontrol.plugins[kontrol.PLUGIN_PUNISH]) do
						if(p:canPlayerUse(LocalPlayer()) and p:canTarget(LocalPlayer(), v)) then
							local pTmp = pMenu:AddOption(p:getName(), function()
								p:onMenuClick(v)
							end)

							if(p:getIcon() ~= "") then
								pTmp:SetImage("icon16/"..p:getIcon()..".png")
							end
						end
					end

					pMenu:Open()
				end
			end

			local pVIP = vgui.Create("KListButton", pTmp)
			pVIP:SetSize(60, 17.5)
			pVIP:SetPos(pSteam:GetPos() + 246.5, 20.5)
			pVIP:SetText("Tools")
			pVIP:SetTextColor(color_white)
			function pVIP:DoClick()
				local pMenu = DermaMenu()
				ModdedMenu(pMenu)
				for _,p in SortedPairs(kontrol.plugins[kontrol.PLUGIN_TOOL]) do
					if(p:CanUse(LocalPlayer()) and !p.ShouldShow or p:ShouldShow(v) == true) then
						local strName = p.GetName and p:GetName(v) or p.Name
						local pTmp = pMenu:AddOption(strName, function()
							p.Menu(v)
						end)
						if(p.Icon) then
							pTmp:SetImage("icon16/"..p.Icon..".png")
						end
					end
				end
				pMenu:Open()
			end

			pList:AddItem(pTmp)
			iNum = iNum + 1
		end
	end
end

local bOpen = false
local pFrame = nil

local function Menu()
	if(pFrame) then
		pFrame:Close()
		CloseDermaMenus()
		return
	end

	pFrame = vgui.Create("KFrame")
	pFrame:SetSize(500, 347.5)
	pFrame:Center()
	pFrame:SetTitle("kontrol: be - administration in moderation")
	pFrame:MakePopup()
	--gui.EnableScreenClicker(true)
	pFrame:SetKeyboardInputEnabled(false)
	pFrame:SetVisible(true)

	function pFrame:OnClose()
		gui.EnableScreenClicker(false)
		pList = nil
		if(pFrame) then
			pFrame = nil
		end
		bOpen = false
	end

	function pFrame:PaintOver(w, h)
		draw.SimpleTextOutlined("Players: ", "Trebuchet22", self:GetWide() - 22.5, self:GetTall() - 25, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, color_black)
		draw.SimpleTextOutlined(#player.GetAll(), "Trebuchet22", self:GetWide() - 5, self:GetTall() - 25, Color(48, 172, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, color_black)

		return true
	end

	pList = vgui.Create("DPanelList", pFrame)
	pList:SetPos(5, 32.5)
	pList:SetSize(pFrame:GetWide() - 10, pFrame:GetTall() - 60)
	pList:SetPadding(5)
	pList:SetSpacing(5)
	pList:EnableVerticalScrollbar(true)
	function pList:Paint()
		local iNum = pList:GetItems()
		local iOffset = 0
		if(#iNum > 6) then
			iOffset = 17.5
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, self:GetWide() - iOffset, self:GetTall())
	end

	if(LocalPlayer():isMod()) then
		local pUnban = vgui.Create("KButton", pFrame)
		pUnban:SetSize(100, 20)
		pUnban:SetPos(5, pFrame:GetTall() - 25)
		pUnban:SetText("Unban SteamID")
		pUnban:SetTextColor(color_white)
		function pUnban:DoClick()
			local pMenu = vgui.Create("KFrame")
			pMenu:SetSize(200, 112 / 1.3)
			pMenu:Center()
			pMenu:SetTitle("Unban SteamID")
			pMenu:SetDraggable(true)
			pMenu:ShowCloseButton(true)
			pMenu:SetSizable(false)
			pMenu:SetScreenLock(true)

			local objSteamIDInput = vgui.Create("DTextEntry", pMenu)
			objSteamIDInput:SetSize(pMenu:GetWide() - 20, 20)
			objSteamIDInput:SetPos(10, 32)
			objSteamIDInput:SetValue("")

			local pAccept = vgui.Create("KButton", pMenu)
			pAccept:SetSize(pMenu:GetWide() - 20, 20)
			pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
			pAccept:SetText("Unban SteamID")
			pAccept:SetDisabled(true)
			pAccept:SetTextColor(color_white)
			function pAccept:DoClick()
				if(not pAccept:GetDisabled()) then
					RunConsoleCommand("kontrol_unban", objSteamIDInput:GetValue())
					pMenu:Close()
				end
			end

			function objSteamIDInput:OnTextChanged()
				local txt = string.upper(objSteamIDInput:GetValue())

				if(string.isSteamID(txt)) then
					pAccept:SetDisabled(false)
					objSteamIDInput:SetTextColor(color_black)
				else
					pAccept:SetDisabled(true)
					objSteamIDInput:SetTextColor(colorx.red)
				end
			end

			function pMenu:Think()
				if(not self:HasFocus()) then
					self:RequestFocus()
					objSteamIDInput:RequestFocus()
				end
			end

			pMenu:MakePopup()
		end

		local pBan = vgui.Create("KButton", pFrame)
		pBan:SetSize(75, 20)
		pBan:SetPos(pUnban:GetWide() + 10, pFrame:GetTall() - 25)
		pBan:SetText("Ban SteamID")
		pBan:SetTextColor(color_white)
		function pBan:DoClick()
			local pMenu = vgui.Create("KFrame2")
			pMenu:SetSize(300, 137)
			pMenu:Center()
			pMenu:SetTitle("Ban SteamID")
			pMenu:SetDraggable(true)
			pMenu:ShowCloseButton(true)
			pMenu:SetSizable(false)
			pMenu:SetScreenLock(true)
			pMenu:MakePopup()

			local pID = vgui.Create("DTextEntry", pMenu)
			pID:SetSize(280, 20)
			pID:SetPos(10, 32)
			pID:SetValue("")

			local pReason = vgui.Create("DTextEntry", pMenu)
			pReason:SetSize(250, 20)
			pReason:SetPos(10, 57)
			pReason:SetValue("Consider this a warning...")

			local bReasons = vgui.Create("KButton", pMenu)
			bReasons:SetSize(25, 20)
			bReasons:SetPos(15 + pReason:GetWide(), 57.5)
			bReasons:SetText(">")
			bReasons:SetTextColor(color_white)
			function bReasons:DoClick()
				local pSR = DermaMenu()
				for k,v in pairs(kontrol.banReasons) do
					pSR:AddOption(v, function()
						pReason:SetValue(v)
					end)
				end
				pSR:Open()
			end

			local sChoice = time.simple(5 * 60)
			local pLength = vgui.Create("DComboBox", pMenu)
			pLength:SetPos(10, 82)
			pLength:SetSize(280, 20)
			pLength:SetText(sChoice)
			function pLength:OnSelect(pPanel, sValue)
				sChoice = sValue
			end

			for k,v in pairs(kontrol.banTimes) do
				pLength:AddChoice(v.Word)
			end

			pLength:AddChoice("Permanent")

			local pAccept = vgui.Create("KButton", pMenu)
			pAccept:SetSize(pMenu:GetWide() - 20, 20)
			pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
			pAccept:SetText("Ban")
			pAccept:SetDisabled(true)
			pAccept:SetTextColor(color_white)
			function pAccept:DoClick()
				if(not pAccept:GetDisabled()) then
					local sReason = pReason:GetValue()
					kontrol:AddBanReason(sReason)
					local sID = pID:GetValue()

					RunConsoleCommand("kontrol_banid", sID, kontrol.banTimesConvert[sChoice] or "5", sReason)
					pMenu:Close()
				end
			end

			function pID:OnTextChanged()
				local sTxt = string.upper(pID:GetValue())

				if(string.isSteamID(sTxt)) then
					pAccept:SetDisabled(false)
					pID:SetTextColor(color_black)
				else
					pAccept:SetDisabled(true)
					pID:SetTextColor(colorx.red)
				end
			end
		end

		--[[local pBulk = vgui.Create("KButton", pFrame)
		pBulk:SetSize(85, 20)
		pBulk:SetPos(pUnban:GetWide() + pBan:GetWide() + 15, pFrame:GetTall() - 25)
		pBulk:SetText("Mass Actions")
		pBulk:SetTextColor(color_white)
		function pBulk:DoClick()
			local pMenu = DermaMenu()
			ModdedMenu(pMenu)

			for k,v in pairs(kontrol.plugins[PLUGIN_TOOL]) do
				if(v:CanUse(LocalPlayer()) and v.Bulk) then
					local pTmp = pMenu:AddOption("Mass "..v.Name, function()
						for _,objPl in pairs(player.GetAll()) do
							v.Menu(objPl:UniqueID())
						end
					end)
					if(v.Icon) then
						pTmp:SetImage(v.Icon)
					end
				end
			end
			pMenu:Open()
		end]]--

		/*local pRefresh = vgui.Create("KButton", pFrame)
		pRefresh:SetSize(100, 20)
		pRefresh:SetPos(pBulk:GetWide() + pBan:GetWide() + pUnban:GetWide() + 20, pFrame:GetTall() - 25)
		pRefresh:SetText((tobool(LocalPlayer():GetPData("kontrol_autorefresh", false)) and "Auto-Refreshing..." or "Refresh"))
		pRefresh:SetTextColor(color_white)
		function pRefresh:DoClick()
			UpdateList()
		end

		function pRefresh:DoRightClick()
			local pAutoRefreshMenu = DermaMenu()
			local bEnabled = tobool(LocalPlayer():GetPData("kontrol_autorefresh", false))
			pAutoRefreshMenu:AddOption((bEnabled and "Disable" or "Enable").." Auto-Refresh", function()
				if(bEnabled) then
					self:SetText("Refresh")
				else
					self:SetText("Auto-Refreshing...")
				end

				LocalPlayer():SetPData("kontrol_autorefresh", !bEnabled)
			end)
			pAutoRefreshMenu:Open()
		end*/
	end

	UpdateList()
	bOpen = !bOpen
end

net.Receive("kontrol.showMenu", function(iLen)
	Menu()
end)

hook.Add("PlayerInitialSpawn", "kontrol.UpdateList", UpdateList)
hook.Add("PlayerDisconnected", "kontrol.UpdateList", UpdateList)

usermessage.Hook("kontrol.Log", function(um)
	LocalPlayer():PrintMessage(HUD_PRINTTALK, glon.decode(um:ReadString()))
end)

net.Receive("kontrol_Log", function(iLength)
	LocalPlayer():PrintMessage(HUD_PRINTTALK, net.ReadString())
end)

hook.Add("OnEntityCreated", "kontrol.UpdatePlayers", function(objEnt)
	if(objEnt:IsPlayer() and objEnt ~= LocalPlayer()) then
		hook.Call("PlayerInitialSpawn", GAMEMODE)
	end
end)

hook.Add("EntityRemoved", "kontrol.UpdatePlayers", function(objEnt)
	if(objEnt:IsPlayer() and objEnt ~= LocalPlayer()) then
		hook.Call("PlayerDisconnected", GAMEMODE, objEnt)
	end
end)

function kontrol:AddBanReason(sReason)
	sReason = string.Trim(string.Replace(sReason, "\n", ""))
	local found = false
	for k,v in pairs(kontrol.banReasons) do
		if(v == sReason) then
			found = true
			break
		end
	end
	if(not found) then
		if(not file.Exists("kontrol/", "DATA")) then
			file.CreateDir("kontrol/")
		end
		
		file.Append("kontrol/banReasons.txt", "\n"..sReason)
		kontrol.ReloadBanReasons(false)
	end
end