local KFRAME = {}

function KFRAME:Init()
end

function KFRAME:Paint(w, h)
	draw.RoundedBox(6, 0, 2, 217, 26, Color(48, 172, 255, 255))
	draw.RoundedBox(0, 0, 22, self:GetWide(), self:GetTall() - 22, Color(150, 150, 150, 255))
	draw.RoundedBox(0, 1, 23, self:GetWide() - 2, self:GetTall() - 24, Color(230, 230, 230, 255))

	return true
end

vgui.Register("KFrame", KFRAME, "DFrame")


local KFRAME2 = {}

function KFRAME2:Init()
end

function KFRAME2:Paint(w, h)
	draw.RoundedBox(6, 0, 2, self:GetWide(), 26, Color(48, 172, 255, 255))
	draw.RoundedBox(0, 0, 22, self:GetWide(), self:GetTall() - 22, Color(150, 150, 150, 255))
	draw.RoundedBox(0, 1, 23, self:GetWide() - 2, self:GetTall() - 24, Color(230, 230, 230, 255))
	draw.RoundedBox(4, 5, 27, self:GetWide() - 10, self:GetTall() - 32, Color(200, 200, 200, 255))

	return true
end

vgui.Register("KFrame2", KFRAME2, "DFrame")


local KBUTTON = {}
KBUTTON.Color = Color(48, 172, 255)

function KBUTTON:OnCursorEntered()
	self.Color = Color(94, 190, 255)
end

function KBUTTON:OnCursorExited()
	self.Color = Color(48, 172, 255)
end

function KBUTTON:OnMousePressed()
	self.Color = Color(35, 137, 206)
end

function KBUTTON:OnMouseReleased()
	self.Color = Color(48, 172, 255)
	self:DoClick()
end

function KBUTTON:Paint(w, h)
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))
	draw.RoundedBox(0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color(35, 137, 206))
	draw.RoundedBox(0, 2, 2, self:GetWide() - 4, self:GetTall() - 4, self.Color)

	return false
end

vgui.Register("KButton", KBUTTON, "DButton")


local KLISTBUTTON = {}
KLISTBUTTON.Color = Color(48, 172, 255)

function KLISTBUTTON:OnCursorEntered()
	self.Color = Color(94, 190, 255)
end

function KLISTBUTTON:OnCursorExited()
	self.Color = Color(48, 172, 255)
end

function KLISTBUTTON:OnMousePressed()
	self.Color = Color(35, 137, 206)
end

function KLISTBUTTON:OnMouseReleased()
	self.Color = Color(48, 172, 255)
	self:DoClick()
end

function KLISTBUTTON:Paint(w, h)
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))
	draw.RoundedBox(0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color(35, 137, 206))
	draw.RoundedBox(0, 2, 2, self:GetWide() - 4, self:GetTall() - 4, self.Color)
	draw.RoundedBox(0, 3, 3, 10, self:GetTall() - 6, Color(0, 0, 0, 70))

	return false
end

vgui.Register("KListButton", KLISTBUTTON, "DButton")