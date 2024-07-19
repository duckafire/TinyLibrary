-- NAME:    LongBit
-- AUTHOR:  DuckAfire
-- VERSION: 3.4.3
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

local function libError(condAssert, par, msg, opt, func, id)
	-- "assert" be like
	if condAssert ~= nil then
		if not condAssert then return end
	end
	
	local default = {"Error", "Function", "Index"}
	local text = {nil, func, "#"..id}
	local full = "\n\n[longBit]"

	par = par and '"'..par..'"' or ""
	local function cat(str) text[1] = par..str end

	if     msg == "1" then cat("was not specified")
	elseif msg == "2" then cat("was not defined")
	elseif msg == "3" then cat("is invalid")
	else                   cat(msg)
	end

	for i = 1, 3 do
		full = full.."\n"..default[i]..": "..text[i].."."

		if i == 1 and opt ~= nil then
			full = full.."\nTry: "
			for j = 1, #opt - 1 do full = full.." | " end
			fulll = full..opt[#opt] -- without '|'
		end
	end

	trace("\n>\n>\n>")
	error(full.."\n")
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
	libError(nil, nil, "Invalid class: "..id, nil, funcName, argID)
end

local function ckID(itemID, func, id)
	libError(itemID < 1 or itemID > 9, "itemID", "3", nil, func, id)
	
	return itemID + 1 -- 1-9 -> 2-10
end



----- GET VALUE -----

local function LIB_getNum(itemID, className, length)
	local origin = {"getNum", "getBool"}
	libError(itemID < 0 or itemID > 9, nil, "Invalid index #"..itemID..".\nTry values between 1-9", nil, origin[GetBy], 1)
	
	itemID = ckID(itemID, origin[GetBy], 1)
	length = length or 1
	
	libError(length < 1 or length > 9, nil, "Invalid sub-memory scale.\nTry values between 1-9", nil, origin[GetBy], 3)

	local pmemID = classToId("getNum", 2, className)
	
	libError(#tostring(pmem(pmemID)) < 10, nil, "Sub-memory not defined", nil, origin[GetBy], 1)
	GetBy = 1
	return tonumber(string.sub(tostring(pmem(pmemID)), itemID, itemID + length - 1))
end

local function LIB_getBool(itemID, className, equal, length)
	GetBy = 2
	return LIB_getNum(itemID, className, length) == (equal or 1)
end

local function LIB_getClass(id)
	libError(id < 0 or id > 255, "id", "3", nil, "getClass", 1)

	return LBC[id]
end

local function LIB_getAll(className, full)
	local pmemID = classToId("getAll", 1, className)

	if pmem(pmemID) < ZERO then return 0 end
	
	local value = string.sub(tostring(pmem(pmemID)), 2)

	if full then return value end
	return tonumber(value)
end



----- SET VALUE -----

local function LIB_setClass(classes, init)
	init = init or 0

	libError(type(classes) ~= "table", "classes", "1", nil, "setClass", 1)
	libError(init < 0 or init > 255, nil, '"init" is invalid.\nTry values between 0-255', nil, "setClass", 1)
	
	local max = init + #classes - 1
	max = max < 255 and max or 255

	local id, addToCID = 1, true
	for i = init, max do
		libError(classes[id] == "" or string.find(classes[id], " ") ~= nil, nil, "Invalid class. Do not use strings with spaces or void strings", nil, "setClass", 1)
		
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

local function LIB_setNum(newValue, itemID, className, length)
	local pmemID  = classToId("setMem", 3, className)
	local value   = nil

	itemID = ckID(itemID, "setNum", 2) -- from 2 to next
	length = length or 1

	libError(itemID < 1 or itemID > 9, "itemID", "3",                     nil, "setNum", 2)
	libError(itemID + length >= 10,    nil,      "'Sub-Memory' overflow", nil, "setNum", 4)

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

local function LIB_setAll(newValue, className, update)
	local pmemID = classToId("setAll", 2, className)

	-- value to update or replace
	if update then
		newValue = pmem(pmemID) + newValue
	else
		newValue = tostring(math.abs(newValue))
		if #newValue < 9 then
			for i = 1, 9 - #newValue do
				newValue = "0"..newValue
			end
		end
		newValue = tonumber("2"..newValue)
	end

	local status = (newValue < ZERO) and -1 or (newValue > MAX) and 1 or 0
	
	-- leak not allowed
	if     status < 0 then pmem(pmemID, ZERO    ) -- underflow
	elseif status > 0 then pmem(pmemID, MAX     ) -- overflow
	else                   pmem(pmemID, newValue) -- sucess
	end

	return status
end

local function LIB_boot(memID, replace, init, left, empty)
	init = init or 0
	empty = tonumber(empty) ~= nil and empty or 0
	local id, value = 0, ""
	
	local max = init + #memID - 1
	libError(init < 0 or init > 255,  "init",  "3",                                      nil, "boot", 3)
	libError(#memID > 256,            nil,     "The table specified is bigger that 256", nil, "boot", 1)
	libError(max > 255,               nil,     "Index overflow",                         nil, "boot", 1)
	libError(empty < 0 or empty > 9,  "empty", "3",                                      nil, "boot", 5)

	for i = init, max do
		id = id + 1

		if pmem(i) <= ZERO or replace then
			-- check if it is valid
			value = memID[id]

			libError(type(    value) ~= "string", nil, value.." is not a string",                       nil, "boot", 1)
			libError(tonumber(value) == nil,      nil, value.." cannot be converted to number",         nil, "boot", 1)
			libError(tonumber(value) > 999999999, nil, value.." is too big.\nThe maximum is 999999999", nil, "boot", 1)
			
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

local function LIB_update(class, values, indexes)
	libError(#values ~= #indexes, nil, "The quantity of values and indexes must be equal", nil, "update", "1-2")

	local changed = false
	for i = 1, 9 do
		if i == indexes[i] then
			LIB_setNum(values[i], indexes[i], class, #tostring(values[i]))
			changed = true
		end
	end

	return changed
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

	libError(not isValid, Type, allTypes, nil, "clear", 1)

	init = init or 0
	max  = max  or 255

	libError(init < 0,   "init", "3", "clear", 3)
	libError(max  > 255, "max",  "3", "clear", 4)

	local changed = false

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
	
	-- clear memories without class
	if Type == "noneClass" then
		for i = init, max do
			if LBC[i] == nil then
				changed = true
				pmem(i, (absolute) and 0 or ZERO)
			end
		end
	end

	-- clear classes without memory
	if Type == "noneMemory" then
		for i = init, max do
			if pmem(i) < ZERO or pmem(i) > MAX then
				changed = true
				LBC[i] = nil
			end
		end
	end

	return changed
end



----- SWAP -----

local function LIB_swapClass(newName, id)
	libError(type(newName) ~= "string", "newValue", "is not a string", nil, "swapClass", 1)
	libError(id < 0 or id > 255, "id", "3", nil, "swapClass", 2)

	local wasDefined = LBC[id]
	LBC[id] = newName

	if wasDefined then return true end
	return false
end
