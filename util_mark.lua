local max_col, max_row

function recursive_connected_components(b, b_max_col, b_max_row)
	max_col = b_max_col
	max_row = b_max_row
	local lb = negate(b)
	local label = 0
	find_components(lb, label)
	return lb
end

function find_components(lb, label)
	for l = 0, max_col do
		for p = 0, max_row do
			if lb[l][p] == -1 then
				label = label + 1
				search(lb, label, l, p)
			end
		end
	end
end

function search(lb, label, l, p)
	lb[l][p] = label
	local Nset = neighbors(l, p)
	for _, lp in pairs(Nset) do
		if lb[lp[1]][lp[2]] == -1 then
			search(lb, label, lp[1], lp[2])
		end
	end
end

function neighbors(l, p)
	local n = {}
	if l-1 >= 0 then table.insert(n, {l-1, p}) end
	if p-1 >= 0 then table.insert(n, {l, p-1}) end
	if p+1 <= max_row then table.insert(n, {l, p+1}) end
	if l+1 <= max_col then table.insert(n, {l+1, p}) end
	return n
end

function negate(b)
	local lb = {}
	for l = 0, max_col do
		lb[l] = {}
		for p = 0, max_row do
			if b[l][p] then
				lb[l][p] = -1
			else
				lb[l][p] = 0
			end
		end
	end
	return lb
end
