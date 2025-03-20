
AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.MaxPitchTime = 1.25
SWEP.MaxPitchStrength = 7000


SWEP.PrintName	= "Psychic Hands"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.Spawnable		= false

if ( SERVER ) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

-- faster access to some math library functions
local abs   = math.abs
local Round = math.Round
local sqrt  = math.sqrt
local exp   = math.exp
local log   = math.log
local sin   = math.sin
local cos   = math.cos
local sinh  = math.sinh
local cosh  = math.cosh
local acos  = math.acos

local deg2rad = math.pi/180
local rad2deg = 180/math.pi

local delta = 0.0000001000000

Quaternion = {}
Quaternion.__index = Quaternion

function Quaternion.new(q,r,s,t)
	return setmetatable({q,r,s,t},Quaternion)
end
local quat_new = Quaternion.new

local function qmul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return quat_new(
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	)
end
Quaternion.__mul = qmul

--- Converts <ang> to a quaternion
function Quaternion.fromAngle(ang)
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

function Quaternion.__add(lhs, rhs)
	return quat_new( lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] )
end

function Quaternion.__sub(lhs, rhs)
	return quat_new( lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] )
end

function Quaternion.__mul(lhs, rhs)
	if type(rhs) == "number" then
		return quat_new( rhs * lhs[1], rhs * lhs[2], rhs * lhs[3], rhs * lhs[4] )
	elseif type(rhs) == "Vector" then
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs2, rhs3, rhs4 = rhs.x, rhs.y, rhs.z
		return quat_new(
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			 lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			 lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			 lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
		)
	else
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		return quat_new(
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
		)
	end
end

function Quaternion.__div(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	return quat_new(
		lhs1/rhs,
		lhs2/rhs,
		lhs3/rhs,
		lhs4/rhs
	)
end

function Quaternion:inv()
	local l = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	return quat_new( self[1]/l, -self[2]/l, -self[3]/l, -self[4]/l )
end

function Quaternion:rotationAngle()
	local l2 = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	if l2 == 0 then return 0 end
	local l = sqrt(l2)
	local ang = 2*acos(self[1]/l)*rad2deg  //this returns angle from 0 to 360
	if ang > 180 then ang = ang - 360 end  //make it -180 - 180
	return ang
end

--- Returns the axis of rotation
function Quaternion:rotationAxis()
	local m2 = self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	if m2 == 0 then return Vector( 0, 0, 1 ) end
	local m = sqrt(m2)
	return Vector( self[2] / m, self[3] / m, self[4] / m)
end

function Quaternion:__tostring()
	return string.format("<%01.4f,%01.4f,%01.4f,%01.4f>",self[1],self[2],self[3],self[4])
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "HoldEnt" )
	self:NetworkVar( "Angle", 0, "HoldEntAng" )
	self:NetworkVar( "Angle", 1, "EyeAngStart" )
	self:NetworkVar( "Bool", 0, "HoldingBaseball" )
	self:NetworkVar( "Bool", 1, "Pitching" )
	self:NetworkVar( "Bool", 2, "WasPitching" )
	self:NetworkVar( "Float", 0, "PitchStartTime" )
end

function SWEP:Initialize()
	self:SetHoldType( "none" )
end

function SWEP:Reload()

end

function SWEP:OnRemove()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		if not self:HoldingBall() then
			self:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
			self:GetHoldEnt().Holder = nil
		end
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
	end
end

function SWEP:HoldingBall()
	if not self:GetHoldEnt() then
		return false
	end
	if not self:GetHoldEnt():IsValid() then
		return false
	end
	return self:GetHoldEnt():GetClass() == "gmod_baseball"
end

function SWEP:Pitch(strength)
	self:GetOwner():SetUsingPsychicHands(false)
	self:SetHoldingBaseball(false)
	if SERVER then
		local phys = self:GetHoldEnt():GetPhysicsObject()
		if not self:HoldingBall() then
			phys:EnableGravity(true)
		end
		local power = (strength / (math.sqrt(phys:GetMass()))) + 100
		local powerMult = 0.5 + (self:GetOwner():GetArmsStat() * 0.08)
		power = power * powerMult
		if self:HoldingBall() then
			self:GetHoldEnt():SetPitcher(self:GetOwner())
			self:GetHoldEnt():SetThrowTime(CurTime())
			self:GetHoldEnt():SetThrowVector(self:GetOwner():EyeAngles():Forward())
			power = power + self:GetHoldEnt():GetLaggedVel()
			--if power > 6000 then
			--	redColor = math.Clamp(math.Remap(power, 6000, 7000, 255, 100), 0, 255)
			--end
			if self:GetHoldEnt().trail then
				self:GetHoldEnt().trail:Remove()
				self:GetHoldEnt().trail = nil
			end
			--self:GetHoldEnt().trail = util.SpriteTrail( self:GetHoldEnt(), 0, Color( 255, 255, 255 ), false, 5, 1, 0.5, 1 / ( 15 + 1 ) * 0.5, "trails/smoke" )
		end
		phys:SetVelocity(phys:GetVelocity() + (self:GetOwner():EyeAngles():Forward() * power) + Vector(0, 0, 0.02 * power))
	end
	self:GetHoldEnt().Holder = nil
	self:SetHoldEnt(nil)
	if self:GetOwner().oldWep then
		self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
		self:GetOwner().oldWep = nil
	end
end

function SWEP:PrimaryAttack()
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		self:SetPitching(true)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self:GetHoldEnt():IsValid() == false then
		self:GetOwner():SetMaxSpeed(75)
		local ballCatchTest = util.TraceHull({
			mins = Vector(-48, -48, -48),
			maxs = Vector(48, 48, 48),
			start = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 64),
			endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 72),
			filter = player.GetAll(),
			ignoreworld = true
		})
		--debugoverlay.SweptBox( self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 64), ballCatchTest.HitPos, Vector(-48, -48, -48), Vector(48, 48, 48), Angle(0,0,0), FrameTime(), Color( 255, 255, 255 ) )
		--debugoverlay.Box(ballCatchTest.HitPos, Vector(-48, -48, -48), Vector(48, 48, 48), FrameTime(), Color( 255, 255, 255, 50 ) )
		if ballCatchTest.Hit and ballCatchTest.Entity:GetClass() == "gmod_baseball" then
			if ballCatchTest.Entity:GetPitcher() == self:GetOwner() and ballCatchTest.Entity:GetThrowTime() + 0.25 > CurTime() then
				return
			end
			self:SetHoldEnt(ballCatchTest.Entity)
			self:SetHoldEntAng(ballCatchTest.Entity:GetAngles())
			self:SetEyeAngStart(self:GetOwner():EyeAngles())
			self:GetHoldEnt():GetPhysicsObject():EnableMotion(true)
			self:GetHoldEnt():GetPhysicsObject():EnableGravity(false)
			self:GetHoldEnt().Holder = self:GetOwner()
			self:GetHoldEnt():SetCollisionGroup(COLLISION_GROUP_WEAPON)
			self:GetHoldEnt():SetPitcher(nil)
			self:GetHoldEnt():SetThrowTime(-1)
			self:GetOwner():SetUsingPsychicHands(true)
		end
	end
end

hook.Add( "StartCommand", "CatchingSlow", function( pl, cmd )

	if cmd:KeyDown(IN_ATTACK2) then
		cmd:AddKey(IN_WALK)
	end

end )

function SWEP:GrabOverride()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		if not self:HoldingBall() then
			self:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
		end
		self:GetHoldEnt():SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetHoldEnt(nil)
		self:GetHoldEnt().Holder = nil
		print(self:GetOwner().oldWep)
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
		self:GetOwner():SetUsingPsychicHands(false)
		self:SetHoldingBaseball(false)
		return
	end
	local pickprop = util.TraceLine({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 128),
		filter = player.GetAll(),
		ignoreworld = true
	})
	if pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() then
		self:SetHoldEnt(pickprop.Entity)
		self:SetHoldEntAng(pickprop.Entity:GetAngles())
		self:SetEyeAngStart(self:GetOwner():EyeAngles())
		self:GetHoldEnt():GetPhysicsObject():EnableMotion(true)
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(false)
		self:GetHoldEnt():SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if self:GetHoldEnt():GetClass() == "gmod_baseball" then
			self:GetHoldEnt():SetPitcher(nil)
			self:GetHoldEnt():SetThrowTime(-1)
		end
		self:GetOwner():SetUsingPsychicHands(true)
		self:EmitSound("physics/rubber/rubber_tire_impact_soft3.wav",80,math.random(95,105), 1)
		return true
	end
	pickprop = util.TraceHull({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 96),
		filter = player.GetAll(),
		mins = Vector(-16, -16, -16),
		maxs = Vector(16, 16, 16),
		ignoreworld = true
	})
	if pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() then
		self:SetHoldEnt(pickprop.Entity)
		self:SetHoldEntAng(pickprop.Entity:GetAngles())
		self:SetEyeAngStart(self:GetOwner():EyeAngles())
		self:GetHoldEnt():GetPhysicsObject():EnableMotion(true)
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(false)
		self:GetHoldEnt().Holder = self:GetOwner()
		self:GetHoldEnt():SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if self:GetHoldEnt():GetClass() == "gmod_baseball" then
			self:GetHoldEnt():SetPitcher(nil)
			self:GetHoldEnt():SetThrowTime(-1)
		end
		self:GetOwner():SetUsingPsychicHands(true)
		return true
	end
	return false
end

if SERVER then

	hook.Add("AllowPlayerPickup", "PsychicHandsAllowPickup", function(pl, ent)
		if pl:HasWeapon("psychichands") then
			return false
		end
	end)
	hook.Add("KeyPress", "PsychicHandsPickupOverride", function( pl, key )
		if pl:Alive() and pl:HasWeapon("psychichands") and not pl:GetUsingPhysgun() then
			if key == IN_USE then
				if not pl.oldWep then
					pl.oldWep = pl:GetActiveWeapon():GetClass()
				end
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 128),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local pickprop2 = util.TraceHull({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 96),
					filter = player.GetAll(),
					mins = Vector(-16, -16, -16),
					maxs = Vector(16, 16, 16),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() or pickprop2.Hit and pickprop2.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					pl:SelectWeapon("psychichands")
					if pl:GetActiveWeapon():GetClass() == "psychichands" then
						pl:GetActiveWeapon():GrabOverride()
					end
				end
			end
			if key == IN_GRENADE1 then
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 256),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					local hands = pl:GetWeapon("psychichands")
					if hands.weldtarget1 then
						constraint.Weld( hands.weldtarget1, pickprop.Entity, 0, 0, 0, true, false )
						hands.weldtarget1 = nil
					else
						hands.weldtarget1 = pickprop.Entity
					end
				end
			end
			if key == IN_GRENADE2 then
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 256),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					constraint.RemoveAll(pickprop.Entity)
				end
			end
		end
	end )
end


function SWEP:Tick()
	if CLIENT then return end
	local cmd = self.Owner:GetCurrentCommand()
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		self:SetHoldingBaseball(false)
		if self:GetPitching() and self:GetWasPitching() == false then
			print("Pitch started")
			self:SetPitchStartTime(CurTime())
		end
		if self:GetPitching() == false and self:GetWasPitching() then
			local pitchTime = math.min(CurTime() - self:GetPitchStartTime(), self.MaxPitchTime)
			pitchTime = pitchTime / self.MaxPitchTime
			local pitchStrength = Lerp(pitchTime, 0, self.MaxPitchStrength)
			print("Pitch ended")
			print("Pitch time: " .. pitchTime)
			if SERVER then
				self:Pitch(pitchStrength)
			end
			return
		end
		if SERVER then
			local realViewAngle = self:GetOwner():EyeAngles()
			if self:GetHoldEnt():GetModel() == "models/weapons/w_models/w_baseball.mdl" then
				self:SetHoldingBaseball(true)
			else
				realViewAngle = batterCamAng
			end
			if self:GetHoldEnt().DontFuckingMove then
				return
			end
			self:GetHoldEnt().Holder = self:GetOwner()
			local phys = self:GetHoldEnt():GetPhysicsObject()
			local startPos = self:GetHoldEnt():LocalToWorld(phys:GetMassCenter() - Vector(0, 0, 76))
			if self:GetHoldingBaseball() then
				startPos = self:GetHoldEnt():LocalToWorld(phys:GetMassCenter())
			end
			local holdDist = math.max(24 + (self:GetHoldEnt():BoundingRadius() * 1.2), 48)
			local noPitchAimVector = self:GetOwner():EyeAngles()
			noPitchAimVector.p = 0
			noPitchAimVector = noPitchAimVector:Forward()
			noPitchAimVector.z = 0
			noPitchAimVector:Normalize()
			--print(noPitchAimVector)
			local targetPos = self:GetOwner():GetShootPos() + (noPitchAimVector * holdDist) + Vector(0, 0, -self:GetOwner():EyeAngles().p * 1.5)
			local swingPowerMult = 0.7 + (self:GetOwner():GetArmsStat() * 0.05)
			local newVel = (targetPos - startPos) * FrameTime() * 2200 * swingPowerMult
			phys:SetVelocity(newVel)
			local trueHoldEntAng = self:GetHoldEntAng()
			if cmd:KeyDown( IN_RELOAD ) then
				trueHoldEntAng:RotateAroundAxis(Vector(0, 0, 1), cmd:GetMouseX() * -0.05)
				trueHoldEntAng:RotateAroundAxis(realViewAngle:Right(), cmd:GetMouseY() * 0.05)
			end
			local eyeAngDiff = self:GetOwner():EyeAngles() - self:GetEyeAngStart()
			self:SetEyeAngStart(self:GetOwner():EyeAngles())
			trueHoldEntAng:RotateAroundAxis(Vector(0, 0, 1), eyeAngDiff.y)
			trueHoldEntAng:RotateAroundAxis(self:GetOwner():EyeAngles():Right(), -eyeAngDiff.p * 0.25)
			self:SetHoldEntAng(trueHoldEntAng)
			local ang1 = Quaternion.fromAngle(phys:GetAngles())
			local ang2 = Quaternion.fromAngle(trueHoldEntAng)
			local diff = ang1:inv() * ang2
			local axis = diff:rotationAxis()
			local power = diff:rotationAngle()
			local desAngleVel = (axis * power * FrameTime()) * 1600 * swingPowerMult
			phys:AddAngleVelocity(-phys:GetAngleVelocity() + desAngleVel)
		end
	end
	self:SetWasPitching(self:GetPitching())
	self:SetPitching(false)
end

function SWEP:TranslateFOV( current_fov )
end

function SWEP:Deploy()
end

function SWEP:Equip()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:DoShootEffect()
end

hook.Add("PlayerSwitchWeapon", "PsychicHandsHook", function(pl, oldWeapon, newWeapon)
	if CLIENT then return end
	if oldWeapon and oldWeapon:IsValid() and oldWeapon:GetClass() == "psychichands" then
		if oldWeapon:GetHoldEnt() and oldWeapon:GetHoldEnt():IsValid() then
			if not self:HoldingBall() then
				oldWeapon:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
				oldWeapon:GetHoldEnt().Holder = nil
			end
			oldWeapon:SetHoldEnt(nil)
			return
		end
	end
end)


if ( SERVER ) then return end -- Only clientside lua after this line

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_camera" )

-- Don't draw the weapon info on the weapon selection thing
function SWEP:DrawHUD()

	local pitchTime = math.min(CurTime() - self:GetPitchStartTime(), self.MaxPitchTime)
	pitchTime = pitchTime / self.MaxPitchTime
	local pitchStrength = Lerp(pitchTime, 0, self.MaxPitchStrength) / 30
	local momentumStorage = 0
	if self:GetHoldingBaseball() and self:GetHoldEnt():IsValid() and self:GetHoldEnt():GetClass() == "gmod_baseball" then
		momentumStorage = self:GetHoldEnt():GetLaggedVel() / 5
	end

    surface.SetDrawColor(0,0,0,150)
    surface.DrawRect((ScrW() * 0.5) - self.MaxPitchStrength / 30, 25, self.MaxPitchStrength * 2 / 30, 50)
    if self:GetPitching() then
    	surface.SetDrawColor(255,255,255,255)
    	surface.DrawRect((ScrW() * 0.5) - (self.MaxPitchStrength / 30), 25, pitchStrength * 2, 50)
    	surface.SetDrawColor(255,0,0,255)
    	surface.DrawRect(((ScrW() * 0.5) - (self.MaxPitchStrength / 30)) + pitchStrength * 2, 25, momentumStorage, 50)
    else
	   surface.SetDrawColor(255,0,0,255)
	   surface.DrawRect((ScrW() * 0.5) - (self.MaxPitchStrength / 30), 25, momentumStorage, 50)
	end

end
function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:FreezeMovement()

	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_RELOAD ) || self.Owner:KeyReleased( IN_RELOAD ) ) then
		return true
	end

	return false

end