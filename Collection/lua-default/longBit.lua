-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 1.0

-- FOLLOW_ME:
	-- Itch:     http://duckafire.itch.io
	-- GitHub:   http://github.com/duckafire
	-- Tic80:    http://tic80.com/dev?id=8700
	-- Facebook: http://facebook.com/duckafire

-- LICENSE:
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



----- SET VALUE -----

_G.__LONGBIT_CLASSES = {}

local function setClass(...)
	_G.__LONGBIT_CLASSES = {...}
end

local function bootMem(memID)
	for i = 0, #memID - 1 do
		pmem(i, tonumber(memID[i + 1]))
	end
end

local function clearMem(max, init)
	local _init = init or 0
	local _max  = max or 255
	local add   = (init ~= nil and init < 0) and -1 or 1

	for i = _init, _max, add do pmem(i, 0) end
end



----- INTERNAL -----

local function classToId(id)-- number (pmem id)
	for i = 1, #__LONGBIT_CLASSES do
		if id == __LONGBIT_CLASSES[i] then return i - 1 end
	end
end



----- GET VALUE -----

local function getMem(itemID, className, lenght)
	local _itemID = itemID + 1
	local _lenght = lenght or 1
	local pmemID  = classToId(className)
	
	return tonumber(string.sub(tostring(pmem(pmemID)), _itemID, _itemID + _lenght - 1))
end

local function boolMem(itemID, className, equal)-- get value like boolean
	return getMem(itemID, className) == (equal or 1)
end

local function setMem(newValue, itemID, className, lenght)
	local pmemID  = classToId(className)
	local _itemID = itemID + 1
	local _lenght = lenght or 1
	local value = nil
	
	-- convert boolean to binary
	if type(newValue) == "boolean" then
		value = newValue and 1 or 0
	
	-- fill "blank spaces" in newValue
	else
		value = tostring(newValue)
		
		if _lenght > 1 then
			for i = 1, _lenght do-- update "_lenght" times
				value = (#value < _lenght) and "0"..value or value
			end
		end
	end
	
	-- get pmem value "fragments" to restaur it
	local function convert(a, z)   return string.sub(tostring(pmem(pmemID)), a, z)   end
	local back   = convert(1, _itemID - 1)
	local front  = convert(_itemID + _lenght)
	
	pmem(pmemID, tonumber(back..value..front))
end

	
	
-- ADD TO TABLE -------------------------------------------------------------
	
local longBit = {}

longBit.setClass = setClass
longBit.bootMem  = bootMem
longBit.clearMem = clearMem
longBit.getMem   = getMem
longBit.boolMem  = boolMem
longBit.setMem   = setMem

return longBit