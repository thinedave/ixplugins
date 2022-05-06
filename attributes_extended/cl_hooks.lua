
local PLUGIN = PLUGIN

function PLUGIN:CanCreateCharacterInfo(suppress)
    suppress.attributes = true

end

function PLUGIN:CreateCharacterInfo(panel)
	panel.attribs = {}

	panel.accolades = panel:Add("ixListRow")
	panel.accolades:SetList(panel.list)
	panel.accolades:Dock(TOP)
	panel.accolades:SizeToContents()

	for i, _ in pairs(ix.attribs.list) do
		panel.attribs[i] = panel:Add("ixListRow")
		panel.attribs[i]:SetList(panel.list)
		panel.attribs[i]:Dock(TOP)
		panel.attribs[i]:SizeToContents()

	end

end

function PLUGIN:UpdateCharacterInfo(panel, char)
	for i, v in pairs(panel.attribs) do
		if (panel.attribs[i]) then
			local modifier = ""
       		local mod = char:GetData(i.."_modifier", 0)

       		if mod > 0 then
       		    modifier = "["..mod.."]"

       		end

			panel.attribs[i]:SetLabelText(ix.attribs.list[i].name or i)
			panel.attribs[i]:SetText(char:GetData(i, 0).." "..modifier)

			panel.attribs[i]:SizeToContents()
    	    panel.attribs[i]:SetHelixTooltip(function(tooltip)
				local title = tooltip:AddRow("name")
				title:SetImportant()
				title:SetText(ix.attribs.list[i].name or i)
				title:SizeToContents()

				local description = tooltip:AddRow("description")
				description:SetText(ix.attribs.list[i].desc or i.."_description")
				description:SizeToContents()
			end)
		end
		
	end

    if (panel.accolades) then
		panel.accolades:SetLabelText(L("attrib_accolades"))
		panel.accolades:SetText(char:GetData("attrib_accolades", 0))

		panel.accolades:SizeToContents()
        panel.accolades:SetHelixTooltip(function(tooltip)
			local title = tooltip:AddRow("name")
			title:SetImportant()
			title:SetText(L("attrib_accolades"))
			title:SizeToContents()

			local description = tooltip:AddRow("description")
			description:SetText(L("attrib_accolades_description"))
			description:SizeToContents()
		end)
	end

end

net.Receive("ixAttribLogs", function()
    local logPanel = vgui.Create("DFrame")
    logPanel:SetSize(ScrW() / 3, ScrH() / 1.5)
    logPanel:SetPos((ScrW() / 1.2) - (ScrW() / 2), (ScrH()/1.2) - (ScrH() / 1.5))
    logPanel:MakePopup()
    logPanel:SetTitle("Attribute Logs")

    scrollPanel = logPanel:Add("DListView")
    scrollPanel:Dock(FILL)
    
    scrollPanel:AddColumn("Date")
    scrollPanel:AddColumn("Action")
    scrollPanel:AddColumn("Players")

    for _, v in pairs(net.ReadTable()) do
        local text = scrollPanel:AddLine(v[1], v[2], v[3])

    end

end)