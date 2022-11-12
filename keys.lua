#!/usr/bin/env lua
local l = require"lib"
local the = l.settings[[
ranges.lua : report ranges that disguise best rows from rest
(c)2022, Tim Menzies <timm@ieee.org>, BSD-2 

USAGE:   ranges.lua  [OPTIONS]

INFERENCE OPTIONS:
  -b  --best   coefficient on 'best'        = .5
  -B  --Bins   initial number of bins       = 16
  -c  --cohen  Cohen's small effect test    = .35
  -r  --rest   explore rest* number of best = 4

OTHER OPTIONS:
  -d  --dump   on crash, print stack dump = false
  -f  --file   csv file                   = ../data/auto93.csv
  -g  --go     start-up action            = data
  -h  --help   show help                  = false
]]
local csv,list,push,kap,sort,o,oo,obj,rnd = 
         l.csv,               -- file tricks
         l.list,l.push,l.kap, -- list tricks
         l.sort,              -- sorting tricks
         l.o,l.oo,            -- printing tricks
         l.obj,               -- object tricks
         l.rnd                -- random number tricks
--------------------------------------------------------------------------------
-- ## NUM
local NUM = obj"NUM"
function NUM:new(n,s) 
  self.at, self.txt  = n or 0, s or ""
  self.n, self.mu, self.m2 = 0, 0, 0
  self.lo, self.hi = math.huge, -math.huge 
  self.w = self.txt:find"-$" and -1 or 1 end

function NUM:add(x)
  if x ~= "?" then
    self.n  = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = (self.m2 <0 or self.n < 2) and 0 or (self.m2/(self.n-1))^0.5 
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi) end end

function NUM:mid(x) return self.mu end
function NUM:div(x) return self.sd end 
function NUM:norm(x)
  if x=="?" then return x end
  return self.hi-self.lo < 1E-9 and 0 or (x-self.lo)/(self.hi - self.lo) end

function NUM:discretize(n) --> num; discretize `Num`s,rounded to (hi-lo)/Bins
  local tmp = (self.hi - self.lo)/(the.Bins - 1)
  return self.hi == self.lo and 1 or math.floor(n/tmp + .5)*tmp end 

function NUM:merge(b4,min) 
  local function fillInGaps(t)
    for j=2,#t do t[j-1].hi = t[j].lo end
    t[1 ].lo = -math.huge
    t[#t].hi =  math.huge
    return #t==1 and {} or t 
  end -------------
  local now,j = {},1
  while j <= #b4 do
    local xy1, xy2 = b4[j], b4[j+1]
    local merged   = xy2 and xy1:merge(xy2,min, the.cohen*self.sd)
    now[1+#now]    = merged or xy1
    j              = j + (merged and 2 or 1) end 
  return #now < #b4 and self:merge(now,min) or fillInGaps(now) end 
--------------------------------------------------------------------------------
-- ## SYM
local SYM = obj"SYM"
function SYM:new(n,s)
  self.at , self.txt = n or 0, s or ""
  self.n   = 0
  self.has = {}
  self.most, self.mode = 0,nil end

function SYM:add(x,inc) 
  if x ~= "?" then 
   inc = inc or 1
   self.n = self.n + inc 
   self.has[x] = inc + (self.has[x] or 0)
   if self.has[x] > self.most then
     self.most,self.mode = self.has[x], x end end end 

function SYM:mid(x) return self.mode end
function SYM:div(x) 
  local function fun(p) return p*math.log(p,2) end
  local e=0; for _,n in pairs(self.has) do e = e - fun(n/self.n) end 
  return e end

function SYM:score(goal,B,R)
  for k,n in pairs(self.has) do
    if k==goal then b=b+n/B else r=r+n/R end end
  return b^2/(b+r) end

function SYM:norm(x)       return x end
function SYM:merge(x,...)  return x end
function SYM:discretize(x) return x end
--------------------------------------------------------------------------------
--- ### XY
local XY=obj"XY"
function XY:new(n,s,lo,hi) 
  self.at, self.txt = n,s
  self.lo = lo
  self.hi = hi or lo 
  self.y = SYM(n,s) 
  self._rows={} end

function XY:add(x,y,row)
  self.lo = math.min(x, self.lo)
  self.hi = math.max(x, self.hi) 
  self._rows[row._id] = row
  self.y:add(y) end

function XY:merge(xy,rare,small)
  local a,b     = self, xy
  local isRare  = a.y.n <= rare or b.y.n <= rare
  local isSmall = a.hi - a.lo <= small or b.hi - b.lo <= small
  if isSmall or isRare then 
    local c   = XY(self.at, self.txt, a.lo, b.hi)
    for _,sym in pairs{self.y,xy.y} do
      for k,n in pairs(sym.has) do c.y:add(k,n) end 
    for _,rows in pairs{self._rows, xy._rows} do
      for _,row in pairs(rows) do c._rows[row._id]=row end end end
    return c end end
--------------------------------------------------------------------------------------------
-- ## COLS
local COLS = obj"COLS"
function COLS:new(t)
  self.names, self.all, self.x, self.y = t,{},{},{} 
  for n,s in pairs(t) do 
    local col = push(self.all, s:find"^[A-Z]+" and NUM(n,s) or SYM(n,s))
    if not s:find"X$" then
      push(s:find"[!+-]$" and self.y or self.x, col) end end end
    
function COLS:add(row)
  for _,cols in pairs{self.x, self.y} do
    for _,col in pairs(cols) do
      col:add(row[col.at]) end end 
  return row end
--------------------------------------------------------------------------------------------
-- ## DATA
local DATA = obj"DATA"
function DATA:new(src)
  self.cols,self.rows = nil,{}
  if   type(src)=="string" 
  then csv(src,       function(row) self:add(row) end)
  else map(src or {}, function(row) self:add(row) end) end end

function DATA:add(row) 
  if self.cols then push(self.rows, self.cols:add(row)) else self.cols = COLS(row) end end

function DATA:stats(  fun,cols,places)
  local t={}
  for _,col in pairs(cols or self.cols.y) do 
    local v = getmetatable(col)[fun or "mid"](col)
    t[col.txt] = type(v)=="number" and rnd(v,places) or v end
  return t end

function DATA:sort(t1,t2)
  local s1,s2,ys = 0,0,self.cols.y
  for _,col in pairs(ys) do
    local x = col:norm( t1[col.at] )
    local y = col:norm( t2[col.at]  )
    s1      = s1 - math.exp(col.w * (x-y)/#ys)
    s2      = s2 - math.exp(col.w * (y-x)/#ys) end
  return s1/#ys < s2/#ys end

function DATA:sorts()
  return sort(self.rows, function(t1,t2) return self:sort(t1,t2) end) end

local _xys
function DATA:xys()
  local t    = {}
  local rows = self:sorts(rows)
  local B    = (#self.rows)^the.best -- the first B rows are great
  local R    = #self.rows - B        -- the rest are not
  for _,col in pairs(self.cols.x) do
    for _,xy in _xys(col,rows, B, R) do
      push(t, xy).score = xy.y:score(true,B,R) end end
  return sort(t, gt"score") end

function _xys(col,rows,B,R)
  local function update(t,row,y,    x,k)
    x = row[col.at]
    if x ~= "?" then
      k = col:discretize(x)
      t[k] = t[k] or XY(col.at, col.txt, x)
      t[k]:add(x, y, row) end 
  end ----------------------- 
  local t = {}
  for i=1,B                        do update(t, rows[i//1], true)  end
  for i=B+1, #rows, R/(the.rest*B) do update(t, rows[i//1], false) end
  return col:merge(sort(list(t),lt"lo"), 
                   #self.rows/the.Bins,  -- prune if under, say, 1/16th of the rows
                   col.sd*the.cohen) end -- prune if under, say, 35% of std dev

--------------------------------------------------------------------------------------------
-- ## Start-up
local eg={}

function eg.the() oo(the) end

function eg.sorts()
  local d=DATA(the.file)
  t = d:sorts()
  oo(d.cols.names)
  for i=1,#t,50 do print(o(t[i]),i) end end

if l.required() then return {STATS=STATS} else l.main(the,eg) end 
