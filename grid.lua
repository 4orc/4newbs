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
  -p  --p     distance coefficient = 2
  -s  --seed  random number seed   = 937162211
]]
local obj,fmt,oo,map =
        lib.obj,        -- object tricks
        lib.fmt,lib.oo, -- string tricks
        lib.map         -- less strings
-----------------------------------------------------------------------------------------
local grid,ok
function grid(file)
  local t=ok(dofile(file))
  local m={}
  for r,row in pairs(t.rows) do 
    m[r]={}; for c=2,#row-1 do m[r][c-1] = row[c] end end 
  for r,row in pairs(m) do
    print""
    for c,cell in pairs(row) do io.write(cell," ") end end
  return m end 

function dist(r1,r2)
  local d=0
  for c,x in pairs(r1) do d= d+math.abs(x-r2[c])^the.p end
  return (d/#r2)^(1/the.p) end

function around(m,r1)
  map(m,function(r2) return {dist=dist(r2,r2),row=r2} end)
  return sort(m,lt"dist") end

function nearest(m,r1) return around(m,r1)[2] end

function fuse(r1,r2) 
  local r3={}
  for c,x in 

function ok(t)
  local template = {rows={},cols={},domain="string"}
  for key,eg in pairs(template) do
    assert(t[key],                      fmt("[%s] missing",key))
    assert(type(t[key]) == type(eg),    fmt("[%s=%s] is not a [%s]", key,t[key], type(eg))) end 
  for r,row in pairs(t.rows) do 
    assert(#row==#t.rows[1],            fmt("row [%s] does not have [%s] cells",r,#t.rows[1])) 
    assert(type(row[1])    == "string", fmt("row [%s] does not have a LHS name",r))
    assert(type(row[#row]) == "string", fmt("row [%s] does not have a RHS name",r)) 
    for c=2,#row-1 do 
      local x = row[c]
      assert(x//1 == x,             fmt("[%s] not an int",x))
      assert(x >= t.lo and x<=t.hi, fmt("[%s] out of range",x)) end end
  return t end
------------------------------------------------------------------------------------------
--- ## Start-up
local eg={}

function eg.the() lib.oo(the) end
function eg.ok()  ok(dofile(the.file)) end
function eg.grid()  grid(the.file) end
if lib.required() then return {STATS=STATS} else lib.main(the,eg) end 
