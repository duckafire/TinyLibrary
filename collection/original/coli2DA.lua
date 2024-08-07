-- NAME:    coli2DA
-- AUTHOR:  DuckAfire
-- VERSION: 4.0.1
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

local function libError(condAssert, par, msg, opt, func, id)
	-- "assert" be like
	if condAssert ~= nil then
		if not condAssert then return end
	end
	
	local default = {"Error", "Function", "Index"}
	local text = {nil, func, "#"..id}
	local full = "\n\n[coli2DA]"

	par = par and '"'..par..'"' or ""
	local function cat(str) text[1] = par..str end

	if     msg == "1" then cat("was not specified")
	elseif msg == "2" then cat("was not defined")
	elseif msg == "3" then cat("is invalid")
	else                   cat(msg)
	end

	for i = 1, 3 do
		full = full.."\n"..default[i]..": "..text[i].."."

		if i == 1 and opt ~= nil then
			full = full.."\nTry: "
			for j = 1, #opt - 1 do full = full..opt[i].." | " end
			full = full..opt[#opt] -- without '|'
		end
	end

	trace("\n>\n>\n>")
	error(full.."\n")
end

----- VARIABLES AND TABLES -----

local RE = "rect"
local CI = "circ"
local SI = "simp"
local W  = "width"
local H  = "height"
local R  = "radius"
local ByBd  = 1
local OrgBd = {"newBody", "distance", "mapAlign", "tile", "tileCross", "rectangle", "circle", "shapesMix", "impactPixel"}
-- local RE, CI, SI, W, H, R = "rect", "circ", "simp", "width", "height", "radius" -- constants
-- local ByBd, OrgBd = 1, {"newBody", "distance", "mapAlign", "tile", "tileCross", "rectangle", "circle", "shapesMix", "impactPixel"} -- to errors in body



----- HEAD OF LIBRARY -----

local function LIB_newBody(Type, x, y, width_radius, height)
	local new = nil

	if     Type == RE then new = {x = x, y = y, width  = width_radius or 8, height = height or 8}
	elseif Type == CI then new = {x = x, y = y, radius = width_radius or 4}
	elseif Type == SI then new = {x = x, y = y}
	end

	libError(new == nil, "type", "3", {RE, CI, SI}, OrgBd[ByBd], 1)

	local par = {"x", "y"}
	for i = 1, 2 do   libError(new[par[i]] == nil, par[i], "3", nil, OrgBd[ByBd], 1 + i)   end

	return new
end

local function ckbd(_bodies, types, id) -- internal function
	ByBd = id
	
	-- break adress link
	local bodies, nodes, length
	
	bodies = {}
	nodes  = {"x", "y", "width", "height"} -- "only" RECT and SIMP
	length = {[RE] = 4, [CI] = 3, [SI] = 2}

	for i = 1, #_bodies do
		bodies[i] = {}
		for j = 1, length[types[i]] do
			if types[i] == CI and j == 3 and _bodies[i][R] ~= nil then
				bodies[i][j] = _bodies[i][R]
			else
				bodies[i][j] = _bodies[i][nodes[j]] or _bodies[i][j]
			end
		end
	end
	
	-- create
	local new = {}
	
	for i = 1, #_bodies do
		new[i] = LIB_newBody(
			types[i],
			bodies[i].x  or bodies[i][1],
			bodies[i].y  or bodies[i][2],
			bodies[i][W] or bodies[i][R] or bodies[i][3],
			bodies[i][H] or bodies[i][4]
		)
	end
	
	ByBd = 1
	return table.unpack(new)
end



----- GEOGRAFY AND MATH -----

local function LIB_distance(objA, objB)
	objA, objB = ckbd({objA, objB}, {SI, SI}, 2)

	return math.sqrt((objA.x - objB.x) ^ 2 + (objA.y - objB.y) ^ 2)
end

local function LIB_mapAlign(obj, onCenter)
	obj = ckbd({obj}, {(onCenter) and RE or SI}, 3)
	
	if onCenter then -- aproximmated
		obj[W] = obj[W] or 8
		obj[H] = obj[H] or 8
		obj.x  = obj.x + obj[W] // 2
		obj.y  = obj.y + obj[H] // 2
	end
	
	return (obj.x // 8) * 8, (obj.y // 8) * 8
end



----- MAP -----

local function LIB_tile(obj, Type, flag, mapX, mapY)
	obj = ckbd({obj}, {RE}, 4)
	
	mapX = mapX or 0
	mapY = mapY or 0

	local x1, y1, x2, y2
	local w, h = obj[W], obj[H]
	
	if     Type == "top"   then x1, y1, x2, y2 =  0, -1,  w - 1, -1
	elseif Type == "below" then x1, y1, x2, y2 =  0,  h,  w - 1,  h
	elseif Type == "left"  then x1, y1, x2, y2 = -1,  0, -1,      h - 1
	elseif Type == "right" then x1, y1, x2, y2 =  w,  0,  w,      h - 1
	else libError(nil, "type", "3", {"top", "below", "left", "right"}, "tile", "(last)") end
	
	return fget(mget((obj.x + x1) // 8 + mapX, (obj.y + y1) // 8 + mapY), flag) and
	       fget(mget((obj.x + x2) // 8 + mapX, (obj.y + y2) // 8 + mapY), flag)
end

local function LIB_tileCross(obj, associative, flag, mapX, mapY)
	obj = ckbd({obj}, {RE}, 5)
	
	-- Flag TaBLe
	local ftbl = {}
	for i = 1, 4 do
		-- number | 0 | table values
		ftbl[i] = (type(flag) == "number") and flag or (type(flag) ~= "table") and 0 or flag[i]
	end
	
	local values = {}
	local tag = {"top", "below", "left", "right"}
	for i = 0, 3 do
		values[i] = LIB_tile(obj, tag[i + 1], ftbl[i + 1], mapX, mapY)
	end
	
	return (associative) and {top = values[0], below = values[1], left = values[2], right = values[3]} or values
end

local function LIB_box360(sx, sy, obj, flag, adjstX, adjstY)
	local sides = LIB_tileCross(obj, false, flag, adjstX, adjstY)
	
	local topBelow  = sy and ((sy < 0 and sides[0]) or (sy > 0 and sides[1])) or false
	local leftRight = sx and ((sx < 0 and sides[2]) or (sx > 0 and sides[3])) or false
		
	return topBelow or leftRight
end



----- SHAPES IMPACT -----

local function LIB_rectangle(RectA, RectB)
	local rects, nodes = {RectA, RectB}, {W, H}
	for i = 1, 2 do
		for j = 3, 4 do
			if not rects[i][j] and not rects[i][nodes[j]] then
				rects[i][j] = 1
			end
		end
	end
	
	rects[1], rects[2] = ckbd({rects[1], rects[2]}, {RE, RE}, 6)

	return math.max(rects[1].x, rects[2].x) < math.min(rects[1].x + rects[1][W], rects[2].x + rects[2][W]) and
	       math.max(rects[1].y, rects[2].y) < math.min(rects[1].y + rects[1][H], rects[2].y + rects[2][H])
end

local function LIB_circle(CircA, CircB)-- two circ bodies; boolean
	local circs = {CircA, CircB}
	for i = 1, 2 do
		if not circs[i][3] and not circs[i][R] then
			circs[i][3] = 0
		end
	end

	circs[1], circs[2] = ckbd({circs[1], circs[2]}, {CI, CI}, 7)
	return (circs[1].x - circs[2].x) ^ 2 + (circs[1].y - circs[2].y) ^ 2 <= (circs[1][R] + circs[2][R]) ^ 2
end

local function LIB_shapesMix(Circ, Rect)-- circ and rect object
	Circ, Rect = ckbd({Circ, Rect}, {CI, RE}, 8)

	-- circle center with rectangle; approximated rectangle center with circle
	if LIB_rectangle({Circ.x, Circ.y}, Rect) or LIB_circle({Rect.x + Rect[W] // 2, Rect.y + Rect[H] // 2}, Circ) then return true end

	-- create a square inside circle
	local widHei = Circ[R] * math.sqrt(2)
	if LIB_rectangle(Rect, {1 + Circ.x - widHei / 2, 1 + Circ.y - widHei / 2, widHei, widHei}) then return true end

	-- distance between vertexes and circle center
	local distID, distance = 1, {
		LIB_distance({Circ.x, Circ.y}, {Rect.x,           Rect.y          }), -- top-left
		LIB_distance({Circ.x, Circ.y}, {Rect.x + Rect[W], Rect.y          }), -- top-right
		LIB_distance({Circ.x, Circ.y}, {Rect.x,           Rect.y + Rect[H]}), -- below-left
		LIB_distance({Circ.x, Circ.y}, {Rect.x + Rect[W], Rect.y + Rect[H]}), -- below-right
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
		{{Rect.x,           Rect.y},           {Rect.x + Rect[W], Rect.y          }}, -- top
		{{Rect.x,           Rect.y + Rect[H]}, {Rect.x + Rect[W], Rect.y + Rect[H]}}, -- below
		{{Rect.x,           Rect.y},           {Rect.x,           Rect.y + Rect[H]}}, -- left
		{{Rect.x + Rect[W], Rect.y},           {Rect.x + Rect[W], Rect.y + Rect[H]}}, -- right
	}

	-- get and update the postions
	local init, final = lines[distID][1], lines[distID][2]

	while true do
		if LIB_circle({init[1], init[2]}, Circ)        then return true  end -- point of collision
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
	cursor[W] = math.abs(dimensions[W] or dimensions[1] or 1)
	cursor[H] = math.abs(dimensions[H] or dimensions[2] or 1)

	return cursor.x + cursor[W] - 1 >= initX  and cursor.x <= finalX and
	       cursor.y + cursor[H] - 1 >= initY  and cursor.y <= finalY
end



----- POINT OF IMPACT -----

local function LIB_impactPixel(Type, mixA, mixB, force)
	libError(Type ~= RE and Type ~= CI, "type", "3", {RE, CI}, OrgBd[9], "(first)")

	mixA, mixB = ckbd({mixA, mixB}, {Type, Type}, 9)

	if Type == RE then
		if not force and not LIB_rectangle(mixA, mixB) then return nil, nil end

		local newMixA = {x = mixA.x + mixA[W] / 2, y = mixA.y + mixA[H] / 2, [R] = (mixA[W] + mixA[H]) / 2}
		local newMixB = {x = mixB.x + mixB[W] / 2, y = mixB.y + mixB[H] / 2, [R] = (mixB[W] + mixB[H]) / 2}

		return LIB_impactPixel(CI, newMixA, newMixB, true)
	end

	if Type == CI then
		if not force and not LIB_circle(mixA, mixB) then return nil, nil end

		local x = (mixA.x * mixB[R]) + (mixB.x * mixA[R])
		local y = (mixA.y * mixB[R]) + (mixB.y * mixA[R])
		local totalRadius = (mixA[R] + mixB[R])

		return x / totalRadius, y / totalRadius
		
	end
end
