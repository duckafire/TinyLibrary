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

local NULL, DEBUG_OBJ_HITBOXES, DEBUG_OBJ_TPOINTS, EMPTY_FUNC = nil, {}, {}, function () end
local mapx, mapy = 0, 0

--=======================================================================================--
-- CREATE OBJECTS

-- _d   == debug (it has a lot of debug itens)
-- _d.o == object (related to objects collisions)
-- _d.t == tiles (related to tiles collisions)
-- _d.m == map (related to map grid greograph)
local function newDebugField(obj, debugGroup)
	if not obj._d
	then
		obj._d = {}
	end

	if debugGroup and not obj._d[ debugGroup ]
	then
		obj._d[ debugGroup ] = {}
		obj._d[ debugGroup ].obj = obj
	end
end

local function setDebugGraphColors(debugField, opt, includeDC, includeCC, default)
	-- dc : Default Color
	-- cc : Collision Color
	-- bc : Board Color
	-- co : Current cOlor
	
	default = default or {}
	local dc = opt.color  or (default.dc or 2)
	
	if includeDC
	then
		debugField.dc = dc
	end
	
	if includeDC or includeCC
	then
		debugField.cc = opt.ccolor or (default.cc or 4)
	end

	debugField.co = dc
	debugField.bc = opt.bcolor or 0
end

local function saveInTable(obj, opt, default)
	-- it can be `nil`;
	-- defaul: `true`
	if opt.saveInTable ~= false
	then
		table.insert(opt.debugObjHitboxes or default, obj)
	end
end

local function doesItExistDebugField(obj, ...)
	-- check if an object exists inside
	-- other, after check if other (2nd)
	-- exists inside the founded object
	-- (whether it was found), after ...
	local fields = {...}

	if #fields == 0 or (obj[fields[1]] and doesItExistDebugField( obj[fields[1]], table.unpack(fields, 2) ))
	then
		return true
	end

	return false
end

function drawHitboxes(separate, src)
	-- separate is `true` by default
	src = src or DEBUG_OBJ_HITBOXES

	if separate == false
	then
		for _, obj in ipairs(src) do obj:drawHitbox() end
		return
	end

	-- this avoids that the boards,
	-- of objects above, overrides
	-- the visual-hitbox of objects
	-- below
	for _, obj in ipairs(src) do obj._d.o.db(obj) end
	for _, obj in ipairs(src) do obj._d.o.dr(obj) end
end

--[[

addCreationalDebugFields, newRect, newCirc, newPix:

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

local function addCreationalDebugFields(obj, opt, draw, drawb)
	if not opt or not opt.enableDebug
	then
		return nil
	end

	newDebugField(obj, "o")
	setDebugGraphColors(obj._d.o, opt, true)

	obj._d.o.dr = draw      -- DRaw
	obj._d.o.db = opt.board -- Draw Board
	          and drawb
	           or EMPTY_FUNC

	function obj._d.o:uc(result) -- Update hitbox Color
		self.co = result and self.cc or self.dc
	end

	function obj:drawHitbox()
		self._d.o.db(self)
		self._d.o.dr(self)
	end

	saveInTable(obj, opt, DEBUG_OBJ_HITBOXES)
end

function newRect(_x, _y, _w, _h, debug)
	local obj = {x = _x + 0, y = _y + 0, w = _w + 0, h = type(_h) ~= "number" and _w or _h + 0}

	addCreationalDebugFields(obj, type(_h) == "table" and _h or debug,
		function (obj)
			rectb(obj.x, obj.y, obj.w, obj.h, obj._d.o.co)
		end,
		function (obj)
			for i = -1, 1, 2
			do
				rectb(obj.x + i, obj.y + i, obj.w + i * -2, obj.h + i * -2, obj._d.o.bc)
			end
		end
	)

	return obj
end

function newCirc(_x, _y, _r, debug)
	local obj = {x = _x + 0, y = _y + 0, r = _r + 0}

	addCreationalDebugFields(obj, debug,
		function (obj)
			circb(obj.x, obj.y, obj.r, obj._d.o.co)
		end,
		function (obj)
			for i = -1, 1, 2
			do
				circb(obj.x, obj.y, obj.r + i, obj._d.o.bc)
			end
		end
	)

	return obj
end

function newPix(_x, _y, debug)
	local obj = {x = _x + 0, y = _y + 0}

	addCreationalDebugFields(obj, debug,
		function (obj)
			pix(obj.x, obj.y, obj._d.o.co)
		end,
		function (obj)
			circb(obj.x, obj.y, 1, obj._d.o.bc)
		end
	)

	return obj
end

--=======================================================================================--
-- GEOGRAPH

--[[

addMapDebugFields, updateMapDebugFields, getMapGridPosition:

debug
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
	newDebugField(obj, "m")

	if doesItExistDebugField(obj, "_d", "m")
	then
		return
	end

	setDebugGraphColors(obj._d.m, opt, nil, nil, {co = 5})
	obj._d.m.cc  = debug.ccolor or obj._d.m.bc
	obj._d.m.cbc = NULL                -- Center Board Color
	obj._d.m.hw = (8 * (sw or 1)) // 2 -- Half Width
	obj._d.m.hh = (8 * (sh or 1)) // 2 -- Half Height
	obj._d.m.dr  = rect                -- DRaw
	obj._d.m.mi  = NULL                -- Max I
	obj._d.m.db  = EMPTY_FUNC          -- Draw Board
	obj._d.m.dcb = EMPTY_FUNC          -- Draw Center Board

	if debug.fill == false
	then
		obj._d.m.cc = debug.ccolor or obj._d.m.co

		obj._d.m.mi = -1 -- one loop
		obj._d.m.dr = rectb
	end

	if debug.board
	then
		obj._d.m.mi = 1 -- two loops
		obj._d.m.x = NULL
		obj._d.m.y = NULL

		function obj._d.m.db(obj, ax, ay)
			local x, y = ax or obj._d.m.x, ay or obj._d.m.y

			for i = -1, obj._d.m.mi, 2
			do
				rectb(x + i, y + i, 8 + i * -2, 8 + i * -2, obj._d.m.bc)
			end
		end

		if debug.fill == false
		then
			obj._d.m.cbc = debug.cbcolor or obj._d.m.bc

			function obj._d.m.dcb(obj)
				circb(obj.x + obj._d.m.w, obj.y + obj._d.m.h, 1, obj._d.m.cbc)
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

	obj._d.m.x = x
	obj._d.m.y = y

	if obj.drawMapGridPos
	then
		return
	end

	function obj:drawMapGridPos()
		-- rectangle
		self._d.m.db(self)
		self._d.m.dr(self._d.m.x, self._d.m.y, 8, 8, self._d.m.co)

		-- pixel
		self._d.m.dcb(self)
		pix(self.x + self._d.m.w, self.y + self._d.m.h, self._d.m.cc)
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

function setMapPos(x, y)
	mapx, mapy = x + 0, y + 0
end

function getMapPos()
	return mapx, mapy
end

function drawMap(w, h, sx, sy, colorkey, scale, remap)
	map(mapx, mapy, w, h, sx, sy, colorkey, scale, remap)
end

local function drawTilep(obj, maintain, anonymFunc)
	for i, dir in ipairs(obj._d.t.cp)
	do
		for j, item in ipairs(dir)
		do
			anonymFunc(obj, item, j, dir)
		end

		if not maintain
		then
			-- clear it
			obj._d.t.cp[i] = {}
		end
	end
end

function drawTilePoints(separate, maintain, src)
	src = src or DEBUG_OBJ_TPOINTS

	if separate == false
	then
		for _, obj in ipairs(src) do
			obj:drawTilePoints(maintain)
		end

		return
	end

	for _, cur in ipairs(src) do
		-- if this clear them, the
		-- point will not be drawn
		drawTilep(cur, true, function (obj, item)
			obj._d.t:db(item.x, item.y)
		end)
	end

	for _, cur in ipairs(src) do
		drawTilep(cur, maintain, function (obj, item, pixId, originTable)
			obj._d.t:dr(item.x, item.y)
		end)
	end
end

--[[

addTilesDebugFields, setTilesCollision

debug
	*color           : int   : 2
	*bcolor          : int   : 0
	board            : bool  : false
	enableDebug      : bool  : false
	saveInTable      : bool  : true
	debugObjHitboxes : table : DEBUG_OBJ_TPOINTS

`*`: add to the object

]]

local function addTilesDebugFields(obj, opt)
	if not opt or not opt.enableDebug
	then
		return nil
	end

	newDebugField(obj, "t")
	obj._d.t.cp = { -- Collision Points
		{}, -- top
		{}, -- bottom
		{}, -- left
		{}  -- right
	}

	setDebugGraphColors(obj._d.t, opt)
	obj._d.t.db = EMPTY_FUNC -- Draw Board

	function obj._d.t:dr(x, y)
		pix(x, y, self.co)
	end

	if opt.board
	then
		function obj._d.t:db(x, y)
			circb(x, y, 1, self.bc)
		end
	end

	function obj.tcol:drawTilePoints(maintain)
		drawTilep(self._obj, maintain, function (obj, item, pixId, originTable)

			obj._d.t:db(item.x, item.y)
			obj._d.t:dr(item.x, item.y)

		end)
	end

	function obj._d.t:ctp(start, dir, x, y) -- Catch Tile collision Points
		if start
		then
			self.cp[dir + 1] = {}
			return
		end

		table.insert(self.cp[dir + 1], newPix(x, y))
	end

	saveInTable(obj, opt, DEBUG_OBJ_TPOINTS)
end

local function checkTileCollision(tcol, dir, flag, mx, my)
	-- a == Adjust
	-- d == Dimension
	-- m == Maximum

	-- row by default
	local dfield, maxdfield = "w", "mw"

	-- the "less one" is referring
	-- the first pixel of the object
	local adj = newRect(0, 0, 0)
	adj.mw = tcol._w - 1
	adj.mh = tcol._h - 1

	-- if it is checking at row format,
	-- the "adjust property" will move
	-- horizontally, otherwise it will
	-- move vertically
	if dir < 2 then adj.y = (dir == 0 and -1 or tcol._h)
	else            adj.x = (dir == 2 and -1 or tcol._w)
	                dfield, maxdfield = "h", "mh"
	end

	tcol._obj._d.t:ctp(true, dir)

	repeat
		x, y = tcol._x + adj.x + adj.w, tcol._y + adj.y + adj.h

		if doesItExistDebugField(tcol._obj, "_d", "t", "ctp")
		then
			tcol._obj._d.t:ctp(false, dir, x, y)
		end

		if fget(mget(x // 8 + mx, y // 8 + my), flag)
		then
			return true
		end

		adj[dfield]    = adj[dfield]    + (adj[maxdfield] > 8 and 8 or adj[maxdfield])
		adj[maxdfield] = adj[maxdfield] - 8
	until
		adj[maxdfield] < -7 or adj[maxdfield] == -8
		-- "it all the object width/height was
		-- scrolled OR the object have only one
		-- pixel of width/height"

	return false
end

function setTilesCollision(obj, flag, rectArea, debug)
	if obj.tcol
	then
		return false
	end

	rectArea = rectArea and newRect(table.unpack(rectArea)) or nil

	obj.tcol = {}
	obj.tcol._obj = obj
	obj.tcol._ist = type(flag) == "table" -- IS Table?
	obj.tcol._f   = flag
	obj.tcol._ax  = rectArea and rectArea.x or 0
	obj.tcol._ay  = rectArea and rectArea.y or 0
	obj.tcol._x   = obj.x + obj.tcol._ax
	obj.tcol._y   = obj.y + obj.tcol._ay
	obj.tcol._w   = rectArea and rectArea.w or obj.w
	obj.tcol._h   = rectArea and rectArea.h or obj.h

	addTilesDebugFields(obj, debug)

	function obj.tcol:setxy(x, y)
		self._obj.x = (x or self._obj.x)
		self._obj.y = (y or self._obj.y)

		self._x = self._obj.x + self._ax
		self._y = self._obj.y + self._ay
	end

	function obj.tcol:setwh(w, h)
		self._w = w + 0
		self._h = h and h + 0 or w

		self._obj.w = self._w
		self._obj.h = self._h
	end

	function obj.tcol:_ch(direction, mx, my) -- CHeck
		local flag = self._ist and self._f[direction + 1] or self._f

		return checkTileCollision(self, direction, flag, mx or mapx, my or mapy)
	end

	function obj.tcol:top(   mx, my) return self:_ch(0, mx, my) end
	function obj.tcol:bottom(mx, my) return self:_ch(1, mx, my) end
	function obj.tcol:left(  mx, my) return self:_ch(2, mx, my) end
	function obj.tcol:right( mx, my) return self:_ch(3, mx, my) end

	return true
end

--=======================================================================================--
-- OBJECT COLLISIONS

local function updateHitboxColor(result, ...)
	for _, obj in ipairs({...})
	do
		-- it can not check only if `_d`
		-- exists because other functions
		-- use this fields, in other words,
		-- it is defined do not indicate
		-- that the user want show the
		-- object hitbox
		if doesItExistDebugField(obj, "_d", "o", "uc")
		then
			obj._d.o:uc(result)
		end
	end
end

local function circEucDist(obj, circ, objRad)
	-- based EUClidean DISTance (CIRCle)
	return (obj.x - circ.x) ^ 2 + (obj.y - circ.y) ^ 2 <= (objRad + circ.r) ^ 2
end

-- NOTES:
-- poi == Point Of Impact
-- `anonymFunc` can be a boolean or a function
-- (that it receive two arguments: x an y)

local function callaf(result, anonymFunc, func, ...)
	if result and anonymFunc
	then
		return func(anonymFunc, ...)
	end

	return nil
end

local function runaf(anonymFunc, ...)
	if type(anonymFunc) == "function"
	then
		anonymFunc(...)
	end
end

local function rpoi(anonymFunc, rectA, rectB)
	local x = (math.max(rectA.x, rectB.x) + math.min(rectA.x + rectA.w - 1, rectB.x + rectB.w - 1)) / 2
	local y = (math.max(rectA.y, rectB.y) + math.min(rectA.y + rectA.h - 1, rectB.y + rectB.h - 1)) / 2

	runaf(anonymFunc, x, y)
	return newPix(x, y)
end

local function cpoi(anonymFunc, circA, circB)
	local r = circA.r + circB.r
	local x = (circA.x * circB.r + circB.x * circA.r) / r
	local y = (circA.y * circB.r + circB.y * circA.r) / r

	runaf(anonymFunc, x, y)
	return newPix(x, y)
end

local function simplepoi(anonymFunc, x, y)
	runaf(anonymFunc, x, y)
	return newPix(x, y)
end

function rects(rectA, rectB, anonymFunc)
	local result = math.max(rectA.x, rectB.x) < math.min(rectA.x + rectA.w, rectB.x + rectB.w)
               and math.max(rectA.y, rectB.y) < math.min(rectA.y + rectA.h, rectB.y + rectB.h)

	updateHitboxColor(result, rectA, rectB)
	return result, callaf(result, anonymFunc, rpoi, rectA, rectB)
end

function circs(circA, circB, anonymFunc)
	local result = circEucDist(circA, circB, circA.r)

	updateHitboxColor(result, circA, circB)
	return result, callaf(result, anonymFunc, cpoi, circA, circB)
end

function rectXcirc(rect, circ, anonymFunc)
	local x = math.max(rect.x, math.min(circ.x, rect.x + rect.w - 1))
	local y = math.max(rect.y, math.min(circ.y, rect.y + rect.h - 1))

	local result = circEucDist(newPix(x, y), circ, 0)

	updateHitboxColor(result, rect, circ)
	return result, callaf(result, anonymFunc, simplepoi, x, y)
end

function pixs(pixA, pixB, anonymFunc)
	local result = (pixA.x == pixB.x and pixA.y == pixB.y)

	return result, callaf(result, anonymFunc, simplepoi, pixA.x, pixA.y)
end

function pixXrect(pix, rect, anonymFunc)
	-- the use of `<`, instead `<=`, allows
	-- to avoid decrement the additions (by 1)
	local result = pix.x >= rect.x and pix.x < rect.x + rect.w
               and pix.y >= rect.y and pix.y < rect.y + rect.h

	return result, callaf(result, anonymFunc, simplepoi, pix.x, pix.y)
end

function pixXcirc(pix, circ, anonymFunc)
	local result = circEucDist(pix, circ, 0)

	return result, callaf(result, anonymFunc, simplepoi, pix.x, pix.y)
end

function setColiMethods(obj, poiMethods)
	if poiMethods
	then
		function obj:catchpoi()
			return function (x, y)
				-- declared here
				self._poix = x
				self._poiy = y
			end
		end

		function obj:getpoi()
			return self._poix, self._poiy
		end
	end

	if obj.w
	then
		function obj:crect(rect, anonymFunc) return rects(    self, rect, anonymFunc) end
		function obj:ccirc(circ, anonymFunc) return rectXcirc(self, circ, anonymFunc) end
		function obj:cpix( pix,  anonymFunc) return pixXrect( pix,  self, anonymFunc) end
	elseif obj.r
	then
		function obj:crect(rect, anonymFunc) return rectXcirc(rect, self, anonymFunc) end
		function obj:ccirc(circ, anonymFunc) return circs(    self, circ, anonymFunc) end
		function obj:cpix( pix,  anonymFunc) return pixXcirc( pix,  self, anonymFunc) end
	else
		function obj:crect(rect, anonymFunc) return pixXrect( self, rect, anonymFunc) end
		function obj:ccirc(circ, anonymFunc) return pixXcirc( self, circ, anonymFunc) end
		function obj:cpix( pix,  anonymFunc) return pixs(     self, pix,  anonymFunc) end
	end
end

--=======================================================================================--
