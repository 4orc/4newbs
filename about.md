
<img align=right width=400 src='etc/img/about.jpg'>

# About.lua
Extract stats from csv file (assumes row1 has column names).

```css

about.lua : summarize a table
(c)2022, Tim Menzies <timm@ieee.org>, BSD-2 

USAGE:   about.lua  [OPTIONS]

OPTIONS:
  -d  --dump  on crash, print stackdump = false
  -f  --file  csv file                  = ../data/auto93.csv
  -g  --go    start-up action           = data
  -h  --help  show help                 = false

```
## NUM	
Summarizes a stream of numbers	

<dl>
<dt><b> NUM:new(  n:num?, s:str?) &rArr;  NUM </b></dt><dd>   constructor; optionally for column `n` named `s`  </dd>
<dt><b> NUM:add(n:num) &rArr;  NUM </b></dt><dd>  add `n`, update min,max,standard deviation </dd>
<dt><b> NUM:mid(x) &rArr;  n </b></dt><dd>  return mean </dd>
<dt><b> NUM:div(x) &rArr;  n </b></dt><dd>  return standard deviation </dd>
</dl>

## SYM	
## COLS	
## DATA	

<dl>
<dt><b> DATA:new(src:str) &rArr;  DATA </b></dt><dd>  `src` is either (a) a file name string or (b) list or rows </dd>
</dl>

## Start-up	
