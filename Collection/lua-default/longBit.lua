-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 2.4

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

local LBC = {} -- Long-Bit-Classes



----- INTERNAL -----

local function classToId(funcName, argID, id)-- memory index
	assert(LBC[0]~=nil, '[longBit] pmem classes not defined. In function longBit.'..funcName..', argument #'..argID..'.')

	for i = 0, #LBC do
		if id == LBC[i] then return i end
	end
	
	-- if no a "class" is not returned
	error('[longBit] Undefined class: "'..id..'. In function longBit.'..funcName..', argument #'..argID..'.')
end

local function getArgs(funcName, argID, init, INIT, max, MAX)
	local i = init or INIT
	local m = max  or MAX
	assert(i <= m, '[longBit] The "max" value is less that "init". In function longBit.'..funcName..', argument #'..argID..'.')
	return i, m
end



----- SET VALUE -----

local function setClass(classes, _max, _init)
	local init, max = getArgs("setClass", 2, _init, 0, _max, #classes - 1)
	local id = 0
	
	assert(type(classes) == "table", '[longBit] Table not specified. In function "lbit.setClass", argument #1.')
	
	for i = init, max do
		assert(classes[i + 1] ~= "", '[longBit] Empty strings cannot used like class. In function "lbit.setClass", argument #1 (index: '..i..').')
		assert(string.find(classes[i + 1], " ") == nil, '[longBit] Classes names cannot contain spaces characters. In function "lbit.setClass", argument #1 (index: '..i..').')
		
		id = id + 1
		LBC[i] = classes[id]
	end
end

local function setMem(newValue, itemID, className, lenght)
	local pmemID  = classToId("setMem", 3, className)
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

local function setAll(newValue, className, itself)
	local value  = newValue
	local pmemID = classToId("setAll", 2, className)

	local it = 0
	if itself then it = pmem(pmemID) end
	value = value + it

	assert(value >= 0,        "[longBit] The value specified is too small. In function longBit.setAll, argument #1.")
	assert(value <= 4294967295, "[longBit] The value specified is too big. In function longBit.setAll, argument #1.")
	
	pmem(pmemID, value)
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
			assert(type(    memID[i + 1]) == "string",  errBegin..'not a string'..errEnd)
			assert(tonumber(memID[i + 1]) ~= nil,       errBegin..'unvalid, because it own a NaN character'..errEnd)
			assert(tonumber(memID[i + 1]) <= 999999999, errBegin..'too big, the maximum is "999999999"'..errEnd)
			
			-- string to number
			value = (memID[i + 1] ~= nil) and "2"..memID[i + 1] or memID[#memID]
		
			-- fill empty spaces
			while #value < 10 do   value = value..(empty or "0")   end
		
			-- save in persistent memory
			pmem(i, tonumber(value))
		
		end
	end
	
end

local function clear(_type, _max, _init)
	-- check if "_type" is valid
	assert(_type == "all" or _type == "memory" or _type == "classes" or _type == "lessClass", '[longBit] Keyword '.._type..' is invalid, try "all", "memory", "classes" or "lessClass". In function lbit.clear, argument #1.')
	local init, max = getArgs("clear", 2, _init, 0, _max, 255)
	
	if _type == "memory" or _type == "all" then
		for i = init, max do
			pmem(i, 0)
		end
	end
	
	if _type == "classes" or _type == "all" then
		LBC = {}
	end
	
	if _type == "lessClass" then
		for i = init, max do
			-- check if a class not are defined to this memory
			if not LBC[i] then   pmem(i, 0)    end
		end
	end
	
end



----- GET VALUE -----

local function getNum(_itemID, className, _lenght)
	assert(_itemID > 0 and _itemID < 10, '[longBit] Index invalid, try values between 0-9. In function lbit.getNum, argument #1.')
	
	local itemID = _itemID + 1
	local lenght = _lenght or 1
	local pmemID  = classToId("getNum", 2, className)
	
	return tonumber(string.sub(tostring(pmem(pmemID)), itemID, itemID + lenght - 1))
end

local function getBool(itemID, className, equal)
	assert(itemID > 0 and itemID < 10, '[longBit] Index invalid, try values between 0-9. In function lbit.getNum, argument #1.')
	
	return getNum(itemID, className) == (equal or 1)
end

local function getClass(id, wasDefined)
	assert(not wasDefined or LBC[id], '[longBit] Class not defined, index: '..id..'. In function lbit.getClass, argument #1.')

	return LBC[id]
end

local function showMem(className)
	local pmemID = classToId("showMem", 1, className)

	return pmem(pmemID)
end



----- SWICTH -----	

local function swapClass(newName, id, wasDefined)
	-- check if the class was be defined
	assert(not wasDefined or LBC[id], '[longBit] The class of the "'..id..'th" memory space was not defined. In function lbit.swicthClass, argument #2.')

	LBC[id] = newName
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
longBit.showMem   = showMem
longBit.setAll    = setAll

return longBit