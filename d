local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local badgeId = 2153913164
local targetPlaceId = 8737899170
local originalPlaceId = game.PlaceId

-- หา queue function
local queue = queue_on_teleport 
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

-- ฟังก์ชันเช็ค badge
local function hasBadge(userId, badgeId)
    local url = "https://badges.roblox.com/v1/users/"..userId.."/badges/awarded-dates?badgeIds="..badgeId
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("HTTP error")
        return false
    end

    local data = game:GetService("HttpService"):JSONDecode(response)
    
    if data and data.data and #data.data > 0 then
        return true
    end
    
    return false
end

-- เช็คก่อน
if hasBadge(player.UserId, badgeId) then
    print("มี badge → เริ่มทำงาน")

    -- ใส่ queue กลับ
    if queue then
        queue(string.format([[
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer

            task.wait(10)

            TeleportService:Teleport(%d, player)
        ]], originalPlaceId))
    end

    -- วาร์ปไปเป้าหมาย
    TeleportService:Teleport(targetPlaceId, player)

else
    print("ไม่มี badge → ไม่ทำอะไร")
end
