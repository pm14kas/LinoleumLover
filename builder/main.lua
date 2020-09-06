
utf8 = require('utf8')
require "functions"
require "json.json"
require "callbacks"
love.window.setMode(1280, 720, {resizable = false, borderless=false, vsync = true})
w = love.graphics.getWidth()
h = love.graphics.getHeight()

fontSize = getPercent(w, 1.171875)
bigFont = love.graphics.newFont("fonts/joystix monospace.ttf", 100)
buttonFont = love.graphics.newFont("fonts/joystix monospace.ttf", fontSize)
smallFont = love.graphics.newFont("fonts/joystix monospace.ttf", fontSize / 2)
mistralFont = love.graphics.newFont("fonts/mistral.ttf", 1000)
graphikFont = love.graphics.newFont("fonts/GraphikRegular.ttf", 1000)

arrowPic    = love.graphics.newImage("images/arrow.png")
rotatePic   = love.graphics.newImage("images/rotate.png")
pipetkaPic  = love.graphics.newImage("images/pipetka.png")
cracksPic   = love.graphics.newImage("images/cracks.png")
cracksQuad  = love.graphics.newQuad(0, 0, 1, 1, cracksPic:getDimensions())
cracksPic:setWrap("repeat", "repeat")

cursorWE = love.mouse.getSystemCursor("sizewe")
cursorNS = love.mouse.getSystemCursor("sizens")
cursorSt = love.mouse.getSystemCursor("arrow")

debugRenew = ""
debug = ""

layout = {
	w = 1366, 
	h = 768
}
function layout.getX(x)
	return layout.w * x / screen:get("levelbox").w
end
function layout.getY(x)
	return layout.h * x / screen:get("levelbox").h
end


require "screens"
require "button"
local dirs = {
	"screens"
}
for i=1, #dirs, 1 do
	local files = love.filesystem.getDirectoryItems(dirs[i])
	for k, file in ipairs(files) do
		if love.filesystem.getInfo(dirs[i] .. "/" .. file).type == "file" then
			require(dirs[i] .. "/" .. file:sub(1,-5))
		end
	end
end

function love.load()
	cursor = {
		x = 0,
		y = 0,
		inside = function(field)
			return  cursor.x > (field.X or field.x)
				and cursor.x < (field.X or field.x) + (field.width or field.w)
				and cursor.y > (field.Y or field.y)
				and cursor.y < (field.Y or field.y) + (field.height or field.h)
		end
	}
	love.graphics.setBackgroundColor(204 / 255, 153 / 255, 72 / 255)
    levelbox:load()
    for name, s in screen:getAll() do
        if s.load then s:load() end
    end
end
function love.draw()
	cursor.x, cursor.y = love.mouse.getPosition()
	debugRenew = levelbox.scale
	for name, params in screen:orderBy("z") do
		if screen:get(name).draw then screen:show(name) end
	end
	love.graphics.setFont(smallFont)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(love.timer.getFPS() .. "\n" .. debugRenew .. "\n" .. debug, 0, 0)
end
function love.update(dt)
	--levelbox:update(dt)
end