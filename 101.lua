#!/usr/bin/env lua
---       __   
---     /'__`\   
---    /\ \L\.\_  
---    \ \__/.\_\ 
---     \/__/\/_/ 

local lib = require"lib"
local the = lib.settings[[   
a.lua : an example script with help text and a test suite
(c)2022, Tim Menzies <timm@ieee.org>, BSD-2 

USAGE:   a.lua  [OPTIONS]

OPTIONS:
  -d  --dump  on crash, dump stack = false
  -g  --go    start-up action      = data
  -h  --help  show help            = false
  -s  --seed  random number seed   = 937162211
]]
-----------------------------------------------------------------------------------------
-- ## SYM
-- Summarize a stream of symbols.
local SYM = lib.obj"SYM"
function SYM:new() --> SYM; constructor
  self.n   = 0
  self.has = {}
  self.most, self.mode = 0,nil end

function SYM:add(x) --> nil;  update counts of things seen so far
  if x ~= "?" then 
   self.n = self.n + 1 
   self.has[x] = 1 + (self.has[x] or 0)
   if self.has[x] > self.most then
     self.most,self.mode = self.has[x], x end end end 

function SYM:mid(x) --> n; return the mode
  return self.mode end 

function SYM:div(x) --> n; return the entropy
  local function fun(p) return p*math.log(p,2) end
  local e=0; for _,n in pairs(self.has) do e = e - fun(n/self.n) end 
  return e end
--------------------------------------------------------------------------------
-- ## NUM
-- Summarizes a stream of numbers.
local NUM = lib.obj"NUM"
function NUM:new() --> NUM;  constructor; 
  self.n, self.mu, self.m2 = 0, 0, 0
  self.lo, self.hi = math.huge, -math.huge end

function NUM:add(n) --> NUM; add `n`, update min,max,standard deviation
  if n ~= "?" then
    self.n  = self.n + 1
    local d = n - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(n - self.mu)
    self.sd = (self.m2 <0 or self.n < 2) and 0 or (self.m2/(self.n-1))^0.5 
    self.lo = math.min(n, self.lo)
    self.hi = math.max(n, self.hi) end end

function NUM:mid(x) return self.mu end --> n; return mean
function NUM:div(x) return self.sd end --> n; return standard deviation
--------------------------------------------------------------------------------------------
-- ## Start-up
local eg={}

function eg.crash()        return the.some.missing.nested.field end 
function eg.stillWorking() return true == true end
function eg.the()          lib.oo(the) end
function eg.sym()
  local sym=SYM()
  for _,x in pairs{"a","a","a","a","b","b","c"} do sym:add(x) end
  return "a"==sym:mid() and 1.379 == lib.rnd(sym:div())end

function eg.num()
  local num=NUM()
  for _,x in pairs{1,1,1,1,2,2,3} do num:add(x) end
  return 11/7 == num:mid() and 0.787 == lib.rnd(num:div()) end 

function eg.rand()
  local num1,num2 = NUM(),NUM()
  lib.srand(the.seed); for i=1,10^3 do num1:add( lib.rand() ) end
  lib.srand(the.seed); for i=1,10^3 do num2:add( lib.rand() ) end
  local m1,m2 = num1:mid(), num2:mid()
  return m1==m2 and .5 == lib.rnd(m1,1) end 

if lib.required() then return {STATS=STATS} else lib.main(the,eg) end 
