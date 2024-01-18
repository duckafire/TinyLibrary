local NAME    = "print+"
local AUTHOR  = "DuckAfire"
local VERSION = "2.0"

local FOLLOW_ME = {
	Itch     = "http://duckafire.itch.io",
	GitHub   = "http://github.com/duckafire",
	Tic80    = "http://tic80.com/dev?id=8700",
	Facebook = "http://facebook.com/duckafire"
}

local LICENSE = [[

	MIT License

	Copyright (c) 2024 DuckAfire

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

]]



----- TO PRINT FUNCTION -----

local function lenght( text, lines, fixed, size, small )
	-- X
	assert( type( text ) == "string", '[print+] String (parameter) not specified, in function "pplus.lenght"' )
		
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

	assert( type( text ) == "table", '[print+] Table (parameter) not specified, in function "pplus.list"' )
	
	local x, y = x or 0, y or 0
	local color, space = color or 15, space or 10-- vertical spaces
	
	for i = 1, #text do
		print( tostring( text[i] ), x, y + space * (i - 1), color, fixed, size, small )
	end
	
end



----- USE SPRITES -----

local function title( sprites, X, Y, dimensions, space, size, chromaKey, vertical )
	assert( type( sprites ) == "table", '[print+] Table (parameter) not specified, in function "pplus.title"' )
	
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



-- ADD TO TABLE -------------------------------------------------------------
	
local printPlus = {}
	
printPlus.lenght = lenght
printPlus.center = center
printPlus.list   = list
printPlus.title  = title

return printPlus