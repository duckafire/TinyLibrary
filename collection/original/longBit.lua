-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 3.0.0
-- LICENSE: Zlib License
--
-- Copyright (C) 2024 DuckAfire <duckafire.github.io/nest>
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required. 
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.



----- DEFAULT -----

local function libError3(argument, options, funcName, index)
	local msg = argument -- not customized
	
	if type(options) == "table" then
		
		if options[1] == nil then
			msg = argument.." not specified."

		elseif options[1] == 0 then
			msg = argument.." was not defined."
		
		else
			msg = "Invalid argument: "..argument.."\nTry: "
			for i = 1, #options do
				msg = msg..options[i].." | "
			end
		end

	end

	error("\n\n[longBit]\n"..msg.."\nFunction: "..funcName.."\nParameter: #"..index.."\n")
end

local function libAssert(cond, argument, options, funcName, index)
	if cond then
		libError3(argument, options, funcName, index)
	end
end



----- STORE CHANGES -----

local LBC = {} -- LongBit-Classes
local CID = {} -- Classes-InDex



----- ACTION CONTROLS -----

local GetBy = 1



----- INTERNAL -----

local function classToId(funcName, argID, id)
	libAssert(LBC == nil, "This class", {0}, funcName, argID)

	for i = 0, #CID do
		if id == LBC[CID[i]] then return i end
	end
	
	-- if no a "class" is not returned
	libError3("The class #"..id, {0}, "classToId", argID)
end

local function getArgs(funcName, argID, init, INIT, max, MAX)
	init = init or INIT
	max  = max  or MAX
	libAssert(init > max, 'The "min" value is less that "min"', nil, funcName, argID)
	return init, max
end



----- SET VALUE -----

local function LIB_setClass(classes, max, init)
	init, max = getArgs("setClass", 2, init, 0, max, #classes - 1)

	local id, addToCID = 1
	
	libAssert(type(classes) ~= "table", '"classes"', {}, "setClass", "1")
	
	for i = init, max do
		libAssert(classes[id] == "", "Empty strings cannot be used like class.\nIn index #"..i, nil, "setClass", "1")
		libAssert(string.find(classes[id], " ") ~= nil, "Classes names cannot contain spaces characters.\nIn index #"..i, "setClass", "1")
		
		LBC[i] = classes[id]
		id = id + 1
		
		addToCID = true
		for j = 1, #CID do
			if CID[j] == i then addToCID = false end
		end
		
		if addToCID then table.insert(CID, i) end
	end
end

local function LIB_setMem(newValue, itemID, className, lenght)
	local pmemID  = classToId("setMem", 3, className)
	local value   = nil

	itemID = itemID + 1
	lenght = lenght or 1
	
	-- convert boolean to binary
	if type(newValue) == "boolean" then
		value = newValue and 1 or 0
	
	-- fill "blank spaces" in newValue
	else
		value = tostring(newValue)
		
		if lenght > 1 then
			for i = 1, lenght do-- update "_lenght" times
				value = (#value < lenght) and "0"..value or value
			end
		end
	end
	
	-- get pmem value "fragments" to restaur it
	local function convert(a, z)   return string.sub(tostring(pmem(pmemID)), a, z)   end
	local back   = convert(1, itemID - 1)
	local front  = convert(itemID + lenght)
	
	pmem(pmemID, tonumber(back..value..front))
end

local function LIB_setAll(newValue, className, itself)
	local pmemID = classToId("setAll", 2, className)

	local it = 0
	if itself then it = pmem(pmemID) end
	newValue = newValue + it

	local text = {"small", "big"}
	for i = 1, 2 do
		libAssert((newValue < 0 and i == 1) or (newValue > 4294967295 and i == 2), "The value specified if too "..text[i]..".", nil, "setAll", "1")
	end
	
	pmem(pmemID, newValue)
end

local function LIB_boot(memID, force, init, empty)
	init = getArgs("boot", 3, init, 0, 1, 0)
	local value, mem = "", ""
	
	libAssert(#memID > 256, "The table specified is bigger that 256.", nil, "boot", "1")
	libAssert(init + #memID - 1 > 255, "The value result addition of "..init.." (#3) with "..(#memID - 1).." (#1) is bigger of 256.", "boot", "3")

	for i = init, #memID - 1 do
		if pmem(i) == 0 or force then
			-- check if it is valid
			mem = memID[i + 1]
			libAssert(type(    mem) ~= "string", mem.." is not a string.",                       nil, "boot", "1")
			libAssert(tonumber(mem) == nil,      mem.." have NaN characters.",                   nil, "boot", "1")
			libAssert(tonumber(mem) > 999999999, mem.." is too big.\nThe maximum is 999999999,", nil, "boot", "1")
			
			-- add joker
			value = "2"..mem
		
			-- fill empty spaces
			while #value < 10 do   value = value..(empty or "0")   end
		
			-- save in persistent memory
			pmem(i, tonumber(value))
		end
	end
	
end

local function LIB_clear(Type, max, init)
	-- check if "_type" is valid
	libAssert(Type ~= "all" and Type ~= "memory" and Type ~= "classes" and Type ~= "lessClass", Type, {"all", "memory", "classes", "lessClass"}, "clear", "1")
	init, max = getArgs("clear", 2, init, 0, max, 255)
	
	if Type == "memory" or Type == "all" then
		for i = init, max do
			pmem(i, 0)
		end
	end
	
	if Type == "classes" or _type == "all" then
		LBC = {}
	end
	
	if Type == "lessClass" then
		for i = init, max do
			-- check if a class not are defined to this memory
			if not LBC[i] then   pmem(i, 0)    end
		end
	end
	
end



----- GET VALUE -----

local function LIB_getNum(itemID, className, lenght)
	local origin = {"getNum", "getBool"}
	libAssert(itemID <= 0 and itemID >= 10, "Invalid index #"..itemID..".\nTry values between 1-9", nil, origin[GetBy], "1")
	GetBy = 1

	itemID = itemID + 1
	lenght = lenght or 1
	local pmemID  = classToId("getNum", 2, className)
	
	return tonumber(string.sub(tostring(pmem(pmemID)), itemID, itemID + lenght - 1))
end

local function getBool(itemID, className, equal)
	GetBy = 2
	return getNum(itemID, className) == (equal or 1)
end

local function getClass(id, wasDefined)
	libAssert(wasDefined and not LBC[id], "The class", {0}, "getClass", "1")

	return LBC[id]
end

local function getAll(className)
	local pmemID = classToId("getAll", 1, className)

	return pmem(pmemID)
end



----- SWAP -----

local function LIB_swapClass(newName, id, wasDefined)
	-- check if the class was be defined
	libAssert(wasDefined and not LBC[id], "The class", {0}, "swapClass", "2")
	
	libAssert(type(newName) ~= "string", '"newValue" is not a string.', nil, "swapClass", "1")
	
	LBC[id] = newName
end
