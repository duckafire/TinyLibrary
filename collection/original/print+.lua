-- NAME:    print+
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
local function libError2(argument, options, funcName, index)
	local msg = argument -- not customized
	
	if type(options) == "table" then
		
		if options[1] == nil then
			msg = "\n"..argument.." not specified."
		
		else
			msg = "\nInvalid argument: "..argument.."\nTry: "
			for i = 1, #options do
				msg = msg..options[i].." | "
			end
		end

	end

	error("\n\n[print+]"..msg.."\nFunction: "..funcName.."\nParameter: #"..index.."\n")
end

local function libAssert(cond, argument, options, funcName, index)
	if cond then
		libError2(argument, options, funcName, index)
	end
end



----- ACTION CONTROLS -----

local LenBy = 1 -- LENght called BY itself, center or pCenter
local ShaBy = 1 -- pSHAdow called BY LIB_pList (only)



----- X, Y, WIDTH, HEIGHT -----

local function LIB_lenght(text, lines, fixed, scale, smallfont)
	-- check first argument and functions to print in error message
	local origin = {"lenght", "center", "pCenter"}
	libAssert(type(text) ~= "string", '"text"', {}, origin[LenBy], "1")
	LenBy = 1
	
	local len = print(text, 0, 136)
	len = (smallfont) and len - #text * 2 or len-- normal = 6x6; small = 4x6
	
	-- adjust the space between characters "fixed"
	if fixed then
		local add, cur
		for i = 1, #text do
			add = 0
			cur = string.sub(text, i, i)-- current letter
			
			-- characters with theirs width different
			if     string.match(cur, '[%"%+%-%_%=%<%>%?%{%}%~]') or cur == " " or cur == "'" then   add = 2
			elseif string.match(cur, '[%!%.%,%(%)%:%;%[%]]') then   add = 3
			elseif cur == "|" then   add = 4
			end
			
			len = len + add
		end
	end

	scale = scale or 1
	lines = lines or 1
	return len * scale, (6 * scale) * lines
end

local function LIB_center(text, x, y, lines, fixed, scale, smallfont)
	x, y = x or 0, y or 0
	
	if LenBy ~= 3 then LenBy = 2 end
	local width, height = LIB_lenght(text, lines, fixed, scale, smallfont)
	
	-- value approximated
	return x - width // 2 + 1, y - height // 2 + 1
end



----- PRINT FUNCTIONS -----

local function LIB_pCenter(text, x, y, color, lines, fixed, scale, smallfont)
	LenBy = 3
	x, y = LIB_center(text, x, y, lines, fixed, scale, smallfont)
	
	print(text, x, y, color, fixed, scale or 1, smallfont)
end

local function LIB_pShadow(text, textX, textY, textColor, _shadow, fixed, scale, smallfont) -- the last is a internal parameter
	libAssert(type(_shadow) ~= "table", '"shadow" is not a table.', nil, origin, "1")
	local shadow = {}
	for i = 1, #_shadow do -- "break" link (pointer)
		shadow[i] = _shadow[i]
	end

	scale = scale or 1 -- default
	
	local hyphen, x, y = "", 0, 0 -- '-'
	local direction, distance, color = {}, {}, {}
	local all = {direction, distance, color, "direction", "distance", "color"}
	local less = {[0] = {0, -1}, {0, 1}, {-1, 0}, {1, 0}} -- adjusts to posititon
	
	-- check table "shadow"
	local origin = (ShaBy == 1) and "pShadow" or "pList"
	libAssert(shadow[1] == nil, '"shadow" values not defined.', nil, origin, "1")

	-- load all "shadow(s)"
	for i = 1, ((#shadow < 4) and #shadow or 4) do

		-- obtain: direction, color and distance
		for j = 1, 2 do
			-- get values division ('-')
			hyphen = string.find(shadow[i], "-")
			if #shadow[i] > 0 and #shadow[i] <= 2 then hyphen = 0 end
			libAssert(hyphen == nil, "Hyphen not specified. In index #"..i..' of the table "shadow".', nil, origin, "1")
			
			-- splits the values present in strings
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

			-- convert to number
			for l = 1, 3 do
				if all[l][i] ~= nil then
					all[j][i] = tonumber(all[j][i])
				end
			end
			
		end
		
		-- check if the values getted are valid
		for j = 1, 3 do
			-- all[1][3] == direction[3]
			libAssert(type(tonumber(all[j][i])) ~= "number", "The element "..all[j + 3]..' is NaN. In index #'..i..' of the table "shadow".', nil, origin, "1")
		end
		
		-- minimum (0) and maximum (3) value to "direction" and "distance"
		for l = 1, 2 do
			all[l][i] = (all[l][i] < 0) and 0 or (all[l][i] > 3) and 3 or all[l][i]
		end
		
		-- draw shadows
		x = textX + less[direction[i]][1] * distance[i]
		y = textY + less[direction[i]][2] * distance[i]
		print(text, x, y, color[i], fixed, scale, smallfont)
	end
	
	-- draw original text
	print(text, textX, textY, textColor, fixed, scale, smallfont)
	ShaBy = 1
end

local function LIB_pBoard(text, textX, textY, textColor, bColor, distance, fixed, scale, smallfont)
	-- position and adjust for them
	local x, y = 0, 0
	local less = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	
	-- obtain values (specified or default)
	scale    = scale    or 1
	bcolor   = bColor   or 15
	distance = distance or scale
	
	-- draw boards
	for i = 1, 4 do
		x = textX + less[i][1] * distance
		y = textY + less[i][2] * distance
		print(text, x, y, bColor, fixed, scale, smallfont)
	end
	
	-- draw original text
	print(text, textX, textY, textColor, fixed, scale, smallfont)
end

local function LIB_pList(text, X, Y, color, space, fixed, scale, smallfont, inCenter, effect)
	libAssert(type(text) ~= "table", '"text"', {}, "pList", "1")
	
	color = color or 15
	space = space or 10 -- vertical
	
	-- check values from "effect"
	if effect then
		libAssert(type(effect) ~= "table", '"effect"', {}, "pList", "10")
		libAssert(effect[1] ~= "shadow" and effect[1] ~= "board", '"effect[1]"', {"shadow", "board"}, "pList", "10")
		
		if     effect[1] == "shadow" then libAssert(type(effect[2]) ~= "table",  '"effect[2]" is not a table', nil, "pList", "10")
		elseif effect[1] == "board"  then libAssert(type(effect[2]) ~= "number", '"effect[2]" is NaN',         nil, "pList", "10") -- #3 is optional (distance)
		end
	end
	
	local x, y = 0, 0
	for i = 1, #text do
		-- original positions
		x =  X or 0
		y = (Y or 0) + space * (i - 1)
		
		if inCenter then   x, y = LIB_center(text[i], x, y - #text, #text, fixed, scale, smallfont)   end
		
		-- write text
		if not effect then
			print(tostring(text[i]), x, y, color, fixed, scale or 1, smallfont)
		
		else
			if effect[1] == "shadow" then
				ShaBy = 2
				LIB_pShadow(text[i], x, y, color, effect[2], fixed, scale, smallfont)
			
			elseif effect[1] == "board" then
				LIB_pBoard( text[i], x, y, color, effect[2], effect[3], fixed, scale, smallfont)
			end
		end
		
	end
	
end



----- USE SPRITES -----

local function LIB_title(sprites, X, Y, widHei, space, scale, chromaKey, vertical)
	libAssert(type(strites) == "table", '"sprites"', {}, "title", "1")
	
	local chKey = nil -- table to store the chromaKey colors
	
	if     type(chromaKey) == "number" then
		chKey = {}
		for i = 1, #sprites do   back[i] = chromaKey   end -- one index to all index in table
	
	elseif type(chromaKey) == "table"  then
		chKey = chromaKey
		if #chKey < #sprites then
			for i = #chKey + 1, #sprites do   chKey[i] = 0   end -- fill with default (0)
		end

	else
		chKey = {}
		for i = 1, #sprites do   chKey[i] = 0   end -- default value (0)

	end
	
	-- default values
	X, Y = X or 0, Y or 0
	space  = space  or 1
	scale  = scale  or 1
	widHei = widHei or 8

	widHei = widHei * scale
	
	local x, y
	for i = 1, #sprites do
		if vertical then
			x = X
			y = Y + (widHei + space) * (i - 1)
		else
			x = X + (widHei + space) * (i - 1)
			y = Y
		end
		
		spr(sprites[i], x, y, chKey[i], scale)
	end
	
end
