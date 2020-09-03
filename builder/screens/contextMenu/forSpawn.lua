contextMenu.screens["forSpawn"].categories = {
	{
		value = "Generic",
		types = {
			{
				imageFilename = "images/icons/icon_spawn.png",
				sign = "Active",
				trigger = function()
					levelbox:makeActiveSpawn()
				end
			},
		}
	}
}