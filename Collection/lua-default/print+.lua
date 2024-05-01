-- NAME:    print+
-- AUTHOR:  DuckAfire
-- VERSION: 2.2

----- FOLLOW_ME -----
-- Itch:     http://duckafire.itch.io
-- GitHub:   http://github.com/duckafire
-- Tic80:    http://tic80.com/dev?id=8700
-- Facebook: http://facebook.com/duckafire

----- LICENSE -----

-- Zlib License

-- Copyright (C) 2024 DuckAfire <facebook.com/duckafire>
  
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
  
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required. 
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.



----- X, Y, WIDTH, HEIGHT -----

local function lenght(text, lines, fixed, size, small)
	-- X
	assert(type(text) == "string", '[print+] String (parameter) not specified. In function "pplus.lenght", argument #1')
		
	local scale = print(text, 0, 136)
	scale = (small) and scale - #text * 2 or scale-- 6x6 in normal font; 4x6 in small font (in most cases)
	
	if fixed then
		for i = 1, #text do
			local add = 0
			local cur = string.sub(text, i, i)-- current letter
			
			if 	   string.match(cur, '[%"%+%-%_%=%<%>%?%{%}%~]') or cur == " " or cur == "'" then   add = 2
			elseif string.match(cur, '[%!%.%,%(%)%:%;%[%]]') then   add = 3
			elseif cur == "|" then   add = 4
			end
			
			scale = scale + add
		end
	end

	local size = size or 1

	-- Y
	local lines = lines or 1
	
	return scale * size, (6 * size) * lines
end

local function center(text, _x, _y, lines, fixed, size, small)
	local x, y = _x or 0, _y or 0
	
	local width, height = lenght(text, lines, fixed, size, small)
	
	return x - width // 2 + 1, y - height // 2 + 1
end



----- PRINT FUNCTIONS -----

local function pCenter(text, _x, _y, color, lines, fixed, size, small)
	local x, y = center(text, _x, _y, lines, fixed, size, small)
	
	print(text, x, y, color, fixed, size or 1, small)
end

local function pShadow(text, _x, _y, _color, shadow, fixed, _scale, smallfont, UsedBypList) -- the last is a internal parameter
	local scale  = _scale or 1 -- default
	local hyphen = "" -- the character: "-"
	
	local funcName = '. In function pplus.printShadow, argument #1.'
	if UsedBypList then funcName = funcName.." Called by lbit.pList." end
	
	local direction, color, distance, all = {}, {}, {}, {}
	
	-- convert values to number and if they are check valid
	local function _error(value, name, id)
		for i = 1, 3 do
			value[i][id] = tonumber(value[i][id])
			assert(type(value[i][id]) == "number",'[print+] "shadow" '..name[i]..' is NaN, in index "'..id..'"'..funcName)
		end
	end
	
	-- position and adjust for them
	local x, y = 0, 0 -- optional
	local less = {[0] = {0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	
	assert(type(shadow) == "table", '[print+] "shadow" not is a table'..funcName)
	assert(shadow[1] ~= nil, '[print+] "shadow" values not defined'..funcName)

	-- load "shadow(s)"
	local max = (#shadow <= 4) and #shadow or 4
	for i = 1, max do
		
		-- obtain: direction, color and distance
		for j = 1, 2 do
			hyphen = string.find(shadow[i], "-")
			if #shadow[i] > 0 and #shadow[i] <= 2 then hyphen = 0 end
			assert(hyphen, '[print+] Hyphen not specified in index "'..i..'"'..funcName)
			
			-- splits the strings
			if j == 1 then
				direction[i] = string.sub(shadow[i], 1, hyphen - 1)
				shadow[i]    = string.sub(shadow[i], hyphen + 1, #shadow[i])
			
			else
				color[i] = string.sub(shadow[i], 1, hyphen - 1)
				
				if hyphen == 0 then 
					distance[i] = scale -- default
				else
					distance[i] = string.sub(shadow[i], hyphen + 1, #shadow[i])
				end
				
			end
			
		end
		
		all = {direction, distance, color}
		_error(all, {"direction", "distance", "color"}, i)
		
		-- minimum (0) and maximum (3) value to "direction" and "distance"
		for l = 1, 2 do
			all[l][i] = (all[l][i] < 0) and 0 or (all[l][i] > 3) and 3 or all[l][i]
		end
		
		-- draw shadows
		x = _x + less[direction[i]][1] * distance[i]
		y = _y + less[direction[i]][2] * distance[i]
		print(text, x, y, color[i], fixed, scale, smallfont)
	end
	
	-- draw original text
	print(text, _x, _y, _color, fixed, scale, smallfont)
end

local function pBoard(text, _x, _y, color, _bcolor, _distance, fixed, _scale, smallfont)
	-- position and adjust for them
	local x, y = 0, 0 -- optional
	local less = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	
	-- obitain values (specified or default)
	local scale    = _scale    or 1
	local bcolor   = _bcolor   or 15
	local distance = _distance or scale
	
	-- draw boards
	for i = 1, 4 do
		x = _x + less[i][1] * distance
		y = _y + less[i][2] * distance
		print(text, x, y, bcolor, fixed, scale, smallfont)
	end
	
	-- draw original text
	print(text, _x, _y, color, fixed, scale, smallfont)
end

local function pList(text, _x, _y, color, space, fixed, size, small, inCenter, effect)
	assert(type(text) == "table", '[print+] Table (parameter) not specified. In function "pplus.list", argument #1')
	local backup = {} -- "effect" shadow (#2)
	
	local color, space = color or 15, space or 10-- vertical spaces
	
	-- add shadow effect or board effect to text in list
	if effect then
		local funcName = '. In function pplus.pList, argument #9.'
		
		assert(type(effect) == "table", '[print+] "effect" is not a table'..funcName)
		
		assert(effect[1] == "shadow" or effect[1] == "board", '[print+] Type of "effect[1]" is unvalid, try "shadow" or "board"'..funcName)
		
		if     effect[1] == "shadow" then
			assert(type(effect[2]) == "table",  '[print+] "effect[2]" is not a table'..funcName)
			for i = 1, #effect[2] do   backup[i] = effect[2][i]   end
			
		elseif effect[1] == "board"  then
			assert(type(effect[2]) == "number", '[print+] "effect[2]" is a NaN'..funcName)
		end
		
	end
	
	local x, y = 0, 0
	for i = 1, #text do
		-- original positions
		x = _x or 0
		y = (_y or 0) + space * (i - 1)
		
		-- obtain center postions
		if inCenter then x, y = center(text[i], x, y - #text, #text, fixed, size, small) end
		
		-- no effect
		if not effect then
			print(tostring(text[i]), x, y, color, fixed, size or 1, small)
		
		-- with effect
		else
			if     effect[1] == "shadow" then pShadow(text[i], x, y, color, effect[2],            fixed, size, small, true) for j = 1, #backup do   effect[2][j] = backup[j]   end
			elseif effect[1] == "board"  then pBoard( text[i], x, y, color, effect[2], effect[3], fixed, size, small)
			end
		end
		
	end
	
end



----- USE SPRITES -----

local function title(sprites, X, Y, dimensions, space, size, chromaKey, vertical)
	assert(type(sprites) == "table", '[print+] Table (parameter) not specified. In function "pplus.title", argument #1')
	
	local back-- table to store the chromaKey colors
	
	if     type(chromaKey) == "number" then
		back = {}
		for i = 1, #sprites do   back[i] = chromaKey   end-- one index to all index in table
	
	elseif type(chromaKey) == "table"  then
		back = ChromaKey
		if #back < #sprites then   for i = #back + 1, #sprites do   back[i] = 0   end   end-- populate the table with default (0)
	
	else
		back = {}
		for i = 1, #sprites do   back[i] = 0   end-- default value (0)

	end
	
	-- default values
	local X, Y = X or 0, Y or 0
	local dimensions = dimensions or 8
	local space		 = space 	  or 1
	local size		 = size  	  or 1
	
	for i = 1, #sprites do
		local x, y
		
		if vertical then
			x = X
			y = Y + (dimensions + space) * (i - 1)
		else
			x = X + (dimensions + space) * (i - 1)
			y = Y
		end
		
		spr(sprites[i], x, y, back[i], size)
	end
	
end



----- ADD TO TABLE -----
	
local printPlus = {}
	
printPlus.lenght  = lenght
printPlus.center  = center
printPlus.pCenter = pCenter
printPlus.pShadow = pShadow
printPlus.pBoard  = pBoard
printPlus.pList   = pList
printPlus.title   = title

return printPlus