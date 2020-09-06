contextMenu.screens["forButton"].categories = {
	{
		value = "Link to",
		types = {
			{
				imageFilename = "images/icons/icon_button.png",
				sign = "Active",
				trigger = function()
					levelbox:makeActiveSpawn()
				end
			},
		}
	}
}