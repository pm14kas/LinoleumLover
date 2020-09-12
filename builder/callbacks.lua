click = {x = 0, y = 0}
function click:insideButton(name)
	return  self.x > button:get(name).X + screen:get(button:get(name).screen).X + screen:get(button:get(name).screen).offsetX
		and self.x < button:get(name).X + screen:get(button:get(name).screen).X + screen:get(button:get(name).screen).offsetX + button:get(name).width
		and self.y > button:get(name).Y + screen:get(button:get(name).screen).Y + screen:get(button:get(name).screen).offsetY
		and self.y < button:get(name).Y + screen:get(button:get(name).screen).Y + screen:get(button:get(name).screen).offsetY + button:get(name).height
end

function click:inside(field)
	return  self.x > (field.X or field.x)
		and self.x < (field.X or field.x) + (field.width or field.w)
		and self.y > (field.Y or field.y)
		and self.y < (field.Y or field.y) + (field.height or field.h)
end

function love.mousepressed(clickX, clickY, buttonClick, istouch)
	click.x = clickX
	click.y = clickY
	local activeScreens = {}
	local buttonClicked = false
	for name, s in pairs(screen.s) do
		if s.active then
			table.insert(activeScreens, name)
		end
	end
	if buttonClick == 1 then
		levelbox.grabbedBlock = nil
		levelbox.grabbedMap = nil
		for _, s in ipairs(activeScreens) do
			if click:inside(screen:get(s)) then
				for k,b in pairs(screen:get(s).buttons) do
					if button:get(b).active and click:insideButton(b) then
						button:click(b)
						return
					end
				end
			end
		end
		if 	click:inside(screen:get("levelbox")) then 
			click.x = click.x - levelbox.offsetX
			click.x = click.x / levelbox.scale
			click.y = click.y - levelbox.offsetY
			click.y = click.y / levelbox.scale
			if levelbox:getMapView() then
				local mapClicked = false
				for k, map in levelbox:orderBy("z", levelbox.state.maps) do
					if	click.x > map.x - map.border / levelbox.scale - map.borderW / levelbox.scale / 2 and
						click.x < map.x + map.w + map.border / levelbox.scale + map.borderW / levelbox.scale / 2 and
						click.y > map.y - map.border / levelbox.scale - map.borderW / levelbox.scale / 2 and
						click.y < map.y + map.h + map.border / levelbox.scale + map.borderW / levelbox.scale / 2 then
						if levelbox:getLinkmode() then
							for klink, spawn in pairs(map.spawns) do
								if	click.x > (spawn.x) * map.w / levelbox.w / map.sizeX + map.x and
									click.x < (spawn.x + spawn.w) * map.w / levelbox.w / map.sizeX + map.x and
									click.y > (spawn.y) * map.h / levelbox.h / map.sizeY + map.y and
									click.y < (spawn.y + spawn.h) * map.h / levelbox.h / map.sizeY + map.y then
									if levelbox.linkingTarget then
										levelbox:link({spawn = klink, map = k}, levelbox.linkingTarget)
									elseif not levelbox.linkingSpawn then
										levelbox.linkingSpawn = {spawn = klink, map = k}
									end
									mapClicked = true
								end
							end
							for klink, target in pairs(map.targets) do
								if	click.x > (target.x) * map.w / levelbox.w / map.sizeX + map.x and
									click.x < (target.x + target.w) * map.w / levelbox.w / map.sizeX + map.x and
									click.y > (target.y) * map.h / levelbox.h / map.sizeY + map.y and
									click.y < (target.y + target.h) * map.h / levelbox.h / map.sizeY + map.y then
									if levelbox.linkingSpawn then
										levelbox:link(levelbox.linkingSpawn, {target = klink, map = k})
									elseif not levelbox.linkingTarget then
										levelbox.linkingTarget = {target = klink, map = k}
									end
									mapClicked = true
								end
							end
						elseif levelbox:getUnLinkmode() then
							for klink, spawn in pairs(map.spawns) do
								if	click.x > (spawn.x) * map.w / levelbox.w / map.sizeX + map.x and
									click.x < (spawn.x + spawn.w) * map.w / levelbox.w / map.sizeX + map.x and
									click.y > (spawn.y) * map.h / levelbox.h / map.sizeY + map.y and
									click.y < (spawn.y + spawn.h) * map.h / levelbox.h / map.sizeY + map.y then
									if spawn.link ~= "" then
										levelbox.linkingTarget = levelbox:getLink(spawn.link).target
										levelbox:deletelink(spawn.link)
										levelbox:setLinkmode(true)
									else
										levelbox:setUnLinkmode(false) 
									end
									mapClicked = true
								end
							end
							for klink, target in pairs(map.targets) do
								if	click.x > (target.x) * map.w / levelbox.w / map.sizeX + map.x and
									click.x < (target.x + target.w) * map.w / levelbox.w / map.sizeX + map.x and
									click.y > (target.y) * map.h / levelbox.h / map.sizeY + map.y and
									click.y < (target.y + target.h) * map.h / levelbox.h / map.sizeY + map.y then
									if target.link ~= "" then
										levelbox.linkingSpawn = levelbox:getLink(target.link).spawn
										levelbox:deletelink(target.link)
										levelbox:setLinkmode(true)
									else
										levelbox:setUnLinkmode(false) 
									end
									mapClicked = true
								end
							end
						else
							mapClicked = true
                            levelbox:selectMap(k)
							levelbox.grabbedMap = k
							levelbox:getMap(k).grabbedX = click.x
							levelbox:getMap(k).grabbedY = click.y
						end
					end
				end
				if not mapClicked or love.keyboard.isDown("space") then
                    levelbox:selectMap()
					levelbox:setLinkmode(false)
					levelbox:setUnLinkmode(false)
					levelbox.moving = true
					levelbox.grabbedX = click.x * levelbox.scale + levelbox.offsetX
					levelbox.grabbedY = click.y * levelbox.scale + levelbox.offsetY
				end
			else
				local blockClicked
				for k, block in levelbox:orderBy("z", levelbox:getActiveMap().blocks) do
					if	click.x > block.x - block.border / levelbox.scale - block.borderW / levelbox.scale / 2 and
						click.x < block.x + block.w + block.border / levelbox.scale + block.borderW / levelbox.scale / 2 and
						click.y > block.y - block.border / levelbox.scale - block.borderW / levelbox.scale / 2 and
						click.y < block.y + block.h + block.border / levelbox.scale + block.borderW / levelbox.scale / 2 then
						blockClicked = true
						levelbox:selectBlock(k)
						contextMenu:setActiveScreen("for" .. levelbox:getSelectedBlock().type)
						levelbox.grabbedBlock = k
						levelbox:getBlock(k).grabbedX = click.x
						levelbox:getBlock(k).grabbedY = click.y
					end
				end
				if not blockClicked or love.keyboard.isDown("space") then
					levelbox:selectBlock(nil)
					levelbox:setLinkmode(false)
					levelbox:setUnLinkmode(false)
					contextMenu:setActiveScreen()
					levelbox.moving = true
					levelbox.grabbedX = click.x * levelbox.scale + levelbox.offsetX
					levelbox.grabbedY = click.y * levelbox.scale + levelbox.offsetY
				end
			end
		end
		click.x = click.x * levelbox.scale
		click.x = click.x + levelbox.offsetX
		click.y = click.y * levelbox.scale
		click.y = click.y + levelbox.offsetY
	end
end
function love.mousereleased(clickX, clickY, buttonClick, istouch)
	levelbox.moving = false
	local activeScreens = {}
	for name, s in pairs(screen.s) do
		if s.active then
			table.insert(activeScreens, name)
		end
	end
	if buttonClick == 1 then
		for _, s in ipairs(activeScreens) do
			for k, b in pairs(screen:get(s).buttons) do
				if button:get(b).active and click:insideButton(b) then
					button:release(b)
					return
				end
			end
		end
	end
end

function love.wheelmoved(x, y)
	cursor.x, cursor.y = love.mouse.getPosition()
	if cursor.inside(screen:get("levelbox")) then
		local prevScale = levelbox.scale
		levelbox.scale = math.min(math.max(levelbox.scaleMin, levelbox.scale * math.exp(y * levelbox.scaleStep * (love.keyboard.isDown("lshift") and levelbox.scaleMult or 1))), levelbox.scaleMax)
		cursor.x = cursor.x - levelbox.offsetX
		cursor.y = cursor.y - levelbox.offsetY
		levelbox.offsetX = math.min(math.max(-(levelbox.w * levelbox.scale - levelbox.w * levelbox.scaleMin), levelbox.offsetX + (cursor.x - cursor.x * levelbox.scale / prevScale)), 0)
		levelbox.offsetY = math.min(math.max(-(levelbox.h * levelbox.scale - levelbox.h * levelbox.scaleMin), levelbox.offsetY + (cursor.y - cursor.y * levelbox.scale / prevScale)), 0)
		cursor.y = cursor.y + levelbox.offsetY
		cursor.x = cursor.x + levelbox.offsetX
	end
	for kscreen, screenContext in pairs(contextMenu.screens) do
		if cursor.inside(screenContext) then
			screenContext.offsetY = math.min(math.max(-screenContext.maxY + screenContext.h, screenContext.offsetY + y * 10 * (love.keyboard.isDown("lshift") and levelbox.scaleMult or 1)), 0)
			screenContext.offsetX = math.min(math.max(-screenContext.maxX + screenContext.h, screenContext.offsetX + x * 10 * (love.keyboard.isDown("lshift") and levelbox.scaleMult or 1)), 0)
		end
	end
end

keyboard = {
	up = {
		hold = true,
		onpress = function()
			button:get("toUp").onclick()
		end
	},
	left = {
		hold = true,
		onpress = function()
			button:get("toLeft").onclick()
		end
	},
	right = {
		hold = true,
		onpress = function()
			button:get("toRight").onclick()
		end
	},
	down = {
		hold = true,
		onpress = function()
			button:get("toDown").onclick()
		end
	},
	delete = {
		hold = false,
		onpress = function()
			button:get("deleteBlock").onclick()
		end
	},
	["return"] = {
		hold = false,
		onpress = function()
			button:get("newBlock").onclick()
		end
	},
	backspace = {
		hold = true,
		onpress = function()
			if levelbox.state.selectedBlock then
				if levelbox:getSelectedBlock().type == "Text" then
					local byteoffset = utf8.offset(levelbox:getSelectedBlock().value, -1)
		
					if byteoffset then
						levelbox:getSelectedBlock().value = string.sub(levelbox:getSelectedBlock().value, 1, byteoffset - 1)
					end
				end
			end
		end
	},
	undo = {
		hold = false,
		onpress = function()
		end
	},
}

function love.keypressed(keypressed, scancode, isrepeat)
	for keyCode, key in pairs(keyboard) do
		if keyCode == keypressed then
			love.keyboard.setKeyRepeat(key.hold)
			key.onpress()
		end
	end
end

function love.textinput(text)
	if levelbox.state.selectedBlock then
		if levelbox:getSelectedBlock().type == "Text" then
			levelbox:getSelectedBlock().value = levelbox:getSelectedBlock().value .. text
		end
	end
end