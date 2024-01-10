-- [NOT COMPACTED] Copy and paste the code in your cart [v: 1.0]

local printPlus = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	
	----- TO PRINT FUNCTION -----
	
	local function lenght( word, lines, fixed, size, small )
		local lines = lines or 1
		
		return print( word, 0, 136, 0, small, size or 1, fixed ), 6 * lines
	end

	local function center( word, x, y, lines, fixed, size, small )
		local width, height = lenght( word, lines, fixed, size, small )
		
		return x - width // 2, y - height // 2
	end
	
	local function list( text, x, y, color, space, fixed, size, small )
		if type( text ) ~= "table" then error( '[print+] Table (parameter) not expecified (function: "printPlus.queue")' ) end
		
		local x, y, color, space = x or 0, y or 0, color or 0, space or 10
		
		for i = 1, #text do
			print( text[i], x, y + space * (i - 1), color, fixed, size, small )
		end
	end

	----- USE SPRITES -----

	local function title( letters, x, y, dimensions, space, size, vertical )
		if type( letters ) ~= "table" then error( '[print+] Table (parameter) not expecified (function: "printPlus.title" )' ) end
		
		local dimensions = dimensions or 8
		local space		 = space 	  or 1
		local size		 = size  	  or 1
		
		for i = 1, #letters do
			local x = x + (dimensions + space) * ( i - 1 )
			local y = y
			
			if vertical then
				x = x
				y = y + (dimensions + space) * ( i - 1 )
			end
			
			spr( letters[ i ], x, y, 0, size )
		end
		
	end
	
	-- ADD TO TABLE -------------------------------------------------------------
	
	printPlus.lenght = lenght
	printPlus.center = center
	printPlus.list   = list
	printPlus.title  = title
	
end

local pplus = printPlus -- library reference