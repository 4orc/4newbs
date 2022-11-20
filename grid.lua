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
  -d  --dump  on crash, dump stack       = false
  -f  --file  csv file                   = etc/data/repgrid1.csv
  -g  --go    start-up action            = data
  -h  --help  show help                  = false
  -m  --min   min size for leaf clusters = .5
  -p  --p     distance coefficient       = 2
  -s  --seed  random number seed         = 937162211
]]
local obj,fmt,oo,map,shuffle,lt,gt,sort,push,slice  =
        lib.obj,            -- object tricks
        lib.fmt, lib.oo,     -- string tricks
        lib.map, lib.shuffle, lib.lt, lib.gt, lib.sort, -- less strings
        lib.push, lib.slice  -- list tricks
-----------------------------------------------------------------------------------------
local dist,furthest,x2d,y2d,half,cluster,tree,asConstruct

function asConstruct(lo,hi,t) 
  local tmp = slice(t,2,-2)
  return {raw  = tmp,
          cells= map(tmp, function(x) return (x - lo)/(hi - lo +1E-32) end),
          lhs  = t[1], 
          rhs  = t[#t]} end

function dist(row1,row2)
   local n,d = 0,0
   for c,x in pairs(row1.cells) do 
     n = n+1
     d = d+math.abs(x - row2.cells[c])^the.p end
  return (d/n)^(1/the.p) end

function furthest(rows)
  local u={}
  for i = 1,#rows do
    for j = i+1,#rows do
      if j>i then 
        local r1,r2 = rows[i],rows[i]
        push(u, {left=r1, right=r2, d=dist(r1, r2)}) end end end
  return sort(u, gt"d")[1] end

function x2d(a,b,c) return (a^2 + c^2 - b^2) / (2*c) end
function y2d(a,x)   print(a,x); return (math.max(0, math.min(1, x))^2 - a^2)^.5 end

function half(rows)
  local far = furthest(rows)
  local A,B = far.left, far.right
  local function project(r) return {row=r, d=x2d(dist(r,A), dist(r,B), far.d)} end
  local lefts,rights = {},{}
  for n,dr in pairs(sort(map(rows, project), lt"d")) do
    row,x = dr.row, dr.x
    row.x = row.x or x
    row.y = row.y or y2d(A, x)
    push( n > #rows/2 and lefts or rights, row) end
  return lefts, rights end

function cluster(rows, min)
  min = min or (#rows)^the.min
  local node = {here=rows}
  if #rows > min then
    local left,right = half(rows)
    node.left  = cluster(left,min)
    node.right = cluster(right,min) end
  return node end 

function tree(node, b4)
  if node then
    b4 = b4 or ""
    print(b4 .. #node.here)
    tree(node.left,  "|.. ".. b4)
    tree(node.right, "|.. ".. b4) end end

local function ok(t)
  local template = {rows={},lo=1,hi=1,cols={},domain="string"}
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

function eg.the()   lib.oo(the) end
function eg.ok()    ok(dofile(the.file)) end
function eg.data()  map(DATA(ok(dofile(the.file))).rows,oo) end
function eg.dist()  
  local m=ok(dofile(the.file))
  local rows = map(m.rows, function(row) return asConstruct(m.lo, m.hi, row) end)
  cluster(rows,1)
end

if lib.required() then return {STATS=STATS} else lib.main(the,eg) end 
