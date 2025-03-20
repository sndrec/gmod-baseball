
--[[---------------------------------------------------------

	Sandbox Gamemode

	This is GMod's default gamemode

-----------------------------------------------------------]]

include( 'shared.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_notice.lua' )
include( 'cl_hints.lua' )
include( 'cl_worldtips.lua' )
include( 'cl_search_models.lua' )
include( 'gui/IconEditor.lua' )
include( 'bb_hud.lua' )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )


local physgun_halo = CreateConVar( "physgun_halo", "1", { FCVAR_ARCHIVE }, "Draw the physics gun halo?" )

function GM:Initialize()

	BaseClass.Initialize( self )

end

function GM:InitPostEntity()

	LocalPlayer():ConCommand("cl_interp 0.016")
	LocalPlayer():ConCommand("cl_interp_ratio 0")

end

function GM:LimitHit( name )

	self:AddNotify( "#SBoxLimit_" .. name, NOTIFY_ERROR, 6 )
	surface.PlaySound( "buttons/button10.wav" )

end

net.Receive("ShowStatMenu", function()

	print("showspare1")
	local StatMenu = vgui.Create("DFrame")
	local CreateTime = CurTime()
	local PosX = ScrW() * -0.25
	local Width = 480
	local Height = 720
	local PosY = ScrH() - Height - 220
	
	--local BaseballMat = Material( "baseball.png", "noclamp smooth" )
	local PointEmpty = Material ( "baseball/statui_empty.png", "noclamp smooth" )
	local PointFull = Material ( "baseball/statui_full.png", "noclamp smooth" )
	local BackPoints = Material ( "baseball/statui_points.png", "noclamp smooth" )
	local BackArms = Material ( "baseball/statui_arms.png", "noclamp smooth" )
	local BackLegs = Material ( "baseball/statui_legs.png", "noclamp smooth" )
	local BackBody = Material ( "baseball/statui_body.png", "noclamp smooth" )
	local BackSpirit = Material ( "baseball/statui_spirit.png", "noclamp smooth" )
	local BackStamina = Material ( "baseball/statui_stamina.png", "noclamp smooth" )
	local Unspent = Material ( "baseball/statui_unspent.png", "noclamp smooth" )
	
	StatMenu:SetPos(PosX, PosY)
	StatMenu:SetSize(Width, Height)
	StatMenu:SetVisible(true)
	StatMenu:SetDraggable(false)
	StatMenu:ShowCloseButton(true)
	StatMenu:SetTitle("")
	StatMenu:MakePopup()

	ArmData = {}
	LegData = {}
	BodyData = {}
	HeartData = {}
	ArmData.Points = LocalPlayer():GetArmsStat()
	LegData.Points = LocalPlayer():GetLegsStat()
	BodyData.Points = LocalPlayer():GetBodyStat()
	HeartData.Points = LocalPlayer():GetHeartStat()
	ArmData.PrettyName = "Arms"
	LegData.PrettyName = "Legs"
	BodyData.PrettyName = "Body"
	HeartData.PrettyName = "Spirit"
	local DataTable = {ArmData, LegData, BodyData, HeartData}
	local NumStatsMax = 8

	function StatMenu:Think()
		PosX = Lerp(RealFrameTime() * 12, PosX, 10)
		StatMenu:SetPos(PosX, PosY)
		ArmData.Points = LocalPlayer():GetArmsStat()
		LegData.Points = LocalPlayer():GetLegsStat()
		BodyData.Points = LocalPlayer():GetBodyStat()
		HeartData.Points = LocalPlayer():GetHeartStat()
	end

	function StatMenu:Paint( w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255, 80 ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(BackPoints)
		surface.DrawTexturedRect( 0, 0, 480, 120 )
		surface.SetMaterial(BackArms)
		surface.DrawTexturedRect( 0, 120, 480, 120 )
		surface.SetMaterial(BackLegs)
		surface.DrawTexturedRect( 0, 240, 480, 120 )
		surface.SetMaterial(BackBody)
		surface.DrawTexturedRect( 0, 360, 480, 120 )
		surface.SetMaterial(BackSpirit)
		surface.DrawTexturedRect( 0, 480, 480, 120 )
		surface.SetMaterial(BackStamina)
		surface.DrawTexturedRect( 0, 600, 480, 120 )
		--draw.SimpleTextOutlined( "Stat Points Remaining:", "DermaDefault", 6, (Height * 0.11) - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) )
		
		local points = LocalPlayer():GetStatPoints()
		points = points + ArmData.Points
		points = points + LegData.Points
		points = points + BodyData.Points
		points = points + HeartData.Points
		
		surface.SetMaterial(PointEmpty)
		for i = 1, points, 1 do
			surface.DrawTexturedRect(Width-(i*37), 5, 32, 32 )
		end
		surface.SetMaterial(PointFull)
		for i = 1, LocalPlayer():GetStatPoints(), 1 do
			surface.DrawTexturedRect(Width-1-(i*37), 4, 34, 34 )
		end

		for i, v in ipairs(DataTable) do
			for n = 1, NumStatsMax, 1 do
				local offs = 0
				local siz = 0
				if n <= v.Points then
					--surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial(PointFull)
					offs = -1
					siz = 2
				else
					--surface.SetDrawColor( 0, 0, 0, 60 )
					surface.SetMaterial(PointEmpty)
				end
				surface.DrawTexturedRect( Width-offs-((NumStatsMax+1)*37)+(n*37), (120 * i) + offs + 5, 32+siz, 32+siz )
				--draw.SimpleTextOutlined( v.PrettyName, "DermaDefault", 6, (((Height * 0.15) * i) + (Height * 0.1)) - 16, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) )
			end
		end
		draw.SimpleText(math.SnapTo( 100 - LocalPlayer():GetMaxStamina(), 0.01) .. "%", "UIStaminaFont", 440, 670, Color(255, 60, 60, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(math.SnapTo( LocalPlayer():GetStamina() / LocalPlayer():GetMaxStamina() * 100, 0.01) .. "%", "UIStaminaFont", 38, 670, Color(100, 255, 60, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		
		local stam = LocalPlayer():GetStamina() / LocalPlayer():GetMaxStamina()
		local fati = (100-LocalPlayer():GetMaxStamina())/100
		surface.SetDrawColor( 100, 255, 60, 255 )
		surface.DrawRect(40,674,400*(stam-fati),30)
		surface.SetDrawColor( 255, 60, 60, 255 )
		surface.DrawRect(441-(400*fati),674,400*fati,30)
		surface.SetDrawColor( 255, 255, 255, 255 )
		draw.TexturedQuad
		{
			texture = surface.GetTextureID "vgui/gradient-d",
			color = Color(0, 0, 0, 200),
			x = 40,
			y = 674,
			w = 400*(stam-fati),
			h = 30
		}
		draw.TexturedQuad
		{
			texture = surface.GetTextureID "vgui/gradient-d",
			color = Color(0, 0, 0, 200),
			x = 441-(400*fati),
			y = 674,
			w = 400*fati,
			h = 30
		}
	end
	
	local allowRemove = true

	for i, v in ipairs(DataTable) do
		local AddPoint = vgui.Create("DButton", StatMenu)
		AddPoint:SetPos(420, (120 * i)+50)
		AddPoint:SetSize(48, 48)
		AddPoint:SetText("+")
		function AddPoint:DoClick()
			net.Start("RequestStatChange")
			net.WriteInt(i, 4)
			net.WriteBool(true)
			net.SendToServer()
		end
		if allowRemove then
			local RemovePoint = vgui.Create("DButton", StatMenu)
			RemovePoint:SetPos(365, (120 * i)+50)
			RemovePoint:SetSize(48, 48)
			RemovePoint:SetText("-")
			function RemovePoint:DoClick()
				net.Start("RequestStatChange")
				net.WriteInt(i, 4)
				net.WriteBool(false)
				net.SendToServer()
			end
		end
	end

end)

function GM:OnUndo( name, strCustomString )

	if ( !strCustomString ) then
		local str = "#Undone_" .. name
		local translated = language.GetPhrase( str )
		if ( str == translated ) then
			-- No translation available, apply our own
			translated = string.format( language.GetPhrase( "hint.undoneX" ), language.GetPhrase( name ) )
		else
			-- Try to translate some of this
			local strmatch = string.match( translated, "^Undone (.*)$" )
			if ( strmatch ) then
				translated = string.format( language.GetPhrase( "hint.undoneX" ), language.GetPhrase( strmatch ) )
			end
		end

		self:AddNotify( translated, NOTIFY_UNDO, 2 )
	else
		-- This is a hack for SWEPs, etc, to support #translations from server
		local str = string.match( strCustomString, "^Undone (.*)$" )
		if ( str ) then
			strCustomString = string.format( language.GetPhrase( "hint.undoneX" ), language.GetPhrase( str ) )
		end

		self:AddNotify( strCustomString, NOTIFY_UNDO, 2 )
	end

	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:OnCleanup( name )

	self:AddNotify( "#Cleaned_" .. name, NOTIFY_CLEANUP, 5 )

	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:UnfrozeObjects( num )

	self:AddNotify( string.format( language.GetPhrase( "hint.unfrozeX" ), num ), NOTIFY_GENERIC, 3 )

	-- Find a better sound :X
	surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )

end

local strikeBoxColour = Color(255,255,255,50)
local quadMat = Material( "vgui/white" ) -- Calling Material() every frame is quite expensive
function DrawStrikeBox(width, height)
	local mid = Vector(-4755, -4755, 100)
	local orientation = Angle(0, 45, 0)
	cam.Start3D()
		render.DrawLine(
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * 0.5),
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * -0.5),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * -0.5),
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * -0.5),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * -0.5),
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * 0.5),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * 0.5),
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * 0.5),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * -0.5),
		mid + (orientation:Right() * width * 0.5) + (orientation:Up() * height * -0.5) + Vector(0,0,-37),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * -0.5),
		mid + (orientation:Right() * width * -0.5) + (orientation:Up() * height * -0.5) + Vector(0,0,-37),
		strikeBoxColour,
		true)

		render.DrawLine(
		mid + (orientation:Right() * width * 4) + (orientation:Up() * height * -0.5) + Vector(0,0,-37),
		mid + (orientation:Right() * width * -4) + (orientation:Up() * height * -0.5) + Vector(0,0,-37),
		strikeBoxColour,
		true)
	cam.End3D()

end

local ballCrossQueue = {}

local StaminaHeartMatFull = Material( "staminafull.png", "noclamp smooth" )
local StaminaHeartMatEmpty = Material( "staminaempty.png", "noclamp smooth" )

function GM:HUDPaint()

	self:PaintWorldTips()

	-- Draw all of the default stuff
	BaseClass.HUDPaint( self )

	self:PaintNotes()
	--draw.SimpleTextOutlined( "Penius", "DermaLarge", ScrW() * 0.5, ScrH() * 0.6, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 255 ) )
	for i = #ballCrossQueue, 1, -1 do
		if CurTime() >= ballCrossQueue[i].deathTime then
			table.remove(ballCrossQueue, i)
			continue
		end
		cam.Start3D()
		local crossPos = ballCrossQueue[i].pos:ToScreen()
		cam.End3D()
		surface.SetDrawColor( 0, 255, 0, 255)
		surface.DrawLine(crossPos.x - 6, crossPos.y, crossPos.x + 6, crossPos.y)
		surface.DrawLine(crossPos.x, crossPos.y - 6, crossPos.x, crossPos.y + 6)
	end

	local HeartSize = 96 * (LocalPlayer():GetMaxStamina() * 0.01)

	local Pos = (LocalPlayer():GetPos() + Vector(0, 0, 48) + EyeAngles():Right() * 18):ToScreen()
	local StaminaPercent = LocalPlayer():GetStamina() / LocalPlayer():GetMaxStamina()
	--print(LocalPlayer():GetStamina())
	--print(LocalPlayer():GetMaxStamina())
	local DrawColor1 = Color(120, 255, 120)
	local DrawColor2 = Color(240 * ((((math.sin(CurTime() * 20) / 3.141592) + 1) * 0.6) + 0.2), 40, 40)
	local Remap = math.Remap(StaminaPercent, 0.4, 0.6, 0, 1)
	local DCF = Color(Lerp(Remap, DrawColor2.r, DrawColor1.r), Lerp(Remap, DrawColor2.g, DrawColor1.g), Lerp(Remap, DrawColor2.b, DrawColor1.b))
	surface.SetDrawColor( DCF.r, DCF.g, DCF.b, math.Remap(StaminaPercent, 0.99, 1, 255, 0))
	surface.SetMaterial(StaminaHeartMatFull)
	surface.DrawTexturedRectUV( Pos.x, Pos.y + (HeartSize * (1 - StaminaPercent)), HeartSize, HeartSize * StaminaPercent, 0, 1 - StaminaPercent, 1, 1 )
	surface.SetMaterial(StaminaHeartMatEmpty)
	surface.DrawTexturedRect( Pos.x, Pos.y, HeartSize, HeartSize )
	

end

function GM:PostDrawOpaqueRenderables(depth, skybox, threedeeskybox)

	DrawStrikeBox(100, 120)

end

net.Receive("StrikePos", function(len, pl)
	local strikePos = net.ReadVector()
	SubmitBallCrossPos(strikePos)
end)

function SubmitBallCrossPos(crossPos)
	local tempTable = {}
	tempTable.deathTime = CurTime() + 6.0
	tempTable.pos = crossPos
	table.insert(ballCrossQueue, tempTable)
end

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

--[[---------------------------------------------------------
	Draws on top of VGUI..
-----------------------------------------------------------]]
function GM:PostRenderVGUI()

	BaseClass.PostRenderVGUI( self )

end

local PhysgunHalos = {}

--[[---------------------------------------------------------
	Name: gamemode:DrawPhysgunBeam()
	Desc: Return false to override completely
-----------------------------------------------------------]]
function GM:DrawPhysgunBeam( ply, weapon, bOn, target, boneid, pos )

	if ( physgun_halo:GetInt() == 0 ) then return true end

	if ( IsValid( target ) ) then
		PhysgunHalos[ ply ] = target
	end

	return true

end

hook.Add( "PreDrawHalos", "AddPhysgunHalos", function()

	if ( !PhysgunHalos || table.IsEmpty( PhysgunHalos ) ) then return end

	for k, v in pairs( PhysgunHalos ) do

		if ( !IsValid( k ) ) then continue end

		local size = math.random( 1, 2 )
		local colr = k:GetWeaponColor() + VectorRand() * 0.3

		halo.Add( PhysgunHalos, Color( colr.x * 255, colr.y * 255, colr.z * 255 ), size, size, 1, true, false )

	end

	PhysgunHalos = {}

end )


--[[---------------------------------------------------------
	Name: gamemode:NetworkEntityCreated()
	Desc: Entity is created over the network
-----------------------------------------------------------]]
function GM:NetworkEntityCreated( ent )

	--
	-- If the entity wants to use a spawn effect
	-- then create a propspawn effect if the entity was
	-- created within the last second (this function gets called
	-- on every entity when joining a server)
	--

	if ( ent:GetSpawnEffect() && ent:GetCreationTime() > ( CurTime() - 1.0 ) ) then

		local ed = EffectData()
			ed:SetOrigin( ent:GetPos() )
			ed:SetEntity( ent )
		util.Effect( "propspawn", ed, true, true )

	end

end

local OldAngles = EyeAngles()
local ThirdpersonAngles = EyeAngles()

local Minimum = Vector(-5, -5, -5)
local Maximum = Vector(5, 5, 5)

local Enabled = CreateClientConVar("bb_thirdperson_enabled", "1")
local Distance = CreateClientConVar("bb_thirdperson_distance", "120")
local Height = CreateClientConVar("bb_thirdperson_height", "15")
local Offset = CreateClientConVar("bb_thirdperson_offset", "20")

local realPos = EyePos()
local realAng = EyeAngles()

local is_batting = false
local is_batting_old = false
local batting_start_time = CurTime()

local Thirdperson = function(pl, origin, angles)
	if !(Enabled:GetBool()) then return end
	if (pl:GetMoveType() == MOVETYPE_OBSERVER) then return end
	if pl == CurrentCameraPlayer then return end

	local view = {}
	local trace = {}
	local ShootPos = pl:GetShootPos()

	--angles = ThirdpersonAngles
	ThirdpersonAngles = ThirdpersonAngles + (pl:EyeAngles() - OldAngles)

	ThirdpersonAngles.p = math.Clamp(ThirdpersonAngles.p, -89, 89)
	local endPosDir = (angles:Forward() * Distance:GetInt()) + (angles:Right() * Offset:GetInt()) - (angles:Up() * Height:GetInt())

	--if (trace2.HitPos - LocalPlayer():GetShootPos()):Dot(trace2.HitPos - trace.HitPos) > 0 then
	--	local ang = (trace2.HitPos - ShootPos):Angle()
	--	pl:SetEyeAngles(ang)
	--	OldAngles = pl:EyeAngles()
	--else
	--	pl:SetEyeAngles(angles)
	--	OldAngles = angles
	--end

	local finalpos = origin - endPosDir
	local finalang = angles
	local finalfov = 90
	is_batting_old = is_batting
	is_batting = false
	if pl:Alive() then
		if pl:GetActiveWeapon():GetClass() == "baseball_bat" then
			if pl:GetPos():Distance(Vector(-4754.198730, -4755.620605, 64.031250)) < 500 then
				is_batting = true
				finalpos = batterCamPos + ((pl:GetPos() - Vector(-4650, -4650, 64)) * 0.025)
				finalang = batterCamAng
				finalfov = 60
			end
		end
	end

	if is_batting == true and is_batting_old == false then
		batting_start_time = CurTime()
	end
	if is_batting == false and is_batting_old == true then
		batting_start_time = CurTime()
	end

	local shake = origin - LocalPlayer():GetShootPos()

	local ratio = math.ease.InOutSine(math.min((CurTime() - batting_start_time), 1))

	local tp_pos = LerpVector(ratio, origin - endPosDir, batterCamPos + ((pl:GetPos() - Vector(-4650, -4650, 64)) * 0.025))
	local tp_ang = Angle(Lerp(ratio, angles.p, batterCamAng.p), Lerp(ratio, angles.y, batterCamAng.y), Lerp(ratio, angles.z, batterCamAng.z))
	local tp_fov = Lerp(ratio, 90, 60)
	if is_batting == false then
		tp_pos = LerpVector(ratio, batterCamPos + ((pl:GetPos() - Vector(-4650, -4650, 64)) * 0.025), origin - endPosDir)
		tp_ang = Angle(Lerp(ratio, batterCamAng.p, angles.p), Lerp(ratio, batterCamAng.y, angles.y), Lerp(ratio, batterCamAng.z, angles.z))
		tp_fov = Lerp(ratio, 60, 90)
	end

	view.origin = tp_pos + shake
	view.drawviewer = true
	view.angles = tp_ang
	view.fov = tp_fov
	view.znear = 48
	view.zfar = 20000

	return view
end

hook.Add("CalcView", "Thirdperson", Thirdperson)

local CurrentCameraPos = Vector(0,0,0)
local CurrentCameraAngles = Angle(0,0,0)
local CurrentCameraFov = 90
local CurrentFollowedPlayer = Player(5)
local CurrentCameraPlayer = Player(4)
local NextCameraSwitch = CurTime() + 8

hook.Remove("CalcView", "MyCalcView")

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

hook.Add( "InputMouseApply", "BaseballBatterLook", function( cmd, mx, my, ang )
	if LocalPlayer():Alive() then
		if LocalPlayer():GetActiveWeapon():GetClass() == "baseball_bat" then
			if LocalPlayer():GetPos():Distance(Vector(-4754.198730, -4755.620605, 64.031250)) < 500 then
				local wishmove = Vector(cmd:GetSideMove(), cmd:GetForwardMove(), 0)
				local diff = math.AngleDifference(cmd:GetViewAngles().y, batterCamAng.y)
				local rot = Angle(0, diff, 0)
				wishmove:Rotate(-rot * 0.5)
				--cmd:SetMouseX(-mx)
				--cmd:SetMouseY(my)
				cmd:SetViewAngles(ang + Angle(my * 0.022,mx * 0.022,0))
				return true
			end
		end
	end
end )

local color_green = Color( 100, 255, 100 )
local color_baseball = Color( 255, 255, 255 )

team.SetUp( 2, "Construct Comets", Color(0, 0, 255), true )
team.SetUp( 3, "The Big City Cadavers", Color(255, 0, 0), true )

local players = {}
players["76561198066173943"] = {"AtomicQuote", "VERY FAMILIAR", "Mr. Baseball"}
players["76561198182499237"] = {"Mak von flagrant", "NO FAMILIARITY", "Jimiy Funkworth"}
players["76561198149343349"] = {"DiceyJim", "SOMEWHAT FAMILIAR", "Raven"}
players["76561198025349919"] = {"Padabana", "VERY FAMILIAR", "Kirby Kazama"}
players["76561198149549808"] = {"TallestFella", "SOMEWHAT FAMILIAR", "Ichiro Suzuki"}
players["76561198065691229"] = {"HollyWolly3000", "SOMEWHAT FAMILIAR", "Penny and Bam"}
players["76561198022102650"] = {"pystal crepsi", "SOMEWHAT FAMILIAR", "That Lion on the Saitama Seibu Lions"}
players["76561198048107969"] = {"Lynn", "VERY FAMILIAR", "my older brothers wii sprts mii from wii ports"}
players["76561198131852665"] = {"CHAR", "SOMEWHAT FAMILIAR", "Tatsuo Shinada"}
players["76561198069431861"] = {"Karbi", "SOMEWHAT FAMILIAR", "Captain Sisko of the Deep Space Niners"}
players["76561198070719707"] = {"Captain Basebal", "NOT TOO FAMILIAR", "Staton Stibs"}
players["76561198063430606"] = {"Juice_bax", "SOMEWHAT FAMILIAR", "Kaneko Yuji"}
players["76561198151048243"] = {"Viony", "SOMEWHAT FAMILIAR", "Mike Trout"}
players["76561198126298181"] = {"qwat", "VERY FAMILIAR", "Buster Posey"}
players["76561198053866384"] = {"socksbx", "SOMEWHAT FAMILIAR", "MARIO"}
players["76561198073004130"] = {"gumdiseaseXOX", "VERY FAMILIAR", "Mario Kart 8 Deluxe Baby Park"}
players["76561198838541568"] = {"Bugsnax 5", "SOMEWHAT FAMILIAR", "Myself. (both real and fake)"}
players["76561198095682353"] = {"PayCreeps", "SOMEWHAT FAMILIAR", "Yamcha"}
players["76561198317984165"] = {"RioBlitzle", "NOT TOO FAMILIAR", "steven universe"}
players["76561198036907050"] = {"FIVEpoint9", "VERY FAMILIAR", "Rickey Henderson"}
players["76561198097868842"] = {"Ashe \"The goblin\" Goblin", "SOMEWHAT FAMILIAR", "Pitching Machine from Blaseball"}
players["76561198258784171"] = {"doctorbodacious", "SOMEWHAT FAMILIAR", "Ken Griffey Jr."}
players["76561198069796236"] = {"Lyn Masters", "SOMEWHAT FAMILIAR", "Gary"}
players["76561199135451771"] = {"CatgirlOblivion", "SOMEWHAT FAMILIAR", "Dr Kelf of the Wisconsin Wizards"}
players["76561198004153607"] = {"FIST GRAVEL", "SOMEWHAT FAMILIAR", "Pablo Sanchez from Backyard Baseball"}
players["76561198374100160"] = {"myers", "SOMEWHAT FAMILIAR", "randy johnson"}
players["76561198257155466"] = {"Buggle D. \"Mickey\" Boos", "NOT TOO FAMILIAR", "Sippy J. Paulson"}
players["76561198025661598"] = {"ausk", "NO FAMILIARITY", "Jackie the Bear"}
players["76561198884471782"] = {"The Slayer", "VERY FAMILIAR", "Landry Violence"}
players["76561198073546679"] = {"Mint", "the \"Baseball\" \"Player\"", "NOT TOO FAMILIAR", "Koo Dae-Sung"}
players["76561198035391240"] = {"Stinky Lizard", "SOMEWHAT FAMILIAR", "Sleve McDichael"}
players["76561198024774737"] = {"Azalea", "NOT TOO FAMILIAR", "Beef"}
players["76561198049743081"] = {"UberTheMets", "SOMEWHAT FAMILIAR", "Hyun-jin Ryu."}
players["76561198043654018"] = {"SKULLVOLVER", "VERY FAMILIAR", "#10 Chipper Jones"}
players["76561198151071386"] = {"Phillip Phillips", "SOMEWHAT FAMILIAR", "Dave Stieb"}
players["76561198154778735"] = {"Plums", "VERY FAMILIAR", "Fake"}
players["76561198881320571"] = {"RezzyInHya", "NOT TOO FAMILIAR", "Babe Ruth's psychokinetic ghost from the sandlot"}

hook.Add("HUDDrawTargetID", "DisableTargetID", function()
	return false
end)

hook.Add("HUDPaint", "CustomTeamNametag", function()
	local ply = LocalPlayer()
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
		local pos = trace.Entity:GetPos() + Vector(0, 0, 80)
		local screenPos = pos:ToScreen()

		local teamColor = team.GetColor(trace.Entity:Team()) -- Get team color
		local usenick = trace.Entity:Nick()
		if players[trace.Entity:SteamID64()] then
			usenick = players[trace.Entity:SteamID64()][1]
		end
		draw.SimpleTextOutlined(
			usenick,
			"DermaLarge",
			screenPos.x, screenPos.y - 20,
			teamColor, -- Use team color
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
			1,
			Color(0, 0, 0) -- Black outline
		)
	end
end)