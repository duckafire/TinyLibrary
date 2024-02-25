-- [NOT COMPACTED] Copy and paste the code in your cart [v: 0.0]

local magicPalette = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- CONVERSION -----

	local function sortCode(code, order, hex, low)-- internal
		local ord, _code, c = order or 0, {}, nil-- type of return; colors; to return
		
		-- HEXADECIMAL CODE
		if hex and (type(code) == "string" or (type(code) == "table" and type(code[1]) == "string" and #code == 1)) then
		
			local temp = type(code) == "table" and code[1] or code
			temp = string.sub(temp, 1, 1) == "#" and string.sub(temp, 2) or temp
			
			for i = 2, 6 do if #temp == 6 then break end temp = temp.."0" end-- fill void spaces
			
			local _font = low and string.lower or string.upper
			for i = 1, 3 do local id = {1, 3, 5} _code[i] = _font(string.sub(temp, id[i], id[i] + 1)) end
		
		else-- NUMERIC CODE
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
			error( '[ Magic_Palette ] The parameter "together" is invalid, try values between 0-3. In function "pale.sortCode", argument #2.' )
		end
		
		return c
	end
	
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
		
		return sortCode(inHexa, order, true, low)
	end

	local function swap(id, code) end -- id = "0" - "15" or "all"
	local function light(id, speed, less, duration) end
	
	-- ADD TO TABLE -------------------------------------------------------------

	magicPalette.sortCode = sortCode
	magicPalette.toHex    = toHex
	magicPalette.toDec    = toDec
	-- magicPalette.swap     = swap
	-- magicPalette.light    = light

end

local pale = magicPalette
print(pale.toDec("ffffff"))