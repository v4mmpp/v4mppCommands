---config
local mainConfiguration = {
    timeoutSecondes = 4,
    commandsNames = { twitter = "twt", ano = "ano" },
    showPlayerId = false
};

---@public
---@class playersTimeouts
playersTimeouts = {}

---@private
---@type function sendNotificationToPlayers
---@param publicState boolean
---@param playerData table
---@param callback function
local function sendNotificationToPlayers(publicState, playerData, callback)
    local sendInfos = { [false] = { title = "Anonyme", subject = "Message", char = "CHAR_DEFAULT" }, [true] = { title = "Twitter", subject = (playerData.username or "Utilisateur"), char = "CHAR_TWITTER" } };
    if (not publicState) then
        if (mainConfiguration.showPlayerId) then
            sendInfos[false].subject = ("%s (%i)"):format(sendInfos[false].subject, playerData.source);
        end
    end
    TriggerClientEvent('esx:showAdvancedNotification', -1, sendInfos[publicState].title, sendInfos[publicState].subject, playerData.message, sendInfos[publicState].char, 1);
    callback(true);
end

---@public
---@type function addPlayer
---@param player integer
function playersTimeouts:addPlayer(player)
    if (not playersTimeouts[player]) then
        playersTimeouts[player] = true;

        SetTimeout((mainConfiguration.timeoutSecondes * 1000), function()
            playersTimeouts:removePlayer(player);
        end)
    end
end

---@public
---@type function removePlayer
---@param player integer
function playersTimeouts:removePlayer(player)
    if (playersTimeouts[player]) then
        playersTimeouts[player] = nil;
    end
end

---@public
---@type function playerCanSendMessage
---@param player integer
function playersTimeouts:playerCanSendMessage(player)
    if (not playersTimeouts[player]) then
        return (true);
    end
    return (false);
end

AddEventHandler("playerDropped", function(source)
    playersTimeouts:removePlayer(source);
end)

RegisterCommand(mainConfiguration.commandsNames.twitter, function(source, args)
    local playerMessage = table.concat(args, " ");
    local playerName = GetPlayerName(source);
    if (not playersTimeouts:playerCanSendMessage(source)) then
        return TriggerClientEvent('esx:showNotification', source, "~r~Vous devez patienter afin de pouvoir ré-envoyer un message");
    end

    sendNotificationToPlayers(true, { username = playerName, message = playerMessage }, function(messageSended)
        if (messageSended) then
            playersTimeouts:addPlayer(source);
        end
    end);
end)

RegisterCommand(mainConfiguration.commandsNames.ano, function(source, args)
    local playerMessage = table.concat(args, " ");
    if (not playersTimeouts:playerCanSendMessage(source)) then
        return TriggerClientEvent('esx:showNotification', source, "~r~Vous devez patienter afin de pouvoir ré-envoyer un message");
    end
    
	sendNotificationToPlayers(false, { source = source, message = playerMessage }, function(messageSended)
        if (messageSended) then
            playersTimeouts:addPlayer(source);
        end
    end);
end)
