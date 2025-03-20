
function EFFECT:Init( data )

	self.hitPos = data:GetOrigin()
	self.dieTime = CurTime() + data:GetScale()
	self.glowParticle = Material("beautifulstar.png", "additive")

end

function EFFECT:Think()

	if self.emitter:IsValid() == false or CurTime() > self.dieTime then
		self:Remove()
		return false
	end
	local particle = self.emitter:Add( self.glowParticle, self.hitPos )
	if particle then
	
		local ratio = i / numParticles
		--local deathScale = math.Clamp(math.Remap(realBallVelLength, 2000, 6000, 0.25, 1), 0.25, 1)
		particle:SetDieTime( 0.5 )
	
		particle:SetStartAlpha( 128 )
		particle:SetEndAlpha( 0 )
	
		--local sizeScale = math.Clamp(math.Remap(realBallVelLength, 2000, 4000, 8, 32), 8, 32)
		particle:SetStartSize( 18 )
		particle:SetEndSize( 4 )
	
		--local colorScale = math.max(math.Remap(realBallVelLength, 0, 4000, 255, 0), 0)
		particle:SetColor(255, 255, 255)
	
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetRollDelta( math.Rand( -4, 4 ) )
	
		--particle:SetAirResistance( 1000 )
	
		particle:SetVelocity( VectorRand(-64, 64) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
		particle:SetPos(particle:GetPos() + VectorRand(-8, 8))
	
		--print("ah")
	
	end

	return true
end

function EFFECT:Render()
end
