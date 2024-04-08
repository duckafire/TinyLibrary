----------------------------------------------------------------------------------
-- zlib License

-- Copyright (C) 2024 DuckAfire <facebook.com/duckafire>
  
-- This software is provided 'as-is', without any express or implied
-- warranty.  In no event will the authors be held liable for any damages
-- arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
  
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required. 
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------------

-- [NOT COMPACTED] Copy and paste the code in your cart [v: 2.2]

local printPlus = {}
local DA_LICENSE  = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	
	----- TO PRINT FUNCTION -----
	
	local function lenght( text, lines, fixed, size, small )
		-- X
		assert( type( text ) == "string", '[print+] String (argument) not specified. In function "pplus.lenght", argument #1' )
			
		local scale = print( text, 0, 136 )
		
		scale = small and scale - #text * 2 or scale-- 6x6 in normal font; 4x6 in small font (in most cases)
		
		if fixed then
			for i = 1, #text do
				local add = 0
				local cur = string.sub( text, i, i )-- current letter
				
				if 	   string.match( cur, '[%"%+%-%_%=%<%>%?%{%}%~]' ) or cur == " " or cur == "'" then   add = 2
				elseif string.match( cur, '[%!%.%,%(%)%:%;%[%]]' ) then   add = 3
				elseif cur == "|" then   add = 4
				end
				
				scale = scale + add
			end
		end

		local size = size or 1

		-- Y
		local lines = lines or 1
		
		return scale * size, (6 * size) * lines
	end

	local function center( text, x, y, lines, fixed, size, small )
		local x, y = x or 0, y or 0
		
		local width, height = lenght( text, lines, fixed, size, small )
		
		return x - width // 2 + 1, y - height // 2 + 1
	end
	
	local function list( text, x, y, color, space, fixed, size, small )
	
		assert( type( text ) == "table", '[print+] Table (argument) not specified. In function "pplus.list", argument #1' )
		
		local x, y = x or 0, y or 0
		local color, space = color or 15, space or 10-- vertical spaces
		
		for i = 1, #text do
			print( tostring( text[i] ), x, y + space * (i - 1), color, fixed, size or 1, small )
		end
		
	end

	----- USE SPRITES -----

	local function title( sprites, X, Y, dimensions, space, size, chromaKey, vertical )
		assert( type( sprites ) == "table", '[print+] Table (argument) not specified. In function "pplus.title", argument #1' )
		
		local back-- table to store the chromaKey colors
		
		if     type( chromaKey ) == "number" then
			back = {}
			for i = 1, #sprites do   back[i] = chromaKey   end-- one index to all index in table
		
		elseif type( chromaKey ) == "table"  then
			back = ChromaKey
			if #back < #sprites then   for i = #back + 1, #sprites do   back[i] = 0   end   end-- populate the table with default (0)
		
		else
			back = {}
			for i = 1, #sprites do   back[i] = 0   end-- default value (0)

		end
		
		-- default values
		local X, Y = X or 0, Y or 0
		local dimensions = dimensions or 8
		local space		 = space 	  or 1
		local size		 = size  	  or 1
		
		for i = 1, #sprites do
			local x, y
			
			if vertical then
				x = X
				y = Y + (dimensions + space) * ( i - 1 )
			else
				x = X + (dimensions + space) * ( i - 1 )
				y = Y
			end
			
			spr( sprites[i], x, y, back[i], size )
		end
		
	end
	
	----- ADD TO TABLE -----
	
	printPlus.lenght = lenght
	printPlus.center = center
	printPlus.list   = list
	printPlus.title  = title
	
end

local pplus = printPlus -- you can customize this reference or not use it.