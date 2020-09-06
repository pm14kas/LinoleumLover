contextMenu.screens["forDoor"].categories = {
	{
		value = "Generic",
		types = {
            {
                imageFilename = "images/icons/icon_door.png",
                sign = "Opened",
                trigger = function()
                    levelbox:makeActiveSpawn()
                end
            },
            {
                imageFilename = "images/icons/icon_door.png",
                sign = "Closed",
                trigger = function()
                    levelbox:makeActiveSpawn()
                end
            },
		}
	}
}