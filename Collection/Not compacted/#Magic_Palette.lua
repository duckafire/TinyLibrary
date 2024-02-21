-- [NOT COMPACTED] Copy and paste the code in your cart [v: 0.0]

local magicPalette = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- CONVERSION -----

	local function sortCode(code, together, hex, low)-- internal
		local tg, _code, c = together or 0, {}, nil-- type of return; colors; to return
		
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
		if tg == 0 then-- 3 arg to 3 var
			return _code[1], _code[2], _code[3]
		
		elseif tg == 1 then-- a array (table)
			c = _code
		
		elseif tg == 2 then-- a table with "structure"
			c = {red = _code[1], green = _code[2], blue = _code[3]}
		
		elseif tg == 3 then-- string
			if hex then
				c = "#".._code[1].._code[2].._code[3]-- hexadecimal
			else
				c = _code[1]..", ".._code[2]..", ".._code[3]-- decimal
			end
		else
			error( '[Magic_Palette] The parameter "together" is invalid, try values between 0-3. In function "pale.sortCode", argument #2.' )
		end
		
		return c
	end
	
	-- alterar um cor da palete (editColor): índice da cor, tabela com o código da cor, valor booleano (true para usar valores decimais).
	-- trocar toda a paleta (swapPalette): código RBG hexadecimal da paleta (de todas a cores/para toda a tabela).
	-- alterar o tom (escurecer/clarear) de todas as cores da paleta (light): velocidade do desgaste (em tics), booleano (true para escurecer), index de um cor para alterar apenas ela (-1 por padrão), ciclo (0, padrão, para finalisar no teto/piso; 1 para realizar um "vai e vem"; 2 para um "ciclo bruto")

	-- ADD TO TABLE -------------------------------------------------------------

	magicPalette.sortCode   = sortCode
	-- magicPalette.colorToHex = colorToHex
	-- magicPalette.colorToDec = colorToDec
	-- magicPalette.swap       = swap (alterar uma cor ou a tabela toda)
	-- magicPalette.light      = light (alterar tom: escurecer/clarear)

end

local pale = magicPalette

local code, cod2, cod3