button:get("basicBlocksTrigger").color = button:get("basicBlocksTrigger").colorClicked

itemView.screens["basicBlocks"].types = {
	{
		imageFilename = "images/icons/icon_block.png",
		sign = "Block",
		new = function()
			levelbox:newBlock("Block")
		end
	},--block
	{
		imageFilename = "images/icons/icon_spawn.png",
		sign = "Spawn",
		new = function()
			levelbox:newBlock("Spawn")
		end
	},--spawnPoint
	{
		imageFilename = "images/icons/icon_portal.png",
		sign = "Portal",
		new = function()
			levelbox:newBlock("Portal")
		end
	},--target
	{
		imageFilename = "images/icons/icon_hazard.png",
		sign = "Hazard",
		new = function()
			levelbox:newBlock("Hazard")
		end
	},--hazard
	{
		imageFilename = "images/icons/icon_checkpoint.png",
		sign = "Checkpoint",
		new = function()
			levelbox:newBlock("Checkpoint")
		end
	},--checkpoint
	{
		imageFilename = "images/icons/icon_ai.png",
		sign = "AI",
		new = function()
			levelbox:newBlock("AI")
		end
	},--AI,
    {
        imageFilename = "images/icons/icon_item.png",
        sign = "Item",
        new = function()
            levelbox:newBlock("Item")
        end
    },--item,
    {
        imageFilename = "images/icons/icon_button.png",
        sign = "Button",
        new = function()
            levelbox:newBlock("Button")
        end
    },--button,
    {
        imageFilename = "images/icons/icon_door.png",
        sign = "Door",
        new = function()
            levelbox:newBlock("Door")
        end
    },--button
}