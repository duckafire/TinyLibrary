-- NAME:    coli2DA
-- AUTHOR:  DuckAfire
-- VERSION: 5.0.0-beta
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

--=======================================================================================--
-- GENERIC

-- NULL will be given during the
-- declaration of "optional
-- properties", that they only
-- will exist if a specific
-- condition is `true`, or to
-- "delete" properties
local EMPTY_FUNC, NULL = function () end

local DEBUG_OBJ_HITBOXES = {}

--=======================================================================================--
-- CREATE OBJECTS

function drawHitboxes(separate, src)
	src = src or DEBUG_OBJ_HITBOXES

	if separate
	then
		for _, obj in ipairs(src) do obj:drawHitbox() end
		return
	end

	-- this avoids that the boards,
	-- of objects above, overrides
	-- the visual-hitbox of objects
	-- below
	for _, obj in ipairs(src) do obj._d.db(obj) end
	for _, obj in ipairs(src) do obj._d.dr(obj) end
end

--[[

objDebug, newRect, newCirc, newPix:

debug (parameter; it is a table)
	*color           : int   : 2
	*bcolor          : int   : 0
	*ccolor          : int   : 4
	board            : bool  : false
	enableDebug      : bool  : false
	saveInTable      : bool  : true
	debugObjHitboxes : table : DEBUG_OBJ_HITBOXES

`*`: add to the object

]]

local function objDebug(obj, opt, draw, drawb)
	if not opt or not opt.enableDebug
	then
		return nil
	end

	local debug = {}

	debug.co  = opt.color  or 2                   -- COlor
	debug.bc  = opt.bcolor or 0                   -- Board Color
	debug.cc  = opt.ccolor or 4                   -- Collision Color
	debug.isC = false                             -- IS Colliding
	debug.dr  = draw                              -- DRaw
	debug.db  = opt.board and drawb or EMPTY_FUNC -- Draw Board

	function obj._d:gc() -- Get Color
		return self.isC and self.cc or self.co
	end

	function obj:drawHitbox()
		self._d.db(self)
		self._d.dr(self)
	end

	-- it can be `nil`;
	-- defaul: `true`
	if opt.saveInTable ~= false
	then
		table.insert(opt.debugObjHitboxes or DEBUG_OBJ_HITBOXES, obj)
	end

	return debug
end

function newRect(_x, _y, _w, _h, debug)
	local obj = {x = _x + 0, y = _y + 0, w = _w + 0, h = not _h and _w or _h + 0}

	obj._d = objDebug(obj, debug,
		function (obj)
			rectb(obj.x, obj.y, obj.w, obj.h, obj._d.gc())
		end,
		function (obj)
			for i = -1, 1, 2
			do
				rectb(obj.x + i, obj.y + i, obj.w + i * -2, obj.h + i * -2, obj._d.bc)
			end
		end
	)

	return obj
end

function newCirc(_x, _y, _r, debug)
	local obj = {x = _x + 0, y = _y + 0, r = _r + 0}

	obj._d = objDebug(obj, debug,
		function (obj)
			circb(obj.x, obj.y, obj.r, obj._d.gc())
		end,
		function (obj)
			for i = -1, 1, 2
			do
				circb(obj.x, obj.y, obj.r + i, obj._d.bc)
			end
		end
	)

	return obj
end

function newPix(_x, _y, debug)
	local obj = {x = _x + 0, y = _y + 0}

	obj._d = objDebug(obj, debug,
		function (obj)
			pix(obj.x, obj.y, obj._d.gc())
		end,
		function (obj)
			circb(obj.x, obj.y, 1, obj._d.bc)
		end
	)

	return obj
end

--=======================================================================================--
-- GEOGRAPH

--[[

addMapDebugFields, updateMapDebugFields, getMapGridPosition:

debug (parameter; it is a table)
	*color      : int   : 2
	*bcolor     : int   : 0
	*ccolor     : int   : ~
	*cbcolor    : int   : ~
	board       : bool  : false
	enableDebug : bool  : false
	fill        : bool  : true

`*`: add to the object
`~`: based other arguments

]]

local function addMapDebugFields(obj, debug, sw, sh)
	if not obj._d
	then
		obj._d = {}
	end

	if obj._d.mco
	then
		return
	end

	obj._d.mco  = debug.color  or 5          -- Map COlor
	obj._d.mbc  = debug.bcolor or 0          -- Map Board Color
	obj._d.mcc  = debug.ccolor or obj._d.mbc -- Map Center Color
	obj._d.mcbc = NULL                       -- Map Center Board Color

	obj._d.mw  = (8 * (sw or 1)) // 2 -- Map Width
	obj._d.mh  = (8 * (sh or 1)) // 2 -- Map Height

	obj._d.mdr  = rect       -- Map DRaw
	obj._d.mmi  = NULL       -- Map Max I
	obj._d.mdb  = EMPTY_FUNC -- Map Draw Board
	obj._d.mdcb = EMPTY_FUNC -- Map Draw Center Board

	if debug.fill == false
	then
		obj._d.mcc = debug.ccolor or obj._d.mco

		obj._d.mmi = -1 -- one loop
		obj._d.mdr = rectb
	end

	if debug.board
	then
		obj._d.mmi = 1 -- two loops

		obj._d.mdb = function (obj, ax, ay)
			local x, y = ax or obj._d.mx, ay or obj._d.my

			for i = -1, obj._d.mmi, 2
			do
				rectb(x + i, y + i, 8 + i * -2, 8 + i * -2, obj._d.mbc)
			end
		end

		if debug.fill == false
		then
			obj._d.mcbc = debug.cbcolor or obj._d.mbc

			obj._d.mdcb = function (obj)
				circb(obj.x + obj._d.mw, obj.y + obj._d.mh, 1, obj._d.mcbc)
			end
		end
	end
end

local function updateMapDebugFields(obj, debug, x, y, sw, sh)
	if not debug or not debug.enableDebug
	then
		return
	end

	addMapDebugFields(obj, debug, sw, sh)

	obj._d.mx = x
	obj._d.my = y

	if obj.drawMapGridPos
	then
		return
	end

	function obj:drawMapGridPos()
		-- rectangle
		self._d.mdb(self)
		self._d.mdr(self._d.mx, self._d.my, 8, 8, self._d.mco)

		-- pixel
		self._d.mdcb(self)
		pix(self.x + self._d.mw, self.y + self._d.mh, self._d.mcc)
	end
end

function getMapGridPosition(obj, onCenter, scalew, scaleh, debug)
	-- Position; Map
	local px, py, mx, my = obj.x, obj.y

	if onCenter
	then
		px = px + (8 * (scalew or 1)) // 2
		py = py + (8 * (scaleh or 1)) // 2
	end

	mx, my = px // 8, py // 8
	px, py = mx  * 8, my  * 8

	updateMapDebugFields(obj, debug, px, py, scalew, scaleh)
	return px, py, mx, my
end

function distance(objA, objB, round)
	-- euclidean distance
	local result = math.sqrt((objA.x - objB.x) ^ 2 + (objA.y - objB.y) ^ 2)

	if not round or round == 0
	then
		return result
	end

	return (round < 0 and math.floor or math.ceil)(result)
end

--=======================================================================================--
-- COLLISION WITH MAP TILES

local mapx, mapy = 0, 0

function setMapPos(x, y)
	mapx, mapy = x + 0, y + 0
end

function getMapPos()
	return mapx, mapy
end

local function checkTileCollision(obj, direction, flag, mx, my)
	local w, h, x1, y1, x2, y2 = obj.w, obj.h

	-- vertexes
	if     direction == 0 then x1, y1, x2, y2 =  0, -1,  w - 1, -1
	elseif direction == 1 then x1, y1, x2, y2 =  0,  h,  w - 1,  h
	elseif direction == 2 then x1, y1, x2, y2 = -1,  0,     -1,  h - 1
	elseif direction == 3 then x1, y1, x2, y2 =  w,  0,      w,  h - 1
	end

	return fget(mget((obj.x + x1) // 8 + mx, (obj.y + y1) // 8 + my), flag)
	    or fget(mget((obj.x + x2) // 8 + mx, (obj.y + y2) // 8 + my), flag)
end

-- TODO: auto-add more "points" when the
-- scales are bigger than 8 (or its
-- multiples).
-- TODO: add debug mode (show the "anchors")
function setTiles(obj, flag)
	if obj.tiles
	then
		return false
	end

	obj.tcol = {}
	obj.tcol._ist = type(flag) == "table" -- IS Table?
	obj.tcol._f   = flag

	function obj.tcol:_ch(direction, mx, my) -- CHeck
		local flag = self._ist and self._f[direction + 1] or self._f

		print(self._f, 50, 0, 2)

		return checkTileCollision(obj, direction, flag, mx or mapx, my or mapy)
	end

	function obj.tcol:top(   mx, my) return self:_ch(0, mx, my) end
	function obj.tcol:bottom(mx, my) return self:_ch(1, mx, my) end
	function obj.tcol:left(  mx, my) return self:_ch(2, mx, my) end
	function obj.tcol:right( mx, my) return self:_ch(3, mx, my) end

	return true
end

--=======================================================================================--
-- OBJECT COLLISIONS

local function circEucDist(obj, circ, objRad)
	-- based EUClidean DISTance (CIRCle)
	return (obj.x - circ.x) ^ 2 + (obj.y - circ.y) ^ 2 <= (objRad + circ.r) ^ 2
end

function pixXrect(obj, rect)
	-- the use of `<`, instead `<=`, allows
	-- to avoid decrement the additions (by 1)

	return obj.x >= rect.x
	   and obj.x  < rect.x + rect.w
	   and obj.y >= rect.y
	   and obj.y  < rect.y + rect.h
end

function pixXcirc(obj, circ)
	return circEucDist(obj, circ, 0)
end

function rects(rectA, rectB)
	return math.max(rectA.x, rectB.x) < math.min(rectA.x + rectA.w, rectB.x + rectB.w)
	   and math.max(rectA.y, rectB.y) < math.min(rectA.y + rectA.h, rectB.y + rectB.h)
end

function circs(circA, circB)
	return circEucDist(circA, circB, circA.r)
end

--[[ TODO
function rectXcirc(rect, circ)
	if not rects(rect, newRect(circ.x - circ.r, circ.y - circ.r, circ.r * 2))
	then
		return false
	end

	-- square
	if rect.w == rect.h
	then
		local rectRa = rect.w // 2

		return rects(rect, newRect(circ.x - circ.r, circ.y - circ.r, circ.r * 2))
		   and circs(circ, newCirc(rect.x + rectRa, rect.y + rectRa, rectRa))
   end

   return false
end
]]

-- TODO: impactPixel

--=======================================================================================--
