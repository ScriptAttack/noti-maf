local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Configuration
local TRADE_ACTION_ID = "ca01587a32b24eb1a0527e8e595e8483" -- Replace if trade session ID changes
local DELAY_BETWEEN_OFFERS = 0.3 -- Delay between offers to prevent rate limiting / dropping remote calls

local localPlayer = Players.LocalPlayer
local tradeRemote = ReplicatedStorage:WaitForChild("MW"):WaitForChild("Remotes"):WaitForChild("TradeAction")

-- Path to inventory scroller
local inventoryScroller = localPlayer.PlayerGui:WaitForChild("MafiaWarsUI")
    .Root.Content.InventoryPanel.Scroller

-- Helper function to extract numeric count from TextLabel (e.g., "x18" -> 18)
local function GetItemCount(itemFrame)
    local countTextLabel = itemFrame:FindFirstChild("IconPlate", true) and itemFrame.IconPlate:FindFirstChild("CountText")
    if not countTextLabel then return 1 end -- Default to 1 if count label doesn't exist

    local rawText = countTextLabel.Text or ""
    local cleanNum = string.match(rawText, "%d+") -- Extracts digits only
    return tonumber(cleanNum) or 1
end

-- Main function to iterate inventory and offer all crates
local function OfferAllCrates()
    print("[Trade Helper] Scanning inventory for crates...")
    local cratesFound = 0

    for _, child in ipairs(inventoryScroller:GetChildren()) do
        -- Filter only items starting with "Item_crate"
        if child:IsA("GuiObject") and string.match(child.Name, "^Item_crate") then
            -- Remove "Item_" prefix to get item name (e.g., "Item_crate_ashport" -> "crate_ashport")
            local itemName = string.gsub(child.Name, "^Item_", "")
            local itemCount = GetItemCount(child)

            cratesFound = cratesFound + 1
            print(string.format("[Trade Helper] Offering %s (Amount: %d)", itemName, itemCount))

            -- Invoke remote to add item to trade
            pcall(function()
                tradeRemote:InvokeServer(TRADE_ACTION_ID, "offer", itemName, itemCount)
            end)

            task.wait(DELAY_BETWEEN_OFFERS)
        end
    end

    print(string.format("[Trade Helper] Finished! Added %d crate type(s) to trade.", cratesFound))
end

-- Execute
OfferAllCrates()
