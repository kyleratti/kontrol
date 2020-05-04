class "Plugin" {
	private {
		name = "";
		type = 0;
		icon = "";
	};

	public {
		__construct = function(self, strName, iType)
			self.name = strName
			self.type = iType

			kontrol.plugins[iType][strName] = self
		end;

		getName = function(self)
			return self.name
		end;

		getType = function(self)
			return self.type
		end;

		setIcon = function(self, strIcon)
			self.icon = strIcon
		end;

		getIcon = function(self)
			return self.icon
		end;

		--[[canPlayerUse = function(self, objPl)
			return IsValid(objPl) and objPl:isMod()
		end;

		canConsoleUse = function(self)
			return false
		end;

		canTarget = function(self, objPl, objTarget)
			return false
		end;]]--

		canRunCommand = function(self, objPl, strCmd, tblArgs)
			if(not IsValid(objPl) || not tblArgs) then return false end

			if(not self:canPlayerUse(objPl)) then
				objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
				return false
			end

			return true
		end;

		onMenuClick = function(self, objPl)
			print("Menu was clicked", objPl)
		end;

		onServerLoad = function(self)
			return
		end;

		onClientLoad = function(self)
			return
		end;
	};
}