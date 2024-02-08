-- [NOT COMPACTED] Copy and paste the code in your cart [v: 0.0]

local magicPalette = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- CONVERSION -----

	local function sortCode(codes, together, hex)-- internal
		local tg, _codes, c = together or 0, {}-- type of return; colors; to return
		
		if hex and (type(codes) == "string" or (type(codes) == "table" and type(codes[1]) == "string" and #codes == 1)) then
			local temp = type(codes) == "table" and codes[1] or codes
			temp = string.sub(temp, 1, 1) == "#" and string.sub(temp, 2) or temp
			
			for i = 2, 6 do if #temp == 6 then break end temp = temp.."0" end
			for i = 1, 3 do local id = {1, 3, 5} _codes[i] = string.upper(string.sub(temp, id[i], id[i] + 1)) end
		
		else
			_codes = codes
		end
		
		for i = 1, 3 do if not _codes[i] then _codes[i] = 0 end end-- to decimal
		
		if tg == 0 then-- 3 arguments to 3 variables
			return _codes[1], _codes[2], _codes[3]
		
		elseif tg == 1 then-- a array (table)
			c = _codes
		
		elseif tg == 2 then-- a table with "structure"
			c = {red = _codes[1], green = _codes[2], blue = _codes[3]}
		
		elseif tg == 3 then-- string
			if hex then-- hexadecimal
				c = "#".._codes[1].._codes[2].._codes[3]
			else-- decimal
				c = _codes[1]..", ".._codes[2]..", ".._codes[3]
			end
		end
		
		return c
	end
	
	-- alterar um cor da palete (editColor): índice da cor, tabela com o código da cor, valor booleano (true para usar valores decimais).
	-- trocar toda a paleta (swapPalette): código RBG hexadecimal da paleta (de todas a cores/para toda a tabela).
	-- alterar o tom (escurecer/clarear) de todas as cores da paleta (light): velocidade do desgaste (em tics), booleano (true para escurecer), index de um cor para alterar apenas ela (-1 por padrão), ciclo (0, padrão, para finalisar no teto/piso; 1 para realizar um "vai e vem"; 2 para um "ciclo bruto")

	-- ADD TO TABLE -------------------------------------------------------------

	local magicPalette = {}

	magicPalette.sortCode   = sortCode
	magicPalette.colorToHex = colorToHex
	magicPalette.colorToDec = colorToDec

end

local pale = magicPalette
