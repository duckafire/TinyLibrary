----------------------------------------------------------------------------------
-- MIT License

-- Copyright (c) 2024 DuckAfire

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
----------------------------------------------------------------------------------

-- [COMPACTED or NOT COMPACTED] Copy and paste the code in your cart [v: 1.2]

local DA={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do _G.__LONGBIT_CLASSES={} local _TS,_TN,_T,_SS = tostring,tonumber,type,string.sub local function _C(d) assert(_G.__LONGBIT_CLASSES[0]~=nil,"[longBit] pmem classes not defined.") for i=0,#_G.__LONGBIT_CLASSES do if d==_G.__LONGBIT_CLASSES[i] then return i end end error('[longBit] Undefined class: "'..d..'"') end DA.setClass=function(c,m,s) local j=1 for i=s or 0,m or #c-1,(m~=nil and c>m) and -1 or 1 do _G.__LONGBIT_CLASSES[i],j=c[j],j+1 end end DA.setMem=function(n,P,C,L) local p,l,v,b,f=P+1,L or 1 if _T(n)=="boolean" then v=n and 1 or 0 else v=_TS(n) if l>1 then for i=1,l do v=(#v<l) and "0"..v or v end end end local function c(a,z) return _SS(_TS(pmem(_C(C))),a,z) end b,f= c(1,p-1),c(p+l) pmem(_C(C),_TN(b..v..f)) end DA.boot=function(V,z,a,e) local v for i=a or 0,z or #V-1,(a~=nil and a>z) and -1 or 1 do v=_SS("2".._TS(V[i+1]),1,10) while #v<10 do v=v..(e or "0") end pmem(i,_TN(v)) end end DA.clear=function(Z,A) for i=A or 0,Z or 255,(A~=nil and A>Z) and -1 or 1 do pmem(i,0) end end DA.getNum=function(P,c,l) local p=P+1 return _TN(_SS(_TS(pmem(_C(c))),p,p+((l or 1)-1))) end DA.getBool=function(p,c,e) return DA.getNum(p,c)==(e or 1) end DA.getClass=function(i) return _G.__LONGBIT_CLASSES[i] end end

local lbit=DA -- you can customize this reference or not use it.
DA=nil
