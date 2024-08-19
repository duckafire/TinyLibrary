-- NAME:    print+
-- AUTHOR:  DuckAfire
-- VERSION: 4.3.2
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



----- HEAD -----

local function libError(a,b,c,d,e,f)if a~=nil then if not a then return end end local g={"Error","Function","Index"}local h={nil,e,"#"..f}local i="\n\n[LIB]"b=b and'"'..b..'" ' or"" local function j(k)h[1]=b..k end if c=="1" then j("was not specified")elseif c=="2" then j("was not defined")elseif c=="3" then j("is invalid")else j(c)end for l=1,3 do i=i.."\n"..g[l]..": "..h[l].."." if l==1 and d~=nil then i=i.."\nTry: " for m=1,#d-1 do i=i..d[l].." | " end i=i..d[#d] end end trace("\n>\n>\n>")error(i.."\n")end

local LenBy = 1 -- LENght BY
local ShaBy = 1 -- pSHAdow BY



----- X, Y, WIDTH, HEIGHT -----

local function LIB_length(text, fixed, scale, smallfont)
	-- function (that use "length") names to error messages
	local origin = {"length", "center", "pCenter", "pShadow", "pBorder", "pList"}

	LenBy = 1
	scale = scale or 1
	return print(tostring(text), 0, 136, 0, fixed, scale, smallfont), 5 * scale
end

local function LIB_center(text, x, y, fixed, scale, smallfont)
	if LenBy < 2 then LenBy = 2 end

	local width, height = LIB_length(text, fixed, scale, smallfont)
	
	-- value approximated
	return (x or 0) - width // 2 + 1, (y or 0) - height // 2
end



----- PRINT FUNCTIONS -----

local function LIB_pCenter(text, x, y, color, fixed, scale, smallfont)
	LenBy = 3
	x, y = LIB_center(text, x, y, fixed, scale, smallfont)
	
	print(text, x, y, color, fixed, scale or 1, smallfont)
end

local function LIB_pShadow(text, _shadow, textX, textY, textColor, fixed, scale, smallfont, onCenter)
	local origin = (ShaBy == 1) and "pShadow" or "pList"
	local shadow = {}
	
	if type(_shadow) == "number" then
		shadow[1] = _shadow < 0 and 0 or _shadow > 15 and 15 or math.abs(_shadow)
		shadow[1] = shadow[1].."-1" -- default direction

	elseif type(_shadow) == "table" then
		-- copy "_shadow" to "shadow"
		for i = 1, #_shadow do
			shadow[i] = _shadow[i]
		end
	
	else
		libError(nil, "shadow", "is not a number or table", nil, origin, 5)
	end

	libError(shadow[1] == nil, "shadow", "values not defined", nil, origin, 1)

	if onCenter then
		LenBy = 4
		textX, textY = LIB_center(text, textX, textY, fixed, scale, smallfont)
	end

	scale = scale or 1 -- default
	
	local hyphen, x, y = 0, 0, 0
	local color, direction, distance = {}, {}, {}
	local all = {color, direction, distance, "color", "direction", "distance"}
	local less = {[0] = {0, -1}, {0, 1}, {-1, 0}, {1, 0}} -- adjustments to posititon (top, below, left, rigth)

	-- load all "shadow(s)"
	for i = 1, ((#shadow < 4) and #shadow or 4) do

		-- get: direction, color and distance
		for j = 1, 2 do
			-- get positon of the divisor ('-')
			hyphen = string.find(shadow[i], '-')

			-- one value remains and it is a number
			if #shadow[i] == 1 and tonumber(shadow[i]) ~= nil then hyphen = 0 end
			
			libError(hyphen == nil, nil, "Hyphen not specified. In index #"..i..' of the table "shadow"', nil, origin, 1)
			
			-- splits the values present in strings
			if j == 1 then
				color[i]  = string.sub(shadow[i], 1, hyphen - 1)          -- before '-'
				shadow[i] = string.sub(shadow[i], hyphen + 1, #shadow[i]) -- after '-'
			
			else
				direction[i] = string.sub(shadow[i], 1, hyphen - 1) -- before '-'

				if hyphen == 0 then
					distance[i] = scale -- default
				else
					distance[i] = string.sub(shadow[i], hyphen + 1, #shadow[i]) -- after '-'
				end
				
			end

			-- convert characters getted to number
			for l = 1, 3 do -- color, direction, distance
				if all[l][i] ~= nil then
					all[l][i] = tonumber(all[l][i])
				end
			end
			
		end
		
		-- check if the values getted are valid
		for j = 1, 3 do
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

local function LIB_pBorder(text, textX, textY, textColor, bColor, fixed, scale, distance, smallfont, onCenter)
	-- positions and adjustment for them
	local x, y = 0, 0
	local less = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	
	if onCenter then
		LenBy = 5
		textX, textY = LIB_center(text, textX, textY, fixed, scale, smallfont)
	end

	scale    = scale    or 1
	bcolor   = bColor   or 0
	distance = distance or scale
	
	-- draw borders
	for i = 1, 4 do
		x = textX + less[i][1] * distance
		y = textY + less[i][2] * distance
		print(text, x, y, bColor, fixed, scale, smallfont)
	end
	
	-- draw original text
	print(text, textX, textY, textColor, fixed, scale, smallfont)
end

local function LIB_pList(text, X, Y, _color, space, fixed, scale, smallfont, align, onCenter, effect)
	libError(type(text) ~= "table", "text", "1", nil, "pList", 1)
	
	-- color: (1) one universal OR (2) one for each item
	local color = {}
	if type(_color) == "table" then -- 2
		libError(#_color < #text, "color", "insufficient number of indexes", "pList", 3)
		color = _color
	else -- 1
		for i = 1, #text do
			color[i] = _color
		end
	end

	X, Y = X or 0, Y or 0
	scale = scale or 1
	space = space or 13 * scale
	align = align or -1
	
	-- border or shadow
	if effect then
		libError(type(effect) ~= "table", "effect", "3", nil, "pList", 10)
		libError(effect[1] ~= "shadow" and effect[1] ~= "border", "effect[1]", "3", {"shadow", "border"}, "pList", 10) -- e.g.: {"shadow", ...}
		
		if     effect[1] == "shadow" then libError(type(effect[2]) ~= "table" and type(effect[2]) ~= "number",  "effect[2]", "is not a table or number", nil, "pList", 10)
		elseif effect[1] == "border" then libError(type(effect[2]) ~= "number", "effect[2]", "is NaN", nil, "pList", 10) -- #3 is optional (distance)
		end
	end
	
	-- adjustment axis
	local blen = 0 -- used only if 'align ~= -1'
	
	if onCenter or align ~= -1 then
		-- get item with the bigger width
		local width, bigger = 0, 0

		for i = 1, #text do
			if width < #text[i] then
				width  = #text[i]
				bigger = text[i]
			end
		end

		LenBy = 6
		if onCenter then
			X = LIB_center(bigger, X, Y - #text, fixed, scale, smallfont)
			Y = Y - ((#text - 1) * space * scale ) // 2
		end
		
		-- Bigger LENgth: width of the bigID item
		blen = LIB_length(bigger, fixed, scale, smallfont)
	end

	local x, y = 0, 0
	for i = 1, #text do
		-- restart to original positions
		x = X
		y = Y + space * (i - 1)
		
		if align ~= -1 then
			LenBy = 6

			if     align == 0 then x = LIB_center(text[i], x + blen // 2, y, fixed, scale, smallfont)
			elseif align == 1 then x = x + blen - LIB_length(text[i], fixed, scale, smallfont)
			end
		end
		
		-- draw
		if not effect then
			print(tostring(text[i]), x, y, color[i], fixed, scale, smallfont)
		
		else
			if effect[1] == "shadow" then
				ShaBy = 2
				LIB_pShadow(text[i], effect[2], x, y, color[i], fixed, scale, smallfont)
			
			elseif effect[1] == "border" then
				LIB_pBorder( text[i], x, y, color[i], effect[2], fixed, scale, effect[3], smallfont)
			end
		end
		
	end
	
end



----- USE SPRITES -----

local function LIB_title(sprites, X, Y, chromaKey, space, scale, width, height, _flip, _rotate, alignX, alignY, vertical, dimw, dimh)
	libError(type(strites) == "table", '"sprites"', "1", nil, "title", 1)

	-- flip and rotate (for all or for each)
	local flip, rotate, value = {}, {}, 0
	
	if type(_flip) ~= "table" then
		value = _flip or 0
		for i = 1, #sprites do flip[i] = value end
	else
		flip = _flip
	end
	
	if type(_rotate) ~= "table" then
		value = _rotate or 0
		for i = 1, #sprites do rotate[i] = value end
	else
		rotate = _rotate
	end
	
	-- check flip and rotate quantity
	local function err(tbl, stbl, id) libError(#sprites > #tbl, stbl, "has a insuficient quatity of indexes", "title", id) end
	err(flip,   "flip",    9)
	err(rotate, "rotate", 10)
		
	-- chroma key
	local chKey = nil -- table to store the chromaKey colors
	
	if     type(chromaKey) == "number" then -- one for all
		chKey = {}
		for i = 1, #sprites do chKey[i] = chromaKey end -- one index to all index in table
	
	elseif type(chromaKey) == "table"  then -- one for each
		err(chromaKey, "chromaKey", 4)
		chKey = chromaKey

	else -- not specified
		chKey = {}
		for i = 1, #sprites do chKey[i] = 0 end -- default value (0)

	end
	
	-- default values
	X, Y = X or 0, Y or 0
	scale  = scale or 1
	space  = space or 1
	dimw   = dimw or 1
	dimh   = dimh or 1
	width  = (width  or 8) * scale
	height = (height or 8) * scale

	-- alignment
	local alx, aly = 0, 0
	if alignX then alx = (vertical) and (width // 2) or ((width  + space) * #sprites - space) // 2    end
	if alignY then aly = (vertical) and (((height + space) * #sprites - space) // 2) or (height // 2) end

	-- draw
	local x, y
	for i = 1, #sprites do
		if vertical then
			x = X - alx
			y = Y + ((height + space) * (i - 1)) - aly
		else
			x = X + ((width  + space) * (i - 1)) - alx
			y = Y - aly
		end
		
		spr(sprites[i], x, y, chKey[i], scale, flip[i], rotate[i], dimw, dimh)
	end
	
end
