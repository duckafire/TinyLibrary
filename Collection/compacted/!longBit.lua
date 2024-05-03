----------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------

-- [COMPACTED] Copy and paste the code in your cart [v: 2.4]

local DA4={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _SF,_SS,_TY,_TS,_As,_ER,_TN=string.find,string.sub,type,tostring,assert,error,tonumber local LBC={} local function _AS(c,m,i,n,j) _As(c,'[longBit] '..m..'. In function "longBit.'..n..'", argument #'..i..(j and " (index: "..j..") " or "")..'.') end local function CT(F,J,I) _As(LBC[0]~=nil,'[longBit] pmem classes not defined. In function longBit.'..F..', argument #'..J..'.') for i=0,#LBC do if I==LBC[i] then return i end end _ER('[longBit] Undefined class: "'..I..'". In function longBit.'..F..', argument #'..J..'.') end local function GA(N,G,i,I,m,M) local a=i or I local b=m  or M _AS(a<=b,'The "max" value is less that "init"',G,N) return a,b end DA4.setClass=function(c,M,I) local j,m=GA("setClass",2,I,0,M,#c-1) local d=0 _AS(_TY(c)=="table",'Table not specified',1,"setClass") for i=j,m do _AS(c[i+1]~="",'Empty strings cannot used like class',1,"setClass",i) _AS(_SF(c[i+1]," ")==nil,'Classes names cannot contain spaces characters',1,"setClass",i) d=d+1 LBC[i]=c[d] end end DA4.setMem=function(V,I,c,L) local p,i,l,v=CT("setMem",3,c),I+1,L or 1 if _TY(V)=="boolean" then v=V and 1 or 0 else v=_TS(V) if l>1 then for i=1,l do v=(#v<l) and "0"..v or v end end end local function E(a,z) return _SS(_TS(pmem(p)),a,z) end pmem(p,_TN(E(1,i-1)..v..E(i+l))) end DA4.setAll=function(v,c) _AS(v>=0,'The value specified is too small', 1, "setAll") _AS(v<= 4294967295,'The value specified is too big', 1, "setAll") pmem(CT("setAll",2,c),v) end DA4.boot=function(m,f,M,I,y) local i,_m=GA("boot",3,I,0,M,#m -1) local b,v="","" for i=i,_m do if pmem(i)==0 or f then b='[longBit] The value "'..m[i+1]..'" is ' _AS(_TY(m[i+1])=="string",b..'not a string',1,"boot",i) _AS(_TN(m[i+1])~=nil,b..'unvalid,because it own a NaN character',1,"boot",i) _AS(_TN(m[i+1])<=999999999,b..'too big,the maximum is "999999999"',1,"boot",i) v=(m[i+1] ~= nil) and "2"..m[i+1] or m[#m] while #v < 10 do v=v..(y or "0") end pmem(i,_TN(v)) end end end DA4.clear=function(t,M,I) _AS(t=="all" or t=="memory" or t=="classes" or t=="lessClass",'Keyword '..t..' is invalid,try "all","memory","classes" or "lessClass"',1,"clear") local i,m=GA("clear",2,I,0,M,255) if t=="memory" or t=="all" then for i=i,m do pmem(i,0) end end if t=="classes" or t=="all" then LBC={} end if t=="lessClass" then for i=i,m do if not LBC[i] then pmem(i,0) end end end end DA4.getNum=function(i,c,l) _AS(i>0 and i<10,'Index invalid,try values between 0-9',1,"getNum") return _TN(_SS(_TS(pmem(CT("getNum",2,c))),(i+1),(i+1)+(l or 1)-1)) end DA4.getBool=function(i,c,e) _AS(i>0 and i<10,'Index invalid,try values between 0-9',1,"getBool") return DA4.getNum(i,c)==(e or 1) end DA4.getClass=function(i,w) _AS(not w or LBC[i],'Classe not defined, index: '..i,1,"getClass") return LBC[i] end DA4.showMem=function(c) return pmem(CT("showMem",1,c)) end DA4.swapClass=function(n,i,w) _AS(not w or LBC[i],'The class of the "'..i..'th" memory space was not defined',2,"swapClass") LBC[i]=n end end

local lbit=DA4 -- you can customize this reference or not use it.
