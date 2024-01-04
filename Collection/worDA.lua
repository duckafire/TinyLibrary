-- Copy and paste the code in your cart [v: 0.0]

local worDA = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	local function newFont( LETTERS, letters, numbers, special, _spcial )
		local temp = { LETTERS = LETTERS, letters = letters, numbers = numbers, special = special, _spcial = _spcial }
		
		for i = 1, 27 do
			if not temp.LETTERS[i] then temp.LETTERS[i] = 0 end-- A-Z
			if not temp.letters[i] then temp.letters[i] = 0 end-- a-z
			if not temp.numbers[i] and i <= 10 then temp.numbers[i] = 0 end-- 0-9
			if not temp.special[i] and i <= 13 then temp.special[i] = 0 end-- !?.,:;"()[]{}
			if not temp._spcial[i] and i <= 19 then temp._spcial[i] = 0 end-- '%$#&@-+_`\|=<>^~/*
		end
		
		return temp
	end

	local function drawFont( Font )
		local LETTERS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
		local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
		local numbers = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
		local special = { "!", "?", ".", ",", ":", ";", '"', "(", ")", "[", "]", "{", "}" }
		local _spcial = { "%", "$", "#", "&", "@", "-", "+", "_", "\", "|", "=", "<", ">", "^", "~", "/", "*" }
	-- draw based in resturn of "newFont"
	end

	local function title( letters, x, y, wh, space, size, vertical )-- revisar
		local wh, space = wh or 7, space or 1
		local between = wh + space
		local size = size or 1
		for i = 1, #letters do
			local x, y = x + between * ( i - 1 ), y
			if vertical then
				x, y = x, y + between * ( i - 1 )
			end
			spr( letters[ i ], x, y, 0, size )
		end
	end

	local function lenght( txt, small, size )-- revisar
		local num = 6
		if small then num = 4 end
		local size = size or 1
		local width, height = #txt * num * size, 1
		for i = 1, #txt do
			if string.sub( txt, i, i ) == "\\" then
				if string.sub( txt, i + 1, i + 1 ) == "n" then
					height = height + 1
				end
			end
		end
		height = height * 7 * size
		return width, height
	end

	local function center( x, y, txt, small, size )-- revisar
		local w, h = text.lenght( txt, small, size )
		return x - w // 2, y - h // 2
	end

	local function brek( max, txt )--refazer
		local new, init = "", 1
		repeat
			new = new..string.sub( txt, init, init + max ).."\n"
			if init < #txt then
				new = new.."\n"
			end
			init = init + max + 2
		until init >= #txt
		return new
	end
	
	-- ADD TO TABLE -------------------------------------------------------------
	
	worDA.title = title
	worDA.center = center
	worDA.lenght = lenght
	worDA.brek = brek
	
end

local word = worDA -- library reference