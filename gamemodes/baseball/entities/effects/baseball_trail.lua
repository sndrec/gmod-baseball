
function EFFECT:Init( data )

	self.attachEnt = data:GetEntity()
	self.emitter = ParticleEmitter( self.attachEnt:GetPos() )
	self.ballOldPos = self.attachEnt:GetPos()
	self.ballPosDelta = Vector(0,0,0)
	self.lastPosCheck = CurTime() + 0.01666
	self.ballVel = Vector(0,0,0)

end

function EFFECT:Think()

	if self.emitter:IsValid() == false or self.attachEnt:IsValid() == false then
		self:Remove()
		return false
	end
	if CurTime() > self.lastPosCheck then
		local realDiff = CurTime() - self.lastPosCheck
		self.lastPosCheck = CurTime() + 0.01666
		self.ballPosDelta = self.attachEnt:GetPos() - self.ballOldPos
		self.ballOldPos = self.attachEnt:GetPos()
		self.ballVel = self.ballPosDelta / realDiff
		local ballVelLength = self.ballVel:Length()
		local realBallVelLength = self.attachEnt:GetOldVel():Length()
		if realBallVelLength > 800 then
			local numParticles = 8
			for i = 1, numParticles, 1 do
				if self.attachEnt:GetLowestVelocityPostSwing():Length() < 3300 then
					local particle = self.emitter:Add( "particle/particle_glow_04", self.attachEnt:GetPos() )
					if particle then
					
						local ratio = i / numParticles
						local deathScale = math.Clamp(math.Remap(realBallVelLength, 2000, 6000, 0.25, 1), 0.25, 1)
						particle:SetDieTime( deathScale )
					
						particle:SetStartAlpha( 8 )
						particle:SetEndAlpha( 0 )
					
						local sizeScale = math.Clamp(math.Remap(realBallVelLength, 2000, 4000, 8, 32), 8, 32)
						particle:SetStartSize( sizeScale )
						particle:SetEndSize( 0 )
		
						local colorScale = math.max(math.Remap(realBallVelLength, 0, 4000, 255, 0), 0)
						particle:SetColor(255, colorScale, colorScale)
					
						--particle:SetRoll( math.Rand( 0, 360 ) )
						--particle:SetRollDelta( math.Rand( -10, 10 ) )
					
						--particle:SetAirResistance( 1000 )
					
						--particle:SetVelocity( -ballVel )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						
						particle:SetPos(particle:GetPos() + (self.ballVel * ratio * -realDiff))
					
						--print("ah")
				
					end
				else
					local particle = self.emitter:Add( "effects/fire_cloud" .. math.random(1, 2) .. ".vmt", self.attachEnt:GetPos() )
					if particle then
					
						local ratio = i / numParticles
						--local deathScale = math.Clamp(math.Remap(realBallVelLength, 2000, 6000, 0.25, 1), 0.25, 1)
						particle:SetDieTime( 0.25 )
					
						particle:SetStartAlpha( 128 )
						particle:SetEndAlpha( 0 )
					
						--local sizeScale = math.Clamp(math.Remap(realBallVelLength, 2000, 4000, 8, 32), 8, 32)
						particle:SetStartSize( 12 )
						particle:SetEndSize( 8 )
		
						--local colorScale = math.max(math.Remap(realBallVelLength, 0, 4000, 255, 0), 0)
						particle:SetColor(255, 255, 255)
					
						particle:SetRoll( math.Rand( 0, 360 ) )
						particle:SetRollDelta( math.Rand( -4, 4 ) )
					
						--particle:SetAirResistance( 1000 )
					
						particle:SetVelocity( VectorRand(-64, 64) )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						
						particle:SetPos(particle:GetPos() + (self.ballVel * ratio * -realDiff) + VectorRand(-8, 8))
					
						--print("ah")
				
					end
					if i % numParticles == 0 then
						local particle = self.emitter:Add( "particle/smokesprites_0001.vmt", self.attachEnt:GetPos() )
						if particle then
						
							local ratio = i / numParticles
							--local deathScale = math.Clamp(math.Remap(realBallVelLength, 2000, 6000, 0.25, 1), 0.25, 1)
							particle:SetDieTime( 0.5 )
						
							particle:SetStartAlpha( 128 )
							particle:SetEndAlpha( 0 )
						
							--local sizeScale = math.Clamp(math.Remap(realBallVelLength, 2000, 4000, 8, 32), 8, 32)
							particle:SetStartSize( 8 )
							particle:SetEndSize( 64 )
			
							--local colorScale = math.max(math.Remap(realBallVelLength, 0, 4000, 255, 0), 0)
							particle:SetColor(40, 40, 40)
						
							particle:SetRoll( math.Rand( 0, 360 ) )
							particle:SetRollDelta( math.Rand( -4, 4 ) )
						
							--particle:SetAirResistance( 1000 )
						
							--particle:SetVelocity( -ballVel )
							particle:SetGravity( Vector( 0, 0, 0 ) )
							
							particle:SetPos(particle:GetPos() + (self.ballVel * ratio * -realDiff) + VectorRand(-12, 12))
						
							--print("ah")
					
						end
					end
				end
			end
		end
	end

	return true
end

function EFFECT:Render()
end
