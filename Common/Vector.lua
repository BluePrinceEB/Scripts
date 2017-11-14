--[[

	Credits: Nebelwolfi, Maxxxel

	Vector: Class {
		Vector(...) - initial call:
                        local myVec = Vector(<vector> or <number>, <number>, <number>)

		properties:
			.x  ->  the x value
			.y  ->  the y value
			.z  ->  the z value

		functions:
			:ToDX3() -> returns D3DXVECTOR3 from Vector
			:ToDX2() -> returns D3DXVECTOR2 from Vector
			:Clone() -> returns a new vector
			:Unpack() -> returns x, y, z
			:DistanceTo(Vector) -> returns distance to another vector
			:Len() -> returns length
			:Len2() -> returns squared length
			:Normalize() -> normalizes a vector
			:Normalized() -> creates a new vector, normalizes it and returns it 
			:Center(Vector) -> center between 2 vectors
			:CrossProduct(Vector) -> cross product of 2 vectors
			:DotProduct(Vector) -> dot product of 2 vectors
			:ProjectOn(Vector) -> projects a vector on a vector
			:MirrorOn(Vector) -> mirrors a vector on a vector
			:Sin(Vector) -> calculates sin of 2 vector
			:Cos(Vector) -> calculates cos of 2 vector
			:Angle(Vector) -> calculates angle between 2 vectors
			:AffineArea(Vector) -> calculates area between 2 vectors
			:TriangleArea(Vector) -> calculates triangular area between 2 vectors
			:RotateX(phi) -> rotates vector by phi around x axis
			:RotateY(phi) -> rotates vector by phi around y axis
			:RotateZ(phi) -> rotates vector by phi around z axis
			:Rotate(phiX, phiY, phiZ) -> rotates vector
			:Rotated(phiX, phiY, phiZ) -> creates a new vector, rotates it and returns it
			:Polar() -> returns polar value
			:AngleBetween(Vector, Vector) -> returns the angle formed from a vector to both input vectors
			:Perpendicular() -> creates a new vector that is rotated 90° right
			:Perpendicular2() -> creates a new vector that is rotated 90° left
                        :Extended(Vector, Distance) -> extends a vector towards a vector and returns it

		Example:

			require 'Vector'

			function OnLoad()
				AddEvent(Events.OnDraw, OnDraw)
			end

			function OnDraw()
				local myHeroVector = Vector(myHero.position.x, myHero.position.y, myHero.position.z)
				DrawHandler:Circle3D(myHeroVector:ToDX3(), 150, 0xffffffff)

				local function mouse() return pwHud.hudManager.activeVirtualCursorPos end
				local mouseVector = Vector(mouse().x, mouse().y, mouse().z)
				DrawHandler:Circle3D(mouseVector:ToDX3(), 150, 0xffffffff)

				local mouseExtended = myHeroVector:Extended(mouseVector, 500)
				DrawHandler:Circle3D(mouseExtended:ToDX3(), 150, 0xffffffff)

				local cursorVector = Vector(mouse().x, mouse().y, mouse().z)
				DrawHandler:Circle(cursorVector:ToDX2(), 150, 0xffffffff)
			end
			
	}
]]

local assert 		= assert
local type 		= assert( type ) 
local next		= assert( next )
local select 		= assert( select )
local setmetatable 	= assert( setmetatable )
local getmetatable 	= assert( getmetatable )
local huge		= assert( math.huge )
local floor		= assert( math.floor )
local ceil 		= assert( math.ceil )
local abs           	= assert( math.abs )
local deg           	= assert( math.deg )
local atan          	= assert( math.atan )
local sqrt 		= assert( math.sqrt ) 
local sin 		= assert( math.sin ) 
local cos 		= assert( math.cos ) 
local acos 		= assert( math.acos ) 
local max 		= assert( math.max )
local min 		= assert( math.min )
local format		= assert( string.format )
local concat      	= assert( table.concat )
local insert 		= assert( table.insert )
local remove 		= assert( table.remove )
local pairs		= assert( pairs )
local ipairs		= assert( ipairs )
local rawget 		= assert( rawget ) 
local rawset 		= assert( rawset )
local open 		= assert( io.open )
local close  		= assert( io.close )
local unpack 		= assert( unpack )

local function class()
        local cls = {}
        cls.__index = cls
        return setmetatable(cls, {__call = function (c, ...)
            local instance = setmetatable({}, cls)
            if cls.__init then
                    cls.__init(instance, ...)
            end
            return instance
        end})
end

local function IsVector(v)
    	return v and v.x and type(v.x) == "number" and ((v.y and type(v.y) == "number") or (v.z and type(v.z) == "number"))
end

local epsilon = 1e-9
local function Close(a, b, eps)
        if abs(eps) < epsilon then
                eps = 1e-9
        end

        return abs(a - b) <= eps
end

Vector = class()

function Vector:__init(x, y, z)
    	if not x then
        	self.x = 0
        	self.y = 0
        	self.z = 0
    	elseif not y then
        	self.x = x.x
        	self.y = x.y
        	self.z = x.z
    	else
        	self.x = x
        	if y and type(y) == "number" then self.y = y end
        	if z and type(z) == "number" then self.z = z end
    	end
end

function Vector:ToDX3()
	return D3DXVECTOR3(self.x, self.y, self.z)
end

function Vector:ToDX2()
	local v = self:Clone()
	local v2D = Renderer:WorldToScreen(v:ToDX3())
	return v2D
end

function Vector:__type()
    	return "Vector"
end

function Vector:__add(v)
	return Vector(self.x + v.x, (v.y and self.y) and self.y + v.y, (v.z and self.z) and self.z + v.z)
end

function Vector:__sub(v)
    	return Vector(self.x - v.x, (v.y and self.y) and self.y - v.y, (v.z and self.z) and self.z - v.z)
end

function Vector.__mul(a, b)
    	if type(a) == "number" and IsVector(b) then
        	return Vector({ x = b.x * a, y = b.y and b.y * a, z = b.z and b.z * a })
    	elseif type(b) == "number" and IsVector(a) then
        	return Vector({ x = a.x * b, y = a.y and a.y * b, z = a.z and a.z * b })
    	else
        	return a:DotProduct(b)
    	end
end

function Vector.__div(a, b)
    	if type(a) == "number" and IsVector(b) then
        	return Vector({ x = a / b.x, y = b.y and a / b.y, z = b.z and a / b.z })
    	else
        	return Vector({ x = a.x / b, y = a.y and a.y / b, z = a.z and a.z / b })
    	end
end

function Vector.__lt(a, b)
    	return a:Len() < b:Len()
end

function Vector.__le(a, b)
    	return a:Len() <= b:Len()
end

function Vector:__eq(v)
    	return self.x == v.x and self.y == v.y and self.z == v.z
end

function Vector:__unm()
    	return Vector(-self.x, self.y and -self.y, self.z and -self.z)
end

function Vector:__tostring()
    	return "Vector(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector:Clone()
    	return Vector(self)
end

function Vector:Unpack()
    return self.x, self.y, self.z
end

function Vector:Len2(v)
    	local v = v and Vector(v) or self
    	return self.x * v.x + (self.y and self.y * v.y or 0) + (self.z and self.z * v.z or 0)
end

function Vector:Len()
    	return sqrt(self:Len2())
end

function Vector:DistanceTo(v)
    	local a = self - v
    	return a:Len()
end

function Vector:Normalize()
    	local l = self:Len()
    	self.x = self.x / l
    	self.y = self.y / l 
    	self.z = self.z / l 
end

function Vector:Normalized()
    	local v = self:Clone()
    	v:Normalize()
    	return v
end

function Vector:Center(v)
    	return Vector((self + v) / 2)
end

function Vector:CrossProduct(v)
   	return Vector({ x = v.z * self.y - v.y * self.z, y = v.x * self.z - v.z * self.x, z = v.y * self.x - v.x * self.y })
end

function Vector:DotProduct(v)
    	return self.x * v.x + (self.y and (self.y * v.y) or 0) + (self.z and (self.z * v.z) or 0)
end

function Vector:ProjectOn(v)
    	local s = self:Len2(v) / v:Len2()
    	return Vector(v * s)
end

function Vector:MirrorOn(v)
    	return self:ProjectOn(v) * 2
end

function Vector:Sin(v)
    	local a = self:CrossProduct(v)
    	return sqrt(a:Len2() / (self:Len2() * v:Len2()))
end

function Vector:Cos(v)
    	return self:Len2(v) / sqrt(self:Len2() * v:Len2())
end

function Vector:Angle(v)
    	return acos(self:Cos(v))
end

function Vector:AffineArea(v)
    	local a = self:CrossProduct(v)
    	return sqrt(a:Len2())
end

function Vector:TriangleArea(v)
    	return self:AffineArea(v) / 2
end

function Vector:RotateX(phi)
    	local c, s = cos(phi), sin(phi)
    	self.y, self.z = self.y * c - self.z * s, self.z * c + self.y * s
end

function Vector:RotateY(phi)
    	local c, s = cos(phi), sin(phi)
    	self.x, self.z = self.x * c + self.z * s, self.z * c - self.x * s
end

function Vector:RotateZ(phi)
    	local c, s = cos(phi), sin(phi)
    	self.x, self.y = self.x * c - self.z * s, self.y * c + self.x * s
end

function Vector:Rotate(phiX, phiY, phiZ)
    	if phiX ~= 0 then self:RotateX(phiX) end
    	if phiY ~= 0 then self:RotateY(phiY) end
    	if phiZ ~= 0 then self:RotateZ(phiZ) end
end

function Vector:Rotated(phiX, phiY, phiZ)
    	local v = self:Clone()
    	v:rotate(phiX, phiY, phiZ)
    	return v
end

function Vector:Polar()
    	if Close(self.x, 0, 0) then
        	if self.z or self.y > 0 then 
        		return 90
        	elseif self.z or self.y < 0 then 
        		return 270
        	else 
        		return 0
        	end
    	else
        	local theta = deg(atan((self.z or self.y) / self.x))

        	if self.x < 0 then 
        		theta = theta + 180 
        	end

        	if theta < 0 then 
        		theta = theta + 360 
       		end

        	return theta
    	end
end

function Vector:AngleBetween(v1, v2)
    	local p1, p2 = (-self + v1), (-self + v2)
    	local theta = p1:polar() - p2:polar()

    	if theta < 0 then 
    		theta = theta + 360 
    	end

    	if theta > 180 then 
    		theta = 360 - theta 
    	end

    	return theta
end

function Vector:Perpendicular()
    	return Vector(-self.z, self.y, self.x)
end

function Vector:Perpendicular2()
    	return Vector(self.z, self.y, -self.x)
end

function Vector:Extended(to, distance)
	return self + (to - self):Normalized() * distance
end