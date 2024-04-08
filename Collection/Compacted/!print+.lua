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

-- [COMPACTED] Copy and paste the code in your cart [v: 2.2]

local DA2={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _T,_S,_TS=type,string,tostring local function ERROR(c,t,f,n) assert(c,'[print+] '..t..' (parameter) not specified. In function "pplus.'..f..'", argument #'..n..'.') end DA2.lenght=function(t,l,f,s,_s) ERROR(_T(t)=="string","String","lenght","1") local S,s,l=print(t,0,136),s or 1, l or 1 S=_s and S-#t*2 or S if f then for i=1,#t do local a,b=0,_S.sub(t,i,i) if _S.match(b,'[%"%+%-%_%=%<%>%?%{%}%~]') or b==" " or b=="'" then a=2 elseif _S.match(b,'[%!%.%,%(%)%:%;%[%]]') then a=3 elseif b=="|" then a=4 end S=S+a end end return S*s,(6*s)*l end DA2.center=function(t,x,y,l,f,s,_s) local x,y,w,h=x or 0,y or 0,DA2.lenght(t,l,f,s,_s) return x-w//2+1,y-h//2+1 end DA2.list=function(t,x,y,c,s,f,S,_s) ERROR(_T(t)=="table","Table","list","1") local x,y,c,s=x or 0,y or 0,c or 15,s or 10 for i=1,#t do print(_TS(t[i]),x,y+s*(i-1),c,f,S or 1,_s) end end DA2.title=function(S,X,Y,d,s,_s,k,v) ERROR(_T(S)=="table","Table","title","1") local b={} if _T(k)=="number" then for i=1,#S do b[i]=k end elseif _T(k)=="table"  then b=k if #b<#S then for i=#b+1,#S do b[i]=0 end end else for i=1,#S do b[i]=0 end end local X,Y,d,s,_S=X or 0,Y or 0,d or 8,s or 1,_s or 1 for i=1,#S do local x,y if v then x,y=X,Y+(d+s)*(i-1) else x,y=X+(d+s)*(i-1),Y end spr(S[i],x,y,b[i],_s) end end end

local pplus=DA2 -- you can customize this reference or not use it.
