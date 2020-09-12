levelboxScreen = screen:new("levelbox", {
    w = w * 3 / 4,
    h = h * 3 / 4,
    -- scaleX = w * 3 / 4 / layout.w,
    -- scaleY = h * 3 / 4 / layout.h,
    active = true,
    draw = true
})
function levelboxScreen:show()
    love.graphics.rectangle("line", 0, 0, math.floor(self.w), math.floor(self.h))
    love.graphics.translate(levelbox.offsetX, levelbox.offsetY)
    love.graphics.scale(levelbox.scale)
    cursor.x = (cursor.x - levelbox.offsetX) / levelbox.scale
    cursor.y = (cursor.y - levelbox.offsetY) / levelbox.scale
    
    levelbox:update()
    levelbox:draw()
    
    cursor.y = (cursor.y * levelbox.scale) + levelbox.offsetY
    cursor.x = (cursor.x * levelbox.scale) + levelbox.offsetX
    love.graphics.scale(1 / levelbox.scale)
    love.graphics.translate(-levelbox.offsetX, -levelbox.offsetY)
end