require "gd"

function histogram(image)
	local max_row, max_col = image:sizeXY()
	local histogram = {}
	for i = 0, 255 do
		histogram[i] = 0
	end

	for l = 0, max_row do
		for r = 0, max_col do
			local color = image:getPixel(l,r)
			--local r, g, b = image:red(color), image:green(color), image:blue(color)
			--local lum = math.floor(0.3 * r + 0.59 * g + 0.11 * b)
			local r = image:red(color)
			histogram[r] = histogram[r] + 1
		end
	end

	return histogram
end

function make_binary(image)
	local binary = {}
	local max_col, max_row = image:sizeXY()
	local black = image:colorClosest(0, 0, 0)
	local white = image:colorClosest(255, 255, 255)
	if black == white then
		white = 0
	end
	for x = 0, max_col do
		binary[x] = {}
		for y = 0, max_row do
			local c = image:getPixel(x,y)
			if c == white then
				binary[x][y] = true
			elseif c == black then
				binary[x][y] = false
			else
				print(x, y, c, black, white)
				assert(false)
			end
		end
	end
	return binary, max_col, max_row
end

function make_pic(bin, max_col, max_row, filename)
	local image = gd.create(max_col, max_row)
	local black = image:colorAllocate(0, 0, 0)
	local white = image:colorAllocate(255, 255, 255)
	for x = 0, max_col do
		for y = 0, max_row do
			if bin[x][y] then
				image:setPixel(x, y, white)
			else
				image:setPixel(x, y, black)
			end
		end
	end
	image:png(filename)
end

function erosion(binary_image, max_col, max_row, struct_elem, smax_col, smax_row)
	local result = {}
	for i = 0, max_col do
		result[i] = {} 
		for j = 0, max_row do
			result[i][j] = false
		end
	end
	local cx = math.floor(smax_col / 2)
	local cy = math.floor(smax_row / 2)
	for i = 0, max_col do
		--print(i)
		for j = 0, max_row do
			if i - cx >= 0 and j - cy >= 0 and i + cx < max_col and j + cy < max_row then
				local is_equal = true 
				for m = -1 * cx, 1 * cx do
					for n = -1 * cy, 1 * cy do
						if not struct_elem[cx + m] then
							print(cx + m, cx, m, smax_col)
						end
						if not binary_image[i + m] or binary_image[i + m][j + n] ~= struct_elem[cx + m][cy + n] then
							is_equal = false 
							break
						end
					end
					if not is_equal then
						break
					end
				end
				if is_equal then
					result[i][j] = result[i][j] or struct_elem[cx][cy]
				end
			end
		end
	end
	return result
end

function square(marked_image, max_col, max_row)
	local result = {}
	for l = 0, max_col do
		for p = 0, max_row do
			if marked_image[l][p] ~= 0 then
				if (not result[ marked_image[l][p]]) then 
					result[ marked_image[l][p]] = 1
				else
					result[ marked_image[l][p] ] = result[ marked_image[l][p] ] + 1
				end
			end
		end
	end
	return result
end

function centroid(marked_image, max_col, max_row, squares)
	local result = {}
	for i,s in ipairs(squares) do
		local sum_r = 0
		local sum_c = 0
		for l = 0, max_col do
			for p = 0, max_row do
				if marked_image[l][p] == i then
					sum_r = sum_r + p
				end
			end
		end
		for p = 0, max_row do
			for l = 0, max_col do
				if marked_image[l][p] == i then
					sum_c = sum_c + l
				end
			end
		end
		result[i] = {}
		result[i].r = math.floor((1 / s) * sum_r)
		result[i].c = math.floor((1 / s) * sum_c)
	end
	return result
end

function otsu(histogram, total)
	local sum = 0
	for i = 1, 255 do
		sum = sum + i * histogram[i]
	end
	local sumB = 0
	local wB = 0
	local wF = 0
	local mB, mF
	local max = 0.0
	local between = 0.0
	local thresold1 = 0.0
	local thresold2 = 0.0
	for i = 0, 255 do
		wB = wB + histogram[i]
		if (wB ~= 0) then
			wF = total - wB
			if (wF == 0) then
				break
			end
			sumB = sumB + i * histogram[i]
			mB = sumB / wB
			mF = (sum - sumB) / wF
			between = wB * wF * math.pow(mB - mF, 2)
			if (between >= max) then
				thresold1 = i
				if (between > max) then
					thresold2 = i
				end
				max = between
			end

		end
	end
	return (thresold1 + thresold2) / 2.0
end
