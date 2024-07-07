-- NAME:    print+
-- AUTHOR:  DuckAfire
-- VERSION: 4.2.2
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
	local full = "\n\n[print+]"

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
			for j = 1, #opt - 1 do full = full.." | " end
			fulll = full..opt[#opt] -- without '|'
		end
	end

	trace("\n>\n>\n>")
	error(full.."\n")
end



----- ACTION CONTROLS -----

local LenBy = 1 -- LENght called BY itself, center or pCenter
local ShaBy = 1 -- pSHAdow called BY LIB_pList (only)



----- X, Y, WIDTH, HEIGHT -----

local function LIB_length(text, fixed, scale, smallfont, lines)
	-- check first argument and functions to print in error message
	local origin = {"length", "center", "pCenter", "pShadow", "pBoard", "pList"}
	libError(type(text) ~= "string", "text", "1", nil, origin[LenBy], 1)
	LenBy = 1
	
	scale = scale or 1
	lines = lines or 1 -- quantity of "\n"

	-- In Tic80 API, "print" return the width of the text used like argument (#1)
	return print(text, 0, 136, 0, fixed, scale, smallfont), (6 * scale) * lines -- width and height
end

local function LIB_center(text, x, y, fixed, scale, smallfont, lines)
	x, y = x or 0, y or 0
	
	if LenBy < 2 then LenBy = 2 end
	local width, height = LIB_length(text, fixed, scale, smallfont, lines)
	
	-- value approximated
	return x - width // 2 + 1, y - height // 2 + 1
end



----- PRINT FUNCTIONS -----

local function LIB_pCenter(text, x, y, color, fixed, scale, smallfont, lines)
	LenBy = 3
	x, y = LIB_center(text, x, y, fixed, scale, smallfont, lines)
	
	print(text, x, y, color, fixed, scale or 1, smallfont)
end

local function LIB_pShadow(text, textX, textY, textColor, _shadow, fixed, scale, smallfont, onCenter) -- the last is a internal parameter
	local origin = (ShaBy == 1) and "pShadow" or "pList"
	local shadow = {}
	
	if type(_shadow) == "number" then
		shadow[1] = _shadow < 0 and 0 or _shadow > 15 and 15 or math.abs(_shadow)
		shadow[1] = shadow[1].."-1"

	elseif type(_shadow) == "table" then
		for i = 1, #_shadow do -- "break" link (pointer)
			shadow[i] = _shadow[i]
		end
	
	else
		libError(nil, "shadow", "is not a number or table", nil, origin, 5)
	end

	if onCenter then
		LenBy = 4
		textX, textY = LIB_center(text, textX, textY, fixed, scale, smallfont)
	end

	scale = scale or 1 -- default
	
	local hyphen, x, y = "", 0, 0 -- '-'
	local color, direction, distance = {}, {}, {}
	local all = {color, direction, distance, "color", "direction", "distance"}
	local less = {[0] = {0, -1}, {0, 1}, {-1, 0}, {1, 0}} -- adjusts to posititon
	
	libError(shadow[1] == nil, "shadow", "values not defined", nil, origin, 1)

	-- load all "shadow(s)"
	for i = 1, ((#shadow < 4) and #shadow or 4) do

		-- obtain: direction, color and distance
		for j = 1, 2 do
			-- get values division ('-')
			hyphen = string.find(shadow[i], "-")
			if #shadow[i] == 1 or tonumber(shadow[i]) ~= nil then hyphen = 0 end -- color-direction
			libError(hyphen == nil, nil, "Hyphen not specified. In index #"..i..' of the table "shadow"', nil, origin, 1)
			
			-- splits the values present in strings
			if j == 1 then
				color[i]  = string.sub(shadow[i], 1, hyphen - 1)
				shadow[i] = string.sub(shadow[i], hyphen + 1, #shadow[i])
			
			else
				direction[i] = string.sub(shadow[i], 1, hyphen - 1)

				if hyphen == 0 then
					distance[i] = scale -- default
				else
					distance[i] = string.sub(shadow[i], hyphen + 1, #shadow[i])
				end
				
			end

			-- convert to number
			for l = 1, 3 do
				if all[l][i] ~= nil then
					all[l][i] = tonumber(all[l][i])
				end
			end
			
		end
		
		-- check if the values getted are valid
		for j = 1, 3 do
			-- all[1][3] == direction[3]
			libError(type(tonumber(all[j][i])) ~= "number", nil, "The element "..all[j + 3]..' is NaN. In index #'..i..' of the table "shadow".', nil, origin, 1)
		end
		
		-- minimum (0) and maximum (3) value to "direction" and "distance"
		for l = 2, 3 do
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

local function LIB_pBoard(text, textX, textY, textColor, bColor, distance, fixed, scale, smallfont, onCenter)
	-- position and adjust for them
	local x, y = 0, 0
	local less = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	
	if onCenter then
		LenBy = 5
		textX, textY = LIB_center(text, textX, textY, fixed, scale, smallfont)
	end

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

local function LIB_pList(text, X, Y, color, space, fixed, scale, smallfont, onCenter, effect)
	libError(type(text) ~= "table", "text", "1", nil, "pList", 1)
	
	color = color or 15
	space = space or 10 -- vertical
	
	-- check values from "effect"
	if effect then
		libError(type(effect) ~= "table", "effect", "1", nil, "pList", 10)
		libError(effect[1] ~= "shadow" and effect[1] ~= "board", "effect[1]", "3", {"shadow", "board"}, "pList", 10)
		
		if     effect[1] == "shadow" then libError(type(effect[2]) ~= "table",  "effect[2]", "is not a table", nil, "pList", 10)
		elseif effect[1] == "board"  then libError(type(effect[2]) ~= "number", "effect[2]", "is NaN",         nil, "pList", 10) -- #3 is optional (distance)
		end
	end
	
	local x, y = 0, 0
	for i = 1, #text do
		-- original positions
		x =  X or 0
		y = (Y or 0) + space * (i - 1)
		
		if onCenter then
			LenBy = 6
			x, y = LIB_center(text[i], x, y - #text, fixed, scale, smallfont, #text)
		end
		
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
	libError(type(strites) == "table", '"sprites"', "1", nil, "title", 1)
	
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
