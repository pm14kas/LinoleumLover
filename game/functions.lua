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

function encrypt(message, key)
  unicode = require('utf8')
  nKey = ''
  for i = 1, unicode.len(key) do
    nKey = nKey..key:byte(i)
  end
 
  math.randomseed(tonumber(nKey))
 
  tKey = {}
  sNewKey = ''
  for j = 1, unicode.len(message) do
    tKey[j] = ''
    while unicode.len(tKey[j]) ~= unicode.len(message.byte(j)) do
      tKey[j] = tKey[j]..math.random(0, 9)
    end
    sNewKey = sNewKey..unicode.char(bit.bxor(message:byte(j), tKey[j]))
  end
  return sNewKey
end

function splitString(inputstr, sep)
	if sep == nil then
		sep = "_";
	end
	local t={};
	local i=1;
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str;
		i = i + 1;
	end
	return t;
end