-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 3.3.0
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


----- CONSTANTS -----

local ZERO = 2000000000
local MAX  = 2999999999



----- STORE CHANGES -----

local LBC = {} -- LongBit-Classes
local CID = {} -- Classes-InDex (it stores the index of spaces used in LCB)


----- ACTION CONTROLS -----

local GetBy = 1



----- INTERNAL -----

local function classToId(funcName, argID, id)
	for i = 1, #CID do
		if id == LBC[CID[i]] then return CID[i] end
	end
	
	-- if no a "class" is not returned
	libError3('The class "'..id..'"', {0}, funcName, argID)
end



----- SET VALUE -----

local function LIB_setClass(classes, init)
	init = init or 0

	libAssert(type(classes) ~= "table", '"classes"', {}, "setClass", "1")
	libAssert(init < 0 or init > 255, '"init" is invalid.\nTry values between 0-255', nil, "setClass", "1")
	
	local max = init + #classes - 1
	max = max < 255 and max or 255

	local id, addToCID = 1, true
	for i = init, max do
		libAssert(classes[id] == "" or string.find(classes[id], " ") ~= nil, "Invalid class.\nDo not use strings with spaces or void strings", nil, "setClass", "1")
		
		LBC[i] = classes[id]
		id = id + 1

		addToCID = true
		for j = 1, #CID do
			if CID[j] == i then
				addToCID = false
				break
			end
		end

		if addToCID then table.insert(CID, i) end
	end

	return #classes == id
end

local function LIB_setMem(newValue, itemID, className, length)
	local pmemID  = classToId("setMem", 3, className)
	local value   = nil

	itemID = itemID + 1
	length = length or 1
	
	-- convert boolean to binary
	if type(newValue) == "boolean" then
		value = newValue and 1 or 0
	
	-- fill "blank spaces" in newValue
	else
		value = tostring(newValue)
		
		if length > 1 then
			for i = 1, length do-- update "_length" times
				value = (#value < length) and "0"..value or value
			end
		end
	end
	
	-- get pmem value "fragments" to restaur it
	local function convert(a, z)   return string.sub(tostring(pmem(pmemID)), a, z)   end
	local back   = convert(1, itemID - 1)
	local front  = convert(itemID + length)
	
	pmem(pmemID, tonumber(back..value..front))
end

local function LIB_setAll(newValue, className, change, loop, right)
	local pmemID = classToId("setAll", 2, className)

	local function convert(value, number, _right)
		if number then
			-- "2000123"
			-- "123"
			repeat
				value = string.sub(value, 2)
			until not (string.sub(value, 1, 1) == 0)

			-- 123
			return tonumber(value)
		end

		-- 123
		-- 000000123
		if #newValue < 9 then
			for i = 1, 9 - #newValue do
				if _right then
					newValue = newValue.."0"
				else
					newValue = "0"..newValue
				end
			end
		end

		-- 2000000123
		return tonumber("2"..newValue)
	end

	change = change or 0
	if change == 0 then   newValue = convert(newValue)   end
	if change ~= 0 then   newValue = convert(pmem(ID), true) + convert(newValue, true) * (change < 0 and -1 or 1)   end
	if right       then   newValue = newValue(newValue, true, true)   end

	-- "invalid" value or the replacement is "forced"
	if pmem(pmemID) < ZERO or pmem(pmemID) > MAX or change ~= 0 then
		local status = (newValue < ZERO) and 0 or (newValue > MAX) and 2 or 1
		
		-- check underflow and overflow
		if loop then
			if     newValue < ZERO then
				pmem(pmemID, MAX - math.abs(newValue))
			elseif newValue > MAX  then
				pmem(pmemID, newValue - MAX)
			else
				pmem(pmemID, newValue)
			end

			return status
		end

		if     newValue < ZERO then pmem(pmemID, ZERO)
		elseif newValue > MAX  then pmem(pmemID, MAX)
		else   pmem(pmemID, newValue)
		end

		return status
	end

	return -1 -- not added
end

local function LIB_boot(memID, replace, init, left, empty)
	init = init or 0
	empty = tonumber(empty) ~= nil and empty or "0"
	local id, value = 1, ""
	
	libAssert(#memID > 256, "The table specified is bigger that 256.", nil, "boot", "1")
	libAssert(init + #memID - 1 > 255, "The value result addition of "..init.." (#3) with "..(#memID - 1).." (#1) is bigger of 256.", "boot", "3")

	for i = init, init + #memID - 1 do
		if pmem(i) <= ZERO or replace then
			-- check if it is valid
			value = memID[id]
			id = id + 1

			libAssert(type(    value) ~= "string", value.." is not a string.",                       nil, "boot", "1")
			libAssert(tonumber(value) == nil,      value.." cannot be converted to number.",         nil, "boot", "1")
			libAssert(tonumber(value) > 999999999, value.." is too big.\nThe maximum is 999999999,", nil, "boot", "1")
				
			-- fill empty spaces
			while #value < 9 do
				if left then
					value = empty..value
				else
					value = value..empty
				end
			end

			-- add joker
			value = "2"..value
		
			-- save in persistent memory
			pmem(i, tonumber(value))
		end
	end
	
	return #memID == id
end

local function LIB_clear(Type, absolute, init, max)
	-- check if "_type" is valid
	local isValid = false
	local allTypes = {"all", "memory", "class", "noneMemory", "noneClass"}

	for i = 1, #allTypes do
		if Type == allTypes[i] then
			isValid = true
			break
		end
	end

	libAssert(not isValid, Type, allTypes, "clear", "1")

	init = init or 0
	max  = max  or 255

	local changed = false
	local memZero = absolute and 0 or ZERO

	if Type == "memory" or Type == "all" then
		for i = init, max do
			changed = true
			pmem(i, memZero)
		end
	end
	
	if Type == "class" or Type == "all" then
		changed = true
		LBC = {}
	end
	
	if Type == "lessClass" then
		for i = init, max do
			-- check if a class not are defined to this memory
			if LBC[i] ~= nil then
				changed = true
				pmem(i, memZero)
			end
		end
	end

	if Type == "noneMemory" then
		for i = init, max do
			if LBC[i] ~= nil and pmem(i) < ZERO and pmem(i) > MAX then
				changed = true
				LBC[i] = nil
			end
		end
	end

	return changed
end



----- GET VALUE -----

local function LIB_getNum(itemID, className, length)
	local origin = {"getNum", "getBool"}
	libAssert(itemID < 0 or itemID > 9, "Invalid index #"..itemID..".\nTry values between 1-9.", nil, origin[GetBy], "1")
	
	itemID = itemID + 1
	length = length or 1
	
	libAssert(length < 1 or length > 9, "Invalid sub-memory scale.\nTry values between 1-9.", nil, origin[GetBy], "3")

	local pmemID = classToId("getNum", 2, className)
	
	libAssert(#tostring(pmem(pmemID)) < 10, "Sub-memory not defined.", nil, origin[GetBy], "1")
	GetBy = 1
	return tonumber(string.sub(tostring(pmem(pmemID)), itemID, itemID + length - 1))
end

local function LIB_getBool(itemID, className, equal, length)
	GetBy = 2
	return LIB_getNum(itemID, className, length) == (equal or 1)
end

local function LIB_getClass(id, wasDefined)
	libAssert(wasDefined and not LBC[id], "The class", {0}, "getClass", "1")

	return LBC[id]
end

local function LIB_getAll(className, full)
	local pmemID = classToId("getAll", 1, className)

	if pmem(pmemID) < ZERO then return 0 end
	
	local value = string.sub(tostring(pmem(pmemID)), 2)

	if full then return value end
	return tonumber(value)
end



----- SWAP -----

local function LIB_swapClass(newName, id)
	libAssert(type(newName) ~= "string", '"newValue" is not a string.', nil, "swapClass", "1")

	local wasDefined = LBC[id]
	LBC[id] = newName

	if wasDefined then return true end
	return false
end
