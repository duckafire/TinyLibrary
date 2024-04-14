-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 1.2

----- FOLLOW_ME -----
-- Itch:     http://duckafire.itch.io
-- GitHub:   http://github.com/duckafire
-- Tic80:    http://tic80.com/dev?id=8700
-- Facebook: http://facebook.com/duckafire

----- LICENSE -----

-- Zlib License

-- Copyright (C) 2024 DuckAfire <facebook.com/duckafire>
  
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
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



----- GLOBAL -----

_G.__LONGBIT_CLASSES = {}-- "_G" to explicity a global table (or variable)



----- INTERNAL -----

local function classToId(id)-- number (pmem id)
	assert(_G.__LONGBIT_CLASSES[0]~=nil, "[longBit] pmem classes not defined.")

	for i = 0, #_G.__LONGBIT_CLASSES do
		if id == _G.__LONGBIT_CLASSES[i] then return i end
	end
	
	-- if no a "class" is not returned
	error('[longBit] Undefined class: "'..d..'"')
end

local function parameter(init, INIT, max, MAX)
	local _init = init or INIT
	local _max  = max  or MAX
	local add   = (_init > _max) and -1 or 1
	
	return _init, _max, _add
end



----- SET VALUE -----

local function setClass(classes, max, init)
	local _init, _max, add = parameter(init, 0, max, #classes - 1)
	local id = 0
	
	for i = _init, _max, add do
		id = id + 1
		_G.__LONGBIT_CLASSES[i] = classes[id]
	end
end

local function setMem(newValue, itemID, className, lenght)
	local pmemID  = classToId(className)
	local _itemID = itemID + 1
	local _lenght = lenght or 1
	local value   = nil
	
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

local function boot(memID, max, init, empty)
	local _init, _max, add = parameter(init, 0, max, #memID -1)
	local value = ""
	
	for i = _init, _max, add do
		-- add "joker" value
		value = string.sub("2"..tostring(memID[i + 1]), 1, 10)
		
		-- fill empty spaces
		while #value < 10 do value = value..(empty or "0") end
	
		-- save in persistent memory
		pmem(i, tonumber(value))
	end
end

local function clear(class, max, init)
	if class then
		_G.__LONGBIT_CLASSES = {}
		
	else
		local _init, _max, add = parameter(init, 0, max, 255)

		for i = _init, _max, add do pmem(i, 0) end
	end
end



----- GET VALUE -----

local function getNum(itemID, className, lenght)
	local _itemID = itemID + 1
	local _lenght = lenght or 1
	local pmemID  = classToId(className)
	
	return tonumber(string.sub(tostring(pmem(pmemID)), _itemID, _itemID + _lenght - 1))
end

local function getBool(itemID, className, equal)
	return getNum(itemID, className) == (equal or 1)
end

local function getClass(id)
	return _G.__LONGBIT_CLASSES[id]
end


	
----- ADD TO TABLE -----
	
local longBit = {}

longBit.setClass = setClass
longBit.setMem   = setMem
longBit.boot     = boot
longBit.clear    = clear
longBit.getNum   = getNum
longBit.getBool  = getBool
longBit.getClass = getClass

return longBit