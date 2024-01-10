local AUTHOR  = "DuckAfire"
local VERSION = "1.0"

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
	
local printPlus = {}
	
printPlus.lenght = lenght
printPlus.center = center
printPlus.list   = list
printPlus.title  = title

return printPlus