local tPlugin = {}
tPlugin.Name = "Slap"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_PUNISH
tPlugin.Icon = "icon16/wand.png"
tPlugin.API = 1
tPlugin.Strength = {}
tPlugin.Strength["Light"] = {
	LogName = "lightly",
	MaxVelocity = 200,
}
tPlugin.Strength["Hard"] = {
	LogName = "hard",
	MaxVelocity = 500,
}
tPlugin.Strength["Super"] = {
	LogName = "hard but fast",
	MaxVelocity = 10000,
}
tPlugin.Strength["Deadly"] = {
	LogName = "with deadly force",
	MaxVelocity = 1000,
}
tPlugin.Strength["Into Space"] = {
	LogName = "into space",
	MaxVelocity = 100000,
}
tPlugin.Sounds = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
	"physics/body/body_medium_impact_soft5.wav",
	"physics/body/body_medium_impact_soft6.wav",
	"physics/body/body_medium_impact_soft7.wav",
}
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Slap")

	kontrol:AddCommand("slap", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		local tStrength = tPlugin.Strength[tblArgs[2]] or tPlugin.Strength["Light"]

		local vVel = Vector(math.random(tStrength.MaxVelocity) - (tStrength.MaxVelocity / 2), math.random(tStrength.MaxVelocity) - (tStrength.MaxVelocity / 2), math.random(tStrength.MaxVelocity) - (tStrength.MaxVelocity / 4))

		objTarget:EmitSound(table.Random(tPlugin.Sounds))
		objTarget:SetVelocity(vVel)

		kontrol:Log({
			["Type"] = KONTROL_LOG_SLAP,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " slapped "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				{["Log"] = " "},
				{["Log"] = tStrength["LogName"], ["Chat"] = {color_white, tStrength["LogName"]}},
			},
		})
	end)
else
	local iTimesRun = 0

	function tPlugin.Menu(iUID)
		local objPl = player.GetByUniqueID(iUID)
		iTimesRun = 0

		local pMenu = vgui.Create("KFrame2")
		pMenu:SetSize(300, 85)
		pMenu:Center()
		pMenu:SetTitle("Slap "..objPl:Nick())
		pMenu:SetDraggable(true)
		pMenu:ShowCloseButton(true)
		pMenu:SetSizable(false)
		pMenu:SetScreenLock(true)
		pMenu:MakePopup()

		local sChoice = "Light"
		local pChoice = vgui.Create("DComboBox", pMenu)
		pChoice:SetPos(10, 32.5)
		pChoice:SetSize(280, 20)
		pChoice:SetText(sChoice)
		function pChoice:OnSelect(pPanel, sValue)
			sChoice = sValue
		end
		pChoice:AddChoice("Light")
		pChoice:AddChoice("Hard")
		pChoice:AddChoice("Super")
		pChoice:AddChoice("Deadly")
		pChoice:AddChoice("Into Space")

		local pAccept = vgui.Create("KButton", pMenu)
		pAccept:SetSize(pMenu:GetWide() - 20, 20)
		pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
		pAccept:SetText("Slap "..objPl:Nick())
		function pAccept:DoClick()
			RunConsoleCommand("kontrol_slap", iUID, sChoice)
			if(iTimesRun >= 3) then
				pMenu:Close() -- mass abuse
			end
			iTimesRun = iTimesRun + 1
		end
	end
end

kontrol:RegisterPlugin(tPlugin)