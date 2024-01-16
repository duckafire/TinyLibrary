local AUTHOR  = "DuckAfire"
local VERSION = "1.6.4"

local FOLLOW_ME = {
	Itch     = "http://duckafire.itch.io",
	GitHub   = "http://github.com/duckafire",
	Tic80    = "http://tic80.com/dev?id=8700",
	Facebook = "http://facebook.com/duckafire"
}

local LICENSE = [[

	MIT License

	Copyright (c) 2024 DuckAfire

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

]]



----- HEAD OF LIBRARY -----

local function newBody( Type, x, y, width_radius, height )
	local body = { x = x or 0, y = y or 0 }
	
	if     Type == "rect" then
		body.width  = width_radius or 0
		body.height = height or 0
	elseif Type == "circ" then
		body.radius = width_radius or 0
	elseif Type ~= "simp" then
		error( '[coli2DA] The parameter "Type" is invalid, try "rect" or "circ" (function: "coli2DA.newBody")' ) 
	end
	
	return body
end

local function checkBodies( par, types )-- all parameters; type of bodies(max: 2)
	local id, bodies, lastPar = 1, { {}, {} }, 0-- "lastPar" store the position (id) of last parameter, used in a body, more one.
	
	for i = 1, #types do
		local adj = types[i] == "circ" and 1 or types[i] == "simp" and 2 or 0-- ADJust parameters indexs (id and lastPar)
		local cur = par[ id ]-- CURrent parameter to check
		local res = 0-- result of conditions

		if type( cur ) == "table" then-- 1, 2 (0)
			if cur.x then   bodies[i] = cur   else   bodies[i] = newBody( types[i], cur[1], cur[2], cur[3], cur[4] )   end
			lastPar = lastPar + 1
		else-- 3
			res, bodies[i] = 3, newBody( types[i], par[id], par[id + 1], par[id + 2], par[id + 3] )
			lastPar = lastPar + 4 - adj
		end
		
		-- update "id" to check the next parameter
		if res == 3 then   id = 5 - adj   else   id = 2   end

	end
	
	return bodies[1], bodies[2], par, lastPar + 1
end



----- GEOGRAFY AND MATHEMATICS -----

local function distance( ... )-- two simp object
	local objA, objB = checkBodies( { ... }, { "simp", "simp" } )
	return math.sqrt( ( objA.x - objB.x ) ^ 2 + ( objA.y - objB.y ) ^ 2 )
end

local function mapAlign( ... )-- two rect object; boolean
	local par = { ... }
	if type(par[1]) ~= "table" and #par < 4 then error( '[coli2DA] Parameters not expecified in table "mapAlign".' ) end-- check if the values "width" and "height" exist, in format: func( 10, 10, 10, 10, (false/true) )
	local obj, _, par, lastPar = checkBodies( par, { "rect" } )
	
	local x, y = obj.x, obj.y
	
	if par[ lastPar ] then-- based in the approximate center of object
		local width  = obj.width  or 8
		local height = obj.height or 8
		x = x + width  // 2
		y = y + height // 2
	end
	
	return (x // 8) * 8, (y // 8) * 8
end



----- MAP -----

local function tile( ... )-- rect object; type; id flag (optional)
	local obj, _, par, lastPar = checkBodies( { ... }, { "rect" } )
	
	local w, h, flagID = obj.width, obj.height, par[ lastPar + 1 ] or 0
	local x1, y1, x2, y2-- to add XY
	
	if     par[ lastPar ] == "top"   then x1, y1, x2, y2 =  0, -1,  w - 1, -1
	elseif par[ lastPar ] == "below" then x1, y1, x2, y2 =  0,  h,  w - 1,  h
	elseif par[ lastPar ] == "left"  then x1, y1, x2, y2 = -1,  0, -1,      h - 1
	elseif par[ lastPar ] == "right" then x1, y1, x2, y2 =  w,  0,  w,      h - 1
	else error( '[coli2DA] The parameter "Type" is invalid, try "top", "below", "left" or "right" (function: "coli2DA.tile")' ) end
	
	return fget( mget( (obj.x + x1) // 8, (obj.y + y1) // 8), flagID ) and-- 1
		   fget( mget( (obj.x + x2) // 8, (obj.y + y2) // 8), flagID )	-- 2
end

local function tileCross( ... )-- rect object; bollean
	local obj, _, par, lastPar = checkBodies( { ... }, { "rect" } )
	return par[ lastPar ] and { top = tile( obj, "top" ), below = tile( obj, "below" ), left = tile( obj, "left" ), right = tile( obj, "right" ) } or
							  { 	  tile( obj, "top" ), 		  tile( obj, "below" ), 	   tile( obj, "left" ), 		tile( obj, "right" ) }
end



-- CURSOR / TOUCH -------------------------------------------------------------

local function touch( ... )-- two rect object (2st is optional)
	local obj, cursor = checkBodies( { ... }, { "rect", "rect" } )
	
	cursor.x, cursor.y = mouse()
	
	cursor.width  = cursor.width  and math.abs( cursor.width  ) or 1-- only positive values
	cursor.height = cursor.height and math.abs( cursor.height ) or 1
	
	return cursor.x + cursor.width  - 1 >= obj.x					  and
		   cursor.x						<= obj.x + obj.width  - obj.x and
		   cursor.y + cursor.height - 1 >= obj.y					  and
		   cursor.y						<= obj.y + obj.height - obj.y
end



-- POINT OF IMPACT -------------------------------------------------------------

local function impactPixel( ... )-- two objects (rect-rect; circ-circ; circ-rect); collision type
	local temp, typeA, typeB = { ... }

	if     temp[#temp] == "rect" then typeA, typeB = "rect", "rect"-- 
	elseif temp[#temp] == "circ" then typeA, typeB = "circ", "circ"
	elseif temp[#temp] == "mix"  then typeA, typeB = "circ", "rect"
	else error( '[coli2DA] The parameter "Type" is invalid, try "rect", "circ" or "mix" (function "coli2DA.impactPixel")' )
	end

	local mixA, mixB, par, lastPar = checkBodies( temp, { typeA, typeB } )

	if 	   par[ lastPar ] == "rect" then
		local newMixA = {   x = mixA.x + mixA.width / 2,   y = mixA.y + mixA.height / 2,   radius = (mixA.width + mixA.height) / 2   }
		local newMixB = {   x = mixB.x + mixB.width / 2,   y = mixB.y + mixB.height / 2,   radius = (mixB.width + mixB.height) / 2   }
		return impactPixel( newMixA, newMixB, "circ" )-- "tranform" all in circles
	
	elseif par[ lastPar ] == "circ" then
		local x = (mixA.x * mixB.radius) + (mixB.x * mixA.radius)
		local y = (mixA.y * mixB.radius) + (mixB.y * mixA.radius) 
		
		local totalRadius = (mixA.radius + mixB.radius)
	
		return x / totalRadius, y / totalRadius
	
	elseif par[ lastPar ] == "mix"  then
		local x, y
		
		local Circ = {   x = mixA.x,   y = mixA.y,   radius = mixA.radius   }
		
		local Rect = {   top = mixB.x,   below = mixB.y + mixB.height - 1,   left = mixB.y,   right = mixB.y + mixB.width - 1   }
	
		if Circ.x <= Rect.left then   x = Rect.left   elseif Circ.x > Rect.right then   x = Rect.right   else   x = Circ.x   end
		if Circ.y <= Rect.top  then   y = Rect.top    elseif Circ.y > Rect.below then   y = Rect.below   else   y = Circ.y   end
	
		return x, y
	
	end
end



-- SHAPES IMPACT -------------------------------------------------------------

local function rectangle( ... )-- two rect object
	local rectA, rectB = checkBodies( { ... }, { "rect", "rect" } )

	local rectAW, rectAH = rectA.width or 1, rectA.height or 1--default is zero
	local rectBW, rectBH = rectB.width or 1, rectB.height or 1
	
	rectAW, rectAH = math.abs(rectAW) - 1, math.abs(rectAH) - 1-- only positive numbers
	rectBW, rectBH = math.abs(rectBW) - 1, math.abs(rectBH) - 1
	
	return rectA.x + rectAW >= rectB.x			and
		   rectA.x			<= rectB.x + rectBW and
		   rectA.y + rectAH >= rectB.y			and
		   rectA.y			<= rectB.y + rectBH
end

local function circle( ... )
	local circleA, circleB, par, lastPar = checkBodies( { ... }, { "circ", "circ" } )
	
	local totalRadius = par[ lastPar ] and circleA.radius + circleB.radius or circleB.radius
	
	return ( circleA.x - circleB.x ) ^ 2 + ( circleA.y - circleB.y ) ^ 2 <= totalRadius ^ 2
end

local function shapesMix( ... )-- circ and rect object
	local Circ, Rect = checkBodies( { ... }, { "circ", "rect" } )

	local tempCircle = {}
	
	tempCircle.radius = 0
	tempCircle.x, tempCircle.y = impactPixel( Circ, Rect, "mix" )-- "transform" the rectangle in a circle

	return circle( tempCircle, Circ )-- collision between Circ and Rect (now is a "circle")
end


-- ADD TO TABLE -------------------------------------------------------------

local coli2DA = {}

coli2DA.newBody 	= newBody
coli2DA.distance 	= distance
coli2DA.mapAlign 	= mapAlign
coli2DA.tileCross 	= tileCross
coli2DA.tile 		= tile
coli2DA.touch 		= touch
coli2DA.impactPixel = impactPixel
coli2DA.rectangle 	= rectangle
coli2DA.circle 		= circle
coli2DA.shapeMix 	= shapeMix

return coli2DA
