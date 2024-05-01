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

-- [COMPACTED] Copy and paste the code in your cart [v: 3.2]

local DA2={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _SM,_SS,_SF,_TY,_PR,_TN,_TS=string.match,string.sub,string.find,type,print,tonumber,tostring local function _AS(c,m,i,n,j) assert(c,'[_PR+] '..m..'. In function "longBit.'..n..'", argument #'..i..(j and " (index: "..j..") " or "")..'.') end DA2.lenght=function(t,l,f,S,s) _AS(_TY(t)=="string","String (parameter) not specified",1,"lenght") local z=_PR(t,0,136) z=(s) and z-#t*2 or z if f then for i=1,#t do local a,c=0,_SS(t,i,i) if _SM(c,'[%"%+%-%_%=%<%>%?%{%}%~]') or c==" " or c=="'" then a=2 elseif _SM(c,'[%!%.%,%(%)%:%;%[%]]') then a=3 elseif c=="|" then a=4 end z=z+a end end return z*(S or 1),(6*(S or 1))*(l or 1) end DA2.center=function(t,x,y,l,f,S,s) local w,h=DA2.lenght(t,l,f,S,s) return (x or 0)-w//2+1,(y or 0)-h//2+1 end DA2.pCenter=function(t,X,Y,c,l,f,S,s) local x,y=DA2.center(t,X,Y,l,f,S,s) _PR(t,x,y,c,f,S or 1,s) end DA2.pShadow=function(t,X,Y,C,sh,f,S,s,pl) local e,h,d,c,n,a,l,m,g=S or 1,"",{},{},{},{},{[0]={0,-1},{0,1},{-1,0},{1,0}},(#sh<=4) and #sh or 4,sh and " (called by longBit.pList)" or "" local function rr(v, N, D) for i=1,3 do v[i][id]=_TN(v[i][id]) _AS(_TY(v[i][D])=="number",'"shadow" '..N..'" is NaN'..g,1,"pShadow",D) end end _AS(_TY(sh)=="table",'"shadow" is not a table'..g,1,"pShadow") _AS(sh[1]~=nil,'"shadow" values not defined'..g,1,"pShadow") for i=1,m do for j=1,2 do h=_SF(sh[i],"-") if #sh[i]>0 and #sh[i]<=2 then h=0 end _AS(h,'Hyphen not specified in index "'..i..'"',5,"pShadow") if j==1 then d[i]=_SS(sh[i],1,h-1) sh[i]=_SS(sh[i],h+1,#sh[i]) else c[i]=_SS(sh[i],1,h-1) if h==0 then n[i]=e else n[i]=_SS(sh[i],h+1,#sh[i]) end end end a={d,n,c} rr(a,{"d","n","c"},i) for l=1,2 do a[l][i]=(a[l][i]<0) and 0 or (a[l][i]>3) and 3 or a[l][i] end _PR(t,X+l[d[i]][1]*n[i],Y+l[d[i]][2]*n[i],c[i],f,e,s) end _PR(t,X,Y,C,f,e,s) end DA2.pBoard=function(t, X, Y, c, B, E, f, S, s) local l,_S,b,e={{0,-1},{0,1},{-1,0},{1,0}},S or 1,B or 15,E or _S for i=1,4 do _PR(t,X+l[i][1]*e,Y+l[i][2]*e,b,f,_S,s) end _PR(t,X,Y,c,f,_S,s) end DA2.pList=function(t,X,Y,C,p,f,S,s,ic,e) assert(_TY(t)=="table",'Table (parameter) not specified',1,"pList") local c,p,x,y,b=C or 15,p or 10,0,0,{} if e then _AS(_TY(e)=="table",'"effect" is not a table',9,"pList") _AS(e[1]=="shadow" or e[1]=="board",'Type of "effect[1]" is unvalid, try "shadow" or "board"',9,"pList") if e[1]=="shadow" then _AS(_TY(e[2])=="table",'"effect[2]" is not a table',9,"pList") for i=1,#e[2] do b[i]=e[2][i] end elseif e[1]=="board" then _AS(_TY(e[2])=="number",'"effect[2]" is a NaN',9,"pList") end end for i=1,#t do x,y=X or 0,(Y or 0)+p*(i-1) if ic then x,y=center(t[i],x,y - #t,#t,f,S,s) end if not e then _PR(_TS(t[i]),x,y,c,f,S or 1,s) else if e[1]=="shadow" then DA.pShadow(t[i],x,y,c,e[2],f,S,s,true) for j=1,#b do e[2][j]=b[j] end elseif e[1]=="board" then DA.pBoard( t[i],x,y,c,e[2],e[3],f,S,s) end end end end DA2.title=function(S,X,Y,d,s,_s,k,v) ERROR(_T(S)=="table","Table","title","1") local b={} if _T(k)=="number" then for i=1,#S do b[i]=k end elseif _T(k)=="table"  then b=k if #b<#S then for i=#b+1,#S do b[i]=0 end end else for i=1,#S do b[i]=0 end end local X,Y,d,s,_S=X or 0,Y or 0,d or 8,s or 1,_s or 1 for i=1,#S do local x,y if v then x,y=X,Y+(d+s)*(i-1) else x,y=X+(d+s)*(i-1),Y end spr(S[i],x,y,b[i],_s) end end end

local pplus=DA2 -- you can customize this reference or not use it.
