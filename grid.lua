#!/usr/bin/env lua
---                       _        __
---     ____ _   _____   (_)  ____/ /
---    / __ `/  / ___/  / /  / __  / 
---   / /_/ /  / /     / /  / /_/ /  
---   \__, /  /_/     /_/   \__,_/   
---   /____/                           
                                           
local lib = require"lib"
local the = lib.settings[[   
grud.lua : row/column clustering for rep grids
(c)2022, Tim Menzies <timm@ieee.org>, BSD-2 

Reads a csv file where row1 is column names and col1,coln
is dimension left,right and all other cells are numerics.

USAGE:   grid.lua  [OPTIONS]

OPTIONS:
  -d  --dump  on crash, dump stack = false
  -f  --file  csv file             = etc/data/repgrid1.csv
  -g  --go    start-up action      = data
  -h  --help  show help            = false
  -s  --seed  random number seed   = 937162211
]]
local fmt =
       lib.fmt -- string tricks
-----------------------------------------------------------------------------------------
local function(file)
  t=ok(dofile(file))
  
  m={}
  cols=#t.rows[1]
  for r,row in pairs(t.rows) do 
    assert(#row=ncols,"rows wrong width"
    m[r]={}
    for c=2,#row-1 do 
      x = row[c]
      assert(x//1 == x,             fmt("[%s] not an int",x)
      assert(x<=t.hi and x >= t.lo, fmt("[%s] out of range") and m[r][c-1] = x end end end 

local function ok(t)
  local want={rows={},hi=1,lo=1,cols={},domain="string"}
  for key,eg in pairs(want) do
    assert(t[key],                   fmt("[%s] missing",key))
    assert(type(t[key]) == type(eg), fmt("[%s] not of type [%s]", t[key], type(eg))) end 
  for r,row in pairs(t.rows) do 
    assert(#row==#t.rows[1],            fmt("row [%s] does not have [%s] cells",r,#t.rows[1])) 
    assert(type(row[1]) == "string",    fmt("row [%s] does not have a LHS name",r))
    assert(type(row[#row]) == "string", fmt("row [%s] does not have a RBS name",r)) end
  for c=2,#row-1 do 
    x = row[c]
    assert(x//1 == x,             fmt("[%s] not an int",x))
    assert(x >= t.lo and x<=t.hi, fmt("[%s] out of range")) end end 
  return t end
--------------------------------------------------------------------------------------------
--- ## Start-up
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
