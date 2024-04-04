-- [NOT COMPACTED] Copy and paste the code in your cart [v: 1.0]

local longBit = {}
local DA_LICENSE = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
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

	----- ADD TO TABLE -----

	longBit.setClass = setClass
	longBit.bootMem  = bootMem
	longBit.clearMem = clearMem
	longBit.getMem   = getMem
	longBit.boolMem  = boolMem
	longBit.setMem   = setMem

end

local lbit = longBit