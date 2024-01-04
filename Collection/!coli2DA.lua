-- Copy and paste the code in your cart (don't copy the comments) [v: 1.3].

local DA_LICENSE,DA="github.com/DuckAfire/TinyLibrary/blob/main/LICENSE",{}-- There's no need to copy "DA_LICENSE" if they are already in the code.
do
local function ERROR(opt,func) error('The parameter "Type" is invalid, try "'..opt..'" (function: "'..func..'")') end
DA.newBody=function(T,x,y,w,h) if T=="rect" then return {x=x,y=y,width=w,height=h} elseif T=="circ" then return {x=x,y=y,radius=w} else ERROR('rect" or "circ','coli2DA.newBody') end end
local function CB(T,b,I) local i=I or 1 if type(b[i])=="table" then if b[i].x then return b[i] else return DA.newBody(T,b[i][1],b[i][2],b[i][3],b[i][4]) end else return DA.newBody(T,b[i],b[1+i],b[2+i],b[3+i]) end end
DA.tile=function(o,t,id) local w,h,i,x1,y1,x2,y2=o.width or 8,o.height or 8,id or 0 if t=="top" then x1,y1,x2,y2=0,-1,w,-1 elseif t=="below" then x1,y1,x2,y2=0,h,w,h elseif t=="left" then x1,y1,x2,y2=-1,0,-1,h elseif t=="right" then x1,y1,x2,y2=w,0,w,h else ERROR('top", "below", "left" or "right','coli2DA.tile') end return fget(mget((o.x+x1)//8,(o.y+y1)//8),i) and fget(mget((o.x+x2)//8,(o.y+y2)//8),i) end
DA.touch=function(...) local o,m=CB("rect",{...}),CB("rect",{...},5) m.width,m.height,m.x,m.y=m.width and math.abs(m.width) or 0,m.height and math.abs(m.height) or 0,mouse() return m.x+m.width-1>=o.x and m.x<=o.x+o.width-1 and m.y+m.height-1>=o.y and m.y<=o.y+o.height-1 end
DA.impactPixel=function(t,a,b) if t=="rect" then local a,b={x=a.x+a.width/2,y=a.y+a.height/2,radius=(a.width+a.height)/2},{x=b.x+b.width/2,y=b.y+b.height/2,radius=(b.width+b.height)/2} return DA.impactPixel("circ",a,b) elseif t=="circ" then local x,y=(a.x*b.radius)+(b.x*a.radius),(a.y*b.radius)+(b.y*a.radius) local tr=(a.radius+b.radius) return x/tr,y/tr elseif t=="mix" then local c,r,x,y={x=a.x,y=a.y,radius=a.radius},{t=b.x,b=b.y+b.height-1,l=b.y,r=b.y+b.width-1} if c.x<=r.l then x=r.l elseif c.x>r.r then x=r.r else x=c.x end if c.y<=r.t then y=r.t elseif c.y>r.b then y=r.b else y=c.y end return x,y else ERROR('rect", "circ" or "mix','coli2DA.impactPixel') end end
DA.rectangle=function(...) local a,b=CB("rect",{...}),CB("rect",{...},5) local aW,aH,bW,bH=a.width or 1,a.height or 1,b.width or 1,b.height or 1 aW,aH,bW,bH=math.abs(aW)-1,math.abs(aH)-1,math.abs(bW)-1,math.abs(bH)-1 return a.x+aW>=b.x and a.x<=b.x+bW and a.y+bH>=b.y and a.y<=b.y+bH end
DA.circle=function(...) local p={...} local a,b,q=CB("circ",{...}),CB("circ",{...},4),type(p[3])=="boolean" and p[3] or type(p[7])=="boolean" and p[7] or false local tr=q and a.radius+b.radius or b.radius return (a.x-b.x)^2+(a.y-b.y)^2<=tr^2 end
DA.shapesMix=function(...) local c,r,t=CB("circ",{...}),CB("rect",{...},4),{} t.radius=0 t.x,t.y=DA.impactPixel("mix",c,r) return DA.circle(t,c,true) end
end

coli=DA-- library reference

-- NOTE: in functions ".shapeMix" and ".impactPixel"(in mode "mix"), only the "circle" can move, because moving the "square/rectangle" will generate unexpected results.