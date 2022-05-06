
PLUGIN.name = "Extended Attributes"
PLUGIN.description = "Rehaul of the default helix attribute system."
PLUGIN.author = "dave"
PLUGIN.license = [[
    Copyright © 2022 dave
    
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
    For support, contact .dave#1661

    //COMMANDS
    -- Admin only
        /CharSetAttribute <character target> <string attribute> <int number> - Set a character's attribute.
        /CharSetAttributeModifier <character target> <string attribute> <int number> <string mod. name> - Set a character's attribute modifier.
        /CharGiveAttributePoints <character target> <int number> - Give a character a number of Attribute Points. Set to a negative number to take.
        /AttributeLogs - Shows the all-time logs for attribute/attribute point usage.

    -- Everyone
        /RedeemAttributePoints <string attribute> - Redeem an attribute point in exchange for five points to an attribute.
        /RollAtribute <string attribute> - Roll out of 100 with a modifier depending on your attributes.

]]

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

ix.attribs = ix.attribs or {}
ix.attribs.list = ix.attribs.list or {}

ix.attribs.defaultAttribPoints = {25, 15, 15, 10} -- fill this table with the points you want players to be able to spend at character creation.
-- ^ THERE SHOULD BE ONE FOR EVERY ATTRIBUTE ^

function ix.attribs.Add(id, name, description)
    ix.attribs.list["attrib_"..id] = {
        name = name,
        desc = description
    }

end

function ix.attribs.Remove(id)
    ix.attribs.list["attrib_"..id] = nil

end

ix.attribs.Add("physical", "Physical", "The representation of your physical strength, dexterity, coordination, etc. This may affect your lifting, moving, pushing, and dragging abilities.")
ix.attribs.Add("mental", "Mental", "The representation of your mental abilities such as intelligence, wisdom, and mental fortitude. This may affect your crafting, inventing, and repairing abilities.")
ix.attribs.Add("persona", "Persona", "The representation of your ability to tease out information, call in support, and sometimes, your plain luck. This may affect your ability to torture, interrogate, persuade, plead and resist torture. This may also affect your morale checks.")
ix.attribs.Add("constitution", "Constitution", "The representation of your overall healthiness, your physical fortitude, ability to ward off diseases, survival, etc. This may affect your ability to withstand wounds, stay conscious, and hold your breath.")

/*
   ////////////////////////////////////////////////////////////////////////////
    DO NOT CHANGE ANYTHING UNDER THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!
   ////////////////////////////////////////////////////////////////////////////
*/

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("attrib_roll", {
    	color = Color(155, 111, 176),
    	CanHear = ix.config.Get("chatRange", 280),
    	deadCanChat = true,
    	OnChatAdd = function(self, speaker, value, bAnonymous, data)
            local color = data.color
            local attrib = string.upper(string.sub(data.attrib, 1, 1))..string.sub(data.attrib, 2, #data.attrib)
            local attribVal = data.attribVal
            local success = data.success
    		chat.AddText(data.color, "** ["..success.."] "..speaker:Name().." has rolled ", Color(255,255,255), math.min(value+attribVal, 100), data.color, " out of ", Color(255,255,255), "100", data.color, ". ["..attrib..", "..value.."+"..attribVal.."]")
    	end
    })

end

ix.command.Add("CharSetAttribute", {
	description = "Set a character's attribute.",
	arguments = {ix.type.character, ix.type.string, ix.type.number,},
	superAdminOnly = true,
	OnRun = function(self, client, char, attrib, int)
		if !ix.attribs.list["attrib_"..attrib] then
            return "That is not a valid attribute!"

        end

        local attrib = "attrib_"..attrib

        local newAttrib = int

        if newAttrib > 45 then newAttrib = 45 end
        if newAttrib < 0 then newAttrib = 0 end

        char:SetData(attrib, newAttrib)

        print(attrib, newAttrib)

        ix.attribs.logs[#ix.attribs.logs + 1] = {os.date("%m/%d/%Y - %H:%M "), "ATTRIBUTE.SET ["..attrib.."-->"..int.."]", "["..client:SteamID().."] "..client:SteamName().."-->"..char:GetName()}

        return "Done."

	end
})

function Schema:SetCharAttributeModifier(char, attrib, int)
    local attrib = "attrib_"..attrib.."_modifier"

    local curAttrib = char:GetData(attrib, 0)

    local newAttrib = int

    if newAttrib > 15 then newAttrib = 15 end
    if newAttrib < 0 then newAttrib = 0 end

    char:SetData(attrib, newAttrib)

end

ix.command.Add("CharSetAttributeModifier", {
	description = "Set a character's attribute modifier.",
	arguments = {ix.type.character, ix.type.string, ix.type.number, ix.type.string},
	superAdminOnly = true,
	OnRun = function(self, client, char, attrib, int, name)
		if !ix.attribs.list["attrib_"..attrib] then
            return "That is not a valid attribute!"

        end

        Schema:SetCharAttributeModifier(char, attrib, int)

        ix.attribs.logs[#ix.attribs.logs + 1] = {os.date("%m/%d/%Y - %H:%M "), "ATTRIBUTE.SETMOD ["..attrib.."-->"..int.."] WITH NAME ["..name.."]", "["..client:SteamID().."] "..client:SteamName().."-->"..char:GetName()}

        return "Done."

	end
})

ix.command.Add("CharGiveAttributePoints", {
	description = "Give a character accolades.",
	arguments = {ix.type.character, ix.type.number,},
	superAdminOnly = true,
	OnRun = function(self, client, char, int)
        local oldAco = char:GetData("attrib_accolades", 0)
        local newAco = oldAco + int

        if newAco > 15 then newAco = 15 end
        if newAco < 0 then newAco = 0 end

        char:SetData("attrib_accolades", newAco)

        ix.attribs.logs[#ix.attribs.logs + 1] = {os.date("%m/%d/%Y - %H:%M "), "ATTRIBPOINT.GIVE ["..int.."]", "["..client:SteamID().."] "..client:SteamName().."-->"..char:GetName()}

        return "Done."

	end
})

ix.command.Add("RedeemAttributePoints", {
	description = "Reedem your attribute points for an attribute boost.",
	arguments = {ix.type.string,},
	OnRun = function(self, client, attrib)
        if !ix.attribs.list["attrib_"..attrib] then
            return "That is not a valid attribute!"

        end

        local char = client:GetCharacter()

        local attrib = "attrib_"..attrib

        local curAttrib = char:GetData(attrib, 0)

        local newAttrib = curAttrib + 5

        if newAttrib > 45 then newAttrib = 45 end
        if newAttrib < 0 then newAttrib = 0 end

        char:SetData(attrib, newAttrib)
        
        local oldAco = char:GetData("attrib_accolades", 0)
        local newAco = oldAco - 1

        if newAco > 15 then newAco = 15 end
        if newAco < 0 then newAco = 0 end

        char:SetData("attrib_accolades", newAco)

        return "Done."

	end
})

ix.command.Add("RollAttribute", {
	description = "Roll with a modifier based on your attributes.",
	arguments = {ix.type.string},
	OnRun = function(self, client, attrib)
        if !ix.attribs.list["attrib_"..attrib] then
            return "That is not a valid attribute!"

        end

        local char = client:GetCharacter()

		local value = math.random(0, 100)

        local scaledValue = value + char:GetData("attrib_"..attrib, 0) + char:GetData("attrib_"..attrib.."_modifier", 0)

        local color = Color(100,255,100)

        color = Color(Lerp(scaledValue/100, 175, 100), Lerp(scaledValue/100, 0, 255), Lerp(scaledValue/100, 0, 100))

        local success = "Easy"

        if value < 6 then
            success = "Critical Failure"

        elseif scaledValue >= 100 then
            success = "Routine"

        elseif scaledValue >= 80 then
            success = "Easy"

        elseif scaledValue >= 60 then
            success = "Reasonable"

        elseif scaledValue >= 40 then
            success = "Hard"

        elseif scaledValue >= 20 then
            success = "Difficult"

        elseif scaledValue >= 6 then
            success = "Insane"

        else
            success = "Critical Failure"

        end

		ix.chat.Send(client, "attrib_roll", tostring(value), nil, nil, {
			color = color,
            attrib = attrib,
            attribVal = char:GetData("attrib_"..attrib, 0) + char:GetData("attrib_"..attrib.."_modifier", 0),
            success = success,
		})

		ix.log.Add(client, "roll", scaledValue, 100)

	end
})

ix.command.Add("AttributeLogs", {
	description = "View the logs for attributes.",
	arguments = nil,
	superAdminOnly = true,
	OnRun = function(self, client)
        net.Start("ixAttribLogs")
            net.WriteTable(ix.attribs.logs)
        net.Send(client)

        return "Done."

	end
})

--setup character var
ix.char.RegisterVar("attributes", {
    field = "attributes",
    fieldType = ix.type.text,
    default = {},
    index = 4,
    category = "attributes",
    isLocal = true,
    OnDisplay = function(self, container, payload)
        local attributes = container:Add("Panel")
        attributes:Dock(FILL)

        LocalPlayer().hackyAttributes = {}

        for i, _ in pairs(ix.attribs.list) do
            LocalPlayer().hackyAttributes[i] = {}

        end

        payload.aP = {}

        table.Add(payload.aP, ix.attribs.defaultAttribPoints)

        local infoPanel = attributes:Add("DLabel")
        infoPanel:SetText("")
        infoPanel:SetFont("ixMenuButtonFont")
        infoPanel:Dock(TOP)
        infoPanel:SetTall(infoPanel:GetTall() + 30)
        infoPanel.Paint = function(p,w,h)
            local aP = ""

            for i, v in pairs(payload.aP) do
                local added1 = v and v or ""
                local added2 = v and (i != #payload.aP and ", " or "") or "None"

                local added = added1..added2

                aP = aP..added

            end

            if #payload.aP == 0 then
                aP = "None"
            end

            local text = "Available Points: "..aP

            draw.SimpleText(text, p:GetFont(), 4, h/2, p:GetColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local scrollPanel = attributes:Add("DScrollPanel")
        scrollPanel:Dock(FILL)

        for i, v in pairs(LocalPlayer().hackyAttributes) do
            local name = ix.attribs.list[i].name or i

            local infoPanel = attributes:Add("DButton")
            infoPanel:SetText("")
            infoPanel:SetFont("ixMenuButtonFont")
            infoPanel:Dock(TOP)
            infoPanel:SetTall(infoPanel:GetTall() + 20)
            infoPanel.Paint = function(p,w,h)
                payload.sum = 0
                local v = LocalPlayer().hackyAttributes[i]

                for _, v in pairs(v) do
                    if !v then continue end

                    payload.sum = payload.sum + v

                end

                local text = name.." ("..payload.sum..")"

                draw.SimpleText(text, p:GetFont(), 4, h/2, p:GetColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            infoPanel.DoClick = function()
                local point = payload.aP[1]
                local v = LocalPlayer().hackyAttributes[i]

                if !point then return end
                if #v != 0 then return end

                v[#v+1] = point
                table.remove(payload.aP, 1)

                net.Start("ixSendHackyAttributes")
                    net.WriteTable(LocalPlayer().hackyAttributes)
                net.SendToServer()

            end

        end

        local reset = attributes:Add("DButton")
        reset:SetText("")
        reset:SetFont("ixMenuButtonFont")
        reset:Dock(TOP)
        reset:SetTall(reset:GetTall() + 30)
        reset.Paint = function(p,w,h)
            local text = "Reset Attributes"

            draw.SimpleText(text, p:GetFont(), 4, h/2, p:GetColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        reset.DoClick = function()
            LocalPlayer().hackyAttributes = {}

            for i, _ in pairs(ix.attribs.list) do
                LocalPlayer().hackyAttributes[i] = {}

            end

            net.Start("ixSendHackyAttributes")
                net.WriteTable(LocalPlayer().hackyAttributes)
            net.SendToServer()

            PrintTable(ix.attribs.defaultAttribPoints)

            payload.aP = {}
            table.Add(payload.aP, ix.attribs.defaultAttribPoints)

        end

        scrollPanel:SizeToContents()
        attributes:SizeToContents()
        return attributes

    end,

    OnValidate = function(self, value, payload, client)
        if !client.hackyAttributes then return false, "unknownError" end

        if payload.aP and #payload.aP != 0 then return false, "You haven't spent all of your attribute points!" end

    end,

    OnSet = function(character, value)

        for i, v in pairs(character.player.hackyAttributes) do
            local sum = 0

            for _, k in pairs(v) do
                sum = sum + k

            end

            character:SetData(i, sum)

        end

    end,

    ShouldDisplay = function(self, container, payload)
    	return !IsValid(LocalPlayer().hackyAttributes)

    end

})