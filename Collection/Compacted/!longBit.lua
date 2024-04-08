----------------------------------------------------------------------------------
-- zlib License

-- Copyright (C) 2024 DuckAfire <facebook.com/duckafire>
  
-- This software is provided 'as-is', without any express or implied
-- warranty.  In no event will the authors be held liable for any damages
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

-- [COMPACTED or NOT COMPACTED] Copy and paste the code in your cart [v: 1.2]

local DA4={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do _G.__LONGBIT_CLASSES={} local _TS,_TN,_T,_SS = tostring,tonumber,type,string.sub local function _C(d) assert(_G.__LONGBIT_CLASSES[0]~=nil,"[longBit] pmem classes not defined.") for i=0,#_G.__LONGBIT_CLASSES do if d==_G.__LONGBIT_CLASSES[i] then return i end end error('[longBit] Undefined class: "'..d..'"') end DA4.setClass=function(c,m,s) local j=1 for i=s or 0,m or #c-1,(m~=nil and c>m) and -1 or 1 do _G.__LONGBIT_CLASSES[i],j=c[j],j+1 end end DA4.setMem=function(n,P,C,L) local p,l,v,b,f=P+1,L or 1 if _T(n)=="boolean" then v=n and 1 or 0 else v=_TS(n) if l>1 then for i=1,l do v=(#v<l) and "0"..v or v end end end local function c(a,z) return _SS(_TS(pmem(_C(C))),a,z) end b,f= c(1,p-1),c(p+l) pmem(_C(C),_TN(b..v..f)) end DA4.boot=function(V,z,a,e) local v for i=a or 0,z or #V-1,(a~=nil and a>z) and -1 or 1 do v=_SS("2".._TS(V[i+1]),1,10) while #v<10 do v=v..(e or "0") end pmem(i,_TN(v)) end end DA4.clear=function(Z,A) for i=A or 0,Z or 255,(A~=nil and A>Z) and -1 or 1 do pmem(i,0) end end DA4.getNum=function(P,c,l) local p=P+1 return _TN(_SS(_TS(pmem(_C(c))),p,p+((l or 1)-1))) end DA4.getBool=function(p,c,e) return DA4.getNum(p,c)==(e or 1) end DA4.getClass=function(i) return _G.__LONGBIT_CLASSES[i] end end

local lbit=DA4 -- you can customize this reference or not use it.
