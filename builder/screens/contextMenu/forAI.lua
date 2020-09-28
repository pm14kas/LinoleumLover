contextMenu.screens["forAI"].categories = {
	{
		value = "Generic",
		types = {
			{

				imageFilename = "images/icons/icon_ai_enemy.png",
				sign = "enemy",
				trigger = function()
                    levelbox:getSelectedBlock():setType(1, 1)
					levelbox:getSelectedBlock().color = {1, 0, 0}
				end
			},
			{
				imageFilename = "images/icons/icon_ai_friendly.png",
				sign = "friendly",
				trigger = function()
                    levelbox:getSelectedBlock():setType(1, 2)
					levelbox:getSelectedBlock().color = {0, 1, 0}
				end
			},
		}
	}
}