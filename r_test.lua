require "util"
require "util_mark"

local b = {1, 0, 0, 0, 1,  1, 0, 1, 0 ,0,  1,1,1,0,0, 0,0,1,1,1}
local b_col = 5
local b_row = 4

local s = {{0,0,0}, {1,1,0}, {0,0,0}}
local s_col = 3
local s_row = 1

local result = erosion(b, b_col, b_row, s, s_col, s_row)
print(result)
