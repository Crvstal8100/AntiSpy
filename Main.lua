local AntiSpy = {}
local Players = {}

local SimpleNotification = require(game.ReplicatedStorage.SimpleNotification)
local UI = SimpleNotification:Create("SimpleNotify")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultChatSystemChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
local OnMessageDoneFiltering = DefaultChatSystemChatEvents:WaitForChild("OnMessageDoneFiltering")

local function Setup(player)
	if not Players[player.UserId] then
		Players[player.UserId] = {
			["LastCFrame"] = {},
			["LastMessage"] = {},
			["Flags"] = {}
		}
	end
end

local function Remove(player)
	if Players[player.UserId] then
		Players[player.UserId] = nil
	end
end

local function GetFriendsInServer()
	local Friends = {}
	
	for i, v in pairs(game:GetService("Players"):GetPlayers()) do
		if v:IsFriendsWith(game:GetService("Players").LocalPlayer.UserId) then
			table.insert(Friends, v)
		end
	end
	
	return Friends
end

local function CheckBlacklist(check)
	local Found = false
	
	if check:IsA("Player") then
		if table.find(getgenv().AntiSpy["Blacklist"]["Players"], check.UserId) then
			Found = true
		end
	elseif check:IsA("Accessory") then
		if table.find(getgenv().AntiSpy["Blacklist"]["Accessories"], check.Name) then
			Found = true
		end
	end

	return Found
end

local function CheckWhitelist(player)
	local Found = false

	if table.find(getgenv().AntiSpy["Whitelist"], player.UserId) then
		Found = true
	end

	return Found
end

local function CheckMention(Str)
	local Mentioned = false
	
	local Split = string.split(Str, " ")
	
	if Str:lower() == game:GetService("Players").LocalPlayer.Name:lower() or Str:lower() == game:GetService("Players").LocalPlayer.DisplayName:lower() or Str:lower() == tostring(game:GetService("Players").LocalPlayer.UserId):lower() then
		Mentioned = true
	else
		if #Split ~= 1 then
			for i, v in pairs(Split) do
				if v:lower() == game:GetService("Players").LocalPlayer.Name:lower() or v:lower() == game:GetService("Players").LocalPlayer.DisplayName:lower() or v:lower() == tostring(game:GetService("Players").LocalPlayer.UserId):lower() then
					Mentioned = true
				elseif string.find(v:lower(), (game:GetService("Players").LocalPlayer.Name:lower()):sub(1, #v)) or string.find(v:lower(), (game:GetService("Players").LocalPlayer.DisplayName:lower()):sub(1, #v)) or string.find(v:lower(), (tostring(game:GetService("Players").LocalPlayer.UserId):lower()):sub(1, #v)) then
					Mentioned = true
				end
			end
		else
			if string.find(Str:lower(), (game:GetService("Players").LocalPlayer.Name:lower()):sub(1, #Str)) or string.find(Str:lower(), (game:GetService("Players").LocalPlayer.DisplayName:lower()):sub(1, #Str)) or string.find(Str:lower(), (tostring(game:GetService("Players").LocalPlayer.UserId):lower()):sub(1, #Str)) then
				Mentioned = true
			end
		end
	end
	
	return Mentioned
end

local function GetTime(Time)
	return tick() - Time
end

local function RoundCFrame(cframe)
	local cframeTable = table.pack(cframe:GetComponents())
	
	for i, v in pairs(cframeTable) do
		cframeTable[i] = math.round(v)
	end
	
	local roundedCFrame = CFrame.new(table.unpack(cframeTable))
	
	return roundedCFrame
end

local function CheckActivity(PlayerInfo)
	local Activity = true
	
	if GetTime(PlayerInfo["LastCFrame"]["Time"]) >= getgenv().AntiSpy["MaxAbsence"] and GetTime(PlayerInfo["LastMessage"]["Time"]) >= getgenv().AntiSpy["MaxAbsence"] then
		Activity = false
	end
	
	return Activity
end

function AntiSpy:GetPlayerInfo(player)
	if Players[player.UserId] then
		return Players[player.UserId]
	end
end

function AntiSpy:GetAccessories(player)
	local Accessories = {}
	
	if player.Character then
		for i, v in pairs(player.Character:GetChildren()) do
			if v:IsA("Accessory") then
				table.insert(Accessories, v)
			end
		end
	end
	
	return Accessories
end

function AntiSpy:AddFlag(player, flag)
	if Players[player.UserId] and Players[player.UserId]["Flags"] then
		if not table.find(Players[player.UserId]["Flags"], flag) then
			table.insert(Players[player.UserId]["Flags"], flag)
		end
	end
end

function AntiSpy:RemoveFlag(player, flag)
	if Players[player.UserId] and Players[player.UserId]["Flags"] then
		for i, v in pairs(Players[player.UserId]["Flags"]) do
			if v == flag then
				Players[player.UserId]["Flags"][i] = nil
			end
		end
	end
end

function AntiSpy:ClearFlags(player, flag)
	if Players[player.UserId] and Players[player.UserId]["Flags"] then
		for i, v in pairs(Players[player.UserId]["Flags"]) do
			Players[player.UserId]["Flags"][i] = nil
		end
	end
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
	Setup(v)
	
	local Friends = GetFriendsInServer()
	local OtherPlayers = (#game:GetService("Players"):GetPlayers() - #Friends) - 1
	
	if #Friends > 0 then
		if #Friends > 1 then
			if OtherPlayers > 0 then
				if OtherPlayers > 1 then
					UI:Notify(string.format("There are <b>%d</b> friends and <b>%d</b> other players in your server!", #Friends, OtherPlayers), 5, getgenv().AntiSpy["Sounds"]["Normal"])
				else
					UI:Notify(string.format("There are <b>%d</b> friends and <b>%d</b> other player in your server!", #Friends, OtherPlayers), 5, getgenv().AntiSpy["Sounds"]["Normal"])
				end
			else
				UI:Notify(string.format('There are <b>%d</b> friends and <font color="rgb(255, 74, 74)">no</font> other players in your server!', #Friends), 5, getgenv().AntiSpy["Sounds"]["Normal"])
			end
		else
			if OtherPlayers > 0 then
				if OtherPlayers > 1 then
					UI:Notify(string.format("There is <b>%d</b> friend and <b>%d</b> other players in your server!", #Friends, OtherPlayers), 5, getgenv().AntiSpy["Sounds"]["Normal"])
				end
			else
				UI:Notify(string.format('There is <b>%d</b> friend and <font color="rgb(255, 74, 74)">no</font> other players in your server!', #Friends), 5, getgenv().AntiSpy["Sounds"]["Normal"])
			end
		end
	else
		if OtherPlayers > 0 then
			if OtherPlayers > 1 then
				UI:Notify(string.format('There are <font color="rgb(255, 74, 74)">no</font> friends and <b>%d</b> other players in your server!', OtherPlayers), 5, getgenv().AntiSpy["Sounds"]["Normal"])
			else
				UI:Notify(string.format('There are <font color="rgb(255, 74, 74)">no</font> friends and <b>%d</b> other player in your server!', OtherPlayers), 5, getgenv().AntiSpy["Sounds"]["Normal"])
			end
		else
			UI:Notify('There are <font color="rgb(255, 74, 74)">no</font> friends and <font color="rgb(255, 74, 74)">no</font> other players in your server!', 5, getgenv().AntiSpy["Sounds"]["Normal"])
		end
	end
	
	task.delay(2, function()
		for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			if CheckBlacklist(v) == true and v.UserId ~= game:GetService("Players").LocalPlayer.UserId then
				UI:Notify(string.format('There is a <font color="rgb(255, 74, 74)">blacklisted</font> player in your server!:\n<font color="rgb(255, 74, 74)">%s (%d)</font>', v.Name, v.UserId), 15, getgenv().AntiSpy["Sounds"]["Warning"])
				
				AntiSpy:AddFlag(v, "Blacklisted_Player")	
			end
		end
		
		task.delay(2, function()
			if v.Character and v.Character:WaitForChild("Humanoid").Health ~= 0 then
				local Accessories = AntiSpy:GetAccessories(v)

				for _, Accessory in pairs(Accessories) do
					if CheckBlacklist(Accessory) == true then
						AntiSpy:AddFlag(v, "Blacklisted_Accessory")
						
						UI:Notify(string.format('%s (%d) has a <font color="rgb(255, 74, 74)">blacklisted</font> accessory on!:\n<font color="rgb(255, 74, 74)">%s</font>', v.Name, v.UserId, Accessory.Name))
					end
				end
			end

			v.CharacterAdded:Connect(function(character)
				v.CharacterAppearanceLoaded:Wait()

				local Accessories = AntiSpy:GetAccessories(v)

				for _, Accessory in pairs(Accessories) do
					if CheckBlacklist(Accessory) == true then
						AntiSpy:AddFlag(v, "Blacklisted_Accessory")
						
						UI:Notify(string.format('%s (%d) has a <font color="rgb(255, 74, 74)">blacklisted</font> accessory on!:\n<font color="rgb(255, 74, 74)">%s</font>', v.Name, v.UserId, Accessory.Name))
					end
				end
			end)
		end)
	end)
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	Setup(player)
	
	if player:IsFriendsWith(game:GetService("Players").LocalPlayer.UserId) then
		UI:Notify(string.format("Your friend %s (%d) has joined the game!", player.Name, player.UserId), 5, getgenv().AntiSpy["Sounds"]["Normal"])
	else
		if CheckBlacklist(player) == true then
			UI:Notify(string.format('A <font color="rgb(255, 74, 74)">blacklisted</font> friend has joined your server!\n<font color="rgb(255, 74, 74)">%s (%d)</font>', player.Name, player.UserId), 15, getgenv().AntiSpy["Sounds"]["Warning"])
			
			AntiSpy:AddFlag(player, "Blacklisted_Player")
			
			if getgenv().AntiSpy["Kick"] == true then
				task.delay(getgenv().AntiSpy["Kick"]["Delay"], function()
					game:GetService("Players").LocalPlayer:Kick()
				end)	
			end		
		else
			UI:Notify(string.format("%s (%d) has joined the game!", player.Name, player.UserId), 5, getgenv().AntiSpy["Sounds"]["Normal"])
		end
	end
	
	player.CharacterAdded:Connect(function(character)
		player.CharacterAppearanceLoaded:Wait()
		
		local Accessories = AntiSpy:GetAccessories(player)
		
		for i, v in pairs(Accessories) do
			if CheckBlacklist(v) == true then
				AntiSpy:AddFlag(v, "Blacklisted_Accessory")
				
				UI:Notify(string.format('%s (%d) has a <font color="rgb(255, 74, 74)">blacklisted</font> accessory on!:\n<font color="rgb(255, 74, 74)">%s</font>', player.Name, player.UserId, v.Name), 15, getgenv().AntiSpy["Sounds"]["Warning"])
			end
		end
	end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	Remove(player)
	
	if player:IsFriendsWith(game:GetService("Players").LocalPlayer.UserId) then
		UI:Notify(string.format("Your friend %s (%d) has left the game!", player.Name, player.UserId), 5, getgenv().AntiSpy["Sounds"]["Normal"])
	else
		if CheckBlacklist(player) == true then
			UI:Notify(string.format('A <font color="rgb(255, 74, 74)">blacklisted</font> player has left your server!\n<font color="rgb(255, 74, 74)">%s (%d)</font>', player.Name, player.UserId), 15, getgenv().AntiSpy["Sounds"]["Warning"])
		else
			UI:Notify(string.format("%s (%d) has left the game!", player.Name, player.UserId), 5, getgenv().AntiSpy["Sounds"]["Normal"])
		end
	end
end)

OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
	local player = game:GetService("Players"):GetPlayerByUserId(messageData["SpeakerUserId"])
	
	Players[player.UserId]["LastMessage"] = {
		["Message"] = messageData["Message"],
		["Time"] = tick()
	}

	if CheckMention(Players[player.UserId]["LastMessage"]["Message"]) == true then
		if CheckBlacklist(player) == true and player ~= game:GetService("Players").LocalPlayer then
			AntiSpy:AddFlag(player, "Mention_Player")
			
			UI:Notify(string.format('A <font color="rgb(255, 74, 74)">blacklisted</font> player has mentioned you!:\n<font color="rgb(255, 74, 74)">%s (%d)</font>\n<b><font color="rgb(255, 74, 74)">%s</font>', player.Name, player.UserId, Players[player.UserId]["LastMessage"]["Message"]), 15, getgenv().AntiSpy["Sounds"]["Warning"])
		else
			AntiSpy:AddFlag(player, "Mention_Player")
			
			UI:Notify(string.format('%s (%d) has mentioned you!:\n%s', player.Name, player.UserId, Players[player.UserId]["LastMessage"]["Message"]), 5, getgenv().AntiSpy["Sounds"]["Normal"])
		end
	end
end)

local Rah = false

game:GetService("RunService").RenderStepped:Connect(function()
	if Rah then
		return
	end
	
	for i, v in pairs(game:GetService("Players"):GetPlayers()) do
		local PlayerInfo = AntiSpy:GetPlayerInfo(v)
		
		if PlayerInfo then
			if CheckBlacklist(v) then
				if PlayerInfo["Flags"] and getgenv().AntiSpy["Kick"]["Enabled"] == true and #PlayerInfo["Flags"] >= getgenv().AntiSpy["Kick"]["MaxFlags"] then
					Rah = true
					UI:Notify(string.format('A <font color="rgb(255, 74, 74)">blacklisted</font> player has reached the maximum amount of flags!\n<font color="rgb(255, 74, 74)">%s (%d)</font>\nAmount: <font color="rgb(255, 74, 74)">%d</font>\nFlags: {\n<font color="rgb(255, 74, 74)">%s</font>\n}', v.Name, v.UserId, #PlayerInfo["Flags"], string.gsub(table.concat(PlayerInfo["Flags"], ", "), " ", "\n")), 15, getgenv().AntiSpy["Sounds"]["Warning"])
					
					task.delay(getgenv().AntiSpy["Kick"]["Delay"], function()
						game:GetService("Players").LocalPlayer:Kick()
					end)	
				end
			elseif not CheckWhitelist(v) then
				if PlayerInfo["Flags"] and getgenv().AntiSpy["Kick"]["Enabled"] == true and #PlayerInfo["Flags"] >= getgenv().AntiSpy["Kick"]["MaxFlags"] then
					Rah = true
					UI:Notify(string.format('%s (%d) has reached the maximum amount of flags!\nAmount: <font color="rgb(255, 74, 74)">%d</font>\nFlags: {\n<font color="rgb(255, 74, 74)">%s</font>\n}', v.Name, v.UserId, #PlayerInfo["Flags"], string.gsub(table.concat(PlayerInfo["Flags"], ", "), " ", "\n")), 15, getgenv().AntiSpy["Sounds"]["Warning"])

					task.delay(getgenv().AntiSpy["Kick"]["Delay"], function()
						game:GetService("Players").LocalPlayer:Kick()
					end)	
				end
			end
			
			if PlayerInfo["LastCFrame"] and v.Character and v.Character.PrimaryPart then
				if not PlayerInfo["LastCFrame"]["CFrame"] and not PlayerInfo["LastCFrame"]["Time"] then
					PlayerInfo["LastCFrame"] = {
						["CFrame"] = nil,
						["Time"] = nil
					}
				end
				
				if CheckBlacklist(v) then
					if PlayerInfo["LastCFrame"]["CFrame"] ~= RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)) then
						PlayerInfo["LastCFrame"] = {
							["CFrame"] = RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)),
							["Time"] = tick()
						}
					else
						if CheckActivity(PlayerInfo) == false then
							local Time = GetTime(PlayerInfo["LastCFrame"]["Time"])
							PlayerInfo["LastCFrame"] = {
								["CFrame"] = RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)),
								["Time"] = tick()
							}
							UI:Notify(string.format('A <font color="rgb(255, 74, 74)">blacklisted</font> player has been absent for the maximum amount of seconds!\n<font color="rgb(255, 74, 74)">%s (%d)</font>\n<font color="rgb(255, 74, 74)">Seconds: %d</font>', v.Name, v.UserId, Time), 15, getgenv().AntiSpy["Sounds"]["Warning"])
							
							AntiSpy:AddFlag(v, "Maximum_Absence")
						end
					end
				elseif not CheckWhitelist(v) then
					if PlayerInfo["LastCFrame"]["CFrame"] ~= RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)) then
						PlayerInfo["LastCFrame"] = {
							["CFrame"] = RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)),
							["Time"] = tick()
						}
					else
						if CheckActivity(PlayerInfo) == false then
							local Time = GetTime(PlayerInfo["LastCFrame"]["Time"])
							PlayerInfo["LastCFrame"] = {
								["CFrame"] = RoundCFrame(CFrame.new(v.Character.PrimaryPart.Position)),
								["Time"] = tick()
							}
							UI:Notify(string.format('%s (%d) has been absent for %d seconds!', v.Name, v.UserId, Time), 10, getgenv().AntiSpy["Sounds"]["Normal"])
							
							AntiSpy:AddFlag(v, "Maximum_Absence")
						end
					end
				end
			end
		end
	end
end)

return AntiSpy
