itemView.screens["mapBasicBlocks"].types = {
	{
		imageFilename = "images/icons/icon_link.png",
		sign = "Link",
		new = function()
			levelbox:setLinkmode(true)
		end
	},--link
	{
		imageFilename = "images/icons/icon_unlink.png",
		sign = "Unlink",
		new = function()
			levelbox:setUnLinkmode(true)
		end
	},--unlink
}