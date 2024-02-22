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
		local color, inDeci = {["A"] = 10, ["B"] = 11, ["C"] = 12, ["D"] = 13, ["E"] = 14, ["F"] = 15}, {}
		
		local code
		code = type(_code) == "table" and _code[1] or _code
		code = string.sub(code, 1, 1) == "#" and string.sub(code, 2) or code-- remove "#"
		
		for i = 0, 4, 2 do
			local a = string.sub(code, i + 1, i + 1)
			local b = string.sub(code, i + 2, i + 2)
			
			-- 0 - 9 ; A - F
			if tonumber(a) then a = a * 16 else a = color[a] * 16 end
			if tonumber(b) then a = a + b  else a = color[b] + a  end
			
			inDeci[i // 2 + 1] = (a == 256) and a - 1 or a
		end
		
		return sortCode(inDeci, order)
		
	end
	
	local function toHex(_code, order, low)
		local color, inHexa = {[10] = "A", [11] = "B", [12] = "C", [13] = "D", [14] = "E", [15] = "F"}, ""
		
		for i = 1, 3 do
			assert(_code[i] < 256, '[ Magic_Palette ] Index very long in "_code" parameter. In function "pale.toHex", argument #1, index #'..i..'.')
		
			local a = _code[i] // 16
			local b = _code[i] %  16
			
			-- 0 - 9 ; A - F
			if a < 10 then a = tostring(a) else a = color[a] end
			if b < 10 then b = tostring(b) else b = color[b] end
			
			inHexa = inHexa..a..b
		end
		
		return sortCode(inHexa, order, true, low)
	end
	
	-- alterar um cor da palete (editColor): índice da cor, tabela com o código da cor, valor booleano (true para usar valores decimais).
	-- trocar toda a paleta (swapPalette): código RBG hexadecimal da paleta (de todas a cores/para toda a tabela).
	-- alterar o tom (escurecer/clarear) de todas as cores da paleta (light): velocidade do desgaste (em tics), booleano (true para escurecer), index de um cor para alterar apenas ela (-1 por padrão), ciclo (0, padrão, para finalisar no teto/piso; 1 para realizar um "vai e vem"; 2 para um "ciclo bruto")

	-- ADD TO TABLE -------------------------------------------------------------

	magicPalette.sortCode = sortCode
	magicPalette.toHex    = toHex
	magicPalette.toDec    = toDec
	-- magicPalette.swap     = swap (alterar uma cor ou a tabela toda)
	-- magicPalette.light    = light (alterar tom: escurecer/clarear)

end

local pale = magicPalette