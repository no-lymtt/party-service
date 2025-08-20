local PartyService = {}

-- Functions
--Iterates through a page object
local function IterPageItems(pages) -- From the FriendPages docs
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

--Constructs a new party with the specified parameters
function PartyService.new(
	Owner: Player,
	MaxPlayers: number,
	FriendsOnly: boolean
)
	
	assert(Owner, "Parameter Owner expected, recieved nil")
	
	local self = setmetatable({}, {__index = PartyService})
	self.Owner = Owner
	self.MaxPlayers = MaxPlayers or 4
	self.Players = {Owner}
	self.FriendsOnly = FriendsOnly or false
	self.TeleportData = {}
	Owner:AddTag("InParty")
	
	-- Connections
	local NewOwner: RBXScriptConnection
	
	--Disband the current party
	function self:Disband()
		NewOwner:Disconnect()
		for i, player in self.Players do
			player:RemoveTag("InParty")
		end
		self:Destroy()
	end

	--Teleport players to the specified place
	function self:Teleport(PlaceId: number)
		local ServerId = game:GetService("TeleportService"):ReserveServer(PlaceId)
		game:GetService("TeleportService"):TeleportToPrivateServer(PlaceId, ServerId, self.Players, nil, { "FROMPARTYSERVICE" , Owner = self.Owner, Players = self.Players, OtherData = self.TeleportData })
	end
	
	--Add a player to the current party. Returns true if it successfully adds the player to the party, otherwise returns false and a string.
	function self:AddPlayer(player: Player)
		if player:HasTag("InParty") then return false, "InParty" end
		
		if #self.Players >= self.MaxPlayers then return false, "MaxPlayers" end
		
		if self.FriendsOnly == true then
			local IsFriend = false
			for i, friend in IterPageItems(game.Players:GetFriendsAsync(self.Owner.UserId)) do
				if friend.Id == player.UserId then

				end
			end
			if not IsFriend then return false, "NotFriend" end
		end
		
		table.insert(self.Players, player)
		player:AddTag("InParty")
		return true
	end
		
		
	-- Connections pt.2
	NewOwner = game.Players.PlayerRemoving:Connect(function(plr)
		if plr == self.Owner then
			if #self.Players > 1 then
				local PlayersTable = {self.Players}
				table.remove(PlayersTable, table.find(PlayersTable, self.Owner))
				self.Owner = PlayersTable[1]
			else
				self:Disband()
			end
		end
		
		if table.find(self.Players, plr) then
			table.remove(self.Players, table.find(self.Players, plr))
		end
	end)
	
	return self
end

return PartyService
