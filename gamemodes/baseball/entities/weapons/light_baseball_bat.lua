
AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = "models/weapons/w_models/w_bat.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.PrintName	= "Baseball Bat"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
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

-----------------------------------------------
-- Helper: BuildVMatrix
--
-- Creates a VMatrix from an origin and three basis vectors.
-- The parameters are:
--   origin  : Vector (translation)
--   forward : Vector (first basis vector)
--   up      : Vector (second basis vector)
--   right   : Vector (third basis vector)
--
-- Assumes the basis vectors already represent a rotation (no scaling).
-----------------------------------------------
function BuildVMatrix(origin, forward, up, right)
    local m = Matrix()  -- create a new VMatrix (assumed available)
    m:SetForward(forward)
    m:SetUp(up)
    m:SetRight(right)
    m:SetTranslation(origin)
    return m
end

-----------------------------------------------
-- Helper: LerpVector
--
-- Linearly interpolates between two Vectors.
-----------------------------------------------
local function LerpVector(t, v1, v2)
    return v1 * (1 - t) + v2 * t
end

-----------------------------------------------
-- Quaternion helper functions
--
-- We represent a quaternion as a table with fields:
--   q = { x = ..., y = ..., z = ..., w = ... }
-----------------------------------------------

local function QuaternionNormalize(q)
    local mag = math.sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w)
    if mag == 0 then return {x=0, y=0, z=0, w=1} end
    return { x = q.x / mag, y = q.y / mag, z = q.z / mag, w = q.w / mag }
end

-----------------------------------------------
-- Convert a VMatrix’s rotation (its basis) to a quaternion.
--
-- We assume the matrix’s basis vectors are stored as:
--   forward = m:GetForward()   -- first column
--   up      = m:GetUp()        -- second column
--   right   = m:GetRight()     -- third column
--
-- This conversion uses a standard algorithm.
-----------------------------------------------
local function MatrixToQuaternion(m)
    local f = m:GetForward()  -- Vector
    local u = m:GetUp()       -- Vector
    local r = m:GetRight()    -- Vector

    -- The rotation matrix is assumed to be:
    --   [ f.x   u.x   r.x ]
    --   [ f.y   u.y   r.y ]
    --   [ f.z   u.z   r.z ]
    local trace = f.x + u.y + r.z
    local q = {}
    if trace > 0 then
        local s = math.sqrt(trace + 1.0) * 2 -- s = 4 * qw
        q.w = 0.25 * s
        q.x = (u.z - r.y) / s
        q.y = (r.x - f.z) / s
        q.z = (f.y - u.x) / s
    elseif (f.x > u.y) and (f.x > r.z) then
        local s = math.sqrt(1.0 + f.x - u.y - r.z) * 2 -- s = 4 * qx
        q.w = (u.z - r.y) / s
        q.x = 0.25 * s
        q.y = (u.x + f.y) / s
        q.z = (r.x + f.z) / s
    elseif u.y > r.z then
        local s = math.sqrt(1.0 + u.y - f.x - r.z) * 2 -- s = 4 * qy
        q.w = (r.x - f.z) / s
        q.x = (u.x + f.y) / s
        q.y = 0.25 * s
        q.z = (r.y + u.z) / s
    else
        local s = math.sqrt(1.0 + r.z - f.x - u.y) * 2 -- s = 4 * qz
        q.w = (f.y - u.x) / s
        q.x = (r.x + f.z) / s
        q.y = (r.y + u.z) / s
        q.z = 0.25 * s
    end
    return QuaternionNormalize(q)
end

-----------------------------------------------
-- Convert a quaternion back into a rotation basis.
--
-- Returns a table with three vectors: forward, up, right.
--
-- This uses one common conversion formula.
-----------------------------------------------
local function QuaternionToMatrix(q)
    local xx = q.x * q.x
    local yy = q.y * q.y
    local zz = q.z * q.z
    local xy = q.x * q.y
    local xz = q.x * q.z
    local yz = q.y * q.z
    local wx = q.w * q.x
    local wy = q.w * q.y
    local wz = q.w * q.z

    -- These formulas produce a 3x3 rotation matrix.
    local forward = Vector(1 - 2*(yy + zz), 2*(xy + wz), 2*(xz - wy))
    local up      = Vector(2*(xy - wz), 1 - 2*(xx + zz), 2*(yz + wx))
    local right   = Vector(2*(xz + wy), 2*(yz - wx), 1 - 2*(xx + yy))
    
    return { forward = forward, up = up, right = right }
end

-----------------------------------------------
-- SLerp between two quaternions.
--
-- Returns a normalized quaternion.
-----------------------------------------------
local function QuaternionSlerp(q1, q2, t)
    local dot = q1.x*q2.x + q1.y*q2.y + q1.z*q2.z + q1.w*q2.w
    if dot < 0 then
        -- Invert one quaternion to take the shortest path.
        q2 = { x = -q2.x, y = -q2.y, z = -q2.z, w = -q2.w }
        dot = -dot
    end

    if dot > 0.9995 then
        -- If the quaternions are very close, use linear interpolation.
        local result = {
            x = q1.x + t*(q2.x - q1.x),
            y = q1.y + t*(q2.y - q1.y),
            z = q1.z + t*(q2.z - q1.z),
            w = q1.w + t*(q2.w - q1.w)
        }
        return QuaternionNormalize(result)
    end

    local theta_0 = math.acos(dot)
    local sin_theta_0 = math.sin(theta_0)
    local theta = theta_0 * t
    local sin_theta = math.sin(theta)

    local s0 = math.cos(theta) - dot * sin_theta / sin_theta_0
    local s1 = sin_theta / sin_theta_0

    local result = {
        x = s0 * q1.x + s1 * q2.x,
        y = s0 * q1.y + s1 * q2.y,
        z = s0 * q1.z + s1 * q2.z,
        w = s0 * q1.w + s1 * q2.w
    }
    return QuaternionNormalize(result)
end

-----------------------------------------------
-- Helper: InterpolateMatrices
--
-- Given two VMatrix objects (assumed to have no scaling) and a
-- parameter t between 0 and 1, this function returns a new VMatrix
-- that is the interpolation of the two.
--
-- Translation is interpolated linearly and the rotation is SLerped.
-----------------------------------------------
function InterpolateMatrices(matA, matB, t)
    -- Interpolate the translation.
    local transA = matA:GetTranslation()
    local transB = matB:GetTranslation()
    local interpTrans = LerpVector(t, transA, transB)

    -- Convert the rotation parts to quaternions and slerp them.
    local quatA = MatrixToQuaternion(matA)
    local quatB = MatrixToQuaternion(matB)
    local interpQuat = QuaternionSlerp(quatA, quatB, t)
    local basis = QuaternionToMatrix(interpQuat)
    
    -- Build a new VMatrix from the interpolated translation and basis.
    return BuildVMatrix(interpTrans, basis.forward, basis.up, basis.right)
end

-----------------------------------------------
-- Helper: OrthonormalizeMatrix
--
-- Given a VMatrix that (may) contain a non-orthonormal basis,
-- this function “fixes” the basis using Gram–Schmidt.
--
-- It normalizes the forward vector, makes the up vector orthogonal to it,
-- and then recomputes the right vector from the cross product.
-----------------------------------------------
function OrthonormalizeMatrix(m)
    local forward = m:GetForward()
    local up      = m:GetUp()
    local right   = m:GetRight()

    forward = forward:GetNormalized()
    up = (up - forward * forward:Dot(up)):GetNormalized()
    right = forward:Cross(up):GetNormalized()  -- Assumes a right-handed system.

    m:SetForward(forward)
    m:SetUp(up)
    m:SetRight(right)
    
    return m
end

--[[ 
Helper: intersect_sphere_ray

Tests for an intersection between a ray segment (from ray_a to ray_b)
and a sphere defined by a center and a radius.

Returns a table:
  {
    t         = <number>,      -- The parameter along the ray where the hit occurred.
    hit_point = <Vector>,      -- The position of the hit.
    hit_normal= <Vector>       -- The sphere's surface normal at the hit point.
  }
If no intersection is found, returns nil.
--]]
function intersect_sphere_ray(ray_a, ray_b, center, radius)
    local d = ray_b - ray_a
    local m = ray_a - center
    local a = d:Dot(d)
    local b = 2.0 * m:Dot(d)
    local c = m:Dot(m) - radius * radius
    local disc = b * b - 4.0 * a * c
    if disc < 0 then
        return nil
    end
    local sqrt_disc = math.sqrt(disc)
    local t1 = (-b - sqrt_disc) / (2.0 * a)
    local t2 = (-b + sqrt_disc) / (2.0 * a)
    local t = nil
    if t1 >= 0 and t1 <= 1 then
        t = t1
    elseif t2 >= 0 and t2 <= 1 then
        t = t2
    end
    if t == nil then return nil end
    local hit_point = ray_a + d * t
    local hit_normal = (hit_point - center):GetNormalized()
    return { t = t, hit_point = hit_point, hit_normal = hit_normal }
end

--[[ 
intersect_capsule_ray

Tests for an intersection between a ray segment (from ray_a to ray_b)
and a capsule defined by two endpoints (cap_a and cap_b) and two radii (r_a and r_b).

Returns a table with:
  hit        = <boolean>   (true if an intersection is found)
  t          = <number>    (the ray parameter where the hit occurred)
  hit_point  = <Vector>    (the position where the ray hit the capsule)
  hit_normal = <Vector>    (the surface normal at the hit point)

If no intersection is found, returns { hit = false }.
--]]
function intersect_capsule_ray(ray_a, ray_b, cap_a, cap_b, r_a, r_b)


    local d = ray_b - ray_a       -- Ray direction.
    local U = ray_a - cap_a
    local D = cap_b - cap_a       -- Capsule axis.
    local dr = r_b - r_a          -- Difference in radii.
    local D2 = D:Dot(D)
    local M = dr * dr - D2
    local K = D:Dot(d)
    local C = D:Dot(U) + dr * r_a
    local epsilon = 1e-6

	if ray_a:IsEqualTol(ray_b, 0.001) then
		return { hit = false}
	end

    -- If M is nearly zero, treat the capsule as two spheres.
    if math.abs(M) < epsilon then
    	print("m case")
        local hit1 = intersect_sphere_ray(ray_a, ray_b, cap_a, r_a)
        local hit2 = intersect_sphere_ray(ray_a, ray_b, cap_b, r_b)
        if hit1 and hit2 then
            if hit1.t < hit2.t then
                return { hit = true, t = hit1.t, hit_point = hit1.hit_point, hit_normal = hit1.hit_normal }
            else
                return { hit = true, t = hit2.t, hit_point = hit2.hit_point, hit_normal = hit2.hit_normal }
            end
        elseif hit1 then
            return { hit = true, t = hit1.t, hit_point = hit1.hit_point, hit_normal = hit1.hit_normal }
        elseif hit2 then
            return { hit = true, t = hit2.t, hit_point = hit2.hit_point, hit_normal = hit2.hit_normal }
        end
        return { hit = false }
    end

    -- Solve for intersection with the lateral (conical) part of the capsule.
    local A = d + D * (K / M)
    local Bprime = U + D * (C / M)
    local term = dr * K / M
    local a = A:Dot(A) - term * term
    local b = 2.0 * (Bprime:Dot(A) + (r_a - (dr * C) / M) * term)
    local c = Bprime:Dot(Bprime) - (r_a - (dr * C) / M)^2

    local s_candidate = -1.0
    if math.abs(a) < epsilon then
        if math.abs(b) > epsilon then
            s_candidate = -c / b
        end
    else
        local disc = b * b - 4.0 * a * c
        if disc >= 0 then
            local sqrt_disc = math.sqrt(disc)
            local s1 = (-b - sqrt_disc) / (2.0 * a)
            local s2 = (-b + sqrt_disc) / (2.0 * a)
            if s1 >= 0 and s1 <= 1 then
                s_candidate = s1
            elseif s2 >= 0 and s2 <= 1 then
                s_candidate = s2
            end
        end
    end

    local candidate_collision = nil
    if s_candidate >= 0 then
        local t_candidate = -(C + s_candidate * K) / M
        if t_candidate >= 0 and t_candidate <= 1 then
            local hit_point = ray_a + d * s_candidate
            local axis_point = cap_a + D * t_candidate
            candidate_collision = { 
                hit = true, 
                t = t_candidate, 
                hit_point = hit_point, 
                hit_normal = (hit_point - axis_point):GetNormalized() 
            }
            print("case 1")
            print(s_candidate)
            print(t_candidate)
        end
    end

    -- Try the spherical endcaps.
    local sphere_hit = nil
    local hit1 = intersect_sphere_ray(ray_a, ray_b, cap_a, r_a)
    local hit2 = intersect_sphere_ray(ray_a, ray_b, cap_b, r_b)
    if hit1 and hit2 then
        sphere_hit = (hit1.t < hit2.t) and hit1 or hit2
    elseif hit1 then
        sphere_hit = hit1
    elseif hit2 then
        sphere_hit = hit2
    end

    if sphere_hit then
        if candidate_collision then
            if sphere_hit.t < candidate_collision.t then
            	print("case 2")
                candidate_collision = { 
                    hit = true, 
                    t = sphere_hit.t, 
                    hit_point = sphere_hit.hit_point, 
                    hit_normal = sphere_hit.hit_normal 
                }
            end
        else
        	print("case 3")
            candidate_collision = { 
                hit = true, 
                t = sphere_hit.t, 
                hit_point = sphere_hit.hit_point, 
                hit_normal = sphere_hit.hit_normal 
            }
        end
    end

    return candidate_collision or { hit = false }
end

--[[ 
intersect_moving_capsule_ray

Tests for an intersection between a ray segment and a moving capsule.
The capsule’s local geometry is defined by cap_a, cap_b, r_a, and r_b.
The capsule moves from transform_start to transform_end (which are VMatrix values 
containing only rotation and translation).

To handle motion, we “bring” the ray into the capsule’s local space by applying the
inverse of transform_start to ray_a and the inverse of transform_end to ray_b.

Returns a table with the same keys as intersect_capsule_ray.
--]]
function intersect_moving_capsule_ray(ray_a, ray_b, cap_a, cap_b, r_a, r_b, transform_start, transform_end)
	if ray_a == nil or ray_b == nil then return {hit = false} end
    local inv_start = Matrix()
    inv_start:Set(transform_start)
    inv_start:Invert()
    local inv_end   = Matrix()
    inv_end:Set(transform_end)
    inv_end:Invert()
    local local_ray_a = inv_start * ray_a
    local local_ray_b = inv_end * ray_b
    return intersect_capsule_ray(local_ray_a, local_ray_b, cap_a, cap_b, r_a, r_b)
end


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "HoldDistance" )
	self:NetworkVar( "Angle", 0, "HoldAngle" )
end

function SWEP:Initialize()
	self:SetHoldType( "none" )
    self:CreateBatModel()
end

function SWEP:Reload()
end

function SWEP:OnRemove()
end

function SWEP:PrimaryAttack()
    if CLIENT and IsFirstTimePredicted() then
	   input.SelectWeapon( self:GetOwner():GetWeapon("psychichands") )
    end
end

function SWEP:SecondaryAttack()
    if CLIENT and IsFirstTimePredicted() then
	   input.SelectWeapon( self:GetOwner():GetWeapon("psychichands") )
    end
end

function SWEP:GrabOverride()
end


function FlattenMatrix(vmat)
   -- vmat:SetField(1, 1, 0.001)
    --vmat:SetField(2, 2, 0.001)
    vmat:SetField(3, 1, 0.001)
    vmat:SetField(3, 2, 0.001)
    vmat:SetField(3, 3, 0.001)
    vmat:SetField(3, 4, 1)

    return vmat
end

local capsules = {}
capsules[1] = {Vector(0, 0, -8), Vector(0, 0, 24), 3, 3}
capsules[2] = {Vector(0, 0, 24), Vector(0, 0, 56), 3, 6}
capsules[3] = {Vector(0, 0, 56), Vector(0, 0, 96), 6, 6}

local ball_radius = 10

local bat_orientation = Angle(0, 0, 0)

function SWEP:FreezeMovement()

	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_RELOAD ) || self.Owner:KeyReleased( IN_RELOAD ) ) then
		return true
	end

	return false

end

function SWEP:CreateBatModel()
    if CLIENT then
        print("lets create bat")
        if self.bat_model then
            self.bat_model:Remove()
            self.shadow_model:Remove()
            self.bat_model = nil
            self.shadow_model = nil
        end
        self.bat_model = ClientsideModel("models/weapons/w_models/w_bat.mdl")
        self.bat_model:SetNoDraw(false)
        self.shadow_model = ClientsideModel("models/weapons/w_models/w_bat.mdl")
        self.shadow_model:SetNoDraw(false)
        self.transform = Matrix()
        self.transform_old = Matrix()
        self.bat_model.mostRecentThink = CurTime()
        self.shadow_model.mostRecentThink = CurTime()
        table.insert(bat_model_list, self.bat_model)
        table.insert(bat_model_list, self.shadow_model)
    end
end

function ArrayRemove(t, fnKeep)
    local j, n = 1, #t;
    for i=1,n do
        if (fnKeep(t, i, j)) then
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1;
        else
            t[i] = nil;
        end
    end
    return t;
end

if CLIENT then
    bat_model_list = {}
    hook.Add("Think", "BatCleanup", function()
        ArrayRemove(bat_model_list, function(t, i, j)
            -- Return true to keep the value, or false to discard it.
            local v = bat_model_list[i]
            local should_remove = false
            if !v.mostRecentThink then
                should_remove = true
            else
                should_remove = CurTime() > v.mostRecentThink + 3.0
            end
            if should_remove then v:Remove() end
            return !should_remove
        end);
    end)
end

function SWEP:DrawWorldModel( flags )
	if self.hasHit then
		self.hasHit = self.hasHit + FrameTime()
		self.hitBall:SetRenderOrigin(self.clientHitPos)
		if self.hasHit > 0.125 then
			self.hasHit = nil
			self.hitBall:SetRenderOrigin(nil)
		end
		return
	end
	if self.bat_model == nil then
		print("no bat model")
		self:CreateBatModel()
		return
	end
    if !self.bat_model:IsValid() then
        print("no bat model")
        self:CreateBatModel()
        return
    end
    self.bat_model.mostRecentThink = CurTime()
    self.shadow_model.mostRecentThink = CurTime()

    self.bat_model:SetRenderBoundsWS(self.transform:GetTranslation(), self.transform:GetTranslation(), Vector(100, 100, 100))

	local balls = ents.FindByClass("gmod_baseball")
	local origin = self:GetOwner():EyePos()
	local eyeang = self:GetOwner():EyeAngles()
	local test_eyeang = eyeang
	if test_eyeang.p > 180 then
		test_eyeang.p = test_eyeang.p - 360
		test_eyeang.y = test_eyeang.y - 360
	end
	if self:GetOwner() ~= LocalPlayer() then
		eyeang = test_eyeang
	end
	--print(eyeang)
	local fw = eyeang:Forward()
	local up = eyeang:Up()
	local rt = eyeang:Right()
	local desired_bat_matrix = BuildVMatrix(origin, fw, up, rt)
	desired_bat_matrix:Rotate(Angle(80, 0, 0))
	desired_bat_matrix:Translate(Vector(0, 0, 172))
	desired_bat_matrix:Rotate(Angle(-eyeang.p * 0.75, 0, 0))
	desired_bat_matrix:Rotate(self:GetHoldAngle())
	self.transform_old:Set(self.transform)
	self.transform = InterpolateMatrices(self.transform, desired_bat_matrix, FrameTime() * math.Remap(self:GetOwner():GetArmsStat(), 0, 8, 16, 24))

	local render_matrix = Matrix()
	local shadow_matrix = Matrix()
	render_matrix:Set(self.transform)
	render_matrix:SetScale(Vector(3.75, 3.75, 3.75))
	self.bat_model:EnableMatrix("RenderMultiply", render_matrix)
	shadow_matrix:Set(render_matrix)
	--shadow_matrix:Translate(Vector(0, 0, 40))
	shadow_matrix = FlattenMatrix(shadow_matrix)
	self.shadow_model:EnableMatrix("RenderMultiply", shadow_matrix)
	self.shadow_model:SetColor(Color(0, 0, 0))

	if self:GetOwner() ~= LocalPlayer() then
		return
	end

	local collisions = {}
	for k, b in ipairs(balls) do
		if b.client_hit then
			b.client_hit = b.client_hit + FrameTime()
			if b.client_hit > 1 then
				b.client_hit = nil
			end
			continue
		end
		for i, v in ipairs(capsules) do
			local p1 = self.transform * v[1]
			local p2 = self.transform * v[2]
			debugoverlay.Line( p1, p2, FrameTime(), Color( 255, 255, 255 ), true )
			debugoverlay.Sphere( p1, v[3], FrameTime(), Color( 255, 255, 255, 0 ), true )
			debugoverlay.Sphere( p2, v[4], FrameTime(), Color( 255, 255, 255, 0 ), true )
			local hit = intersect_moving_capsule_ray(b.position_old, b.position, v[1], v[2], v[3] + ball_radius, v[4] + ball_radius, self.transform_old, self.transform)
			if hit and hit.hit then
				hit.hit_ball = b
				b.client_hit = FrameTime()
				table.insert(collisions, hit)
			end
		end
	end
	if #collisions > 0 then
		local lowest_t = 1.0
		local lowest_t_index = 0
		for c, v in ipairs(collisions) do
			if v.t < lowest_t then
				lowest_t = v.t
				lowest_t_index = c
			end
		end
		local p = self.transform * collisions[lowest_t_index].hit_point
		local p_old = self.transform_old * collisions[lowest_t_index].hit_point
		local vel_at_point = p - p_old
		vel_at_point = vel_at_point
		local normal = collisions[lowest_t_index].hit_normal
		local rot_matrix = Matrix()
		rot_matrix:Set(self.transform)
		rot_matrix:SetTranslation(Vector(0, 0, 0))
		normal = rot_matrix * normal
		self.hasHit = FrameTime()
		self.clientHitPos = self.transform * collisions[lowest_t_index].hit_point
		self.hitBall = collisions[lowest_t_index].hit_ball
		local ball_vel = collisions[lowest_t_index].hit_ball.position - collisions[lowest_t_index].hit_ball.position_old
		net.Start("ClientBatHit")
			net.WriteVector(ball_vel / FrameTime())
			net.WriteVector(self.transform * collisions[lowest_t_index].hit_point)
			debugoverlay.Sphere(self.transform * collisions[lowest_t_index].hit_point, 1, 4, Color( 0, 255, 0, 0 ), true )
			net.WriteVector(normal)
			debugoverlay.Line(self.transform * collisions[lowest_t_index].hit_point, self.transform * collisions[lowest_t_index].hit_point + normal * 16, 4, Color(0, 255, 0), true)
			net.WriteVector(vel_at_point / FrameTime())
			debugoverlay.Line(self.transform * collisions[lowest_t_index].hit_point, self.transform * collisions[lowest_t_index].hit_point + vel_at_point / FrameTime(), 4, Color(0, 0, 255), true)
			net.WriteEntity(collisions[lowest_t_index].hit_ball)
			print("HIT")
		net.SendToServer()
		print("sent")
	end

	--self:DrawModel( flags )
end

function SWEP:Think()
	local cmd = self.Owner:GetCurrentCommand()
	local realViewAngle = batterCamAng
	local trueHoldEntAng = self:GetHoldAngle()
	trueHoldEntAng.y = 0
	if cmd:KeyDown( IN_RELOAD ) then
		trueHoldEntAng.r = trueHoldEntAng.r + cmd:GetMouseX() * 0.05
		trueHoldEntAng.p = trueHoldEntAng.p + cmd:GetMouseY() * 0.05
	end
    if self.bat_model then
        self.bat_model.mostRecentThink = CurTime()
        self.shadow_model.mostRecentThink = CurTime()
    end
	self:SetHoldAngle(trueHoldEntAng)
end

function SWEP:Holster(wep)
	return true
end

function SWEP:Deploy()
    if IsFirstTimePredicted() then
	   self:CreateBatModel()
    end
end

function SWEP:Equip()
    if IsFirstTimePredicted() then
       self:CreateBatModel()
    end
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:DoShootEffect()
end

if ( SERVER ) then return end -- Only clientside lua after this line

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_camera" )

function SWEP:DrawHUD()
end

function SWEP:PrintWeaponInfo( x, y, alpha )
end

function SWEP:FreezeMovement()

	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_RELOAD ) || self.Owner:KeyReleased( IN_RELOAD ) ) then
		return true
	end

	return false

end