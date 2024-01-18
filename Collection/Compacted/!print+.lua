-- [COMPACTED] Copy and paste the code in your cart [v: 2.0]

local DAMIT,DA="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE",{}

do local _T,_S,_TS=type,string,tostring local function ERROR(c,t,f) assert(c,'[print+] '..t..' (parameter) not specified, in function "pplus.'..f..'"') end DA.lenght(t,l,f,s,_s) ERROR(_T(t)=="string","String","lenght") local S,s,l=print(t,0,136),s or 1, l or 1 S=_s and S-#t*2 or S if f then for i=1,#t do local a,b=0,_S.sub(t,i,i) if _S.match(b,'[%"%+%-%_%=%<%>%?%{%}%~]') or b==" " or b=="'" then a=2 elseif _S.match(b,'[%!%.%,%(%)%:%;%[%]]') then a=3 elseif b=="|" then a=4 end S=S+a end end return S*s,(6*s)*l end DA.center(t,x,y,l,f,s,_s) local x,y,w,h=x or 0,y or 0,DA.lenght(t,l,f,s,_s) return x-w//2+1,y-h//2+1 end DA.list(t,x,y,c,s,f,s,_s) ERROR(_T(t)=="table","Table","list") local x,y,c,s=x or 0,y or 0,c or 15,s or 10 for i=1,#t do print(_TS(t[i]),x,y+s*(i-1),c,f,s,_s) end end DA.title(S,X,Y,d,s,_s,k,v) ERROR(_T(S)=="table","Table","title") local b={} if _T(k)=="number" then for i=1,#S do b[i]=k end elseif _T(k)=="table"  then b=k if #b<#S then for i=#b+1,#S do b[i]=0 end end else for i=1,#S do b[i]=0 end end local X,Y,d,s,_S=X or 0,Y or 0,d or 8,s or 1,_s or 1 for i=1,#S do local x,y if v then x,y=X,Y+(d+s)*(i-1) else x,y=X+(d+s)*(i-1),Y end spr(S[i],x,y,b[i],_s) end end end

local pplus=DA
