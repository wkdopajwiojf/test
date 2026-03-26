local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local localPlayer = Players.LocalPlayer
local targetPlaceId = 8737899170
local currentPlaceId = game.PlaceId
local externalScriptUrl = "YOUR_EXTERNAL_SCRIPT_URL_HERE" -- ใส่ URL ของ Script ที่ต้องการรัน

-- ฟังก์ชันสำหรับส่งคำสั่งไปรันที่แมพปลายทาง (Queue on Teleport)
local function prepareQueue()
    local queueScript = string.format([[
        -- 1. ลบ RobloxGui ออก
        local core = game:GetService("CoreGui")
        local rbx = core:FindFirstChild("RobloxGui")
        if rbx then
            pcall(function() 
                rbx:Destroy() 
                print("Status: RobloxGui Removed")
            end)
        end

        -- 2. รัน External Script จาก URL
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("%s"))()
            end)
            if not success then
                warn("External Script Error: " .. tostring(err))
            end
        end)

        -- 3. รอ 10 วินาทีแล้ววาร์ปกลับมาที่แมพต้นทาง (PlaceId: %d)
        task.wait(10)
        print("Status: Time is up, teleporting back...")
        game:GetService("TeleportService"):Teleport(%d, game:GetService("Players").LocalPlayer)
    ]], externalScriptUrl, currentPlaceId, currentPlaceId)

    -- ตรวจสอบฟังก์ชัน queue ตามประเภทของ Executor
    local queue = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if queue then
        queue(queueScript)
        return true
    else
        warn("Executor ของคุณไม่รองรับ queue_on_teleport")
        return false
    end
end

-- เริ่มการทำงานทันที
print("Preparing to teleport to Place ID: " .. targetPlaceId)

if prepareQueue() then
    -- ทำการวาร์ปไปแมพเป้าหมาย
    TeleportService:Teleport(targetPlaceId, localPlayer)
else
    print("Execution failed: Queue system not supported.")
end
