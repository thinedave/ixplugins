
local PLUGIN = PLUGIN

if !file.Exists("extended_attributes_log.json", "DATA") then
    ix.attribs.logs = ix.attribs.logs or {}
    
    file.Write("extended_attributes_log.json", util.TableToJSON(ix.attribs.logs))

else
    ix.attribs.logs = ix.attribs.logs or util.JSONToTable(file.Read("extended_attributes_log.json"))

end

util.AddNetworkString("ixAttribLogs")

function PLUGIN:OnCharacterCreated(client, char)
    char:SetData("attrib_accolades", 0)
    char:SetData("attrib_constitution_modifier", 0)
    --char:SetData("attrib_mental", 0)
    char:SetData("attrib_mental_modifier", 0)
    --char:SetData("attrib_persona", 0)
    char:SetData("attrib_persona_modifier", 0)
    --char:SetData("attrib_physical", 0)
    char:SetData("attrib_physical_modifier", 0)

    char:SetAttributes("attributes", {nil})

end

util.AddNetworkString("ixSendHackyAttributes")

net.Receive("ixSendHackyAttributes", function(_, client)
    local tbl = net.ReadTable()
    local shouldReturn = true

    for i, v in pairs(tbl) do
        if i != "attrib_physical" and i != "attrib_persona" and i != "attrib_mental" and i != "attrib_constitution" then continue end
        local shouldReturn2 = true

        for _, k in pairs(v) do
            if k > 25 then continue end

            shouldReturn2 = false

        end

        if shouldReturn2 then return end

        shouldReturn = false

    end

    if shouldReturn then return end

    client.hackyAttributes = tbl

    --print(client.hackyAttributes)

end)