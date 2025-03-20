
AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.PrintName = "Baseball"
ENT.Editable = true

BASEBALL_HITMULT = 1.25

physenv.AddSurfaceData([["gmod_baseball"
{
	"base"		"rubber"

	"bulletimpact"	"Weapon_Baseball.HitWorld"
	"scraperough"	"Grenade.ScrapeRough"
	"scrapesmooth"	"Grenade.ScrapeSmooth"
	"impacthard"	"Weapon_Baseball.HitWorld"
	"impactsoft"	"Weapon_Baseball.HitWorld"
	"rolling"	"Grenade.Roll"
	"friction"	"0"
	"dampening"	"0"
	"elasticity"	"10000"
	"density"	"10000"
}]])

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Pitcher" )
	self:NetworkVar( "Float", 0, "ThrowTime" )
	self:NetworkVar( "Float", 1, "LaggedVel" )
	self:NetworkVar( "Float", 2, "LastHitStrength" )
	self:NetworkVar( "Vector", 0, "ThrowVector" )
	self:NetworkVar( "Vector", 1, "TrueAngleVel" )
	self:NetworkVar( "Vector", 2, "OldPos" )
	self:NetworkVar( "Vector", 3, "OldVel" )
	self:NetworkVar( "Vector", 4, "LowestVelocityPostSwing" )
	self:NetworkVar( "Angle", 0, "LastHitDir" )
	self:NetworkVar( "Bool", 0, "PastStrikeZone" )
	self:NetworkVar( "Bool", 1, "WasPastStrikeZone" )
end

local ball_matrix = Matrix()
ball_matrix:SetScale(Vector(2.5, 2.5, 2.5))

function ENT:Initialize()
	self:SetModel("models/weapons/w_models/w_baseball.mdl", "gmod_baseball")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:Activate()
	self:PhysicsInitSphere(10)

	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then

		phys:SetMass( 10 )
		--phys:Wake()
		phys:EnableGravity( false )

	end
	self.phys = self:GetPhysicsObject()
	self:SetCustomCollisionCheck( true )
	self.beenHit = false
	self.lastHitTime = 0
	self.lastHitVel = Vector(0,0,0)
	self.lastHitPos = Vector(0,0,0)
	self.batEnt = nil
	self.batEntPhys = nil
	self.lastHitVelBat = Vector(0,0,0)
	self.lastHitPosBat = Vector(0,0,0)
	self.lastHitAngBat = Angle(0,0,0)
	self.lastDot = 0
	self.createTime = CurTime()
	local efdata = EffectData()
	efdata:SetOrigin(self:GetPos())
	efdata:SetEntity(self)
	util.Effect("baseball_trail",efdata)

	if SERVER then
		self:UpdateTransmitState(TRANSMIT_ALWAYS)
		local balls = ents.FindByClass("gmod_baseball")
		if #balls > 5 then
			local earliest = balls[1].createTime
			local toDelete = 1
			for i, v in ipairs(ents.FindByClass("gmod_baseball")) do
				if i == 1 then continue end
				if v.createTime < earliest then
					earliest = v.createTime
					toDelete = i
				end
			end
			balls[toDelete]:Remove()
		end
	else
		self:SetRenderBounds(Vector(-1, -1, -1), Vector(1, 1, 1), Vector(32, 32, 500))
		self:EnableMatrix("RenderMultiply", ball_matrix)
	end
end

function ENT:OnRemove()
end

function ENT:HitByBat(ball_vel, hit_point, normal, vel_at_point, hitter)
	if CLIENT then return end
	self.Holder = nil
	for i, v in ipairs(player.GetAll()) do
		if v:GetActiveWeapon() and v:GetActiveWeapon():IsValid() and v:GetActiveWeapon():GetClass() == "psychichands" and v:GetUsingPsychicHands() and v:GetActiveWeapon():GetHoldEnt() == self then
			v:SetUsingPsychicHands(false)
			v:GetActiveWeapon():SetHoldingBaseball(false)
			v:GetActiveWeapon():SetHoldEnt(nil)
		end
	end
	print("HIT BY BAT!")
	self:SetPitcher(nil)
	self:SetThrowTime(-1)
	self:SetPos(hit_point)
	local phys = self:GetPhysicsObject()

	local impactVel = ball_vel * 0.20 - vel_at_point * 0.9

	local dot = impactVel:Dot(normal)

	if hitter then
		local HeartMult = math.Remap(hitter:GetHeartStat(), 0, 8, 1, 1.2)
	
		local RandomMultiplier = math.Rand(1, HeartMult)
	
		dot = dot * RandomMultiplier
	end
	phys:SetVelocity(Vector(0,0,0))
	if self.beenHit == false then
		newNormal = normal
		debugoverlay.Cross(hit_point, 4, 1, Color(255,255,255), true)
		debugoverlay.Line(hit_point, hit_point + (newNormal * 256), 1, Color(255,0,0), true)
		newNormal.z = (newNormal.z * 0.6) + 0.1
		newNormal:Normalize()
		debugoverlay.Line(hit_point, hit_point + (newNormal * 256), 1, Color(0,255,0), true)
		dot = impactVel:Dot(newNormal)
		dot = math.abs(dot) * BASEBALL_HITMULT

		local HeartMult = math.Remap(hitter:GetHeartStat(), 0, 8, 0.0, 1.0)
		local RandomMultiplier = math.Rand(0.2, HeartMult)
		local FlatNormal = Vector(newNormal.x, newNormal.y, 0):GetNormalized()
		local ImprovedNormal = Vector(FlatNormal.x, FlatNormal.y, 0.5):GetNormalized()
		newNormal = LerpVector(RandomMultiplier, newNormal, ImprovedNormal):GetNormalized()
		--print("SPIRIT ANGLE MULT")
		--print(RandomMultiplier)


		if hitter then
			local HeartMult = math.Remap(hitter:GetHeartStat(), 0, 8, 0, 1500)
		
			local RandomMultiplier = math.Rand(0, HeartMult)
			
			print(dot .. " + " .. RandomMultiplier)
			dot = dot + RandomMultiplier
		end
		for i, v in ipairs(player.GetAll()) do
			v:ChatPrint("Batting Power: " .. math.floor(dot))
		end

		--print(impactvel)
		--print(dot)
		--local direct = math.pow(math.abs(ball_vel:GetNormalized():Dot(newNormal)), 3)
		--print(direct)		


		if dot > 5300 then
			self:EmitSound("player/crit_hit" .. math.random(2,5) .. ".wav",110,math.random(70,90), 1)
		elseif dot > 4500 then
			self:EmitSound("player/crit_hit_mini" .. math.random(2,5) .. ".wav",110,math.random(70,90), 1)
		end
		if dot > 3200 then
			local efdata = EffectData()
			efdata:SetOrigin(hit_point)
			efdata:SetRadius(25)
			efdata:SetNormal(-normal)
			util.Effect("cball_bounce",efdata)
			local efdata2 = EffectData()
			efdata:SetMagnitude(2)
			efdata:SetRadius(2)
			efdata:SetScale(2)
			util.Effect("Sparks",efdata2)
			self:EmitSound("physics/wood/wood_plank_impact_hard5.wav",80,math.random(95,105), 0.5)
		elseif dot > 1200 then
			local efdata = EffectData()
			efdata:SetOrigin(hit_point)
			efdata:SetMagnitude(2)
			efdata:SetRadius(0.1)
			efdata:SetScale(2)
			efdata:SetNormal(-normal)
			util.Effect("ElectricSpark",efdata)
			self:EmitSound("physics/wood/wood_plank_impact_hard3.wav",80,math.random(95,105), 0.5)
			self:EmitSound("physics/rubber/rubber_tire_impact_hard" .. math.random(1,3) .. ".wav",80,math.random(95,105), 1)
		elseif dot > 400 then
			local efdata = EffectData()
			efdata:SetOrigin(hit_point)
			efdata:SetMagnitude(2)
			efdata:SetRadius(0.1)
			efdata:SetScale(2)
			efdata:SetNormal(-normal)
			util.Effect("ElectricSpark",efdata)
			self:EmitSound("physics/wood/wood_plank_impact_hard3.wav",80,math.random(95,105), 0.5)
			self:EmitSound("npc/antlion/shell_impact4.wav",80,math.random(95,105), 1)
		elseif dot > 200 then
			self:EmitSound("physics/rubber/rubber_tire_impact_soft" .. math.random(1,3) .. ".wav",80,math.random(95,105), 1)
		end
		newVel = (newNormal * dot) / 1.5
		if newVel:Length() > 3300 then
			local efdata = EffectData()
			efdata:SetOrigin(self:GetPos())
			efdata:SetRadius(25)
			util.Effect("Explosion",efdata)
			self:EmitSound("ambient/explosions/exp" .. math.random(1, 4) .. ".wav",130,math.random(95,105), 1)
		end
		local hitPause = math.Clamp(math.Remap(dot, 3000, 5000, 0.02, 0.2), 0.02, 0.2)
		--print(hitPause)
		self.lastHitTime = CurTime() + hitPause
		util.ScreenShake( self:GetPos(), dot * 0.002, 60, hitPause * 2, 10000 )
		self.lastDot = dot
		self.lastHitVel = newVel
		self.lastHitPos = phys:GetPos()
		--self.batEntPhys = hitEnt:GetPhysicsObject()
		--self.batEnt = hitEnt
		--self.batEnt.DontFuckingMove = true
		--self.lastHitVelBat = self.batEntPhys:GetVelocity()
		--self.lastHitPosBat = self.batEntPhys:GetPos()
		--self.lastHitAngBat = self.batEntPhys:GetAngles()
		self.beenHit = true
		self:SetLastHitStrength(dot)
		self:SetLastHitDir(newNormal:Angle())
		timer.Simple(0.01, function()
			game.SetTimeScale( 0.25 )
		end)
		--print("case 2")
		return
	end
	--print("case 3")
end

if SERVER then
	net.Receive("ClientBatHit", function(len, pl)
		print("GOT HIT FROM CLIENT!")
		local ball_vel = net.ReadVector()
		local hit_point = net.ReadVector()
		local normal = net.ReadVector()
		local vel_at_point = net.ReadVector()
		local ball = net.ReadEntity()
		print(hit_point)
		print(normal)
		print(vel_at_point:Length())
		ball:HitByBat(ball_vel, hit_point, normal, vel_at_point, pl)
	end)
end

function ENT:PhysicsCollide( data, physobj )
	self:SetPitcher(nil)
	self:SetThrowTime(-1)
	local oldVel = data.OurOldVelocity
	local hitNormal = data.HitNormal

	local newVel = physobj:GetVelocity()
	local hitEnt = data.HitEntity
	if hitEnt:IsWorld() then
		if math.abs(hitNormal.z) > 0.1 then
			hitNormal = Vector(0, 0, -1)
		end
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
	local hitEntPhysObj = hitEnt:GetPhysicsObject()
	local hitPos = data.HitPos

	local impactVel = oldVel - hitEntPhysObj:GetVelocityAtPoint(hitPos)

	local dot = impactVel:Dot(hitNormal)
	dot = math.abs(dot)
	if dot > 3200 then
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetRadius(25)
		efdata:SetNormal(-hitNormal)
		util.Effect("cball_bounce",efdata)
		local efdata2 = EffectData()
		efdata:SetMagnitude(2)
		efdata:SetRadius(2)
		efdata:SetScale(2)
		util.Effect("Sparks",efdata2)
		self:EmitSound("physics/rubber/rubber_tire_impact_bullet" .. math.random(1,3) .. ".wav",80,math.random(95,105), 1)
	elseif dot > 1200 then
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetMagnitude(2)
		efdata:SetRadius(0.1)
		efdata:SetScale(2)
		efdata:SetNormal(-hitNormal)
		util.Effect("ElectricSpark",efdata)
		self:EmitSound("physics/rubber/rubber_tire_impact_hard" .. math.random(1,3) .. ".wav",80,math.random(95,105), 1)
	elseif dot > 400 then
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetMagnitude(2)
		efdata:SetRadius(0.1)
		efdata:SetScale(2)
		efdata:SetNormal(-hitNormal)
		util.Effect("ElectricSpark",efdata)
		self:EmitSound("npc/antlion/shell_impact4.wav",80,math.random(95,105), 1)
	elseif dot > 200 then
		self:EmitSound("physics/rubber/rubber_tire_impact_soft" .. math.random(1,3) .. ".wav",80,math.random(95,105), 1)
	end
	physobj:SetVelocity(Vector(0,0,0))
	if hitEnt:IsWorld() then
		local mult = 1.4
		velKeep = 0.85
		local zVelKeep = 1
		local impulse = dot * -mult
		--print(impulse)
		if impulse > -100 then
			velKeep = 1
		end
		debugoverlay.Cross(data.HitPos, 32, 1, Color(0,0,255), true)
		debugoverlay.Line(data.HitPos, data.HitPos + (hitNormal * 256), 1, Color(0,0,255), true)
		physobj:SetVelocity((oldVel + (impulse * hitNormal)) * velKeep * Vector(1, 1, zVelKeep))
		if self.trail then
			self.trail:Remove()
			self.trail = nil
		end
		return
	end
end


	hook.Add( "ShouldCollide", "CustomCollisions", function( ent1, ent2 )
		
		if ent1:IsPlayer() then
			return false
		end
	
		if ent2:IsPlayer() then
			return false
		end
	
		if ent1:GetClass() == "gmod_baseball" and ent1.hasCollided and ent2:IsWorld() == false then
			return false
		end
		
	end )

for i, v in ipairs(player.GetAll()) do
	v:SetCustomCollisionCheck(true)
end

function ENT:CheckJustPassedStrikeZone()
	if self:GetPastStrikeZone() == true and self:GetWasPastStrikeZone() == false then
		self:SetWasPastStrikeZone(true)
		if SERVER then
			net.Start("StrikePos")
			net.WriteVector(self:GetOldPos())
			net.Broadcast()
		end
		return true
	else
		return false
	end
end

function ENT:Think()
	if CLIENT then
		return
	end
	self:CheckJustPassedStrikeZone()
	self:SetOldVel(self.phys:GetVelocity())
	if self.phys:GetVelocity():Length() < self:GetLowestVelocityPostSwing():Length() then
		self:SetLowestVelocityPostSwing(self.phys:GetVelocity())
	end
	self:SetWasPastStrikeZone(self:GetPastStrikeZone())
	local rotatedPos = self:GetPos()
	local rotatedOldPos = self:GetOldPos()
	rotatedPos:Rotate(Angle(0, 45, 0))
	rotatedOldPos:Rotate(Angle(0, 45, 0))
	if rotatedPos.y < -6724 and rotatedOldPos.y > -6724 then
		self:SetPastStrikeZone(true)
	else
		self:SetPastStrikeZone(false)
	end
	self:SetOldPos(self:GetPos())
	local onGround = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0,0,-30),
		filter = {self}
		})

	local vel = self.phys:GetVelocity()
	local ballColor = math.Remap(vel:Length(), 0, 3000, 255, 50)
	ballColor = math.Clamp(ballColor, 50, 255)
	self:SetColor(Color(255, ballColor, ballColor))
	self:SetLaggedVel(math.max(Lerp(FrameTime() * 2, self:GetLaggedVel(), vel:Length()), vel:Length()))
	--print(self:GetLaggedVel())
	if onGround.Hit then
		vel = vel + (-vel * FrameTime())
		local angleVel = self.phys:GetAngleVelocity()
		angleVel = angleVel + (-angleVel * FrameTime() * 2)
		self.phys:SetAngleVelocity(angleVel)
		local velLength = vel:Length()
		velLength = velLength - (FrameTime() * 2)
		vel = vel:GetNormalized() * velLength
		--print("hit at " .. CurTime())
		--print(vel:Length())
	else
		--print("no hit")
	end
	local gravity = -800
	if self:GetPitcher():IsValid() then
		local curPitcherView = self:GetPitcher():EyeAngles():Forward()
		local dirToBall = (self:GetPos() - self:GetPitcher():GetShootPos()):GetNormalized()
		local pitcherViewOffsetDot = curPitcherView:Dot(dirToBall)
		local scaledDot = math.min(math.abs(pitcherViewOffsetDot - 1) * 120, 1)
		--print(scaledDot)
		scaledDot = math.pow(scaledDot, 0.5)
		local axis = curPitcherView:Cross(dirToBall):GetNormalized()
		--debugoverlay.Line(self:GetPos(), self:GetPos() + (axis * 64), 0.04, Color( 255, 255, 255 ), true )
		local desiredAngleVelocity = axis * scaledDot * 150000 * FrameTime()
		local angleVelDiff = desiredAngleVelocity - self.phys:GetAngleVelocity()
		--print(angleVelDiff:Length())
		local BallCurveMult = math.Remap(self:GetPitcher():GetHeartStat(), 0, 8, 0.5, 1.1)
		local dist = (self:GetPos() - self:GetPitcher():GetPos()):Length()
		local distModifier = math.Clamp(math.Remap(dist, 800, 1800, 1, 0.1), 0.1, 1)

		--print(distModifier)
		self.phys:AddAngleVelocity(angleVelDiff * FrameTime() * 8 * distModifier)
		if self.phys:GetAngleVelocity():Length() > 1000 then
			self.phys:SetAngleVelocity(self.phys:GetAngleVelocity():GetNormalized() * 1000)
		end
		--print(self.phys:GetAngleVelocity():Length())
		--print(vel:Length())
		local curveStrengthModifier = math.Clamp(math.Remap(vel:Length(), 0, 2400, 7, 2.8), 2.8, 7)
		gravity = math.Remap(vel:Length(), 0, 2400, math.Remap(self:GetPitcher():GetHeartStat(), 0, 8, -160, -40), -600)
		--print(vel:Length())
		local curveStrength = self.phys:GetAngleVelocity():Length() * curveStrengthModifier * BallCurveMult
		local curveDir = vel:Cross(self.phys:GetAngleVelocity()):GetNormalized()
		local oldVelSpeed = vel:Length()
		--print(vel:Length())
		self:SetTrueAngleVel(self.phys:GetAngleVelocity())
		vel = (vel:GetNormalized() + (curveDir * curveStrength * FrameTime() * 0.00014)) * oldVelSpeed
	end
	vel = vel + Vector(0,0,gravity * FrameTime())

	if CurTime() < self.lastHitTime then
		self.phys:SetPos(self.lastHitPos)
		self.phys:SetVelocity(Vector(0,0,0))
		--self.batEntPhys:SetPos(self.lastHitPosBat)
		--self.batEntPhys:SetVelocity(Vector(0,0,0))
		--self.batEntPhys:SetAngles(self.lastHitAngBat)
		--self.batEntPhys:SetAngleVelocity(Vector(0,0,0))
		local ballColor = math.Remap(self.lastHitVel:Length(), 0, 3000, 255, 50)
		ballColor = math.Clamp(ballColor, 50, 255)
		self:SetColor(Color(255, ballColor, ballColor))
		vel = Vector(0,0,0)
		--print("case 3")
	end
	if self.lastHitTime < CurTime() and self.beenHit then
		--print("applying vel")
		if self.trail then
			self.trail:Remove()
			self.trail = nil
		end

		local length = math.Remap(self.lastDot, 3000, 6000, 0.5, 0.25)
		local width = math.max(math.Remap(self.lastDot, 3000, 6000, 0, 75), 5)
		local trailcolor = math.max(math.Remap(self.lastDot, 3000, 6000, 255, 0), 0)
		local redColor = 255
		if self.lastDot > 6000 then
			redColor = math.Clamp(math.Remap(self.lastDot, 6000, 7000, 255, 100), 0, 255)
		end
		--self.trail = util.SpriteTrail( self, 0, Color( redColor, trailcolor, trailcolor ), false, width, 1, length, 1 / ( 15 + 1 ) * 0.5, "trails/smoke" )


		self.phys:SetPos(self.lastHitPos)
		vel = self.lastHitVel
		self:SetLowestVelocityPostSwing(vel)
		local ballColor = math.Remap(self.lastHitVel:Length(), 0, 3000, 255, 50)
		ballColor = math.Clamp(ballColor, 50, 255)
		self:SetColor(Color(255, ballColor, ballColor))
		self.beenHit = false
		--self.batEnt.DontFuckingMove = false
		game.SetTimeScale( 1 )
		self:SetLastHitStrength(0)
		self:SetLastHitDir(Angle(0,0,0))
		--print("case 4")
	end
	self.phys:SetVelocity(vel)
	self:SetVelocity(vel)
	self:NextThink(CurTime())
	return true
end

if SERVER then return end

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

ballIndicatorColor = Color(255,255,255,20)
ballGroundIndicatorMat = Material("effects/select_ring")

function ENT:Draw()
	self:DrawModel()
	local selfPos = self:GetPos()
	selfPos.z = 1
	render.DrawLine(self:GetPos(), selfPos, ballIndicatorColor, true)
	render.SetMaterial( ballGroundIndicatorMat )
	render.DrawQuadEasy( selfPos, Vector( 0, 0, 1 ), 40, 40, Color( 255, 255, 255, 200 ), 0 )
	--cam.Start2D()
		--local ballScreenPos = (self:GetPos() + Vector(0, 0, 32)):ToScreen()
		--draw.SimpleTextOutlined( math.Round(self:GetOldVel():Length()), "DermaDefault", ballScreenPos.x, ballScreenPos.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 255 ) )
	--cam.End2D()
	if self:GetPitcher():IsValid() and self:GetPitcher() == LocalPlayer() then
		local vel = self:GetVelocity()
		gravity = -600
		local curPitcherView = self:GetPitcher():EyeAngles():Forward()
		local dirToBall = (self:GetPos() - self:GetPitcher():GetShootPos()):GetNormalized()
		local pitcherViewOffsetDot = curPitcherView:Dot(dirToBall)
		local scaledDot = math.min(math.abs(pitcherViewOffsetDot - 1) * 4, 0.25)
		local axis = curPitcherView:Cross(dirToBall):GetNormalized()
		local curveStrengthModifier = math.Remap(vel:Length(), 0, 4000, 4, 1)
		local curveStrength = self:GetTrueAngleVel():Length() * curveStrengthModifier
		local curveDir = vel:Cross(self:GetTrueAngleVel()):GetNormalized()
		local oldVelSpeed = vel:Length()
		local offset = EyePos() + (self:GetPitcher():EyeAngles():Forward() * 512) + (self:GetTrueAngleVel() * 0.065)
		offset = offset:ToScreen()
		local tx, ty = offset.x - (ScrW() * 0.5), offset.y - (ScrH() * 0.5)
		local rx, ry = -ty, tx
		--PrintTable(offset)
		local origin = self:GetPos():ToScreen()
		cam.Start2D()
			surface.DrawCircle(origin.x, origin.y, 64, 0, 0, 0, 150)
			surface.SetDrawColor( 255, 255, 255, 200)
			draw.Circle(origin.x + rx, origin.y + ry, 4, 8)
		cam.End2D()
	elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "psychichands" and LocalPlayer():GetActiveWeapon():GetHoldEnt():IsValid() and LocalPlayer():GetActiveWeapon():GetHoldEnt() == self then
		local origin = self:GetPos():ToScreen()
		cam.Start2D()
			surface.DrawCircle(origin.x, origin.y, 64, 0, 0, 0, 150)
		cam.End2D()
	end
end