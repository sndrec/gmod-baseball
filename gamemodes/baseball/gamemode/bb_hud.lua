--[[local inn_top =
{
	{ x = 100, y = 200 },
	{ x = 150, y = 100 },
	{ x = 200, y = 200 }
}
local inn_bot =
{
	{ x = 100, y = 100 },
	{ x = 200, y = 100 },
	{ x = 150, y = 200 }
}
local base = 
{
	{ x = 100, y = 100 },
	{ x = 175, y = 150 },
	{ x = 100, y = 200 },
	{ x = 25, y = 150 },
}]]

surface.CreateFont( "UIFont", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 44,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "UITitleFont", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "UIScoreFont", {
	font = "Typographica", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size =74,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

--local ui_scale = 3;

local xoffset = 30;
local inn_top = --top inning icon
{
	{ x = 270, y = ScrH()-33 },
	{ x = 283, y = ScrH()-55 },
	{ x = 296, y = ScrH()-33 }
}
local inn_bot = --bottom inning icon
{
	{ x = 270, y = ScrH()-55 },
	{ x = 296, y = ScrH()-55 },
	{ x = 283, y = ScrH()-33 }
}

local base1 = --first base icon
{
	{ x = xoffset+140, y = ScrH()-110 },
	{ x = xoffset+180, y = ScrH()-90 },
	{ x = xoffset+140, y = ScrH()-70 },
	{ x = xoffset+100, y = ScrH()-90 },
}
local base2 = --second base icon
{
	{ x = xoffset+90, y = ScrH()-135 },
	{ x = xoffset+130, y = ScrH()-115 },
	{ x = xoffset+90, y = ScrH()-95 },
	{ x = xoffset+50, y = ScrH()-115 },
}
local base3 = --third base icon
{
	{ x = xoffset+40, y = ScrH()-110 },
	{ x = xoffset+80, y = ScrH()-90 },
	{ x = xoffset+40, y = ScrH()-70 },
	{ x = xoffset, y = ScrH()-90 },
}
--177,309(243) - 19,151(85)
local ahhhhhhhhh = --thats me yellin
{
	{ x = xoffset+183, y = ScrH()-151 },
	
	{ x = xoffset+303, y = ScrH()-151 },
	{ x = xoffset+307, y = ScrH()-149 },
	{ x = xoffset+309, y = ScrH()-145 },
	
	{ x = xoffset+309, y = ScrH()-25 },
	{ x = xoffset+307, y = ScrH()-21 },
	{ x = xoffset+303, y = ScrH()-19 },
	
	{ x = xoffset+183, y = ScrH()-19 },
	{ x = xoffset+179, y = ScrH()-21 },
	{ x = xoffset+177, y = ScrH()-25 },
	
	{ x = xoffset+177, y = ScrH()-145 },
	{ x = xoffset+179, y = ScrH()-149 },
}

local base1front = --first base icon
{
	{ x = xoffset+276, y = ScrH()-113 },
	{ x = xoffset+304, y = ScrH()-85 },
	{ x = xoffset+276, y = ScrH()-57 },
	{ x = xoffset+248, y = ScrH()-85 },
}

local base1back1 = --first base icon
{
	{ x = xoffset+276, y = ScrH()-113 },
	{ x = xoffset+304, y = ScrH()-85 },
	{ x = xoffset+299, y = ScrH()-85 },
	{ x = xoffset+276, y = ScrH()-108 },
}

local base1back2 = --first base icon
{
	{ x = xoffset+299, y = ScrH()-85 },
	{ x = xoffset+304, y = ScrH()-85 },
	{ x = xoffset+276, y = ScrH()-57 },
	{ x = xoffset+276, y = ScrH()-62 },
}

local base1back3 = --first base icon
{
	{ x = xoffset+248, y = ScrH()-85 },
	{ x = xoffset+253, y = ScrH()-85 },
	{ x = xoffset+276, y = ScrH()-62 },
	{ x = xoffset+276, y = ScrH()-57 },
}

local base1back4 = --first base icon
{
	{ x = xoffset+276, y = ScrH()-113 },
	{ x = xoffset+276, y = ScrH()-108 },
	{ x = xoffset+253, y = ScrH()-85 },
	{ x = xoffset+248, y = ScrH()-85 },
}

local base2front = --first base icon
{
	{ x = xoffset+243, y = ScrH()-146 },
	{ x = xoffset+271, y = ScrH()-118 },
	{ x = xoffset+243, y = ScrH()-90 },
	{ x = xoffset+215, y = ScrH()-118 },
}

local base2back1 = --first base icon
{
	{ x = xoffset+243, y = ScrH()-146 },
	{ x = xoffset+271, y = ScrH()-118 },
	{ x = xoffset+266, y = ScrH()-118 },
	{ x = xoffset+243, y = ScrH()-141 },
}

local base2back2 = --first base icon
{
	{ x = xoffset+266, y = ScrH()-118 },
	{ x = xoffset+271, y = ScrH()-118 },
	{ x = xoffset+243, y = ScrH()-90 },
	{ x = xoffset+243, y = ScrH()-95 },
}

local base2back3 = --first base icon
{
	{ x = xoffset+215, y = ScrH()-118 },
	{ x = xoffset+220, y = ScrH()-118 },
	{ x = xoffset+243, y = ScrH()-95 },
	{ x = xoffset+243, y = ScrH()-90 },
}

local base2back4 = --first base icon
{
	{ x = xoffset+243, y = ScrH()-146 },
	{ x = xoffset+243, y = ScrH()-141 },
	{ x = xoffset+220, y = ScrH()-118 },
	{ x = xoffset+215, y = ScrH()-118 },
}

local base3front = --first base icon
{
	{ x = xoffset+210, y = ScrH()-113 },
	{ x = xoffset+238, y = ScrH()-85 },
	{ x = xoffset+210, y = ScrH()-57 },
	{ x = xoffset+182, y = ScrH()-85 },
}

local base3back1 = --first base icon
{
	{ x = xoffset+210, y = ScrH()-113 },
	{ x = xoffset+238, y = ScrH()-85 },
	{ x = xoffset+233, y = ScrH()-85 },
	{ x = xoffset+210, y = ScrH()-108 },
}

local base3back2 = --first base icon
{
	{ x = xoffset+233, y = ScrH()-85 },
	{ x = xoffset+238, y = ScrH()-85 },
	{ x = xoffset+210, y = ScrH()-57 },
	{ x = xoffset+210, y = ScrH()-62 },
}

local base3back3 = --first base icon
{
	{ x = xoffset+182, y = ScrH()-85 },
	{ x = xoffset+187, y = ScrH()-85 },
	{ x = xoffset+210, y = ScrH()-62 },
	{ x = xoffset+210, y = ScrH()-57 },
}

local base3back4 = --first base icon
{
	{ x = xoffset+210, y = ScrH()-113 },
	{ x = xoffset+210, y = ScrH()-108 },
	{ x = xoffset+187, y = ScrH()-85 },
	{ x = xoffset+182, y = ScrH()-85 },
}


local emptyColour = Color(128, 128, 128, 64)
local loadedColour = Color(255, 255, 255, 200)

local teamMat1 = Material("constructcomets.png", "noclamp smooth")
local teamMat2 = Material("flatgrassfriends.png", "noclamp smooth")
local uiBack = Material("baseball/baseui_back.png", "noclamp smooth")
local uiTitle = Material("baseball/baseui_title.png", "noclamp smooth")
local uiBSO = Material("baseball/baseui_bso.png", "noclamp smooth")
local uiLogoFlair = Material("baseball/baseui_logoflair.png", "noclamp smooth")
local uiSectionBack = Material("baseball/baseui_sectionback.png", "noclamp smooth")
local uiBaseEmpty = Material("baseball/baseui_baseempty.png", "noclamp smooth")
local uiBaseFull = Material("baseball/baseui_basefull.png", "noclamp smooth")
local uiInningTop = Material("baseball/baseui_inningtop.png", "noclamp smooth")
local uiInningBot = Material("baseball/baseui_inningbot.png", "noclamp smooth")

function HUD()
	render.SetGoalToneMappingScale( 0.5 )
	local client = LocalPlayer()
	--draw.RoundedBox(20, 10, ScrH() - (186)-10, 477, 186, Color(0, 0, 0, 150))
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial(uiBack)
	surface.DrawTexturedRect(10, ScrH() - (186)-10, 477, 186)
	surface.SetMaterial(uiTitle)
	surface.DrawTexturedRect(10, ScrH() - (187)-10, 477, 37)


	local fb = GetGlobalBool( "firstbase", false )
	local sb = GetGlobalBool( "secondbase", false )
	local tb = GetGlobalBool( "thirdbase", false )
	local inningside = GetGlobalBool( "inningside", false )
	local inning = GetGlobalInt( "inning", 0 )
	local balls = GetGlobalInt( "balls", 0 )
	local strikes = GetGlobalInt( "strikes", 0 )
	local fouls = GetGlobalInt( "fouls", 0 )
	local outs = GetGlobalInt( "outs", 0 )
	local score_red = GetGlobalInt( "redscore", 0 )
	local score_blue = GetGlobalInt( "bluescore", 0 )
	--local chyron = GetGlobalString( "THIS SPACE FOR RENT", 0 )
	--surface.DrawLine(1,1,50,50)

	draw.Text( {
		text = "THIS SPACE FOR RENT KL5-3226",
		font = "UITitleFont",
		pos = { 84, ScrH()-165 },
		xalign = 0,
		yalign = 4
	} )

	draw.NoTexture() --i dont remember putting this here but ok !!
	
	--bases
	
	--surface.SetDrawColor( 0, 0, 0, 200 )
	--draw.RoundedBox(5, 10+(197), ScrH() - 151, 132, 132, Color(0, 0, 0, 128))
	surface.SetMaterial(uiSectionBack)
	surface.DrawTexturedRect(10+(197), ScrH() - (141)-10, 132, 132)
	--surface.DrawPoly( ahhhhhhhhh )
	--surface.SetDrawColor( 255, 255, 255, 255 )
	if fb then
		--surface.DrawPoly( base1front )
		surface.SetMaterial(uiBaseFull)
	else
		--surface.DrawPoly( base1back1 )
		--surface.DrawPoly( base1back2 )
		--surface.DrawPoly( base1back3 )
		--surface.DrawPoly( base1back4 )
		surface.SetMaterial(uiBaseEmpty)
	end
	surface.DrawTexturedRect(10+(268), ScrH() - (103)-10, 56, 56)
	
	if sb then
		surface.SetMaterial(uiBaseFull)
	else
		surface.SetMaterial(uiBaseEmpty)
	end
	surface.DrawTexturedRect(10+(235), ScrH() - (136)-10, 56, 56)
	
	if tb then
		surface.SetMaterial(uiBaseFull)
	else
		surface.SetMaterial(uiBaseEmpty)
	end
	surface.DrawTexturedRect(10+(202), ScrH() - (103)-10, 56, 56)
	
	--inning icon
	if inningside then
		--surface.DrawPoly( inn_bot )
		surface.SetMaterial(uiInningBot)
	else
		--surface.DrawPoly( inn_top )
		surface.SetMaterial(uiInningTop)
	end
	surface.DrawTexturedRect(10+(263), ScrH() - (45)-10, 26, 24)
	draw.Text( {
		text = inning,
		font = "UIFont",
		pos = { 258, ScrH()-20 },
		xalign = 1,
		yalign = 4
	} )
	
	surface.SetMaterial(uiSectionBack)
	surface.DrawTexturedRect(10+(336), ScrH() - (141)-10, 132, 132)
	--draw.RoundedBox(5, 10+(336), ScrH() - 151, 132, 132, Color(0, 0, 0, 200))
	--245
	draw.Text( {
		text = "B",
		font = "UIFont",
		pos = { 365, ScrH()-101 },
		xalign = 1,
		yalign = 4
	} )
	draw.Text( {
		text = "S",
		font = "UIFont",
		pos = { 365, ScrH()-62 },
		xalign = 1,
		yalign = 4
	} )
	draw.Text( {
		text = "O",
		font = "UIFont",
		pos = { 365, ScrH()-23 },
		xalign = 1,
		yalign = 4
	} )
	
	
	surface.SetMaterial(uiBSO)
	local curColour = loadedColour

	if balls >= 1 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	--270, 306, 342
	--draw.RoundedBox(12, 384, ScrH() - 137, 26, 26, curColour)
	surface.SetMaterial(uiBSO)
	surface.DrawTexturedRect(384, ScrH() - 137, 26, 26)

	if balls >= 2 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end

	--draw.RoundedBox(12, 415, ScrH() - 137, 26, 26, curColour)
	surface.DrawTexturedRect(415, ScrH() - 137, 26, 26)

	if balls >= 3 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	--draw.RoundedBox(12, 446, ScrH() - 137, 26, 26, curColour)
	surface.DrawTexturedRect(446, ScrH() - 137, 26, 26)


	-- inning

	--strike
	if strikes >= 1 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	--draw.RoundedBox(12, 384, ScrH() - 98, 26, 26, curColour)
	surface.DrawTexturedRect(384, ScrH() - 98, 26, 26)

	if strikes >= 2 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	--draw.RoundedBox(12, 415, ScrH() - 98, 26, 26, curColour)
	surface.DrawTexturedRect(415, ScrH() - 98, 26, 26)
	--out

	if outs >= 1 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	--draw.RoundedBox(12, 384, ScrH() - 59, 26, 26, curColour)
	surface.DrawTexturedRect(384, ScrH() - 59, 26, 26)

	if outs >= 2 then
		--curColour = loadedColour
		surface.SetDrawColor(loadedColour)
	else
		--curColour = emptyColour
		surface.SetDrawColor(emptyColour)
	end
	
	--draw.RoundedBox(12, 415, ScrH() - 59, 26, 26, curColour)
	surface.DrawTexturedRect(415, ScrH() - 59, 26, 26)
	
	--scoreboard back
	draw.RoundedBox(5, 10+(10), ScrH() - 151, 179, 60, Color(255, 255, 255, 255))
	draw.RoundedBox(5, 10+(9), ScrH() - 151, 90, 60, Color(200, 60, 60, 255))
	draw.TexturedQuad
	{
		texture = surface.GetTextureID "vgui/gradient-u",
		color = Color(0, 0, 0, 120),
		x = 10+(12),
		y = ScrH() - 148,
		w = 84,
		h = 54
	}
	
	--draw.RoundedBox(5, 10+(12), ScrH() - 142, 84, 54, Color(0, 60, 60, 255))
	
	
	draw.RoundedBox(5, 10+(10), ScrH() - 80, 179, 60, Color(255, 255, 255, 255))
	draw.RoundedBox(5, 10+(9), ScrH() - 80, 90, 60, Color(60, 60, 200, 255))
	draw.TexturedQuad
	{
		texture = surface.GetTextureID "vgui/gradient-u",
		color = Color(0, 0, 0, 120),
		x = 10+(12),
		y = ScrH() - 77,
		w = 84,
		h = 54
	}
	
	--score icons (replace with graphix!!!)
	surface.SetDrawColor( 255, 255, 255, 255 )
	--surface.SetMaterial(teamMat1)
	--surface.DrawTexturedRect(395, ScrH() - 75, 55, 55)
	--surface.SetMaterial(teamMat2)
	--surface.DrawTexturedRect(395, ScrH() - 140, 55, 55)
	--score itsel;f
	-- score_red
	-- score_blue
	draw.Text( {
		text = score_red,
		font = "UIScoreFont",
		pos = { 10+(144), ScrH()-(109)-10 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 0, 0, 0, 255 )
	} )
	draw.Text( {
		text = score_blue,
		font = "UIScoreFont",
		pos = { 10+(144), ScrH()-(38)-10 },
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
		color = Color( 0, 0, 0, 255 )
	} )
	surface.SetMaterial(uiLogoFlair)
	surface.DrawTexturedRect(19, ScrH() - 151, 90, 60)
	surface.DrawTexturedRect(19, ScrH() - 80, 90, 60)
end
hook.Add("HUDPaint", "TestHud", HUD)