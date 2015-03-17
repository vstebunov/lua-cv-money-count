require "gd"
require "util"
require "util_mark"

local filename = arg[1]
if not filename then
	filename = "IMG_20150310_210430"
end

local big_image = gd.createFromJpeg(filename .. ".jpg")
local srcW, srcH = big_image:sizeXY()

local image = gd.createTrueColor(640, 361)
local real_image = gd.createTrueColor(640, 361)

gd.copyResized(image, big_image, 0, 0, 0, 0, 640, 361, srcW, srcH)
gd.copyResized(real_image, big_image, 0, 0, 0, 0, 640, 361, srcW, srcH)

local h = histogram(image)

local max_row, max_col = image:sizeXY()
local thresold = otsu(h, max_row * max_col)

local black = image:colorAllocate(0, 0, 0)
local white = image:colorAllocate(255, 255, 255)
local curc = 0

for x = 0, max_row do
	for y = 0, max_col do
		local c = image:getPixel(x,y)
		local r = image:red(c)
		if r < thresold then
			curc = black
		else
			curc = white	
		end
		image:setPixel(x, y, curc)
	end
end

local b, b_max_col, b_max_row = make_binary(image)
local marked = recursive_connected_components(b, b_max_col, b_max_row)

local squares = square(marked, b_max_col, b_max_row)
local centroids = centroid(marked, b_max_col, b_max_row, squares)

local img = gd.createTrueColor(b_max_col, b_max_row)
local color = {}
local money = {}

for i = 1, 7 do money[i] = {}; money[i].count = 0 end
money[1].value = 0.5
money[2].value = 1
money[3].value = 2
money[4].value = 5
money[5].value = 10
money[6].value = 0.05
money[7].value = 0.1

for k,v in ipairs(squares) do
	table.insert(color, img:colorClosest( math.random(255), math.random(255), math.random(255)))
	if v >= 1200 and v < 1300 then color[k] = img:colorClosest(0,127,0); money[6].count = money[6].count + 1 end
	if v >= 1300 and v < 1400 then color[k] = img:colorClosest(0,255,0); money[1].count = money[1].count + 1 end
	if v >= 1400 and v < 1600 then color[k] = img:colorClosest(0,0,255); money[2].count = money[2].count + 1 end
	if v >= 1700 and v < 1800 then color[k] = img:colorClosest(255,255,0); money[5].count = money[5].count + 1 end
	if v >= 1800 and v < 1930 then color[k] = img:colorClosest(0,255,255); money[3].count = money[3].count + 1 end
	if v >= 2100 and v < 2200 then color[k] = img:colorClosest(255,0,255); money[4].count = money[4].count + 1 end
	if v < 1200 or v > 2200 then color[k] = img:colorClosest(255,0,0) end
end

color[0] = img:colorClosest(0,0,0)
for l = 0, b_max_col do
	for p = 0, b_max_row do
		local pixel = color[marked[l][p]]
		if pixel == 0 then
			pixel = real_image:getPixel(l,p)
		end
		img:setPixel(l, p, pixel)
	end
end

for k,v in ipairs(squares) do
	img:string(gd.FONT_SMALL, centroids[k].c, centroids[k].r, v, color[0])
end

local sum = 0
for _, m in ipairs(money) do
	sum = sum + m.value * m.count
end
local white = img:colorClosestAlpha(255,255,255, 50)
local black = img:colorClosestAlpha(0,0,0, 50)
img:filledRectangle(640 / 2 - 50 , 341 / 2 - 50, 640 / 2 + 150 , 341 / 2 - 30, black)
img:string(gd.FONT_GIANT, 640 / 2 - 50 , 341 / 2 - 50, "Summa:" .. sum .. " rub", white)
img:pngEx(filename .. "_result.png", 6)
print("Summa:", sum, " rub")
