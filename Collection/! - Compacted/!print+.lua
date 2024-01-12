-- [COMPACTED] Copy and paste the code in your cart [v: 1.0]

local DAMIT,DA="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE",{}

do local function E(a) error('[print+] Table (parameter) not expecified (function: "printPlus.'..a..'")') end DA.lenght=function( a, b, c, d, e ) local f,g,h,i=type(b)~="table" and b or b[1] or b.lines or 1,b[2] or b.spaces or 5,e and #a*2 or 0,0 if c then for i=1,#a do if string.sub(a,i,i)==" " then i=i+2 end end end return print(a,0,136,d)-h+i,f*g end DA.center=function(a,x,y,b,c,d,e) local w,h=DA.lenght(a,b,c,d,e) return x-w//2,y-h//2 end DA.list=function(a,x,y,b,c,d,e,f) if type(a)~="table" then E("list") end local x, y, c = x or 0, y or 0, c or 10 for i = 1, #a do print(a[i],x,y+c*(i-1),b,d,e,f) end end DA.title=function(a,x,y,b,c,d,e) if type(a)~="table" then E("title") end local b,c,d=b or 8,c or 1, d or 1 for i=1,#a do local x,y=x+(b+c)*(i-1),y if e then x,y=x,y+(b+c)*(i-1) end spr(a[i],x,y,0,d) end end end

local pplus = DA