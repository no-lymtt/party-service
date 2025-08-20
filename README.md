# Party Service
A lightweight party manager built in luau. I'm probably not gonna maintain this as this was built in around an hour just to help me practice my OOP.
## Constructors:
`PartyService.new(Owner: Player)`
## Methods:
`Party:Disband()` Disbands the party

`Party:Teleport(PlaceId: number)` Teleports everyone in the party into a reserved server with the given PlaceId

`Party:AddPlayer(player: Player)` Add a player to the party. Returns true if it successfully adds the player to the party, otherwise returns false and a string.
