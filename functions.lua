function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read("*a") -- *a or *all reads the whole file
    file:close()
    return content
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function math.sign(x)
	return x > 0 and 1 or x < 0 and -1 or 0;
end

function math.between(x, a, b)
	if x > a and x < b then return true else return false end;
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getPercent(value, percents)
	return value * percents / 100
end

function tern ( cond , T , F )
    if cond then return T else return F end
end