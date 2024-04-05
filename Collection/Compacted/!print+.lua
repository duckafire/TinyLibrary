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

-- [COMPACTED] Copy and paste the code in your cart [v: 2.2]

local DA={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _T,_S,_TS=type,string,tostring local function ERROR(c,t,f,n) assert(c,'[print+] '..t..' (parameter) not specified. In function "pplus.'..f..'", argument #'..n..'.') end DA.lenght=function(t,l,f,s,_s) ERROR(_T(t)=="string","String","lenght","1") local S,s,l=print(t,0,136),s or 1, l or 1 S=_s and S-#t*2 or S if f then for i=1,#t do local a,b=0,_S.sub(t,i,i) if _S.match(b,'[%"%+%-%_%=%<%>%?%{%}%~]') or b==" " or b=="'" then a=2 elseif _S.match(b,'[%!%.%,%(%)%:%;%[%]]') then a=3 elseif b=="|" then a=4 end S=S+a end end return S*s,(6*s)*l end DA.center=function(t,x,y,l,f,s,_s) local x,y,w,h=x or 0,y or 0,DA.lenght(t,l,f,s,_s) return x-w//2+1,y-h//2+1 end DA.list=function(t,x,y,c,s,f,S,_s) ERROR(_T(t)=="table","Table","list","1") local x,y,c,s=x or 0,y or 0,c or 15,s or 10 for i=1,#t do print(_TS(t[i]),x,y+s*(i-1),c,f,S or 1,_s) end end DA.title=function(S,X,Y,d,s,_s,k,v) ERROR(_T(S)=="table","Table","title","1") local b={} if _T(k)=="number" then for i=1,#S do b[i]=k end elseif _T(k)=="table"  then b=k if #b<#S then for i=#b+1,#S do b[i]=0 end end else for i=1,#S do b[i]=0 end end local X,Y,d,s,_S=X or 0,Y or 0,d or 8,s or 1,_s or 1 for i=1,#S do local x,y if v then x,y=X,Y+(d+s)*(i-1) else x,y=X+(d+s)*(i-1),Y end spr(S[i],x,y,b[i],_s) end end end

local pplus=DA -- you can customize this reference or not use it.
DA=nil
