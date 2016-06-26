local config = {
	key = 'NePSettings',
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..' '..NeP.Info.Name,
	subtitle = 'NerdPack Settings',
	color = NeP.Interface.addonColor,
	width = 250,
	height = 350,
	config = {

		{ type = 'header', text = 'Performance Settings:', align = 'center' },
			{
				type = 'dropdown',
				text = 'Cycle',
				key = 'NeP_Cycle',
				list = {
					{text = 'Standard', key = 'Standard'},
					{text = 'Random', key = 'Random'},
					{text = 'Manual', key = 'Manual'}
				}, 
			    default = 'Standard', 
			    desc = 'Standard (0.5 miliseconds).\nRandom (Between 0.3 and 0.7 miliseconds.\nUse namual to insert your own value.' 
			},
			{type = 'input', text = 'Manual Cycle Time', key = 'MCT', default = 0.5},

		{ type = 'spacer' },{ type = 'rule' },
		{ type = 'header', text = 'Visual Settings:', align = 'center' },
			{type = 'spinner', text = 'Toggle Size', key = 'tSize', default = 40, min = 25, max = 100},

		{ type = 'spacer' },{ type = 'rule' },
		{ type = 'header', text = 'ObjectManager Settings:', align = 'center' },
			{ type = 'checkbox', text = 'Force OM Fallback', key = 'fOM_Fallback', default = false },

	}
}

function NeP.Config.CreateSettingsFrame()
	NeP.Interface.buildGUI(config)
end