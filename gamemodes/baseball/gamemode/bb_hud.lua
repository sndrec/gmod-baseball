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
	size = 50,
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
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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

local xoffset = 30;
local inn_top = --top inning icon
{
	{ x = 90, y = ScrH()-30 },
	{ x = 105, y = ScrH()-60 },
	{ x = 120, y = ScrH()-30 }
}
local inn_bot = --bottom inning icon
{
	{ x = 90, y = ScrH()-60 },
	{ x = 120, y = ScrH()-60 },
	{ x = 105, y = ScrH()-30 }
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

local emptyColour = Color(128, 128, 128, 64)
local loadedColour = Color(255, 255, 255, 200)

local teamMat1 = Material("constructcomets.png", "noclamp smooth")
local teamMat2 = Material("flatgrassfriends.png", "noclamp smooth")

function HUD()
	render.SetGoalToneMappingScale( 0.5 )
	local client = LocalPlayer()
	draw.RoundedBox(10, 10, ScrH() - 150, 570, 140, Color(0, 0, 0, 150))
	surface.SetDrawColor( 255, 255, 255, 255 )


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
	--surface.DrawLine(1,1,50,50)

	draw.NoTexture() --i dont remember putting this here but ok !!
	--inning icon
	if inningside then
		surface.DrawPoly( inn_bot )
	else
		surface.DrawPoly( inn_top )
	end
	draw.Text( {
		text = inning,
		font = "UIFont",
		pos = { 140, ScrH()-20 },
		xalign = 1,
		yalign = 4
	} )
	--bases
	if fb then 
		surface.SetDrawColor( loadedColour.r, loadedColour.g, loadedColour.b, loadedColour.a )
	else
		surface.SetDrawColor( emptyColour.r, emptyColour.g, emptyColour.b, emptyColour.a )
	end
	surface.DrawPoly( base1 )
	if sb then 
		surface.SetDrawColor( loadedColour.r, loadedColour.g, loadedColour.b, loadedColour.a )
	else
		surface.SetDrawColor( emptyColour.r, emptyColour.g, emptyColour.b, emptyColour.a )
	end
	surface.DrawPoly( base2 )
	if tb then 
		surface.SetDrawColor( loadedColour.r, loadedColour.g, loadedColour.b, loadedColour.a )
	else
		surface.SetDrawColor( emptyColour.r, emptyColour.g, emptyColour.b, emptyColour.a )
	end
	surface.DrawPoly( base3 )
	draw.Text( {
		text = "B",
		font = "UIFont",
		pos = { 245, ScrH()-95 },
		xalign = 1,
		yalign = 4
	} )
	draw.Text( {
		text = "S",
		font = "UIFont",
		pos = { 245, ScrH()-55 },
		xalign = 1,
		yalign = 4
	} )
	draw.Text( {
		text = "O",
		font = "UIFont",
		pos = { 245, ScrH()-15 },
		xalign = 1,
		yalign = 4
	} )


	local curColour = loadedColour

	if balls >= 1 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end

	draw.RoundedBox(20, 270, ScrH() - 136, 30, 30, curColour)

	if balls >= 2 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end

	draw.RoundedBox(20, 306, ScrH() - 136, 30, 30, curColour)

	if balls >= 3 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end
	draw.RoundedBox(20, 342, ScrH() - 136, 30, 30, curColour)


	-- inning

	--strike
	if strikes >= 1 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end
	draw.RoundedBox(20, 270, ScrH() - 96, 30, 30, curColour)

	if strikes >= 2 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end
	draw.RoundedBox(20, 306, ScrH() - 96, 30, 30, curColour)
	--out

	if outs >= 1 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end
	draw.RoundedBox(20, 270, ScrH() - 56, 30, 30, curColour)

	if outs >= 2 then
		curColour = loadedColour
	else
		curColour = emptyColour
	end
	draw.RoundedBox(20, 306, ScrH() - 56, 30, 30, curColour)
	--scoreboard back
	draw.RoundedBox(5, 390, ScrH() - 145, 185, 65, Color(200, 60, 60, 255))
	draw.RoundedBox(5, 390, ScrH() - 80, 185, 65, Color(60, 60, 200, 255))
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
		pos = { 570, ScrH()-75 },
		xalign = 2,
		yalign = 4
	} )
	draw.Text( {
		text = score_blue,
		font = "UIScoreFont",
		pos = { 570, ScrH()-10 },
		xalign = 2,
		yalign = 4
	} )
end
hook.Add("HUDPaint", "TestHud", HUD)