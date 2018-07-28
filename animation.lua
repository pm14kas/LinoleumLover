animation = {
	default = {
		img = 0,
		w = 0,
		h = 0,
		duration = 1,
		time = 0,
		X = 0,
		Y = 0
	},
	a = {}
}

function animation:new(name, params)
	self.a[name] = {}
	if not params then params = {} end
	for k,v in pairs(animation.default) do
		animation:get(name)[k] = params[k] or v
	end
	animation:get(name).quads = {}
	for i = 0, animation:get(name).img:getHeight() - animation:get(name).h, animation:get(name).h do
        for j = 0, animation:get(name).img:getWidth() - animation:get(name).w, animation:get(name).w do
            table.insert(animation:get(name).quads, love.graphics.newQuad(j, i, animation:get(name).w, animation:get(name).h, animation:get(name).img:getDimensions()))
        end
    end
    return self.a[name]
end

function animation:draw(name, X, Y, width, height)
	local width  = width  or animation:get(name).w
	local height = height or animation:get(name).h
    animation:get(name).time = animation:get(name).time + love.timer.getDelta()--1 / 60
    while animation:get(name).time >= animation:get(name).duration do
        animation:get(name).time = animation:get(name).time - animation:get(name).duration
    end
    love.graphics.draw(
    	animation:get(name).img,
    	animation:get(name).quads[math.floor(animation:get(name).time / animation:get(name).duration * #animation:get(name).quads) + 1], 
    	X, 
    	Y,
    	0,
    	width / animation:get(name).w,
    	height / animation:get(name).h
    )
end

function animation:get(name)
	if not animation:exists(name) then
		error("animation " .. name .. " doesn't exist")
	end
	return self.a[name]
end

function animation:exists(name)
	return self.a[name] ~= nil
end