
local PLUGIN = PLUGIN

PLUGIN.name = "Integrated ULX Commands"
PLUGIN.author = "dave"
PLUGIN.description = "Integrates ULX player management functions as commands."
PLUGIN.readme = [[
]]

ix.command.Add("PlyBan", {
	description = "Bans a player. Leave [minutes] blank for permanent.",
	arguments = {ix.type.player, bit.bor(ix.type.text, ix.type.optional), ix.type.text},
	OnRun = function(self, client, target, minutes, reason)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end  

        ulx.ban( client, target, minutes, reason )

		return "Done."

	end
})

ix.command.Add("PlyBanID", {
	description = "Bans a player from their SteamID. Leave [minutes] blank for permanent.",
	arguments = {ix.type.text, bit.bor(ix.type.text, ix.type.optional), ix.type.text},
	OnRun = function(self, client, steamid, minutes, reason)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end  

        ulx.banid( client, target, minutes, reason )

		return "Done."

	end
})

ix.command.Add("PlyKick", {
	description = "Kicks a player.",
	arguments = {ix.type.player, ix.type.text},
	OnRun = function(self, client, target, reason)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end  

        ulx.kick( client, target, reason )

		return "Done."

	end
})

ix.command.Add("PlyKickRandom", {
	description = "Kicks a random player, excluding staff.",
	arguments = {},
	OnRun = function(self, client)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end
		
		local rf = RecipientFilter()
		rf:AddAllPlayers()
		local players = rf:GetPlayers()
		local target = players[math.random(#players)]

        ulx.kick( client, target, "Kicked to free space." )

		return "Done."

	end
})

ix.command.Add("PlySetHealth", {
	description = "Sets a players health.",
	arguments = {ix.type.player, ix.type.text},
	OnRun = function(self, client, target, amount)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end  

        ulx.hp( client, target, amount )

		return "Done."

	end
})

ix.command.Add("PlySlay", {
	description = "Kills a player.",
	arguments = {ix.type.player},
	OnRun = function(self, client, target)

		if (!client:IsAdmin()) then
			return "You can't do that!"
		end  

        ulx.slay( client, target)

		return "Done."

	end
})