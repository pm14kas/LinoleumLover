itemView.screens["mapBlocks"].types = {}

for i = 1, itemView.screens["mapBlocks"].settings.inRow do
	for j = 1, itemView.screens["mapBlocks"].settings.inRow do
		table.insert(itemView.screens["mapBlocks"].types, {
				imageFilename = "images/icons/icon_404.png",
				sign = j .. "x" .. i,
				new = function()
					levelbox:newMap(j, i)
				end
			}
		)
	end
end