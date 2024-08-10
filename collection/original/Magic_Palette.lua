-- NAME:    Magic Pallete
-- AUTHOR:  DuckAfire
-- VERSION: 2.1.0
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
	local full = "\n\n[MagicPalette]"

	par = par and '"'..par..'" ' or ""
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



----- CONSTANTS -----

local AD = 0x03fc0 -- ADdress



----- ABOUT PALETTE CODE -----

local function LIB_sort(orgCode, order, low)
	local code = {}
	order = order or 0 -- return format

	-- hexadecimal code
	if     type(orgCode) == "string" then
		local temp = orgCode.."000000" -- fill (possible) void spaces
		local char = low and string.lower or string.upper
		
		for i = 1, 5, 2 do   code[#code + 1] = char(string.sub(temp, i, i + 1))   end

	elseif type(orgCode) == "table"  then
		code = orgCode

	else
		libError(nil, "orgCode", "3", nil, "sortCode", 1)
	end

	-- fill void spaces
	for i = 1, 3 do
		if not code[i] then   code[i] = 0   end
	end

	-- RETURN TYPES
	if order == 0 then   return code[1], code[2], code[3]                          end -- x3 values
	if order == 1 then   return code                                               end -- table
	if order == 2 then   return {red = code[1], green = code[2], blue = code[3]}   end -- a table with "structure"
	
	if order == 3 then -- string
		if hex then   return "#"..code[1]..code[2]..code[3]   end -- hexadecimal
		
		return code[1]..", "..code[2]..", "..code[3] -- decimal
	end

	libError(nil, "order", "3", {"0-3"}, "sortCode", 2)
end

local function LIB_save(hex, hyphen)
	local code = {}
	
	if hex then   code = ""   end
	
	for i = 0, 15 do
		if not hex then code[i] = {} end
		
		for j = 0, 2 do
			if hex then
				code = code..string.format("%x", peek(AD + i * 3 + j)) -- hexadecimal (string)
				
				if hyphen and i < 15 then code = code.."-" end -- space between codes
			else
				code[i][j] = peek(AD + i * 3 + j) -- decimal (sub-tables)
			end
		end
	
	end

	return code
end



----- CONVERSION -----

local function LIB_toDec(code, order)
	local inDeci = {}
	
	code = type(code) == "table" and code[1] or code
	code = string.sub(code, 1, 1) == "#" and string.sub(code, 2) or code -- remove "#"
	
	local lcl
	for i = 0, 2 do
		lcl = i + 1 + (i * 1) -- LoCaLe
		inDeci[i + 1] = tonumber(string.sub(code, lcl, lcl + 1), 16)
	end
	
	return LIB_sortCode(inDeci, order)
end

local function LIB_toHex(code, order, low)
	local inHexa = ""
	
	for i = 1, 3 do
		if     code[i] < 0   then code[i] = 0 
		elseif code[i] > 255 then code[i] = 255
		end
		
		inHexa = inHexa..string.format("%x", math.floor(code[i]))
	end
	
	return LIB_sortCode(inHexa, order, low)
end



----- CHANGE TINT (RGB) -----

local function LIB_swap(code, id)
	-- remove trash
	if     string.sub(code, 1, 4) == "000:" then code = string.sub(code, 5)
	elseif string.sub(code, 1, 1) == "#"    then code = string.sub(code, 2)
	end

	-- function core
	local function rgb(v, ifPal)
		-- to edit all colors; store a snippet of the "code"; LoCaLe of color code
		local add, lcl, color = ifPal or 0
		
		for i = 0, 2 do
			lcl = i + 1 + (i * 1)
			color = tonumber(string.sub(code, lcl + add, lcl + 1 + add), 16)
			poke(AD + v * 3 + i, color)
		end
	end
	
	-- swap all colors (palette)
	if id == "palette" then
		code = string.gsub(code, "-", "")
		
		for i = 0, 15 do rgb(i, 6 * i) end
		return
	end
	
	-- swap all colors (to some)
	if id == "equal" then
		for i = 0, 15 do rgb(i) end
		return
	end

	libError(type(id) ~= "number", "id", "3", {"palette", "equal", "0-15"}, "swap", 2)

	-- edit one color
	rgb(tonumber(id))
end

local function LIB_shine(speed, id, tbl)
	local qtt = 0 -- quantity of color in min/max

	speed = speed and math.floor(speed) or 1 -- update speed
	
	local cur, value
	local imin, imax = 0, 15
	local isTable, min, max = (type(tbl) == "table"), 0, 255

	if id ~= nil then
		libError(id < 0 or id > 15, "id", "3", nil, "shine", "2")

		imin = id
		imax = id

		-- "tbl" a table with only one index ( other table: {{r, b, g}} )
		-- it item will be moved from first position to "id" position,
		-- but only if this index is nil
		if isTable then
			tbl = {
				[id] = (type(tbl[id]) == "table") and tbl[id] or ((type(tbl[1]) == "table") and tbl[1] or tbl)
			}
		end
	end

	for i = imin, imax do -- color index
		for j = 0, 2 do -- rgb
		
			cur = peek(AD + i * 3 + j)
			
			if isTable then
				min = tbl[i][j]
				max = tbl[i][j]
			end
			
			if speed <= 0 then
				value = (cur + speed >= min) and cur + speed or min -- less
			else
				value = (cur + speed <= max) and cur + speed or max -- more
			end

			poke(AD + i * 3 + j, value)
			
			if value == min or value == max then   qtt = qtt + 1   end
			
		end
	end
	
	-- true: all colors have arrived at the minimum or maximum of shine
	if qtt == ((id == nil) and 48 or 3) and math.floor(speed) ~= 0 then
		return (speed < 0) and -1 or 1
	end

	return 0
end
