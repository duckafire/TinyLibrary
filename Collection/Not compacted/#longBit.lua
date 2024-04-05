-- [NOT COMPACTED] Copy and paste the code in your cart [v: 1.0]

local longBit = {}
local DA_LICENSE = "github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"-- There's no need to copy "DA_LICENSE" if they are already in the code.

do
	----- GLOBAL -----
	
	_G.__LONGBIT_CLASSES = {}-- "_G" to explicity a global table (or variable)

	----- INTERNAL -----

	local function classToId(id)-- number (pmem id)
		assert(_G.__LONGBIT_CLASSES[1]~=nil, "[longBit] pmem classes not defined.")

		for i = 1, #_G.__LONGBIT_CLASSES do
			if id == _G.__LONGBIT_CLASSES[i] then return i - 1 end
		end
		
		-- if no a "class" is not returned
		error('[longBit] Undefined class: "'..d..'"')
	end

	----- SET VALUE -----

	local function setClass(...)
		_G.__LONGBIT_CLASSES = {...}
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

	local function boot(memID, max, init)
		local _init = init or 0
		local _max  = max or #memID - 1
		local add   = (_init > _max) and -1 or 1

		for i = _init, _max, add do
			pmem(i, tonumber(memID[i + 1]))
		end
	end

	local function clear(class, max, init)
		if class then
			_G.__LONGBIT_CLASSES = {}
			
		else
			local _init = init or 0
			local _max  = max or 255
			local add   = (_init > _max) and -1 or 1

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

	longBit.setClass = setClass
	longBit.setMem   = setMem
	longBit.boot     = boot
	longBit.clear    = clear
	longBit.getNum   = getNum
	longBit.getBool  = getBool
	longBit.getClass = getClass

end

local lbit = longBit