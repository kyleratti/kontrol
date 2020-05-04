local tPlugin = {}
tPlugin.Name = "Goto"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.API = 1
tPlugin.Icon = "icon16/arrow_right.png"
function tPlugin:CanUse(objPl)
	if(GAMEMODE:IsDarkRP()) then
		return objPl:IsMod() or objPl:IsVIP()
	elseif(GAMEMODE:IsPERP()) then
		return objPl:IsMod()
	end
end

function tPlugin:ShouldShow(objPl)
	return objPl ~= LocalPlayer()
end

if(SERVER) then
	kontrol:AddLogType("Teleport")
	
	kontrol:AddCommand("goto", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, false, true)) then return end

		if(objTarget:GetColor().a ~= 255) then
			objPl:PrintMessage(HUD_PRINTTALK, "There's no where to put you :(!")
			return
		end

		if(objPl == objTarget) then
			objPl:PrintMessage(HUD_PRINTTALK, "You can't manipulate yourself!")
			return
		end

		if(objPl:IsVIP() and !objPl:IsMod()) then
			if(objPl.LastTP and CurTime() - objPl.LastTP < 15) then
				objPl:PrintMessage(HUD_PRINTTALK, "Slow down between teleports!")
				return
			end
		end

		-- Code from ULX so thank Megiddo for this. This is so players don't get stuck in the world when you teleport them
		local function playerSend(from, to, force)
			if not to:IsInWorld() and not force then return false end -- No way we can do this one

			local yawForward = to:EyeAngles().yaw
			local directions = {-- Directions to try
				math.NormalizeAngle(yawForward - 180), -- Behind first
				math.NormalizeAngle(yawForward + 180), -- Front
				math.NormalizeAngle(yawForward + 90), -- Right
				math.NormalizeAngle(yawForward - 90), -- Left
				yawForward,
			}

			local t = {}
			t.start = to:GetPos() + Vector(0, 0, 15) -- Move them up a bit so they can travel across the ground
			t.filter = {to, from}

			local i = 1
			t.endpos = to:GetPos() + Angle(0, directions[ i ], 0):Forward() * 47 -- (33 is player width, this is sqrt(33^2 * 2))
			local tr = util.TraceEntity(t, from)
			while tr.Hit do -- While it's hitting something, check other angles
				i = i + 1
				if i > #directions then  -- No place found
					if force then
						return to:GetPos() + Angle(0, directions[ 1 ], 0):Forward() * 47
					else
						return false
					end
				end

				t.endpos = to:GetPos() + Angle(0, directions[ i ], 0):Forward() * 47

				tr = util.TraceEntity(t, from)
		    end

			return tr.HitPos
		end

		local vPos = playerSend(objPl, objTarget, objPl:GetMoveType() == MOVETYPE_NOCLIP)

		if(not vPos) then
			objPl:PrintMessage(HUD_PRINTTALK, "There's no where to put you :(!")
			return
		end

		local aAng = (objTarget:GetPos() - vPos):Angle()
		objPl:SetPos(vPos)
		objPl:SetEyeAngles(aAng)
		objPl:SetLocalVelocity(Vector(0, 0, 0))

		if(objPl:IsVIP() and !objPl:IsMod()) then
			objPl.LastTP = CurTime()
		end

		kontrol:Log({
			["Type"] = KONTROL_LOG_TELEPORT,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " teleported to "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_goto", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)