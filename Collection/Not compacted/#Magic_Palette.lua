----------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------

-- [NOT COMPACTED] Copy and paste the code in your cart [v: 1.1]

local magicPalette = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- ABOUT PALETTE CODE -----

	local function sortCode(code, order, low)
		local ord, _code, c = order or 0, {}, nil-- type of return; colors; to return
		
		-- HEXADECIMAL CODE
		if type(_code) == "string" then
			local temp = _code
			for i = #temp + 1, 6 do temp = temp.."0" end-- fill void spaces
			
			local id    = {1, 3, 5}
			local _font = low and string.lower or string.upper
			for i = 1, 3 do _code[i] = _font(string.sub(temp, id[i], id[i] + 1)) end
		
		-- DECIMAL CODE
		else
			_code = code
		end
		
		for i = 1, 3 do if not _code[i] then _code[i] = 0 end end-- fill void spaces
		
		-- RETURN TYPES
		if ord == 0 then-- 3 arg to 3 var
			return _code[1], _code[2], _code[3]
		
		elseif ord == 1 then-- a array (table)
			c = _code
		
		elseif ord == 2 then-- a table with "structure"
			c = {red = _code[1], green = _code[2], blue = _code[3]}
		
		elseif ord == 3 then-- string
			if hex then
				c = "#".._code[1].._code[2].._code[3]-- hexadecimal
			else
				c = _code[1]..", ".._code[2]..", ".._code[3]-- decimal
			end
		else
			error( '[ Magic_Palette ] The parameter "order" is invalid, try values between 0-3. In function "pale.sortCode", argument #2.' )
		end
		
		return c
	end
	
	local function save(hex)
		local var
		
		if hex then   var = ""   else   var = {}   end
		
		for i = 0, 15 do	
			if not hex then var[i] = {} end
			
			for j = 0, 2 do
				if hex then
					var = var..string.format("%x", peek(0x03FC0 + i * 3 + j))-- hexadecimal
				else
					var[i][j] = peek(0x03FC0 + i * 3 + j)-- decimal (in sub-tables)
				end
			end
		
		end
	
		return var
	end
	
	----- CONVERSION -----
	
	local function toDec(_code, order)
		local inDeci = {}
		
		local code
		code = type(_code) == "table" and _code[1] or _code
		code = string.sub(code, 1, 1) == "#" and string.sub(code, 2) or code-- remove "#"
		
		for i = 0, 2 do
			local lcl = i + 1 + (i * 1)-- LoCaLe
			inDeci[i + 1] = tonumber(string.sub(code, lcl, lcl + 1), 16)
		end
		
		return sortCode(inDeci, order)
	end
	
	local function toHex(_code, order, low)
		local inHexa = ""
		
		for i = 1, 3 do
			if     _code[i] < 0   then _code[i] = 0 
			elseif _code[i] > 255 then _code[i] = 255
			end
			
			inHexa = inHexa..string.format("%x", math.floor(_code[i]))
		end
		
		return sortCode(inHexa, order, low)
	end

	-- CHANGE TINT (RGB)

	local function swap(_code, id)
		local code = _code-- remove trash
		if  string.sub(_code, 1, 4) == "000:" then code = string.sub(_code, 5)
		elseif string.sub(_code, 1, 1) == "#" then code = string.sub(_code, 2)
		end
		
		-- function core
		local function rgb(v, ifPalette)
			local add = ifPalette or 0
			for i = 0, 2 do
				local lcl = i + 1 + (i * 1)-- LoCaLe
				local color = tonumber(string.sub(code, lcl + add, lcl + 1 + add), 16)
				poke(0x03fc0 + v * 3 + i, color)-- apply the edition in ram
			end
		end
		
		if id == "palette" then
			for id = 0, 15 do rgb(id, 6 * id) end-- swap palette
			
		elseif id == "equal" then
			for id = 0, 15 do rgb(id) end-- edit all colors (all are equal)
		
		else
			rgb(tonumber(id))-- edit one color
		
		end
		
	end

	local function light(speed, tbl)
		local spd, qtt = speed and math.floor(speed) or 1, 0-- update speed; quantity of color in min/max
		
		for i = 0, 15 do-- index
			for j = 0, 2 do-- rgb
			
				local cur = peek(0x03FC0 + i * 3 + j)
				
				local min = type(tbl) == "table" and tbl[i][j] or 0
				local max = type(tbl) == "table" and tbl[i][j] or 255
				
				local value = (cur + spd >= min) and cur + spd or min-- less
				if spd > 0 then value = (cur + spd <= max) and cur + spd or max end-- more
				
				poke(0x03FC0 + i * 3 + j, value)
				
				if value == min or value == max then qtt = qtt + 1 end
				
			end
		end
		
		return qtt == 48
	end
	
	----- ADD TO TABLE -----

	magicPalette.sortCode = sortCode
	magicPalette.save     = save
	magicPalette.toDec    = toDec
	magicPalette.toHex    = toHex
	magicPalette.swap     = swap
	magicPalette.light    = light

end

local pale = magicPalette -- you can customize this reference or not use it.
