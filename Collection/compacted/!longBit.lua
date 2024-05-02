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

-- [COMPACTED] Copy and paste the code in your cart [v: 2.2]

local DA4={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _SF,_SS,_TY,_TS,_As,_ER,_TN=string.find,string.sub,type,tostring,assert,error,tonumber local function _AS(c,m,i,n,j) _As(c,'[longBit] '..m..'. In function "longBit.'..n..'", argument #'..i..(j and " (index: "..j..") " or "")..'.') end local function CT(id) _As(_G.__LONGBIT_CLASSES[0]~=nil,"[longBit] pmem classes not defined.") for i=0,#_G.__LONGBIT_CLASSES do if id==_G.__LONGBIT_CLASSES[i] then return i end end _ER('[longBit] Undefined class: "'.._TS(id)..'"') end local function GA(N,G,i,I,m,M) local a=i or I local b=m  or M _AS(a<=b,'The "max" value is less that "init"',G,N) return a,b end DA4.setClass=function(c,M,I) local i,m=GA("setClass",2,I,0,M,#c-1) _AS(_TY(c)=="table",'Table not specified',1,"setClass") for i=m,i do _AS(c[i+1]~="",'Empty strings cannot used like class',1,"setClass",i) _AS(_SF(c[i+1], " ")==nil,'Classes names cannot contain spaces characters',1,"setClass",i) _G.__LONGBIT_CLASSES[i]=c[i+1] end end DA4.setMem=function(V,I,c,L) local p,i,l,v=CT(c),I+1,L or 1 if _TY(V)=="boolean" then v=V and 1 or 0 else v=_TY(V) if l>1 then for i=1,l do v=(#v<l) and "0"..v or v end end end local function E(a,z) return _SS(_TY(pmem(p)),a,z)end pmem(p,_TN(E(1,i-1)..v..E(i+l))) end DA4.boot=function(m,f,M,I,y) local i,m=GA("boot",3,I,0,M,#m -1) local b,v="","" for i=i,m do if pmem(i)==0 or f then b='[longBit] The value "'..m[i+1]..'" is ' _AS(_TY(m[i+1])=="string",b..'not a string',1,"boot",i) _AS(_TN(m[i+1])~=nil,b..'unvalid,because it own a NaN character',1,"boot",i) _AS(_TN(m[i+1])<=999999999,b..'too big,the maximum is "999999999"',1,"boot",i) v=(m[i+1] ~= nil) and "2"..m[i+1] or m[#m] while #v < 10 do v=v..(y or "0") end pmem(i,_TN(v)) end end end DA4.clear=function(t,M,I) _AS(t=="all" or t=="memory" or t=="classes" or t=="lessClass",'Keyword '..t..' is invalid,try "all","memory","classes" or "lessClass"',1,"clear") local i,m=GA("clear",2,I,0,M,255) if t=="memory" or t=="all" then for i=i,m do pmem(i,0) end end if t=="classes" or t=="all" then _G.__LONGBIT_CLASSES={} end if t=="lessClass" then for i=i,m do if not _G.__LONGBIT_CLASSES[i] then pmem(i,0) end end end end DA4.getNum=function(i,c,l) _AS(i>0 and i<10,'Index invalid,try values between 0-9',1,"getNum") return _TN(_SS(_TY(pmem(CT(c))),(i+1),(i+1)+(l or 1)-1)) end DA4.getBool=function(i,c,e) _AS(i>0 and i<10,'Index invalid,try values between 0-9',1,"getBool") return DA4.getNum(i,c)==(e or 1) end DA4.getClass=function(i,w) _AS(not w or _G.__LONGBIT_CLASSES[i],'Classe not defined, index: '..i,1,"getClass") return _G.__LONGBIT_CLASSES[i] end DA4.swapClass=function(n,i,w) _AS(not w or _G.__LONGBIT_CLASSES[i],'The class of the "'..i..'th" memory space was not defined',2,"swapClass") _G.__LONGBIT_CLASSES[i]=n end end

local lbit=DA4 -- you can customize this reference or not use it.