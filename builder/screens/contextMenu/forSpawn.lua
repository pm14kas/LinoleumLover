contextMenu.screens["forSpawn"].categories = {
	{
		value = "Generic",
		types = {
			{
				imageFilename = "images/icons/icon_spawn.png",
				sign = "Active",
				trigger = function()
					levelbox:makeActiveSpawn()
                    button:get("newforSpawn_Active").color = button:get("newforSpawn_Active").colorClicked
				end
			},
		}
	}
}