--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

-----------------------------------------------------------]]

-- These files get sent to the client

AddCSLuaFile( "cl_hints.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_notice.lua" )
AddCSLuaFile( "cl_search_models.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_worldtips.lua" )
AddCSLuaFile( "persistence.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "save_load.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "gui/IconEditor.lua" )
AddCSLuaFile( "bb_hud.lua" )

include( 'shared.lua' )
include( 'commands.lua' )
include( 'player.lua' )
include( 'spawnmenu/init.lua' )

util.AddNetworkString( "ShowStatMenu" )
util.AddNetworkString( "RequestStatChange" )
util.AddNetworkString( "StrikePos" )
util.AddNetworkString( "ClientBatHit" )

resource.AddFile( "materials/baseball.png" )
resource.AddFile( "materials/beautifulstar.png" )
resource.AddFile( "materials/constructcomets.png" )
resource.AddFile( "materials/flatgrassfriends.png" )
resource.AddFile( "materials/staminaempty.png" )
resource.AddFile( "materials/staminafull.png" )

resource.AddFile( "materials/baseball/baseui_back.png" )
resource.AddFile( "materials/baseball/baseui_baseempty.png" )
resource.AddFile( "materials/baseball/baseui_basefull.png" )
resource.AddFile( "materials/baseball/baseui_bso.png" )
resource.AddFile( "materials/baseball/baseui_inningbot.png" )
resource.AddFile( "materials/baseball/baseui_inningtop.png" )
resource.AddFile( "materials/baseball/baseui_logoflair.png" )
resource.AddFile( "materials/baseball/baseui_sectionback.png" )
resource.AddFile( "materials/baseball/baseui_title.png" )

resource.AddFile( "materials/baseball/statui_empty.png" )
resource.AddFile( "materials/baseball/statui_full.png" )
resource.AddFile( "materials/baseball/statui_points.png" )
resource.AddFile( "materials/baseball/statui_arms.png" )
resource.AddFile( "materials/baseball/statui_legs.png" )
resource.AddFile( "materials/baseball/statui_body.png" )
resource.AddFile( "materials/baseball/statui_spirit.png" )
resource.AddFile( "materials/baseball/statui_stamina.png" )
resource.AddFile( "materials/baseball/statui_unspent.png" )

--resource.AddWorkshop( "882463775" )
--resource.AddFile( "materials/indicator.png" )

net.Receive("RequestStatChange", function(len, pl)

	local Stat = net.ReadInt(4)
	local TypeOfChange = net.ReadBool()
	if TypeOfChange == true and pl:GetStatPoints() <= 0 then return end
	if TypeOfChange == false then
		if Stat == 1 then
			if pl:GetArmsStat() <= 0 then
				return
			end
			pl:SetStatPoints(pl:GetStatPoints() + 1)
			pl:SetArmsStat(pl:GetArmsStat() - 1)
		end
		if Stat == 2 then
			if pl:GetLegsStat() <= 0 then
				return
			end
			pl:SetStatPoints(pl:GetStatPoints() + 1)
			pl:SetLegsStat(pl:GetLegsStat() - 1)
		end
		if Stat == 3 then
			if pl:GetBodyStat() <= 0 then
				return
			end
			pl:SetStatPoints(pl:GetStatPoints() + 1)
			pl:SetBodyStat(pl:GetBodyStat() - 1)
		end
		if Stat == 4 then
			if pl:GetHeartStat() <= 0 then
				return
			end
			pl:SetStatPoints(pl:GetStatPoints() + 1)
			pl:SetHeartStat(pl:GetHeartStat() - 1)
		end
		return
	end

	if Stat == 1 then
		if pl:GetArmsStat() >= 8 then
			return
		end
		pl:SetStatPoints(pl:GetStatPoints() - 1)
		pl:SetArmsStat(pl:GetArmsStat() + 1)
	end
	if Stat == 2 then
		if pl:GetLegsStat() >= 8 then
			return
		end
		pl:SetStatPoints(pl:GetStatPoints() - 1)
		pl:SetLegsStat(pl:GetLegsStat() + 1)
	end
	if Stat == 3 then
		if pl:GetBodyStat() >= 8 then
			return
		end
		pl:SetStatPoints(pl:GetStatPoints() - 1)
		pl:SetBodyStat(pl:GetBodyStat() + 1)
	end
	if Stat == 4 then
		if pl:GetHeartStat() >= 8 then
			return
		end
		pl:SetStatPoints(pl:GetStatPoints() - 1)
		pl:SetHeartStat(pl:GetHeartStat() + 1)
	end
end)

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )

--[[---------------------------------------------------------
	Name: gamemode:PlayerSpawn()
	Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl, transiton )

	player_manager.SetPlayerClass( pl, "player_sandbox" )

	BaseClass.PlayerSpawn( self, pl, transiton )
	pl:SetUsingPhysgun(false)
	pl:SetUsingPsychicHands(false)
	pl:SetCustomCollisionCheck(true)

	if not pl.InitialSpawn then
		pl:SetLegsStat(0)
		pl:SetArmsStat(0)
		pl:SetBodyStat(0)
		pl:SetHeartStat(0)
		pl:SetStatPoints(10)
		pl:SetStamina(100)
		pl:SetMaxStamina(100)
		pl:SetMaxStaminaPercent(1)
		pl.InitialSpawn = true
		print("Initial Spawn For" .. pl:Nick())
	end

end

local AutoPitchConstant = CreateConVar( "bb_autopitch", "0", FCVAR_NONE, "When enabled, the autopitcher will run constantly.", 0, 1 )
local lastAutoPitch = CurTime()
hook.Add("Tick", "Autopitch", function()

	if AutoPitchConstant:GetInt() == 1 and CurTime() > lastAutoPitch then
		lastAutoPitch = CurTime() + 4
		TestPitch()
	end

end)

function GM:InitPostEntity()
	SetGlobalBool( "firstbase", false )
	SetGlobalBool( "secondbase", false )
	SetGlobalBool( "thirdbase", false )
	SetGlobalBool( "inningside", false )
	SetGlobalInt( "inning", 1 )
	SetGlobalInt( "balls", 0 )
	SetGlobalInt( "strikes", 0 )
	SetGlobalInt( "outs", 0 )
	SetGlobalInt( "fouls", 0 )
	SetGlobalInt( "redscore", 0 )
	SetGlobalInt( "bluescore", 0 )
	local baseballOrigin = ents.Create("prop_dynamic")
	baseballOrigin:SetModel("models/Gibs/HGIBS.mdl")
	baseballOrigin:SetPos(Vector(-7000, -7000, 320))
	baseballOrigin:Spawn()
	RunConsoleCommand("sv_gravity", "800")
	RunConsoleCommand("sv_accelerate", "0.00001")
	RunConsoleCommand("sv_friction", "3")
	RunConsoleCommand("sv_stopspeed", "40")
	RunConsoleCommand("sv_airaccelerate", "0")
end

concommand.Add( "addstatpoint", function(pl, cmd, args)

	for i, v in ipairs(player.GetAll()) do
		v:SetStatPoints(v:GetStatPoints() + 5)
		v:PrintMessage(HUD_PRINTCENTER, "You've been rewarded 5 additional stat points!")
	end

end)

concommand.Add( "toggleautopitch", function(pl, cmd, args)

	local auto_pitch_status = AutoPitchConstant:GetBool()
	print("Toggling autopitch.")
	if auto_pitch_status then
		AutoPitchConstant:SetBool(false)
	else
		AutoPitchConstant:SetBool(true)
	end

end)

concommand.Add( "setbaseballvar", function( pl, cmd, args )
	print(args[1], args[2])
	if args[1] == "firstbase" then
		SetGlobalBool("firstbase", tobool(args[2]))
		return
	end
	if args[1] == "secondbase" then
		SetGlobalBool("secondbase", tobool(args[2]))
		return
	end
	if args[1] == "thirdbase" then
		SetGlobalBool("thirdbase", tobool(args[2]))
		return
	end
	if args[1] == "inningside" then
		SetGlobalBool("inningside", tobool(args[2]))
		return
	end
	if args[1] == "inning" then
		SetGlobalInt("inning", tonumber(args[2]))
		return
	end
	if args[1] == "balls" then
		SetGlobalInt("balls", tonumber(args[2]))
		return
	end
	if args[1] == "strikes" then
		SetGlobalInt("strikes", tonumber(args[2]))
		return
	end
	if args[1] == "fouls" then
		SetGlobalInt("fouls", tonumber(args[2]))
		return
	end
	if args[1] == "outs" then
		SetGlobalInt("outs", tonumber(args[2]))
		return
	end
	if args[1] == "redscore" then
		SetGlobalInt("redscore", tonumber(args[2]))
		return
	end
	if args[1] == "bluescore" then
		SetGlobalInt("bluescore", tonumber(args[2]))
		return
	end
	pl:ChatPrint("Go fuck yourself.")
end )

print("ahh")

concommand.Add( "incrementbaseballvar", function( pl, cmd, args )
	if args[1] == "firstbase" then
		SetGlobalBool("firstbase", !GetGlobalBool("firstbase"))
		return
	end
	if args[1] == "secondbase" then
		SetGlobalBool("secondbase", !GetGlobalBool("secondbase"))
		return
	end
	if args[1] == "thirdbase" then
		SetGlobalBool("thirdbase", !GetGlobalBool("thirdbase"))
		return
	end
	if args[1] == "inningside" then
		if GetGlobalBool("inningside") == true then
			SetGlobalInt("inning", GetGlobalInt("inning") + 1)
		end
		SetGlobalBool("inningside", !GetGlobalBool("inningside"))
		return
	end
	if args[1] == "inning" then
		SetGlobalInt("inning", GetGlobalInt("inning") + tonumber(args[2]))
		return
	end
	if args[1] == "balls" then
		SetGlobalInt("balls", (GetGlobalInt("balls") + tonumber(args[2])) % 4)
		return
	end
	if args[1] == "strikes" then
		SetGlobalInt("strikes", (GetGlobalInt("strikes") + tonumber(args[2])) % 3)
		return
	end
	if args[1] == "fouls" then
		SetGlobalInt("fouls", GetGlobalInt("fouls") + tonumber(args[2]))
		return
	end
	if args[1] == "outs" then
		SetGlobalInt("outs", (GetGlobalInt("outs") + tonumber(args[2])) % 3)
		return
	end
	if args[1] == "redscore" then
		SetGlobalInt("redscore", GetGlobalInt("redscore") + tonumber(args[2]))
		return
	end
	if args[1] == "bluescore" then
		SetGlobalInt("bluescore", GetGlobalInt("bluescore") + tonumber(args[2]))
		return
	end
	pl:ChatPrint("Go fuck yourself.")
end )

--[[---------------------------------------------------------
	Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
	Desc: The physgun wants to freeze a prop
-----------------------------------------------------------]]
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )

	-- Don't freeze persistent props (should already be frozen)
	if ( ent:GetPersistent() && GetConVarString( "sbox_persist" ):Trim() != "" ) then return false end

	BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )

	ply:SendHint( "PhysgunUnfreeze", 0.3 )
	ply:SuppressHint( "PhysgunFreeze" )
	Timer.Simple(0.5, function()
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)

end

--[[---------------------------------------------------------
	Name: gamemode:OnPhysgunReload( weapon, player )
	Desc: The physgun wants to unfreeze
-----------------------------------------------------------]]
function GM:OnPhysgunReload( weapon, ply )

	local num = ply:PhysgunUnfreeze()

	if ( num > 0 ) then
		ply:SendLua( "GAMEMODE:UnfrozeObjects(" .. num .. ")" )
	end

	ply:SuppressHint( "PhysgunUnfreeze" )

end

function GM:OnPhysgunPickup(pl, ent)

	pl:SetUsingPhysgun(true)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)

end

function GM:PhysgunDrop(pl, ent)

	pl:SetUsingPhysgun(false)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	

end
--[[---------------------------------------------------------
	Name: gamemode:PlayerShouldTakeDamage
	Return true if this player should take damage from this attacker
	Note: This is a shared function - the client will think they can
		damage the players even though they can't. This just means the
		prediction will show blood.
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )

	-- Global godmode, players can't be damaged in any way
	if ( cvars.Bool( "sbox_godmode", false ) ) then return false end

	-- No player vs player damage
	if ( attacker:IsValid() && attacker:IsPlayer() && ply != attacker ) then
		return cvars.Bool( "sbox_playershurtplayers", true )
	end

	-- Default, let the player be hurt
	return true

end

--[[---------------------------------------------------------
	Show the search when f1 is pressed
-----------------------------------------------------------]]
function GM:ShowHelp( ply )

	ply:SendLua( "hook.Run( 'StartSearch' )" )

end

--[[---------------------------------------------------------
	Called once on the player's first spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply, transiton )

	BaseClass.PlayerInitialSpawn( self, ply, transiton )

end


hook.Add("ShowSpare1", "StatMenu", function(pl)

	net.Start("ShowStatMenu")
	net.Send(pl)

end)

--[[---------------------------------------------------------
	A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )

	-- Replace the entity with the ragdoll in cleanups etc
	undo.ReplaceEntity( entity, ragdoll )
	cleanup.ReplaceEntity( entity, ragdoll )

end

--[[---------------------------------------------------------
	Player unfroze an object
-----------------------------------------------------------]]
function GM:PlayerUnfrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
	effectdata:SetOrigin( physobject:GetPos() )
	effectdata:SetEntity( entity )
	util.Effect( "phys_unfreeze", effectdata, true, true )

end

--[[---------------------------------------------------------
	Player froze an object
-----------------------------------------------------------]]
function GM:PlayerFrozeObject( ply, entity, physobject )

	if ( DisablePropCreateEffect ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( physobject:GetPos() )
	effectdata:SetEntity( entity )
	util.Effect( "phys_freeze", effectdata, true, true )

end

--
-- Who can edit variables?
-- If you're writing prop protection or something, you'll
-- probably want to hook or override this function.
--
function TestPitch()
	local ball = ents.Create("gmod_baseball")
	ball:SetPos(Vector(-3000,-3000,500))
	ball:Spawn()
	game.SetTimeScale(1)
	timer.Simple(1, function()
		if ball.trail then
			ball.trail:Remove()
			ball.trail = nil
		end
		--ball.trail = util.SpriteTrail( ball, 0, Color( 255, 255, 255 ), false, 5, 1, 0.5, 1 / ( 15 + 1 ) * 0.5, "trails/smoke" )
		local phys = ball:GetPhysicsObject()
		phys:EnableGravity(false)
		local power = (math.random(6000,10000) / (math.sqrt(phys:GetMass()))) + 100

		local angRand1 = (math.random() * 3) - 2
		local angRand2 = (math.random() * 3) - 1.5
		phys:SetVelocity((Angle(0 + angRand1, -135 + angRand2, 0):Forward() * power) + Vector(0, 0, 800000 / power))
	end)
end

function GM:PlayerSpawnedProp(pl, model, ent)
	ent:GetPhysicsObject():SetMaterial("default_silent")
end

function GM:CanEditVariable( ent, ply, key, val, editor )

	-- Only allow admins to edit admin only variables!
	local isAdmin = ply:IsAdmin() || game.SinglePlayer()
	if ( editor.AdminOnly && !isAdmin ) then
		return false
	end

	-- This entity decides who can edit its variables
	if ( isfunction( ent.CanEditVariables ) ) then
		return ent:CanEditVariables( ply )
	end

	-- default in sandbox is.. anyone can edit anything.
	return true

end

function GM:Tick()
end