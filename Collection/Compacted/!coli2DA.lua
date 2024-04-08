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

-- [COMPACTED] Copy and paste the code in your cart [v: 2.7]

local DA1={}
local TINY_LIBRARY_LICENSE="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE"

do local _T,_M=type,math local function ERROR(p,f,n) error('[coli2DA] The parameter "Type" is invalid,try "'..p..'". In function "coli.'..f..'", argument #'..n..'.') end DA1.newBody=function(t,x,y,wr,h) local b={x=x or 0,y=y or 0} if t=="rect" then b.width,b.height=wr or 8,h or 8 elseif t=="circ" then b.radius=wr or 4 elseif t~="simp" then ERROR('rect","circ" or "simp',"newBody","1") end return b end local function _C(p,t) local I,b,l=1,{{},{}},0 for i=1,#t do local a,c,r=t[i]=="circ" and 1 or t[i]=="simp" and 2 or 0,p[I],0 if _T(c)=="table" then b[i]=DA1.newBody(t[i],c.x or c[1],c.y or c[2],c.width or c.radius or c[3],c.height or c[4]) l=l+1 else r,l,b[i]=3,l+4-a,DA1.newBody( t[i],p[I],p[I + 1],p[I + 2],p[I + 3] ) end if r==3 then I=5-a else I=2 end end return b[1],b[2],p,l+1 end DA1.distance=function(...) local a,b=_C({...},{"simp","simp"}) return _M.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end DA1.mapAlign=function(...) local P={...} local t=(_T( P[1] )=="table" or (_T( P[1] )~="table" and #P>=4)) and "rect" or "simp" if _T(P[1])~= "table" and #P<2 then error( '[coli2DA] Insufficient parameters for this call format. In function "coli.mapAlign", argument #(quantity).' ) end local o,_,p,l=_C(P,{t}) local x,y=o.x,o.y if p[l] then local w,h=o.width or 8,o.height or 8 x,y=x+w//2,y+h//2 end return (x//8)*8,(y//8)*8 end DA1.tile=function(...) local o,_,p,l=_C({...},{"rect"}) local w,h,f,x,y,a,b,c,d=o.width,o.height,p[l+1] or 0,p[l+2] or 0,p[l+3] or 0 if p[l]=="top" then a,b,c,d=0,-1,w-1,-1 elseif p[l]=="below" then a,b,c,d=0,h,w-1,h elseif p[l]=="left" then a,b,c,d=-1,0,-1,h-1 elseif p[l]=="right" then a,b,c,d=w,0,w,h-1 else ERROR('top","below","left" or "right',"tile","(last)") end return fget(mget((o.x+a)//8+x,(o.y+b)//8+y),f) and fget(mget((o.x+c)//8+x,(o.y+d)//8+y),f) end DA1.tileCross=function(...) local o,_,p,l=_C({...},{"rect"}) local f=_T(p[l+1])=="table" and p[l+1] or {} for i=1,4 do if not f[i] or _T(f[i])~="number" then f[i]=_T(p[l+1])=="number" and p[l+1] or 0 end end local a,b,v,t=p[l+2],p[l+3],{},{[0]="top","below","left","right"} for i=0,3 do v[i]=DA1.tile(o,t[i],f[i+1],a,b) end return p[l] and {top=v[0],below=v[1],left=v[2],right=v[3]} or v end DA1.box360=function(x,y,s) local tb,lr if s.top then tb=y and ((y<0 and s.top) or (y>0 and s.below)) or false lr=x and ((x<0 and s.left) or (x>0 and s.right)) or false else tb=y and ((y < 0 and s[0]) or (y>0 and s[1])) or false lr=x and ((x < 0 and s[2]) or (x>0 and s[3])) or false end return tb or lr end DA1.touch=function(a,b,A,B,d) local c,d={},d or {} c.x,c.y=mouse() c.width,c.height=d.width and _M.abs(d.width) or d[1] and _M.abs(d[1]) or 1,d.height and _M.abs(d.height) or d[2] and _M.abs(d[2]) or 1 return c.x+c.width-1>=a and c.x<=A and c.y+c.height-1>=b and c.y<=B end DA1.impactPixel=function(...) local t={...} if t[#t]~="rect" and t[#t]~="circ" then ERROR('rect" or "circ',"impactPixel","(last)") end local a,b,p,l=_C(t,{t[#t],t[#t]}) if p[l]=="rect" then local A,B={x=a.x+a.width/2,y=a.y+a.height/2,radius=(a.width+a.height)/2},{x=b.x+b.width/2,y=b.y+b.height/2,radius=(b.width+b.height)/2} return DA1.impactPixel(A,B,"circ") elseif p[l]=="circ" then local x,y=(a.x*b.radius)+(b.x*a.radius),(a.y*b.radius)+(b.y*a.radius) local tr=(a.radius + b.radius) return x/tr,y/tr end end DA1.rectangle=function(...) local t,i,A={...} i=_T(t[#t])=="boolean" and t[#t] or false A=i and "simp" or "rect" local a,b=_C(t,{A,"rect"}) if i then a.width,a.height=1,1 end return a.x+a.width-1>=b.x and a.x<=b.x+b.width-1 and a.y+a.height-1>=b.y and a.y<=b.y+b.height-1 end DA1.circle=function(...) local t,i,A={...} i=_T(t[#t])=="boolean" and t[#t] or false A=i and "simp" or "circ" local a,b=_C(t,{A,"circ"}) local tr=i and b.radius or a.radius + b.radius return (a.x-b.x)^2+(a.y-b.y)^2<=tr^2 end DA1.shapesMix=function(...) local C,R,r,s,x,y=_C({...},{"circ","rect"}) r=C.radius s=DA1.newBody("rect",C.x-r,C.y-r,r*2,r*2) x,y=DA1.impactPixel(R,s,"rect") return DA1.rectangle({x,y},R,true) or DA1.circle({x,y},C,true) end end

local coli=DA1 -- you can customize this reference or not use it.

-- NOTE:
---- In function "impactPixel" (using "rect"),if any of the bodies is a rectangle with a large difference in size between its pairs of sides (e.g.,5x30),the returned result may is incorrect.
