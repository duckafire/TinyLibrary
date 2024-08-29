-- NAME:    longBit
-- AUTHOR:  DuckAfire
-- VERSION: 3.5.3
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

local function libError(a,b,c,d,e,f)if a~=nil then if not a then return end end local g={"Error","Function","Index"}local h={nil,e,"#"..f}local i="\n\n[LIB]"b=b and'"'..b..'" ' or"" local function j(k)h[1]=b..k end if c=="1" then j("was not specified")elseif c=="2" then j("was not defined")elseif c=="3" then j("is invalid")else j(c)end for l=1,3 do i=i.."\n"..g[l]..": "..h[l].."." if l==1 and d~=nil then i=i.."\nTry: " for m=1,#d-1 do i=i..d[l].." | " end i=i..d[#d] end end trace("\n>\n>\n>")error(i.."\n")end



----- VARIABLES AND TABLES -----

local ZERO   = 2000000000 -- constants
local MAX    = 2999999999
local LBC    = {} -- LongBit-Classes: classes, in other words, strings (0-255, include 'nil')
local CID    = {} -- Classes-InDex:   index of the positions filled in "LCB" (without 'nil')
local Origin = {"getNum", "getBool", "setNum", "setAll", "update"}
local GetBy  = 1
local SetBy  = 3
local AllBy  = 4



----- INTERNAL -----

local function classToId(class, funcName, argID)
	-- search in indexes filled
	for i = 1, #CID do
		-- compare with classes
		if class == LBC[CID[i]] then
			return CID[i]
		end
	end
	
	libError(nil, nil, "Invalid class ("..class..")", nil, funcName, argID)
end

local function ckSign(value, funcName, argID)
	-- memories can store only positive values
	libError(value < 0, nil, "It is not possible store negative values", nil, funcName, argID)
end

local function ckId(id, funcName, argID, mode)
	-- number (index) | string (class)
	id = (mode ~= 2) and id or classToId(id, funcName, argID)

	-- 0-9 | 0-255
	libError(id < 0 or id > ((mode == 1) and 255 or 9), "Index", "3", nil, funcName, argID)
end

local function ckDf(pid, funcName, argID)
	-- check if the memory was defined
	libError(pmem(pid) < ZERO or pmem(pid) > MAX, nil, "Memory not defined or invalid", nil, funcName, argID)
end

local function ckGet(itemID, length, funcName, argID)
	-- check memory index (based in class) and sub-memory length
	length = length or 1
	libError(length <= 0, "length", "3", nil, funcName, argID + 2)

	-- 1-9 -> 2-10; sub-memory length
	local values = {itemID + 1, itemID + 1 + length - 1}

	for i = 1, 2 do
		libError(values[i] < 2 - 1 * (i - 1) or values[i] > 10, ((i == 1) and "index" or "length"), "3", nil, funcName, argID + 2 * (i - 1))
	end

	return values[1], values[2] -- index, length
end



----- GET VALUE -----

local function LIB_getNum(itemID, class, length)
	ckId(itemID, Origin[GetBy], 1, 0)
	
	local pmemID = classToId(class, "getNum", 2)
	itemID, length = ckGet(itemID, length, Origin[GetBy], 1)

	GetBy = 1
	return tonumber(string.sub(tostring(pmem(pmemID)), itemID, length))
end

local function LIB_getBool(itemID, class, equal, length)
	GetBy = 2
	return LIB_getNum(itemID, class, length) == (equal or 1)
end

local function LIB_getClass(id)
	ckId(id, "getClass", 1, 1)

	return LBC[id]
end

local function LIB_getAll(class, full)
	local pmemID = classToId(class, "getAll", 1)
	ckDf(pmemID, "getAll", 1)

	local value = string.sub(tostring(pmem(pmemID)), 2)

	if full then return value end
	return tostring(tonumber(value)) -- remove zeros in left
end



----- SET VALUE -----

local function LIB_setClass(classes, force, init)
	init = init or 0

	libError(type(classes) ~= "table", "classes", "1", nil, "setClass", 1)
	
	local max = init + #classes - 1
	libError(max > 255, nil, "Index overflow (init + #classes - 1 > 255)", nil, "setClass", 1)

	local id       = 1     -- used to get classes from "classes"
	local qtt      = 1     -- quantity of memories updated (to return)
	local addToCID = false -- to save classe
	local defined  = false -- check if the class was DEFINED

	for i = init, max do
		-- invalid classes: void strings and strings with spaces
		libError(classes[id] == "" or string.find(classes[id], " ") ~= nil, nil, "Invalid class. Do not use void strings or strings with spaces", nil, "setClass", 1)
		
		defined = (LBC[i] ~= nil)

		if not defined or force then
			LBC[i] = classes[id] -- save variable
			qtt    = qtt + 1
		end

		id       = id + 1 -- update to get the next class
		addToCID = true

		-- check if this class index already was saved in CID
		if not defined then
			for j = 1, #CID do
				if CID[j] == i then
					addToCID = false -- CID index already filled
					break
				end
			end
		end

		-- if the space was not filled
		if addToCID then table.insert(CID, i) end
	end

	return (#classes == qtt)
end

local function LIB_setNum(newValue, itemID, class, length)
	local values, nVal = "", 0
	itemID, length = ckGet(itemID, length, Origin[SetBy], 2)

	-- convert boolean to number
	if type(newValue) == "boolean" then
		value = (newValue) and 1 or 0
	
	else -- fill "blank spaces" in newValue
		value = tostring(newValue)
		local dif = (length + 1) - itemID
		
		-- fill possible void spaces in "value"
		if dif > 1 then
			for i = 1, dif do
				if #value < dif then
					value = "0"..value
				else
					break
				end
			end
		end

		nVal = tonumber(value) -- <= 9 | <= 99 | <= 999 | ...
		libError(nVal > 10 ^ dif, nil, "Sub-memory OVERFLOW", nil, Origin[SetBy], 1)
	end

	ckSign(nVal, Origin[SetBy], 1)
	local pmemID = classToId(class, Origin[SetBy], 3)

	-- get pmem value "fragments" to restaur it
	local function convert(a, z) return string.sub(tostring(pmem(pmemID)), a, z) end
	local back  = convert(1, itemID - 1)
	local front = convert(length + 1)
	
	SetBy = 3
	pmem(pmemID, tonumber(back..value..front))
end

local function LIB_setAll(newValue, class, update, protect)
	-- negative values only if ...
	if not update then
		ckSign(newValue, Origin[AllBy], 1)
	end

	local pmemID = classToId(class, Origin[AllBy], 2)

	-- value to update or replace
	if update then
		newValue = pmem(pmemID) + newValue -- mem = mem + value
	else
		newValue = tostring(newValue) -- mem = value

		-- fill possible void spaces
		if #newValue < 9 then
			for i = 1, 9 - #newValue do
				newValue = "0"..newValue
			end
		end

		newValue = tonumber("2"..newValue)
	end

	local status = (newValue < ZERO) and -1 or (newValue > MAX) and 1 or 0

	-- "pcall" be like
	if protected then
		if     status < 0 then pmem(pmemID, ZERO    ) -- underflow
		elseif status > 0 then pmem(pmemID, MAX     ) -- overflow
		else                   pmem(pmemID, newValue) -- sucess
		end
	else
		libError(status < 0, nil, "[ UNDERFLOW ]", nil, "setAll", 1)
		libError(status > 0, nil, "[ OVERFLOW ]",  nil, "setAll", 1)
		pmem(pmemID, newValue)
	end

	AllBy = 4
	return status
end

local function LIB_boot(items, replace, init, left, empty)
	init = init or 0
	empty = (tonumber(empty) ~= nil) and empty or 0
	local id, value, vNum = 0, "", 0
	
	ckId(init,  "boot", 3, 1)
	ckId(empty, "boot", 5, 0) -- it is not a index, but it can be check with it

	local max = init + #items - 1
	libError(#items > 256, nil, "The table specified is bigger that 256",   nil, "boot", 1)
	libError(max    > 255, nil, "Index overflow (init + #items - 1 > 255)", nil, "boot", 1)

	for i = init, max do
		id = id + 1 -- to get values from "items"

		if pmem(i) <= ZERO or replace then
			-- check if it is valid
			value = items[id]
			vNum  = tonumber(value)

			ckSign(vNum, "boot", 1)
			libError(type(value) ~= "string", nil, value.." is not a string",               nil, "boot", 1)
			libError(tonumber(vNum) == nil,   nil, value.." cannot be converted to number", nil, "boot", 1)
			libError(tonumber(vNum) > MAX,    nil, value.." is too large (max: "..MAX..")", nil, "boot", 1)
			
			-- fill empty spaces
			while #value < 9 do
				value = (left) and empty..value or value..empty
			end

			-- save in persistent memory (and add joker)
			pmem(i, tonumber("2"..value))
		end
	end
	
	return (#items == id)
end

local function LIB_update(class, values, indexes)
	ckDf(classToId(class, "update", 2), "update", 2)

	-- parameters and texts
	local parTxt = {#values, #indexes, '"values"', '"indexes"'}
	for i = 1, 2 do libError(parTxt[i] < 1 or parTxt[i] > 9, parTxt[i + 2], "invalid quantity of indexes", {"(min: 1", "max: 9)"}, "update", 1 + i) end -- 2 or 3

	libError(#values ~= #indexes, nil, "The quantity of values and indexes must be equal", nil, "update", "2-3")

	GetBy, SetBy = 5, 5 -- to possible error messages in functions used
	local err, nVal, qtt = "", 0, 0

	for i = 1, #indexes do
		err  = "values["..i.."] is not a "
		nVal = tonumber(values[i])

		libError(type(values[i]) ~= "string", nil, err.."string", nil, "update", 1)
		libError(nVal == nil,                 nil, err.."number", nil, "update", 1)

		if LIB_getNum(indexes[i], class, #values[i]) ~= nVal then
			LIB_setNum(nVal, indexes[i], class, #values[i])
			qtt = qtt + 1
		end
	end

	-- quantity of sub-memories changed
	return qtt
end

local function LIB_clear(Type, absolute, init, max)
	-- check if "_type" is valid
	local isValid = false
	local allTypes = {"all", "memory", "class", "noMemory", "noClass"}

	for i = 1, #allTypes do
		if Type == allTypes[i] then
			isValid = true
			break
		end
	end

	libError(not isValid, "type", "3", allTypes, "clear", 1)
	-- end of the check

	init = init or 0
	max  = max  or 255

	ckId(init, "clear", 3, 0) -- init < 0
	ckId(max,  "clear", 4, 1) -- max > 255

	local changed, qtt = false, 0
	local function toReturn() qtt, changed = qtt + 1, true end

	local memZero = (absolute) and 0 or ZERO

	if Type == "memory" or Type == "all" then
		for i = init, max do
			pmem(i, memZero)

			toReturn()
		end
	end
	
	if Type == "class"  or Type == "all" then
		for i = #CID, 1, -1 do
			if CID[i] >= init and CID[i] <= max then
				LBC[CID[i]] = nil
				CID[i] = nil

				toReturn()
			end
		end

		return changed
	end
	
	-- clear memories without class
	if Type == "noClass" then
		for i = init, max do
			if LBC[i] == nil then
				pmem(i, memZero)

				toReturn()
			end
		end

		return changed
	end

	-- clear classes without memory
	if Type == "noMemory" then
		local id = 0

		for i = #CID, 1, -1 do
			id = CID[i]

			if id >= init and id <= max and (pmem(id) < ZERO or pmem(id) > MAX) then
				LBC[id] = nil
				CID[i] = nil

				toReturn()
			end
		end

		return changed, qtt
	end
end



----- SWAP -----

local function LIB_swapClass(newName, oldName)
	local function err(ident, name, id)
		libError(type(ident) ~= "string", name, "3", nil, "swapClass", id)
	end

	err(newName, "newName", 1)
	err(oldName, "oldName", 2)

	LBC[classToId(oldName, "swapClass", 2)] = newName
end
