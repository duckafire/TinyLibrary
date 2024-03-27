-- NAME:    coli2DA
-- AUTHOR:  DuckAfire
-- VERSION: 2.7

-- FOLLOW_ME:
	-- Itch:     http://duckafire.itch.io
	-- GitHub:   http://github.com/duckafire
	-- Tic80:    http://tic80.com/dev?id=8700
	-- Facebook: http://facebook.com/duckafire

-- LICENSE:
	-- MIT License

	-- Copyright (c) 2024 DuckAfire

	-- Permission is hereby granted, free of charge, to any person obtaining a copy
	-- of this software and associated documentation files (the "Software"), to deal
	-- in the Software without restriction, including without limitation the rights
	-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	-- copies of the Software, and to permit persons to whom the Software is
	-- furnished to do so, subject to the following conditions:

	-- The above copyright notice and this permission notice shall be included in all
	-- copies or substantial portions of the Software.

	-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	-- SOFTWARE.



----- HEAD OF LIBRARY -----

local function newBody( Type, x, y, width_radius, height )
	local body = { x = x or 0, y = y or 0 }
	
	if     Type == "rect" then
		body.width  = width_radius or 8
		body.height = height or 8
	elseif Type == "circ" then
		body.radius = width_radius or 4
	elseif Type ~= "simp" then
		error( '[coli2DA] The parameter "Type" is invalid, try "rect", "circ" or "simp". In function "coli.newBody", argument #1.' ) 
	end
	
	return body
end

local function checkBodies( par, types )-- (table) all parameters; (table) type of bodies(max: 2)
	local id      = 1		  -- index of current parameter
	local bodies  = { {}, {} }-- final bodies
	local lastPar = 0		  -- store the position (id) of last parameter, used in a body, more one.
	
	for i = 1, #types do
		local adj = types[i] == "circ" and 1 or types[i] == "simp" and 2 or 0-- ADJust parameters indexs (id and lastPar)
		local cur = par[ id ]-- CURrent parameter to check
		local res = 0-- RESult of conditions

		if type( cur ) == "table" then-- res = 1, 2 (0)
			bodies[i] = newBody( types[i], cur.x or cur[1], cur.y or cur[2], cur.width or cur.radius or cur[3], cur.height or cur[4] )
			lastPar = lastPar + 1

		else-- res = 3
			bodies[i] = newBody( types[i], par[id], par[id + 1], par[id + 2], par[id + 3] )
			res = 3
			lastPar = lastPar + 4 - adj

		end
		
		-- update "id" to check the next parameter
		if res == 3 then   id = 5 - adj   else   id = 2   end

	end
	
	return bodies[1], bodies[2], par, lastPar + 1
end



----- GEOGRAFY AND MATHEMATICS -----

local function distance( ... )-- two any bodies
	local objA, objB = checkBodies( { ... }, { "simp", "simp" } )
	return math.sqrt( ( objA.x - objB.x ) ^ 2 + ( objA.y - objB.y ) ^ 2 )
end

local function mapAlign( ... )-- one rect object; boolean
	local Par      = { ... }
	local bodyType = (type( Par[1] ) == "table" or (type( Par[1] ) ~= "table" and #Par >= 4)) and "rect" or "simp"
	
	-- if the format is: func( x, y, onCenter )
	if type( Par[1] ) ~= "table" and #Par < 2 then error( '[coli2DA] Insufficient parameters for this call format. In function "coli.mapAlign", argument #(quantity).' ) end
	
	local obj, _, par, lastPar = checkBodies( Par, { bodyType } )
	
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

local function tile( ... )-- one rect body; collision side; id flag
	local obj, _, par, lastPar = checkBodies( { ... }, { "rect" } )
	
	local w, h, flagID = obj.width, obj.height
	local x1, y1, x2, y2-- to add XY
	
	local flagID = par[ lastPar + 1 ] or 0
	local extraX = par[ lastPar + 2 ] or 0
	local extraY = par[ lastPar + 3 ] or 0
	
	if     par[ lastPar ] == "top"   then x1, y1, x2, y2 =  0, -1,  w - 1, -1
	elseif par[ lastPar ] == "below" then x1, y1, x2, y2 =  0,  h,  w - 1,  h
	elseif par[ lastPar ] == "left"  then x1, y1, x2, y2 = -1,  0, -1,      h - 1
	elseif par[ lastPar ] == "right" then x1, y1, x2, y2 =  w,  0,  w,      h - 1
	else error( '[coli2DA] The parameter "Type" is invalid, try "top", "below", "left" or "right". In function: "coli.tile", argument #(last).' ) end
	
	return fget( mget( (obj.x + x1) // 8 + extraX, (obj.y + y1) // 8 + extraY), flagID ) and-- 1
		   fget( mget( (obj.x + x2) // 8 + extraX, (obj.y + y2) // 8 + extraY), flagID )	-- 2
end

local function tileCross( ... )-- rect object; table; bollean
	local obj, _, par, lastPar = checkBodies( { ... }, { "rect" } )
	
	local flag = type( par[ lastPar + 1 ] ) == "table" and par[ lastPar + 1 ] or {}
	for i = 1, 4 do   if not flag[i] or type( flag[i] ) ~= "number" then   flag[i] = type( par[ lastPar + 1 ] ) == "number" and par[ lastPar + 1 ] or 0   end   end
	
	-- extra values to adjust map position
	local a, b = par[ lastPar + 2 ], par[ lastPar + 3 ]
	
	local values = {}-- values
	local tag = { [0] = "top", "below", "left", "right" }
	for i = 0, 3 do values[i] = tile( obj, tag[i], flag[ i + 1 ], a, b ) end
	
	return par[ lastPar ] and { top = values[0], below = value[1], left = value[2], right = value[3] } or value
end

local function box360(sx, sy, side)-- horizontal speed; vertical speed; collions sides (from "tile", "tileCross" or manually)
	local topBelow, leftRight
	
	if side.top then
		topBelow  = sy and ((sy < 0 and side.top)  or (sy > 0 and side.below)) or false
		leftRight = sx and ((sx < 0 and side.left) or (sx > 0 and side.right)) or false
		
	else
		topBelow  = sy and ((sy < 0 and side[0]) or (sy > 0 and side[1])) or false
		leftRight = sx and ((sx < 0 and side[2]) or (sx > 0 and side[3])) or false
		
	end
	
	return topBelow or leftRight
end



----- CURSOR / TOUCH -----

local function touch( initX, initY, finalX, finalY, dimensions )-- cursor dimensions
	local cursor, dimensions = {}, dimensions or {}
	cursor.x, cursor.y = mouse()
	
	cursor.width  = dimensions.width  and math.abs( dimensions.width  ) or dimensions[1] and math.abs( dimensions[1] ) or 1-- only positive values
	cursor.height = dimensions.height and math.abs( dimensions.height ) or dimensions[2] and math.abs( dimensions[2] ) or 1
	
	return cursor.x + cursor.width  - 1 >= initX  and-- adjust the cursor dimensions
		   cursor.x						<= finalX and
		   cursor.y + cursor.height - 1 >= initY  and
		   cursor.y						<= finalY
end



----- POINT OF IMPACT -----

local function impactPixel( ... )-- two any bodies; collision type
	local temp = { ... }

	if temp[#temp] ~= "rect" and temp[#temp] ~= "circ" then error( '[coli2DA] The parameter "Type" is invalid, try "rect" or "circ". In function "coli.impactPixel, argument #(first)."' ) end

	local mixA, mixB, par, lastPar = checkBodies( temp, { temp[#temp], temp[#temp] } )

	if 	   par[ lastPar ] == "rect" then
		local newMixA = {   x = mixA.x + mixA.width / 2,   y = mixA.y + mixA.height / 2,   radius = (mixA.width + mixA.height) / 2   }
		local newMixB = {   x = mixB.x + mixB.width / 2,   y = mixB.y + mixB.height / 2,   radius = (mixB.width + mixB.height) / 2   }
		return impactPixel( newMixA, newMixB, "circ" )-- "tranform" all in circles 0o0
	
	elseif par[ lastPar ] == "circ" then
		local x = (mixA.x * mixB.radius) + (mixB.x * mixA.radius)
		local y = (mixA.y * mixB.radius) + (mixB.y * mixA.radius) 
		
		local totalRadius = (mixA.radius + mixB.radius)
	
		return x / totalRadius, y / totalRadius
		
	end
end



----- SHAPES IMPACT -----

local function rectangle( ... )-- two rect bodies; boolean
	local temp  = { ... }
	local isOne = type( temp[ #temp ] ) == "boolean" and temp[ #temp ] or false
	local typeA = isOne and "simp" or "rect"

	local rectA, rectB = checkBodies( temp, { typeA, "rect" } )
	
	if isOne then rectA.width, rectA.height = 1, 1 end
	
	return rectA.x + rectA.width  - 1 >= rectB.x				    and
		   rectA.x					  <= rectB.x + rectB.width  - 1 and
		   rectA.y + rectA.height - 1 >= rectB.y				    and
		   rectA.y					  <= rectB.y + rectB.height - 1
end

local function circle( ... )-- two circ bodies; boolean
	local temp  = { ... }
	local isOne = type( temp[ #temp ] ) == "boolean" and temp[ #temp ] or false
	local typeA = isOne and "simp" or "circ"

	local circleA, circleB = checkBodies( temp, { typeA, "circ" } )
	
	local totalRadius = isOne and circleB.radius or circleA.radius + circleB.radius
	
	return ( circleA.x - circleB.x ) ^ 2 + ( circleA.y - circleB.y ) ^ 2 <= totalRadius ^ 2
end

local function shapesMix( ... )-- circ and rect object
	local Circ, Rect = checkBodies( { ... }, { "circ", "rect" } )
	
	-- transform the circle in a square/rect body
	local square = newBody("rect", Circ.x - Circ.radius, Circ.y - Circ.radius, Circ.radius * 2 + 1, Circ.radius * 2 + 1)
	
	local x, y = impactPixel(Rect, square, "rect")
	
	return rectangle({x, y}, Rect, true) or circle({x, y}, Circ, true)
end



-- ADD TO TABLE -------------------------------------------------------------

local coli2DA = {}

coli2DA.newBody 	= newBody
coli2DA.distance 	= distance
coli2DA.mapAlign 	= mapAlign
coli2DA.tile 		= tile
coli2DA.tileCross 	= tileCross
coli2DA.box360		= box360
coli2DA.touch 		= touch
coli2DA.impactPixel = impactPixel
coli2DA.rectangle 	= rectangle
coli2DA.circle 		= circle
coli2DA.shapeMix 	= shapeMix

return coli2DA

-- NOTES:
---- In function "impactPixel" (using "rect"), if any of the bodies is a rectangle with a large difference in size between its pairs of sides (e.g., 5x30), the returned result may is incorrect.
