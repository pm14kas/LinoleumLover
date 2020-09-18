screen:new("colorPick", {
	X = w / 2,
	Y = h * 3 / 4,
	w = w / 4,
	h = h / 4,
	active = true, 
	draw = true
})

function screen.s.colorPick:show()
	colorPick:draw()
end

colorPick = {
	x = screen:get("colorPick").X,
	y = screen:get("colorPick").Y,
	w = screen:get("colorPick").w,
	h = screen:get("colorPick").h,
	max = 255,
	colorPickBoxW = screen:get("colorPick").w - buttonFont:getWidth("0.00") - 10,
	colorPickBoxH = 20,
	currentColor = {
		r = 0,
		g = 0,
		b = 0
	},
	circle = {
		r = 5,
		x = 0,
		y = 0
	}
}
colorPick.redBox = {
	x = 0,
	y = 0,
	w = colorPick.colorPickBoxW,
	h = colorPick.colorPickBoxH
}
colorPick.rectR = {
	x = colorPick.redBox.x,
	y = colorPick.redBox.y - colorPick.colorPickBoxH / 10,
	w = 1,
	h = colorPick.colorPickBoxH + colorPick.colorPickBoxH / 5
}
colorPick.greenBox = {
	x = colorPick.redBox.x,
	y = colorPick.redBox.y + colorPick.redBox.h + colorPick.colorPickBoxH / 2,
	w = colorPick.colorPickBoxW,
	h = colorPick.colorPickBoxH
}
colorPick.rectG = {
	x = colorPick.greenBox.x,
	y = colorPick.greenBox.y - colorPick.colorPickBoxH / 10,
	w = 1,
	h = colorPick.colorPickBoxH + colorPick.colorPickBoxH / 5
}
colorPick.blueBox = {
	x = colorPick.greenBox.x,
	y = colorPick.greenBox.y + colorPick.greenBox.h + colorPick.colorPickBoxH / 2,
	w = colorPick.colorPickBoxW,
	h = colorPick.colorPickBoxH
}
colorPick.rectB = {
	x = colorPick.blueBox.x,
	y = colorPick.blueBox.y - colorPick.colorPickBoxH / 10,
	w = 1,
	h = colorPick.colorPickBoxH + colorPick.colorPickBoxH / 5
}
colorPick.cell = {
	w = colorPick.redBox.w / colorPick.max,
	h = colorPick.redBox.h / colorPick.max
}

button:add("pickColor",
	{
		X = buttonFont:getWidth ("Apply") * 1.5 / 2,
		Y = screen:get("colorPick").h - buttonFont:getHeight() * 1.5 / 2,
		screen = "colorPick",
		value = "Apply",
		onclick = function()
			if not levelbox:getMapView() then
				if levelbox.state.selectedBlock then
                    levelbox:pushPreviousState()
					levelbox:getSelectedBlock().color = {colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b}
				else
					levelbox:getActiveMap().backgroundColor = {colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b}
				end
			else
				if levelbox.state.selectedMap then
                    levelbox:pushPreviousState()
					levelbox:getMap(levelbox.state.selectedMap).backgroundColor = {colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b}
				end
			end
		end
	}
)

button:add("pipetka",
	{
		X = button:get("pickColor").X + button:get("pickColor").width + button:get("pickColor").height,
		Y = button:get("pickColor").Y + buttonFont:getHeight() * 1.5 / 2,
		width  = button:get("pickColor").height,
		height = button:get("pickColor").height,
		screen = "colorPick",
		value = "",
		backgroundImage = pipetkaPic,
		onclick = function()
			if not levelbox:getMapView() then
				if levelbox.state.selectedBlock then
					colorPick.currentColor = {r = levelbox:getSelectedBlock().color[1], g = levelbox:getSelectedBlock().color[2], b = levelbox:getSelectedBlock().color[3]}
					colorPick.rectR.x = levelbox:getSelectedBlock().color[1] * 255 * colorPick.cell.w
					colorPick.rectG.x = levelbox:getSelectedBlock().color[2] * 255 * colorPick.cell.w
					colorPick.rectB.x = levelbox:getSelectedBlock().color[3] * 255 * colorPick.cell.w
				else
					colorPick.currentColor = {r = levelbox:getActiveMap().backgroundColor[1], g = levelbox:getActiveMap().backgroundColor[2], b = levelbox:getActiveMap().backgroundColor[3]}
					colorPick.rectR.x = levelbox:getActiveMap().backgroundColor[1] * 255 * colorPick.cell.w
					colorPick.rectG.x = levelbox:getActiveMap().backgroundColor[2] * 255 * colorPick.cell.w
					colorPick.rectB.x = levelbox:getActiveMap().backgroundColor[3] * 255 * colorPick.cell.w
				end
            else
                if levelbox.state.selectedMap then
                    colorPick.currentColor = {r = levelbox:getSelectedMap().backgroundColor[1], g = levelbox:getSelectedMap().backgroundColor[2], b = levelbox:getSelectedMap().backgroundColor[3]}
                    colorPick.rectR.x = levelbox:getSelectedMap().backgroundColor[1] * 255 * colorPick.cell.w
                    colorPick.rectG.x = levelbox:getSelectedMap().backgroundColor[2] * 255 * colorPick.cell.w
                    colorPick.rectB.x = levelbox:getSelectedMap().backgroundColor[3] * 255 * colorPick.cell.w
                end
            end
		end
	}
)

function colorPick:draw()
	if not levelbox.grabbedBlock and love.mouse.isDown(1) then
		if  cursor.x > self.redBox.x - 5 and
			cursor.x < self.redBox.x + self.redBox.w + 5 and
			cursor.y > self.redBox.y and
			cursor.y < self.redBox.y + self.redBox.h then
			self.rectR.x = math.min(math.max(0, cursor.x), self.redBox.w)
		end
		if  cursor.x > self.greenBox.x - 5 and
			cursor.x < self.greenBox.x + self.greenBox.w + 5 and
			cursor.y > self.greenBox.y and
			cursor.y < self.greenBox.y + self.greenBox.h then
			self.rectG.x = math.min(math.max(0, cursor.x), self.greenBox.w)
		end
		if  cursor.x > self.blueBox.x - 5 and
			cursor.x < self.blueBox.x + self.blueBox.w + 5 and
			cursor.y > self.blueBox.y and
			cursor.y < self.blueBox.y + self.blueBox.h then
			self.rectB.x = math.min(math.max(0, cursor.x), self.blueBox.w)
		end
	end
	for k = 0, self.max do
		love.graphics.setColor(k / 255, 0, 0)
		love.graphics.rectangle("fill", k * self.cell.w, self.redBox.y, self.cell.w, self.redBox.h)
		if
			self.rectR.x >= k * self.cell.w and
			self.rectR.x <= k * self.cell.w + self.cell.w then
			self.currentColor.r = k / 255
		end
	end
	for k = 0, self.max do
		love.graphics.setColor(0, k / 255, 0)
		love.graphics.rectangle("fill", k * self.cell.w, self.greenBox.y, self.cell.w, self.greenBox.h)
		if
			self.rectG.x >= k * self.cell.w and
			self.rectG.x <= k * self.cell.w + self.cell.w then
			self.currentColor.g = k / 255
		end
	end
	for k = 0, self.max do
		love.graphics.setColor(0, 0, k / 255)
		love.graphics.rectangle("fill", k * self.cell.w, self.blueBox.y, self.cell.w, self.blueBox.h)
		if
			self.rectB.x >= k * self.cell.w and
			self.rectB.x <= k * self.cell.w + self.cell.w then
			self.currentColor.b = k / 255
		end
	end
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line", self.rectR.x, self.rectR.y, self.rectR.w, self.rectR.h)
	love.graphics.rectangle("line", self.rectG.x, self.rectG.y, self.rectG.w, self.rectG.h)
	love.graphics.rectangle("line", self.rectB.x, self.rectB.y, self.rectB.w, self.rectB.h)
	love.graphics.setColor(self.currentColor.r,self.currentColor.g,self.currentColor.b)
	love.graphics.rectangle("fill", 0, colorPick.colorPickBoxH * 4.5, self.w, screen:get("colorPick").h - colorPick.colorPickBoxH * 5 - button:get("pickColor").height)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(buttonFont)
	love.graphics.print(string.format("%.2f", self.currentColor.r), self.redBox.x + self.redBox.w + 10, self.redBox.y)
	love.graphics.print(string.format("%.2f", self.currentColor.b), self.redBox.x + self.redBox.w + 10, self.blueBox.y)
	love.graphics.print(string.format("%.2f", self.currentColor.g), self.redBox.x + self.redBox.w + 10, self.greenBox.y)

end