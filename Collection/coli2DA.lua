-- Copy and paste the code in your cart [v: 1.4.6]

local coli2DA = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- HEAD OF LIBRARY -----
	
	local function newBody( Type, x, y, width_radius, height )
		local body = { x = x, y = y }
		
		if     Type == "rect" then
			body.width  = width_radius
			body.height = height
		elseif Type == "circ" then
			body.radius = width_radius
		elseif Type ~= "xy" then
			error( 'The parameter "Type" is invalid, try "rect" or "circ" (function: "coli2DA.newBody")' ) 
		end
		
		return body
	end

	local function checkBodies( par, types )-- all parameters; type of bodies(max: 2)
		local id, bodies, lastPar = 1, { {}, {} }, 0-- "lastPar" store the position (id) of last parameter, used in a body, more one.
		
		for i = 1, #types do
			local adj = types[i] == "circ" and 1 or types[i] == "xy" and 2 or 0-- ADJust parameters indexs (id and lastPar)
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

	local function distance( ... )
		local objA, objB = checkBodies( { ... }, { "xy", "xy" } )
		return math.sqrt( ( objA.x - objB.x ) ^ 2 + ( objA.y - objB.y ) ^ 2 )
	end

end
--[[
newBody
distance
]]

function tileCross( ... )
	local par = { ... }
	local obj = checkBody( "rect", par )
	local Type = type( par[2] ) == "boolean" and par[2] or par[5]
	local collisions = Type and { top = tile( obj, "top" ), below = tile( obj, "below" ), left = tile( obj, "left" ), right = tile( obj, "right" ) } or { tile( obj, "top" ), tile( obj, "below" ), tile( obj, "left" ), tile( obj, "right" ) }
	return collisions
end

local function mapAlign( ... )
	local obj, _, par, lastPar = checkBodies( { ... }, { "rect" } )
	
	if par[ lastPar ] then-- based in the approximate center of object
		obj.x = obj.x + obj.width  // 2
		obj.y = obj.y + obj.height // 2
	end
	
	return (obj.x // 8) * 8, (obj.y // 8) * 8
end


local function tileCross( ... )
	local par = { ... }
	local obj = checkBody( "rect", par )
	local Type = type( par[2] ) == "boolean" and par[2] or par[5]
	local collisions = Type and { top = tile( obj, "top" ), below = tile( obj, "below" ), left = tile( obj, "left" ), right = tile( obj, "right" ) } or { tile( obj, "top" ), tile( obj, "below" ), tile( obj, "left" ), tile( obj, "right" ) }
	return collisions
end

do
	-- CREATE BODIES -------------------------------------------------------------
	
	local function newBody( Type, x, y, width_radius, height )
		if     Type == "rect" then
			return { x = x, y = y, width = width_radius, height = height }
		elseif Type == "circ" then
			return { x = x, y = y, radius = width_radius }
		else
			error( 'The parameter "Type" is invalid, try "rect" or "circ" (function: "coli2DA.newBody")' ) 
		end
	end
	
	local function checkBody( Type, body, initID )-- internal function
		local id = initID or 1
		
		if type( body[id] ) == "table" then
			if body[id].x then
				return body[id]
			else
				return newBody( Type, body[id][1], body[id][2], body[id][3], body[id][4] )
			end
		else
			return newBody( Type, body[id], body[1 + id], body[2 + id], body[3 + id] )
		end
	
	end
	
	-- MAP TILES -------------------------------------------------------------

	local function tile( obj, Type, tileID )
		local w, h, tile = obj.width or 8, obj.height or 8, tileID or 0
		local x1, y1, x2, y2-- to add XY
			
		if     Type == "top"   then x1, y1, x2, y2 =  0, -1,  w - 1, -1
		elseif Type == "below" then x1, y1, x2, y2 =  0,  h,  w - 1,  h
		elseif Type == "left"  then x1, y1, x2, y2 = -1,  0, -1,      h - 1
		elseif Type == "right" then x1, y1, x2, y2 =  w,  0,  w,      h - 1
		else error( 'The parameter "Type" is invalid, try "top", "below", "left" or "right" (function: "coli2DA.tile")' ) end
		
		return fget( mget( (obj.x + x1) // 8, (obj.y + y1) // 8), tile ) and-- 1
			   fget( mget( (obj.x + x2) // 8, (obj.y + y2) // 8), tile )	-- 2
	end

	-- CURSOR / TOUCH -------------------------------------------------------------

	local function touch( ... )
		local obj	 = checkBody( "rect", { ... } )
		local cursor = checkBody( "rect", { ... }, 5 )
		
		cursor.x, cursor.y = mouse()
		
		cursor.width  = cursor.width  and math.abs( cursor.width  ) or 0-- only positive values
		cursor.height = cursor.height and math.abs( cursor.height ) or 0
		
		return cursor.x + cursor.width  - 1 >= obj.x				  and
			   cursor.x						<= obj.x + obj.width  - 1 and
			   cursor.y + cursor.height - 1 >= obj.y				  and
			   cursor.y						<= obj.y + obj.height - 1
	end

	-- POINT OF IMPACT -------------------------------------------------------------

	local function impactPixel( Type, mixA, mixB )
		if 	   Type == "rect" then
			local newMixA = {   x = mixA.x + mixA.width / 2,   y = mixA.y + mixA.height / 2,   radius = (mixA.width + mixA.height) / 2   }
			local newMixB = {   x = mixB.x + mixB.width / 2,   y = mixB.y + mixB.height / 2,   radius = (mixB.width + mixB.height) / 2   }
			return impactPixel( "circ", newMixA, newMixB )-- "tranform" all in circles
		
		elseif Type == "circ" then
			local x = (mixA.x * mixB.radius) + (mixB.x * mixA.radius)
			local y = (mixA.y * mixB.radius) + (mixB.y * mixA.radius) 
			
			local totalRadius = (mixA.radius + mixB.radius)
		
			return x / totalRadius, y / totalRadius
		
		elseif Type == "mix"  then
			local x, y
			
			local Circ = {   x = mixA.x,   y = mixA.y,   radius = mixA.radius   }
			
			local Rect = {   top = mixB.x,   below = mixB.y + mixB.height - 1,   left = mixB.y,   right = mixB.y + mixB.width - 1   }
		
			if Circ.x <= Rect.left then   x = Rect.left   elseif Circ.x > Rect.right then   x = Rect.right   else   x = Circ.x   end
			if Circ.y <= Rect.top  then   y = Rect.top    elseif Circ.y > Rect.below then   y = Rect.below   else   y = Circ.y   end
		
			return x, y
		
		else
			error( 'The parameter "Type" is invalid, try "rect", "circ" or "mix" (function "coli2DA.impactPixel")' )
		end
	end

	-- SHAPES IMPACT -------------------------------------------------------------

	local function rectangle( ... )
		local rectA = checkBody( "rect", { ... } )
		local rectB = checkBody( "rect", { ... }, 5 )
	
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
		local par = { ... }-- to use in "twoBodies"
		local circleA = checkBody( "circ", par )
		local circleB = checkBody( "circ", par, 4 )
		
		local twoBodies   = type(par[3]) == "boolean" and par[3] or type(par[7]) == "boolean" and par[7] or false
		local totalRadius = twoBodies and circleA.radius + circleB.radius or circleB.radius
		
		return ( circleA.x - circleB.x ) ^ 2 + ( circleA.y - circleB.y ) ^ 2 <= totalRadius ^ 2
	end

	local function shapesMix( ... )
		local Circ = checkBody( "circ", { ... } )
		local Rect = checkBody( "rect", { ... }, 4 )
	
		local tempCircle = {}
		
		tempCircle.radius = 0
		tempCircle.x, tempCircle.y = impactPixel( "mix", Circ, Rect )-- "transform" the rectangle in a circle

		return circle( tempCircle, Circ )-- collision between Circ and Rect (now is a "circle")
	end
	
	-- ADD TO TABLE -------------------------------------------------------------
	
	coli2DA.newBody			= newBody
	coli2DA.tile			= tile
	coli2DA.touch			= touch
	coli2DA.impactPixel		= impactPixel
	coli2DA.rectagle		= rectangle
	coli2DA.circle			= circle
	coli2DA.shapesMix		= shapesMix
	
end

local coli = coli2DA -- library reference

-- NOTE: in functions ".shapeMix" and ".impactPixel"(in mode "mix"), only the "circle" can move, because moving the "square/rectangle" will generate unexpected results.