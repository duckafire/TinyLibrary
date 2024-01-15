-- [COMPACTED] Copy and paste the code in your cart [v: 1.2]

local DAMIT,DA="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE",{}

do local function ERROR(a) error('[print+] Table (parameter) not expecified (function: "printPlus.'..a..'")') end DA.lenght=function(a,b,c,d,e) local s=print(a,0,136,c,d) s=e and s-#a*2 or s if c then for i=1,#a do local A,l=0,string.sub(a,i,i) if string.match(l,'[%"%+%-%_%=%<%>%?%{%}%~]') or l==" " or l=="'" then A=2 elseif string.match(l,'[%!%.%,%(%)%:%;%[%]]') then A=3 elseif l=="|" then A=4 end s=s+A end end local b=b or 1 return s,6*b end DA.center=function(a,x,y,b,c,d,e) local w,h=DA.lenght(a,b,c,d,e) return x-w//2+1,y-h//2+1 end DA.list=function(a,x,y,b,c,d,e,f) if type(a)~="table" then ERROR("list") end local x, y, c = x or 0, y or 0, c or 10 for i = 1, #a do print(a[i],x,y+c*(i-1),b,d,e,f) end end DA.title=function(a,x,y,b,c,d,e) if type(a)~="table" then ERROR("title") end local b,c,d=b or 8,c or 1, d or 1 for i=1,#a do local x,y=x+(b+c)*(i-1),y if e then x,y=x,y+(b+c)*(i-1) end spr(a[i],x,y,0,d) end end end

local pplus=DA