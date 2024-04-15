getgenv().AntiSpy = {
	["Sounds"] = {
		["Normal"] = "rbxassetid://4590662766",
		["Warning"] = "rbxassetid://1570162306"
	},
	["Whitelist"] = {},
	["Blacklist"] = {
		["Players"] = {
			
		},
		["Accessories"] = {
			
		}
	},
	["Kick"] = {
		["Enabled"] = true,
		["MaxFlags"] = 3,
		["Delay"] = 2
	},
	["MaxAbsence"] = 60
}

local AntiSpy = loadstring(game:HttpGet('https://raw.githubusercontent.com/Crvstal8100/AntiSpy/main/Main.lua'))()

--[[

THIS IS NOT IMPORTANT:

FUNCTIONS:
function AntiSpy:GetPlayerInfo(player: Player) returns the player info {["Flags"], ["LastCFrame"], ["LastMessage"]}

function AntiSpy:GetAccessories(player: Player) returns all the accessories (table)

function AntiSpy:AddFlag(player: Player, flag: string)

function AntiSpy:RemoveFlag(player: Player, flag: string)

function AntiSpy:ClearFlags(player: Player, flag: string)

]]--
