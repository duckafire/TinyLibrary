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

local function classToId(id)-- memory index
	assert(_G.__LONGBIT_CLASSES[0]~=nil, "[longBit] pmem classes not defined.")

	for i = 0, #_G.__LONGBIT_CLASSES do
		if id == _G.__LONGBIT_CLASSES[i] then return i end
	end
	
	-- if no a "class" is not returned
	error('[longBit] Undefined class: "'..d..'"')
end

local function getArgs(funcName, argID, init, INIT, max, MAX)
	local i = init or INIT
	local m = max  or MAX
	assert(i > m, '[longBit] The "max" value is less that "init". In function lbit.'..funcName..', argument #'..argID..'.')
	return i, m
end



----- SET VALUE -----

local function setClass(classes, _max, _init)
	local init, max = getArgs("setClass", 2, _init, 0, _max, #classes - 1)
	local id = 0
	
	for i = init, max do
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

local function boot(memID, force, _max, _init, empty)
	local init, max = getArgs("boot", 3, _init, 0, _max, #memID -1)
	local errBegin, errEnd = "", "" -- error messages
	local value = ""
	
	for i = init, max do
		if pmem(i) == 0 or force then
			-- update error mensage
			errBegin = '[longBit] The value "'..memID[i + 1]..'" is '
			errEnd   = '. In function lbit.boot, argument #1 (index: '..i..')'
			
			-- check if it is valid
			assert(type(    memID[i + 1]) == "string",  errBegin..'not a string'..errMsg)
			assert(tonumber(memID[i + 1]) ~= nil,       errBegin..'unvalid, because it own a NaN character'..errMsg)
			assert(tonumber(memID[i + 1]) <= 999999999, errBegin..'too big, the maximum is "999999999"'..errMsg)
			
			-- string to number
			value = (memID[i + 1] ~= nil) and tonumber("2"..memID[i + 1]) or tonumber(memID[#memID])
			
			-- fill empty spaces
			while #value < 10 do   value = value..(empty or "0")   end
		
			-- save in persistent memory
			pmem(i, tonumber(value))
		
		end
	end
	
end

local function clear(_type, _max, _init)
	-- check if "_type" is valid
	assert(_type == "all", _type == "memory" or _type == "classes" or _type == "lessClass", '[longBit] Keyword '.._type..' is invalid, try "all", "memory", "classes" or "lessClass". In function lbit.clear, argument #1.')
	local init, max = getArgs("clear", 2, _init, 0, _max, 255)
	
	if class == "memory" or class == "all" then
		for i = init, max do
			pmem(i, 0)
		end
	end
	
	if class == "classes" or _type == "all" then
		_G.__LONGBIT_CLASSES = {}
	end
	
	if class == "lessClass" then
		for i = init, max do
			-- check if a class not are defined to this memory
			if not _G.__LONGBIT_CLASSES[i] then   pmem(i, 0)    end
		end
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



----- SWICTH -----	

local function swapClass(newName, id, wasDefined)
	-- check if the class was be defined
	assert(not wasDefined or _G.__LONGBIT_CLASSES[id], '[longBit] The class of the "'..id..'th" memory space was not defined. In function lbit.swicthClass, argument #2.')

	_G.__LONGBIT_CLASSES[id] = newName
end



----- ADD TO TABLE -----
	
local longBit = {}

longBit.setClass  = setClass
longBit.setMem    = setMem
longBit.boot      = boot
longBit.clear     = clear
longBit.getNum    = getNum
longBit.getBool   = getBool
longBit.getClass  = getClass
longBit.swapClass = swapClass

return longBit