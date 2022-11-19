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
local fmt,oo,map =
       lib.fmt,lib.oo, -- string tricks
       lib.map         -- less strings
-----------------------------------------------------------------------------------------
local grid,ok
function grid(file)
  t=ok(dofile(file))
  m={}
  for r,row in pairs(t.rows) do 
    m[r]={}
    for c=2,#row-1 do 
      m[r][c-1] = row[c] end end 
  return m end 

function ok(t)
  local template = {rows={},hi=1,lo=1,cols={},domain="string"}
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
function eg.ok()  map(ok(dofile(the.file)),function(row) 
                       row=map(row,tostring)
                       table.concat(row) end) end

if lib.required() then return {STATS=STATS} else lib.main(the,eg) end 
