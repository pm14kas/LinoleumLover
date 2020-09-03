function string.width(text, fontSize)
	return utf8len(tostring(text))*(fontSize*0.835)
end

function tern ( cond , T , F )
	if cond then return T else return F end
end

function degToRad(deg)
	return deg*math.pi/180
end

function getPercent(value, percents)
	return value * percents / 100
end

function topLeft(value)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(value, 0, 0)
end

function bottomLeft(value)
	love.graphics.setColor(255,255,255)
	love.graphics.print(value, y-50, 0)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function customFloor(input, delta)
	local x = math.abs(input)
	local integral, frational = math.modf(x)
	local mult = 10 ^ (tostring(frational):len() - 2)
	return (x * mult * sign(input) - (x * mult) % (delta * mult)) / mult 
end

function customRound(input, delta)
	return customFloor(input + delta / 2, delta)	
end

function sign(x)
	return (x < 0 and -1) or 1
end

function between(a, v, b)
	return a < v and v < b
end

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

function encrypt(message, key)
	nKey = ''
	for i = 1, utf8.len(key) do
		nKey = nKey..key:byte(i)
	end

	math.randomseed(tonumber(nKey))

	tKey = {}
	sNewKey = ''
	for j = 1, utf8.len(message) do
	tKey[j] = ''
	while utf8.len(tKey[j]) ~= utf8.len(message.byte(j)) do
		tKey[j] = tKey[j]..math.random(0, 9)
	end
	sNewKey = sNewKey..utf8.char(bit.bxor(message:byte(j), tKey[j]))
	end
	return sNewKey
end

function inArray(val, tab)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function arrayKeys(array)
	local keys = {}
	for k, v in pairs(array) do
		table.insert(keys, k)
	end
	return keys
end