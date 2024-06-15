-- NAME:    coli2DA
-- AUTHOR:  DuckAfire
-- VERSION: 3.0.1
-- LICENSE: Zlib License
--
-- Copyright (C) 2024 DuckAfire <duckafire.github.io/nest>
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required. 
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.



----- DEFAULT -----

local function libError(argument, options, funcName, index)
	local msg = argument -- not customized
	
	if options ~= nil then
		msg = "\nInvalid argument: "..argument.."\nTry: "
		for i = 1, #options do
			msg = msg..options[i].." | "
		end
	end

	error("\n\n[coli2DA]"..msg.."\nFunction: "..funcName.."\nParameter: #"..index.."\n")
end

----- CONSTANTS -----

local RE = "rect"
local CI = "circ"
local SI = "simp"

----- HEAD OF LIBRARY -----

local function LIB_newBody(Type, x, y, width_radius, height)
	if Type == RE then return {x = x, y = y, width  = width_radius or 8, height = height or 8} end
	if Type == CI then return {x = x, y = y, radius = width_radius or 4} end
	if Type == SI then return {x = x, y = y} end

	libError("type", {RE, CI, SI}, "newBody", 1)
end

local function ckbd(arg, types)--Check bodies: (table) all argameters; (table) type of bodies(1-2)
	-- first element (x) of current object; final bodies; adjust indexes; last arg.; CURrent arg.; arg[x] is a table
	local id, bodies, lastArg, cur, isTable, adj = 1, {{}, {}}, 0, nil, nil
	
	for i = 1, #types do
		cur, isTable, adj = arg[id], true, (types[i] == CI and 1 or types[i] == SI and 2 or 0)

		if type(cur) == "table" then
			bodies[i] = LIB_newBody(types[i], cur.x or cur[1], cur.y or cur[2], cur.width or cur.radius or cur[3], cur.height or cur[4])
			lastArg = lastArg + 1

		else
			isTable = false
			lastArg = lastArg + 4 - adj
			bodies[i] = LIB_newBody(types[i], arg[id], arg[id + 1], arg[id + 2], arg[id + 3])

		end
		
		-- to adjust index to value in next "object"
		if isTable then   id = 2   else   id = 5 - adj   end
	end
	
	return bodies[1], bodies[2], arg, lastArg + 1
end



----- GEOGRAFY AND MATHEMATICS -----

local function LIB_distance(...)
	local objA, objB = ckbd({...}, {SI, SI})

	return math.sqrt((objA.x - objB.x) ^ 2 + (objA.y - objB.y) ^ 2)
end

local function LIB_mapAlign(...)-- one rect object; boolean
	local arg = {...}
	local bodyType, obj, lastArg, x, y = (type(arg[1]) == "table" or (type(arg[1]) ~= "table" and #arg >= 4)) and RE or SI
	
	-- format: func(x, y, onCenter)
	if type(arg[1]) ~= "table" and #arg < 2 then libError("Insuficient arguments for this call format", nil, "mapAlign", "(quantity)") end
	
	obj, _, arg, lastArg = ckbd(arg, {bodyType})
	x, y = obj.x, obj.y
	
	if arg[lastArg] then-- based in the approximate center of object
		obj.width  = obj.width  or 8
		obj.height = obj.height or 8
		x = x + obj.width  // 2
		y = y + obj.height // 2
	end
	
	return (x // 8) * 8, (y // 8) * 8
end



----- MAP -----

local function LIB_tile(...)-- one rect body; collision side; id flag
	local obj, _, arg, lastArg = ckbd({...}, {RE})
	
	local w, h, flagID = obj.width, obj.height
	local x1, y1, x2, y2
	
	local flagID = arg[lastArg + 1] or 0
	local extraX = arg[lastArg + 2] or 0
	local extraY = arg[lastArg + 3] or 0
	
	if     arg[lastArg] == "top"   then x1, y1, x2, y2 =  0, -1,  w - 1, -1
	elseif arg[lastArg] == "below" then x1, y1, x2, y2 =  0,  h,  w - 1,  h
	elseif arg[lastArg] == "left"  then x1, y1, x2, y2 = -1,  0, -1,      h - 1
	elseif arg[lastArg] == "right" then x1, y1, x2, y2 =  w,  0,  w,      h - 1
	else libError("type", {"top", "below", "left", "right"}, "tile", "(last)") end
	
	return fget(mget((obj.x + x1) // 8 + extraX, (obj.y + y1) // 8 + extraY), flagID) and-- 1
		   fget(mget((obj.x + x2) // 8 + extraX, (obj.y + y2) // 8 + extraY), flagID)    -- 2
end

local function LIB_tileCross(...)-- rect object; table; bollean
	local obj, _, arg, lastArg = ckbd({...}, {RE})
	
	local flag = type(arg[lastArg + 1]) == "table" and arg[lastArg + 1] or {}
	for i = 1, 4 do   if not flag[i] or type(flag[i]) ~= "number" then   flag[i] = type(arg[lastArg + 1]) == "number" and arg[lastArg + 1] or 0   end   end
	
	local values = {}-- values
	local tag = {[0] = "top", "below", "left", "right"}
	for i = 0, 3 do   values[i] = LIB_tile(obj, tag[i], flag[i + 1], arg[lastArg + 2], arg[lastArg + 3])   end
	
	return arg[lastArg] and {top = values[0], below = values[1], left = values[2], right = values[3]} or values
end

local function LIB_box360(sx, sy, obj, flag)-- horizontal speed; vertical speed; collions sides (from "tile", "tileCross" or manually)
	local sides = LIB_tileCross(obj, false, flag)
	
	local topBelow  = sy and ((sy < 0 and sides[0]) or (sy > 0 and sides[1])) or false
	local leftRight = sx and ((sx < 0 and sides[2]) or (sx > 0 and sides[3])) or false
		
	return topBelow or leftRight
end



----- SHAPES IMPACT -----

local function LIB_rectangle(...)-- two rect bodies; boolean
	local temp  = {...}
	local isOne = type(temp[#temp]) == "boolean" and temp[#temp] or false
	local typeA = isOne and SI or RE

	local rectA, rectB = ckbd(temp, {typeA, RE})
	
	if isOne then rectA.width, rectA.height = 1, 1 end
	
	return math.max(rectA.x, rectB.x) < math.min(rectA.x + rectA.width,  rectB.x + rectB.width ) and
		   math.max(rectA.y, rectB.y) < math.min(rectA.y + rectA.height, rectB.y + rectB.height)
end

local function LIB_circle(...)-- two circ bodies; boolean
	local temp  = {...}
	local isOne = type(temp[#temp]) == "boolean" and temp[#temp] or false
	local typeA = isOne and SI or CI

	local circleA, circleB = ckbd(temp, {typeA, CI})
	
	local totalRadius = isOne and circleB.radius or circleA.radius + circleB.radius
	
	return (circleA.x - circleB.x) ^ 2 + (circleA.y - circleB.y) ^ 2 <= totalRadius ^ 2
end

local function LIB_shapesMix(...)-- circ and rect object
	local Circ, Rect = ckbd({...}, {CI, RE})

	-- circle center with rectangle; approximated rectangle center with circle
	if LIB_rectangle({Circ.x, Circ.y}, Rect, true) or LIB_circle({Rect.x + Rect.width // 2, Rect.y + Rect.height // 2}, Circ, true) then return true end

	-- create a square inside circle
	local widHei = Circ.radius * math.sqrt(2)
	if LIB_rectangle(Rect, {1 + Circ.x - widHei / 2, 1 + Circ.y - widHei / 2, widHei, widHei}) then return true end

	-- distance between vertexes and circle center
	local distID, distance = 1, {
		LIB_distance({Circ.x, Circ.y}, {Rect.x,              Rect.y              }), -- top-left
		LIB_distance({Circ.x, Circ.y}, {Rect.x + Rect.width, Rect.y              }), -- top-right
		LIB_distance({Circ.x, Circ.y}, {Rect.x,              Rect.y + Rect.height}), -- below-left
		LIB_distance({Circ.x, Circ.y}, {Rect.x + Rect.width, Rect.y + Rect.height}), -- below-right
	}
	
	-- get the vertex closest object of the circle center
	local minor, order = {distance[1], distance[2]}, {{3, 4}, {1, 3}, {2, 4}}
	for i = 1, 3 do
		if distance[order[i][1]] < minor[1] or distance[order[i][2]] < minor[2] then
			distID = i + 1
			minor[1] = distance[order[i][1]]
			minor[2] = distance[order[i][2]]
		end
	end

	-- sides that will be loaded
	local lines = {
		{{Rect.x,              Rect.y},               {Rect.x + Rect.width, Rect.y              }}, -- top
		{{Rect.x,              Rect.y + Rect.height}, {Rect.x + Rect.width, Rect.y + Rect.height}}, -- below
		{{Rect.x,              Rect.y},               {Rect.x,              Rect.y + Rect.height}}, -- left
		{{Rect.x + Rect.width, Rect.y},               {Rect.x + Rect.width, Rect.y + Rect.height}}, -- right
	}

	-- get and update the postions
	local init, final = lines[distID][1], lines[distID][2]

	while true do
		if LIB_circle({init[1], init[2]}, Circ, true)  then return true  end -- point of collision
		if init[1] == final[1] and init[2] == final[2] then return false end -- end of loop

		init[1] = (init[1] + 1 < final[1]) and init[1] + 1 or final[1] -- x
		init[2] = (init[2] + 1 < final[2]) and init[2] + 1 or final[2] -- y
	end
end



----- CURSOR / TOUCH -----

local function LIB_touch(initX, initY, finalX, finalY, dimensions)-- cursor dimensions
	local cursor = {}
	cursor.x, cursor.y = mouse()
	
	dimensions = dimensions or {}
	cursor.width  = dimensions.width  and math.abs(dimensions.width ) or dimensions[1] and math.abs(dimensions[1]) or 1-- only positive values
	cursor.height = dimensions.height and math.abs(dimensions.height) or dimensions[2] and math.abs(dimensions[2]) or 1
	
	return LIB_rectangle(cursor, {initX, initY, finalX, finalY})
end



----- POINT OF IMPACT -----

local function LIB_impactPixel(...)-- two any bodies; collision type
	local temp = {...}
	local tID = type(temp[#temp]) == "boolean" and #temp - 1 or #temp

	if temp[tID] ~= RE and temp[tID] ~= CI then libError("type", {RE, CI}, "impactPixel", "(first)") end

	local mixA, mixB, arg, _ = ckbd(temp, {temp[tID], temp[tID]})

	if     arg[tID] == RE then
		if not arg[tID + 1] and not LIB_rectangle(mixA, mixB) then return nil, nil end

		local newMixA = {  x = mixA.x + mixA.width / 2,   y = mixA.y + mixA.height / 2,   radius = (mixA.width + mixA.height) / 2  }
		local newMixB = {  x = mixB.x + mixB.width / 2,   y = mixB.y + mixB.height / 2,   radius = (mixB.width + mixB.height) / 2  }
		
		return LIB_impactPixel(newMixA, newMixB, CI, true)-- "tranform" all in circles 0o0
	end
	
	if arg[tID] == CI then
		if not arg[tID + 1] and not LIB_circle(mixA, mixB) then return nil, nil end

		local x = (mixA.x * mixB.radius) + (mixB.x * mixA.radius)
		local y = (mixA.y * mixB.radius) + (mixB.y * mixA.radius)
		local totalRadius = (mixA.radius + mixB.radius)
	
		return x / totalRadius, y / totalRadius
		
	end
end
