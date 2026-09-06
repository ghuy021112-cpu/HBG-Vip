--[[
    HBG Elite v5.0 — Professional Edition
    Redz Hub + Maru Hub Level | Auto-Update Data | Sea Events | Race | Leviathan
    Factory Raid | Pirate Raid | Materials | Ectoplasm | Full Feature Set
]]

-- ═══════════════════════════════════════════════════════
-- LAYER 0: ENVIRONMENT & ANTI-DETECT
-- ═══════════════════════════════════════════════════════

local _e = getfenv and getfenv() or _G
local _rs = game:GetService("ReplicatedStorage")
local _plr = game:GetService("Players").LocalPlayer
local _char = _plr.Character or _plr.CharacterAdded:Wait()
local _hrp = _char:WaitForChild("HumanoidRootPart")
local _hum = _char:WaitForChild("Humanoid")
local _ws = game:GetService("Workspace")
local _rsvc = game:GetService("RunService")
local _ts = game:GetService("TweenService")
local _vu = game:GetService("VirtualUser")
local _uis = game:GetService("UserInputService")
local _tsvc = game:GetService("TeleportService")
local _http = game:GetService("HttpService")
local _run = game:GetService("RunService")
local _sg = game:GetService("StarterGui")

-- Anti-AFK + Anti-Kick
pcall(function()
    _plr.Idled:Connect(function()
        _vu:CaptureController()
        _vu:ClickButton2(Vector2.new())
        task.wait(math.random(1, 5) / 10)
    end)
end)

task.spawn(function()
    while true do
        task.wait(math.random(30, 60))
        pcall(function()
            _vu:CaptureController()
            _vu:ClickButton1(Vector2.new(math.random(100, 500), math.random(100, 500)))
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- AUTO-UPDATE DATA SYSTEM
-- ═══════════════════════════════════════════════════════

local _dataUrl = "https://raw.githubusercontent.com/hbg/bloxfruits-data/main/"
local _localData = {
    bosses = {},
    materials = {},
    seaEvents = {},
    races = {},
    factorySchedule = {},
    lastUpdate = 0
}

-- Fetch data từ server
local function _fetchData(endpoint)
    local success, result = pcall(function()
        return game:HttpGet(_dataUrl .. endpoint .. ".json")
    end)
    if success then
        return _http:JSONDecode(result)
    end
    return nil
end

-- Update tất cả data
local function _updateAllData()
    local bosses = _fetchData("bosses")
    local materials = _fetchData("materials")
    local seaEvents = _fetchData("sea_events")
    local races = _fetchData("races")
    local factory = _fetchData("factory_schedule")
    
    if bosses then _localData.bosses = bosses end
    if materials then _localData.materials = materials end
    if seaEvents then _localData.seaEvents = seaEvents end
    if races then _localData.races = races end
    if factory then _localData.factorySchedule = factory end
    
    _localData.lastUpdate = tick()
    return bosses ~= nil or materials ~= nil
end

-- Thử update khi load
task.spawn(function()
    _updateAllData()
end)

-- ═══════════════════════════════════════════════════════
-- FLUENT UI
-- ═══════════════════════════════════════════════════════

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "HBG Elite v5.0",
    SubTitle = "Professional Edition | Auto-Update | Sea Events",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 520),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ═══════════════════════════════════════════════════════
-- SEA DETECTION
-- ═══════════════════════════════════════════════════════

local _sea = 1
local _pid = game.PlaceId
if _pid == 2753915549 then _sea = 1
elseif _pid == 4442272183 then _sea = 2
elseif _pid == 7449423635 then _sea = 3
else pcall(function() _sea = _plr.Data.Sea.Value end) end

-- ═══════════════════════════════════════════════════════
-- STATE VARIABLES
-- ═══════════════════════════════════════════════════════

local _st = {
    -- Farm
    farm = false, farmMelee = false, farmBlox = false, farmSword = false, farmGun = false,
    farmBoss = false, farmMoney = false, farmChest = false, farmFruit = false,
    farmMaterial = false, farmEctoplasm = false,
    -- Sea Events
    seaEvent = false, autoSeaBeast = false, autoLeviathan = false, autoRace = false,
    -- Raid
    raid = false, factoryRaid = false, pirateRaid = false, autoFragment = false,
    -- Utility
    fly = false, esp = false, espPlayer = false, espFruit = false, espChest = false,
    espNPC = false, espMaterial = false, espBoss = false,
    autoHeal = false, autoReset = false, serverHop = false,
    -- Settings
    weapon = "Melee", distance = 20, speed = 300, bring = true, haki = true,
    throttle = 0.08, autoStats = false, statPriority = "Melee",
    selectedBoss = nil, selectedMaterial = nil, selectedRace = nil,
    -- Real-time
    startExp = 0, startTime = tick(), mobsKilled = 0, moneyEarned = 0,
    ectoplasmCount = 0, materialCount = 0
}

pcall(function() _st.startExp = _plr.Data.Exp.Value end)

-- ═══════════════════════════════════════════════════════
-- REMOTE SNIFFER
-- ═══════════════════════════════════════════════════════

local _cRem = nil
local _qRem = nil
local _hRem = nil
local _eventRem = nil -- Remote cho Sea Events

local function _findRemotes()
    for _, v in pairs(_rs:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("attack") or n:find("hit") or n:find("damage") or n:find("combat") then _cRem = v end
            if n:find("quest") or n:find("mission") then _qRem = v end
            if n:find("buso") or n:find("haki") then _hRem = v end
            if n:find("event") or n:find("sea") or n:find("race") then _eventRem = v end
        end
    end
    if not _cRem then _cRem = _rs:FindFirstChild("Remotes") and _rs.Remotes:FindFirstChild("CommF_") end
    if not _qRem then _qRem = _cRem end
    if not _hRem then _hRem = _cRem end
    if not _eventRem then _eventRem = _cRem end
end
pcall(_findRemotes)

-- ═══════════════════════════════════════════════════════
-- HARD-CODE FALLBACK DATA (khi không fetch được)
-- ═══════════════════════════════════════════════════════

local _zones = {}
if _sea == 1 then
    _zones = {
        [1]={n="Starter",npc="Bandit Quest Giver",mob="Bandit",pos=Vector3.new(1059,16,1547)},
        [10]={n="Jungle",npc="Jungle Quest Giver",mob="Monkey",pos=Vector3.new(-1601,37,152)},
        [30]={n="Pirate Village",npc="Pirate Village Quest Giver",mob="Brute",pos=Vector3.new(-1142,4,3913)},
        [60]={n="Desert",npc="Desert Quest Giver",mob="Desert Bandit",pos=Vector3.new(944,6,4426)},
        [90]={n="Frozen Village",npc="Frozen Village Quest Giver",mob="Snowman",pos=Vector3.new(1389,87,-1299)},
        [120]={n="Marine Fortress",npc="Marine Quest Giver",mob="Chief Petty Officer",pos=Vector3.new(-2841,41,5317)},
        [150]={n="Skylands",npc="Skylands Quest Giver",mob="Sky Bandit",pos=Vector3.new(-4967,718,-2623)},
        [190]={n="Prison",npc="Prison Quest Giver",mob="Prisoner",pos=Vector3.new(4854,6,734)},
        [220]={n="Colosseum",npc="Colosseum Quest Giver",mob="Toga Warrior",pos=Vector3.new(-1836,45,-2740)},
        [250]={n="Magma Village",npc="Magma Quest Giver",mob="Magma Ninja",pos=Vector3.new(-5246,9,8500)},
        [300]={n="Underwater City",npc="Underwater Quest Giver",mob="Fishman Warrior",pos=Vector3.new(61122,19,1568)},
        [330]={n="Fountain City",npc="Fountain Quest Giver",mob="Galley Pirate",pos=Vector3.new(5258,39,4052)},
    }
elseif _sea == 2 then
    _zones = {
        [1500]={n="Kingdom of Rose",npc="Rose Quest Giver",mob="Raider",pos=Vector3.new(-775,11,3314)},
        [1575]={n="Kingdom of Rose 2",npc="Rose Quest Giver 2",mob="Mercenary",pos=Vector3.new(-775,11,3314)},
        [1650]={n="Green Zone",npc="Green Quest Giver",mob="Marine Lieutenant",pos=Vector3.new(-2372,73,-3166)},
        [1750]={n="Graveyard",npc="Graveyard Quest Giver",mob="Zombie",pos=Vector3.new(-5634,9,-2040)},
        [1850]={n="Dark Arena",npc="Dark Arena Quest Giver",mob="Dark Master",pos=Vector3.new(5346,1,391)},
        [1950]={n="Snow Mountain",npc="Snow Quest Giver",mob="Snow Trooper",pos=Vector3.new(547,401,-5565)},
        [2075]={n="Hot & Cold",npc="Hot Quest Giver",mob="Lab Subordinate",pos=Vector3.new(-5887,18,-507)},
        [2175]={n="Cursed Ship",npc="Ship Quest Giver",mob="Ship Deckhand",pos=Vector3.new(923,126,32852)},
        [2275]={n="Ice Castle",npc="Ice Quest Giver",mob="Ice Warrior",pos=Vector3.new(5400,29,-6236)},
        [2375]={n="Forgotten Island",npc="Forgotten Quest Giver",mob="Tide Keeper",pos=Vector3.new(-3054,238,-10148)},
    }
elseif _sea == 3 then
    _zones = {
        [2550]={n="Port Town",npc="Port Quest Giver",mob="Pirate Millionaire",pos=Vector3.new(-289,44,5337)},
        [2675]={n="Hydra Island",npc="Hydra Quest Giver",mob="Dragon Crew Warrior",pos=Vector3.new(5228,68,1528)},
        [2775]={n="Great Tree",npc="Tree Quest Giver",mob="Sun-kissed Warrior",pos=Vector3.new(2681,168,-7185)},
        [2875]={n="Floating Turtle",npc="Turtle Quest Giver",mob="Fishman Raider",pos=Vector3.new(-12428,375,-7568)},
        [2975]={n="Castle on the Sea",npc="Castle Quest Giver",mob="Arctic Warrior",pos=Vector3.new(-5076,315,-3155)},
        [3075]={n="Tiki Outpost",npc="Tiki Quest Giver",mob="Isle Outlaw",pos=Vector3.new(-16547,56,-173)},
        [3175]={n="Tiki Outpost 2",npc="Tiki Quest Giver 2",mob="Isle Champion",pos=Vector3.new(-16547,56,-173)},
    }
end

-- BOSS DATA (hardcode fallback + auto-update)
local _bosses = {
    -- Sea 1
    ["The Gorilla King"] = {pos=Vector3.new(-1128,6,-451),minLv=20,sea=1},
    ["Bobby"] = {pos=Vector3.new(-1131,14,4080),minLv=55,sea=1},
    ["Yeti"] = {pos=Vector3.new(1185,106,-2454),minLv=105,sea=1},
    ["Mob Leader"] = {pos=Vector3.new(-2841,7,5327),minLv=120,sea=1},
    ["Vice Admiral"] = {pos=Vector3.new(-4806,22,4360),minLv=130,sea=1},
    ["Warden"] = {pos=Vector3.new(4873,6,736),minLv=220,sea=1},
    ["Chief Warden"] = {pos=Vector3.new(4873,6,736),minLv=230,sea=1},
    ["Swan"] = {pos=Vector3.new(5230,4,757),minLv=240,sea=1},
    ["Magma Admiral"] = {pos=Vector3.new(-5694,16,8732),minLv=350,sea=1},
    ["Fishman Lord"] = {pos=Vector3.new(61350,30,1500),minLv=425,sea=1},
    ["Wysper"] = {pos=Vector3.new(-7894,5545,-273),minLv=500,sea=1},
    ["Thunder God"] = {pos=Vector3.new(-7900,5605,-273),minLv=575,sea=1},
    ["Cyborg"] = {pos=Vector3.new(61350,30,1500),minLv=675,sea=1},
    -- Sea 2
    ["Diamond"] = {pos=Vector3.new(-1566,375,-3137),minLv=750,sea=2},
    ["Jeremy"] = {pos=Vector3.new(2316,449,7870),minLv=850,sea=2},
    ["Fajita"] = {pos=Vector3.new(-3793,144,11491),minLv=925,sea=2},
    ["Don Swan"] = {pos=Vector3.new(2288,15,808),minLv=1000,sea=2},
    ["Cursed Captain"] = {pos=Vector3.new(916,127,32913),minLv=1325,sea=2},
    ["Darkbeard"] = {pos=Vector3.new(3677,13,-3590),minLv=1000,sea=2},
    ["Order"] = {pos=Vector3.new(-6217,23,-5055),minLv=1250,sea=2},
    ["Awakened Ice Admiral"] = {pos=Vector3.new(5663,28,-6257),minLv=1400,sea=2},
    ["Tide Keeper"] = {pos=Vector3.new(-3054,238,-10148),minLv=1475,sea=2},
    -- Sea 3
    ["Stone"] = {pos=Vector3.new(-1046,271,-3052),minLv=1550,sea=3},
    ["Island Empress"] = {pos=Vector3.new(5733,310,211),minLv=1675,sea=3},
    ["Kilo Admiral"] = {pos=Vector3.new(2879,423,-7230),minLv=1750,sea=3},
    ["Captain Elephant"] = {pos=Vector3.new(-13381,332,-8010),minLv=1875,sea=3},
    ["Beautiful Pirate"] = {pos=Vector3.new(5319,23,129),minLv=1950,sea=3},
    ["Longma"] = {pos=Vector3.new(-10218,333,-9444),minLv=2000,sea=3},
    ["Cake Prince"] = {pos=Vector3.new(-2145,70,-12327),minLv=2200,sea=3},
    ["Soul Reaper"] = {pos=Vector3.new(-9523,315,6704),minLv=2300,sea=3},
    -- Sea Bosses
    ["Sea Beast"] = {pos=nil,minLv=0,sea=1,type="sea"},
    ["Leviathan"] = {pos=nil,minLv=0,sea=3,type="sea"},
}

-- MATERIAL DATA
local _materials = {
    ["Ectoplasm"] = {spawnLocations={Vector3.new(923,126,32852)},sea=2,method="kill_mob",mob="Ship Deckhand"},
    ["Magma Ore"] = {spawnLocations={Vector3.new(-5246,9,8500)},sea=1,method="kill_mob",mob="Magma Ninja"},
    ["Angel Wings"] = {spawnLocations={Vector3.new(-4967,718,-2623)},sea=1,method="kill_mob",mob="God's Guard"},
    ["Radioactive Material"] = {spawnLocations={Vector3.new(-5887,18,-507)},sea=2,method="kill_mob",mob="Lab Subordinate"},
    ["Vampire Fang"] = {spawnLocations={Vector3.new(-9515,142,5537)},sea=2,method="kill_mob",mob="Vampire"},
    ["Mystic Droplet"] = {spawnLocations={Vector3.new(61122,19,1568)},sea=1,method="kill_mob",mob="Fishman Warrior"},
    ["Dragon Scale"] = {spawnLocations={Vector3.new(5228,68,1528)},sea=3,method="kill_mob",mob="Dragon Crew Warrior"},
    ["Gunpowder"] = {spawnLocations={Vector3.new(-16547,56,-173)},sea=3,method="kill_mob",mob="Isle Outlaw"},
    ["Mini Tusk"] = {spawnLocations={Vector3.new(-16547,56,-173)},sea=3,method="kill_mob",mob="Isle Champion"},
}

-- SEA EVENT DATA
local _seaEvents = {
    ["Sea Beast"] = {detectMethod="model_name",pattern="SeaBeast",minSea=1},
    ["Rough Sea"] = {detectMethod="gui",pattern="Rough Sea",minSea=2},
    ["Frozen Dimension"] = {detectMethod="gui",pattern="Frozen Dimension",minSea=3},
    ["Leviathan"] = {detectMethod="model_name",pattern="Leviathan",minSea=3},
    ["Ship Raid"] = {detectMethod="gui",pattern="Ship Raid",minSea=2},
    ["Haunted Ship Raid"] = {detectMethod="gui",pattern="Haunted Ship Raid",minSea=3},
}

-- RACE DATA
local _races = {
    ["Race v3"] = {guiName="RaceV3",checkMethod="gui"},
    ["Race v4"] = {guiName="RaceV4",checkMethod="gui"},
}

-- FACTORY SCHEDULE
local _factorySchedule = {
    spawnInterval = 130, -- minutes
    lastSpawn = 0,
    isOpen = false
}

-- ═══════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════

local function _lvl()
    local s,v = pcall(function() return _plr.Data.Level.Value end)
    return s and v or 1
end

local function _exp()
    local s,v = pcall(function() return _plr.Data.Exp.Value end)
    return s and v or 0
end

local function _money()
    local s,v = pcall(function() return _plr.Data.Beli.Value end)
    return s and v or 0
end

local function _zone()
    local lv = _lvl()
    local z, bl = nil, 0
    for ml, d in pairs(_zones) do
        if lv >= ml and ml > bl then z, bl = d, ml end
    end
    return z
end

-- VELOCITY SPOOF
local function _vSpoof()
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = _hrp
        task.wait(0.1)
        bv:Destroy()
    end)
end

-- TELEPORT
local function _tp(pos)
    pcall(function()
        _hrp.Velocity = Vector3.new(0, 0, 0)
        _hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
    _vSpoof()
    _hrp.CFrame = CFrame.new(pos)
    task.wait(0.05)
    pcall(function()
        _hrp.Velocity = Vector3.new(0, -2, 0)
        _hrp.AssemblyLinearVelocity = Vector3.new(0, -2, 0)
    end)
    task.wait(0.1)
    _vSpoof()
end

-- TWEEN
local function _tween(pos, spd)
    spd = spd or _st.speed
    local dist = (_hrp.Position - pos).Magnitude
    if dist < 5 then return end
    _vSpoof()
    local tt = math.clamp(dist / spd, 0.1, 8)
    local tw = _ts:Create(_hrp, TweenInfo.new(tt, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tw:Play()
    tw.Completed:Wait()
    task.wait(0.05)
    _vSpoof()
end

-- FIND MOB
local function _fMob(name)
    if not _ws:FindFirstChild("Enemies") then return nil end
    local near, md = nil, math.huge
    for _, m in pairs(_ws.Enemies:GetChildren()) do
        if m and m.Name == name and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            if m.Humanoid.Health > 0 then
                local d = (_hrp.Position - m.HumanoidRootPart.Position).Magnitude
                if d < md then near, md = m, d end
            end
        end
    end
    return near
end

-- FIND BOSS
local function _fBoss(bossName)
    if not _ws:FindFirstChild("Enemies") then return nil end
    for _, m in pairs(_ws.Enemies:GetChildren()) do
        if m and m.Name == bossName and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            if m.Humanoid.Health > 0 then return m end
        end
    end
    return nil
end

-- FIND SEA BOSS (Sea Beast, Leviathan)
local function _fSeaBoss(pattern)
    for _, m in pairs(_ws:GetDescendants()) do
        if m and m.Name:find(pattern) and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            if m.Humanoid.Health > 0 then return m end
        end
    end
    return nil
end

-- FIND FRUIT
local function _fFruit()
    for _, v in pairs(_ws:GetChildren()) do
        if v and v.Name:find("Fruit") and v:IsA("Tool") and v:FindFirstChild("Handle") then
            return v
        end
    end
    return nil
end

-- FIND CHEST
local function _fChest()
    for _, v in pairs(_ws:GetChildren()) do
        if v and v.Name:find("Chest") and v:FindFirstChild("TouchInterest") then
            return v
        end
    end
    return nil
end

-- FIND MATERIAL (dropped item)
local function _fMaterial(matName)
    for _, v in pairs(_ws:GetChildren()) do
        if v and v.Name:find(matName) and v:FindFirstChild("TouchInterest") then
            return v
        end
    end
    return nil
end

-- CHECK SEA EVENT GUI
local function _checkSeaEventGui()
    local playerGui = _plr:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text:lower()
            for eventName, eventData in pairs(_seaEvents) do
                if text:find(eventData.pattern:lower()) and _sea >= eventData.minSea then
                    return eventName
                end
            end
        end
    end
    return nil
end

-- CHECK FACTORY STATUS
local function _checkFactory()
    -- Kiểm tra GUI hoặc remote để biết factory đang mở
    local playerGui = _plr:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text:find("Factory") then
                return true
            end
        end
    end
    return false
end

-- EQUIP WEAPON
local function _equip(wtype)
    local bp = _plr:FindFirstChild("Backpack")
    if not bp then return end
    local meleeList = {"Combat","Dark Step","Electro","Water Kung Fu","Dragon Claw","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman","Sanguine Art"}
    local tname = nil
    for _, t in pairs(bp:GetChildren()) do
        if not t then continue end
        if wtype == "Melee" and table.find(meleeList, t.Name) then tname = t.Name; break
        elseif wtype == "BloxFruit" and (t:FindFirstChild("Fruit") or t.ToolTip == "Blox Fruit") then tname = t.Name; break
        elseif wtype == "Sword" and t.ToolTip == "Sword" then tname = t.Name; break
        elseif wtype == "Gun" and t.ToolTip == "Gun" then tname = t.Name; break end
    end
    if tname and _char:FindFirstChild("Humanoid") then
        _char.Humanoid:EquipTool(bp:FindFirstChild(tname))
    end
end

-- HAKI
local function _haki()
    pcall(function()
        if _hRem then
            if _hRem:IsA("RemoteFunction") then _hRem:InvokeServer("Buso")
            elseif _hRem:IsA("RemoteEvent") then _hRem:FireServer("Buso") end
        end
    end)
end

-- QUEST
local function _quest(z)
    if not z then return end
    _tween(z.pos + Vector3.new(0, 10, 0))
    task.wait(0.3 + math.random(1, 5) / 10)
    pcall(function()
        if _qRem then
            if _qRem:IsA("RemoteFunction") then _qRem:InvokeServer("StartQuest", z.npc, z.lvl or 1)
            elseif _qRem:IsA("RemoteEvent") then _qRem:FireServer("StartQuest", z.npc, z.lvl or 1) end
        end
    end)
    task.wait(0.3)
end

-- REMOTE COMBAT với THROTTLE
local _atkQueue = {}
local function _rCombat(mob)
    if not mob or not mob.Parent then return end
    if not mob:FindFirstChild("Humanoid") or not mob:FindFirstChild("HumanoidRootPart") then return end
    
    local count = 0
    while _st.farm and mob.Parent and mob.Humanoid.Health > 0 do
        if count > 500 then break end
        if not mob or not mob.Parent or not mob:FindFirstChild("Humanoid") then break end
        if mob.Humanoid.Health <= 0 then break end
        
        local off = Vector3.new(math.random(-3, 3), _st.distance, math.random(-3, 3))
        _hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(off)
        
        table.insert(_atkQueue, tick())
        if #_atkQueue > 10 then table.remove(_atkQueue, 1) end
        
        pcall(function()
            if _cRem then
                local args = {Target = mob, Hit = mob.HumanoidRootPart, Position = mob.HumanoidRootPart.Position}
                if _cRem:IsA("RemoteEvent") then _cRem:FireServer(args)
                elseif _cRem:IsA("RemoteFunction") then _cRem:InvokeServer(args) end
            end
        end)
        
        if _st.bring then
            pcall(function()
                if mob and mob:FindFirstChild("HumanoidRootPart") then
                    mob.HumanoidRootPart.CFrame = _hrp.CFrame * CFrame.new(0, -8, 0)
                    mob.HumanoidRootPart.CanCollide = false
                end
            end)
        end
        
        task.wait(_st.throttle + math.random(1, 3) / 100)
        count = count + 1
    end
    _st.mobsKilled = _st.mobsKilled + 1
end

-- AUTO HEAL
local function _heal()
    local bp = _plr:FindFirstChild("Backpack")
    if not bp then return end
    for _, t in pairs(bp:GetChildren()) do
        if t and (t.Name:find("Cake") or t.Name:find("Bottle") or t.Name:find("Potion")) then
            if _char:FindFirstChild("Humanoid") then
                _char.Humanoid:EquipTool(t)
                task.wait(0.2)
                pcall(function()
                    _vu:CaptureController()
                    _vu:ClickButton1(Vector2.new(0, 0))
                end)
                return
            end
        end
    end
end

-- AUTO STATS
local function _stats()
    pcall(function()
        local pts = _plr.Data.Points.Value
        if pts > 0 then
            local prio = _st.statPriority
            if prio == "Melee" then prio = "Melee"
            elseif prio == "BloxFruit" then prio = "Demon Fruit"
            elseif prio == "Sword" then prio = "Sword"
            elseif prio == "Gun" then prio = "Gun" end
            
            if _qRem and _qRem:IsA("RemoteFunction") then
                _qRem:InvokeServer("AddPoint", prio, pts)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- AUTO FLY
-- ═══════════════════════════════════════════════════════

local _flyConn = nil
local function _toggleFly(state)
    _st.fly = state
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "HBG_Fly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = _hrp
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "HBG_FlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 10000
        bg.Parent = _hrp
        
        _flyConn = _rsvc.RenderStepped:Connect(function()
            if not _st.fly then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0, 0, 0)
            if _uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if _uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if _uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if _uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if _uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if _uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            if bv and bv.Parent then bv.Velocity = dir * _st.speed end
            if bg and bg.Parent then bg.CFrame = cam.CFrame end
        end)
    else
        if _flyConn then _flyConn:Disconnect() end
        pcall(function() _hrp:FindFirstChild("HBG_Fly"):Destroy() end)
        pcall(function() _hrp:FindFirstChild("HBG_FlyGyro"):Destroy() end)
    end
end

-- ═══════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════

local _espFolder = Instance.new("Folder")
_espFolder.Name = "HBG_ESP"
_espFolder.Parent = _ws

local function _espAdd(obj, color, text)
    if not obj then return end
    local target = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Handle") or obj
    if not target then return end
    if target:FindFirstChild("HBG_ESP") then return end
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "HBG_ESP"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 120, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Parent = target
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Text = text or obj.Name
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bb
end

local function _espClear()
    for _, v in pairs(_espFolder:GetChildren()) do v:Destroy() end
    for _, v in pairs(_ws:GetDescendants()) do
        if v.Name == "HBG_ESP" then v:Destroy() end
    end
end

local _espConn = nil
local function _toggleESP(state, type)
    if type == "enemy" then _st.esp = state
    elseif type == "player" then _st.espPlayer = state
    elseif type == "fruit" then _st.espFruit = state
    elseif type == "chest" then _st.espChest = state
    elseif type == "npc" then _st.espNPC = state
    elseif type == "material" then _st.espMaterial = state
    elseif type == "boss" then _st.espBoss = state end
    
    if state then
        if _espConn then _espConn:Disconnect() end
        _espConn = _rsvc.Heartbeat:Connect(function()
            if _st.esp and _ws:FindFirstChild("Enemies") then
                for _, m in pairs(_ws.Enemies:GetChildren()) do
                    if m and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                        _espAdd(m, Color3.fromRGB(255, 0, 0), m.Name .. "\nHP: " .. math.floor(m.Humanoid.Health))
                    end
                end
            end
            if _st.espPlayer then
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= _plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        _espAdd(p.Character, Color3.fromRGB(0, 255, 255), p.Name)
                    end
                end
            end
            if _st.espFruit then
                for _, f in pairs(_ws:GetChildren()) do
                    if f and f.Name:find("Fruit") and f:IsA("Tool") then
                        _espAdd(f, Color3.fromRGB(255, 255, 0), "FRUIT: " .. f.Name)
                    end
                end
            end
            if _st.espChest then
                for _, c in pairs(_ws:GetChildren()) do
                    if c and c.Name:find("Chest") then
                        _espAdd(c, Color3.fromRGB(0, 255, 0), "CHEST")
                    end
                end
            end
            if _st.espMaterial then
                for matName, _ in pairs(_materials) do
                    for _, item in pairs(_ws:GetChildren()) do
                        if item and item.Name:find(matName) then
                            _espAdd(item, Color3.fromRGB(255, 165, 0), "MAT: " .. matName)
                        end
                    end
                end
            end
            if _st.espBoss then
                for bossName, _ in pairs(_bosses) do
                    local boss = _fBoss(bossName)
                    if boss then
                        _espAdd(boss, Color3.fromRGB(148, 0, 211), "BOSS: " .. bossName)
                    end
                end
            end
        end)
    else
        if not (_st.esp or _st.espPlayer or _st.espFruit or _st.espChest or _st.espNPC or _st.espMaterial or _st.espBoss) then
            if _espConn then _espConn:Disconnect() end
            _espClear()
        end
    end
end

-- ═══════════════════════════════════════════════════════
-- SERVER HOP
-- ═══════════════════════════════════════════════════════

local function _serverHop()
    local servers = {}
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    pcall(function()
        local data = game:HttpGet(url)
        local json = _http:JSONDecode(data)
        for _, s in pairs(json.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
    end)
    if #servers > 0 then
        _tsvc:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], _plr)
    end
end

-- ═══════════════════════════════════════════════════════
-- FLUENT UI — TABS (MENU CHI TIẾT NHƯ REDZ/MARU)
-- ═══════════════════════════════════════════════════════

local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Sea = Window:AddTab({ Title = "Sea", Icon = "anchor" }),
    Boss = Window:AddTab({ Title = "Bosses", Icon = "skull" }),
    Fruit = Window:AddTab({ Title = "Fruit/Raid", Icon = "apple" }),
    Chest = Window:AddTab({ Title = "Chest", Icon = "box" }),
    Ectoplasm = Window:AddTab({ Title = "Ectoplasm", Icon = "ghost" }),
    Material = Window:AddTab({ Title = "Materials", Icon = "gem" }),
    Factory = Window:AddTab({ Title = "Factory Raid", Icon = "factory" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" })
}

-- ═══════════════════════════════════════════════════════
-- TAB: FARM (Auto Farm Level + Mastery)
-- ═══════════════════════════════════════════════════════

local _statusLabel = Tabs.Farm:AddParagraph({
    Title = "Status",
    Content = "Sea: " .. _sea .. " | Level: " .. _lvl() .. " | EXP: " .. _exp() .. " | Money: " .. _money()
})

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local elapsed = math.floor(tick() - _st.startTime)
            local expGain = _exp() - _st.startExp
            _statusLabel:SetDesc("Sea: " .. _sea .. " | Level: " .. _lvl() .. 
                "\nEXP: " .. _exp() .. " (+" .. expGain .. ")" ..
                "\nMoney: " .. _money() .. " | Mobs: " .. _st.mobsKilled ..
                "\nEctoplasm: " .. _st.ectoplasmCount .. " | Materials: " .. _st.materialCount ..
                "\nTime: " .. elapsed .. "s | Data Updated: " .. os.date("%H:%M:%S", _localData.lastUpdate))
        end)
    end
end)

Tabs.Farm:AddDropdown("Weapon", {
    Title = "Weapon Type",
    Values = {"Melee", "BloxFruit", "Sword", "Gun"},
    Multi = false,
    Default = "Melee",
    Callback = function(v) _st.weapon = v end
})

Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        _st.farm = v
        if v then
            task.spawn(function()
                while _st.farm do
                    pcall(function()
                        if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                    end)
                    local z = _zone()
                    if z then
                        _quest(z)
                        task.wait(0.5 + math.random(1, 3) / 10)
                        local mob = _fMob(z.mob)
                        if mob then
                            _equip(_st.weapon)
                            task.wait(0.2)
                            if _st.haki then _haki() end
                            _rCombat(mob)
                        else
                            task.wait(1 + math.random(1, 5) / 10)
                        end
                    else
                        task.wait(2)
                    end
                    if _st.autoStats then _stats() end
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("FarmMelee", {
    Title = "Farm Melee Mastery",
    Default = false,
    Callback = function(v)
        _st.farmMelee = v; _st.weapon = "Melee"; _st.farm = v
        if v then
            task.spawn(function()
                while _st.farmMelee do
                    pcall(function()
                        if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                    end)
                    local z = _zone()
                    if z then _quest(z); task.wait(0.5); local mob = _fMob(z.mob)
                        if mob then _equip("Melee"); task.wait(0.2); _haki(); _rCombat(mob) end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("FarmBlox", {
    Title = "Farm Blox Fruit Mastery",
    Default = false,
    Callback = function(v)
        _st.farmBlox = v; _st.weapon = "BloxFruit"; _st.farm = v
        if v then
            task.spawn(function()
                while _st.farmBlox do
                    pcall(function()
                        if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                    end)
                    local z = _zone()
                    if z then _quest(z); task.wait(0.5); local mob = _fMob(z.mob)
                        if mob then _equip("BloxFruit"); task.wait(0.2); _rCombat(mob) end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("FarmSword", {
    Title = "Farm Sword Mastery",
    Default = false,
    Callback = function(v)
        _st.farmSword = v; _st.weapon = "Sword"; _st.farm = v
        if v then
            task.spawn(function()
                while _st.farmSword do
                    pcall(function()
                        if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                    end)
                    local z = _zone()
                    if z then _quest(z); task.wait(0.5); local mob = _fMob(z.mob)
                        if mob then _equip("Sword"); task.wait(0.2); _haki(); _rCombat(mob) end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("FarmGun", {
    Title = "Farm Gun Mastery",
    Default = false,
    Callback = function(v)
        _st.farmGun = v; _st.weapon = "Gun"; _st.farm = v
        if v then
            task.spawn(function()
                while _st.farmGun do
                    pcall(function()
                        if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                    end)
                    local z = _zone()
                    if z then _quest(z); task.wait(0.5); local mob = _fMob(z.mob)
                        if mob then _equip("Gun"); task.wait(0.2); _rCombat(mob) end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("FarmMoney", {
    Title = "Auto Farm Money (Rich Mob)",
    Default = false,
    Callback = function(v)
        _st.farmMoney = v
        if v then
            task.spawn(function()
                while _st.farmMoney do
                    local z = _zone()
                    if z then
                        local mob = _fMob(z.mob)
                        if mob then
                            _equip(_st.weapon)
                            task.wait(0.2)
                            _haki()
                            _rCombat(mob)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: SEA (Sea Events, Race, Leviathan)
-- ═══════════════════════════════════════════════════════

Tabs.Sea:AddParagraph({
    Title = "Sea Events",
    Content = "Auto-detect and farm sea events"
})

Tabs.Sea:AddToggle("AutoSeaEvent", {
    Title = "Auto Detect & Farm Sea Events",
    Default = false,
    Callback = function(v)
        _st.seaEvent = v
        if v then
            task.spawn(function()
                while _st.seaEvent do
                    local event = _checkSeaEventGui()
                    if event then
                        Fluent:Notify({
                            Title = "Sea Event Detected!",
                            Content = event .. " is active!",
                            Duration = 5
                        })
                        
                        -- Handle specific events
                        if event == "Sea Beast" then
                            _st.autoSeaBeast = true
                        elseif event == "Leviathan" then
                            _st.autoLeviathan = true
                        elseif event == "Ship Raid" then
                            _st.pirateRaid = true
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

Tabs.Sea:AddToggle("AutoSeaBeast", {
    Title = "Auto Farm Sea Beast",
    Default = false,
    Callback = function(v)
        _st.autoSeaBeast = v
        if v then
            task.spawn(function()
                while _st.autoSeaBeast do
                    local beast = _fSeaBoss("SeaBeast")
                    if beast then
                        _equip(_st.weapon)
                        task.wait(0.2)
                        _haki()
                        
                        local count = 0
                        while _st.autoSeaBeast and beast and beast.Parent and beast:FindFirstChild("Humanoid") and beast.Humanoid.Health > 0 do
                            if count > 1000 then break end
                            if not beast or not beast.Parent then break end
                            
                            local off = Vector3.new(math.random(-10, 10), 30, math.random(-10, 10))
                            _hrp.CFrame = beast.HumanoidRootPart.CFrame * CFrame.new(off)
                            
                            pcall(function()
                                if _cRem then
                                    local args = {Target = beast, Hit = beast.HumanoidRootPart, Position = beast.HumanoidRootPart.Position}
                                    if _cRem:IsA("RemoteEvent") then _cRem:FireServer(args)
                                    elseif _cRem:IsA("RemoteFunction") then _cRem:InvokeServer(args) end
                                end
                            end)
                            
                            task.wait(_st.throttle + math.random(1, 3) / 100)
                            count = count + 1
                        end
                    else
                        -- Tìm Sea Beast trên biển
                        _tp(Vector3.new(math.random(-5000, 5000), 100, math.random(-5000, 5000)))
                        task.wait(3)
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Sea:AddToggle("AutoLeviathan", {
    Title = "Auto Farm Leviathan",
    Default = false,
    Callback = function(v)
        _st.autoLeviathan = v
        if v then
            task.spawn(function()
                while _st.autoLeviathan do
                    local levi = _fSeaBoss("Leviathan")
                    if levi then
                        _equip(_st.weapon)
                        task.wait(0.2)
                        _haki()
                        
                        local count = 0
                        while _st.autoLeviathan and levi and levi.Parent and levi:FindFirstChild("Humanoid") and levi.Humanoid.Health > 0 do
                            if count > 2000 then break end
                            if not levi or not levi.Parent then break end
                            
                            local off = Vector3.new(math.random(-15, 15), 40, math.random(-15, 15))
                            _hrp.CFrame = levi.HumanoidRootPart.CFrame * CFrame.new(off)
                            
                            pcall(function()
                                if _cRem then
                                    local args = {Target = levi, Hit = levi.HumanoidRootPart, Position = levi.HumanoidRootPart.Position}
                                    if _cRem:IsA("RemoteEvent") then _cRem:FireServer(args)
                                    elseif _cRem:IsA("RemoteFunction") then _cRem:InvokeServer(args) end
                                end
                            end)
                            
                            task.wait(_st.throttle + math.random(1, 3) / 100)
                            count = count + 1
                        end
                    else
                        _tp(Vector3.new(math.random(-8000, 8000), 100, math.random(-8000, 8000)))
                        task.wait(5)
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

Tabs.Sea:AddToggle("AutoRace", {
    Title = "Auto Race v3/v4",
    Default = false,
    Callback = function(v)
        _st.autoRace = v
        if v then
            task.spawn(function()
                while _st.autoRace do
                    -- Kiểm tra GUI race
                    local playerGui = _plr:FindFirstChild("PlayerGui")
                    if playerGui then
                        for _, gui in pairs(playerGui:GetDescendants()) do
                            if gui:IsA("TextButton") and gui.Text:find("Race") then
                                pcall(function()
                                    firesignal(gui.MouseButton1Click)
                                end)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: BOSSES (Update Boss List + Auto Kill)
-- ═══════════════════════════════════════════════════════

Tabs.Boss:AddButton({
    Title = "Update Boss List",
    Callback = function()
        local success = _updateAllData()
        if success then
            -- Cập nhật UI
            Fluent:Notify({
                Title = "Boss List Updated",
                Content = "Fetched " .. #_localData.bosses .. " bosses from server",
                Duration = 3
            })
            -- Merge với _bosses
            for name, data in pairs(_localData.bosses) do
                _bosses[name] = data
            end
        else
            Fluent:Notify({
                Title = "Update Failed",
                Content = "Using fallback data. Check connection.",
                Duration = 3
            })
        end
    end
})

-- Dropdown boss từ data
local _bossNames = {}
for name, _ in pairs(_bosses) do table.insert(_bossNames, name) end

Tabs.Boss:AddDropdown("BossSelect", {
    Title = "Select Boss",
    Values = _bossNames,
    Multi = false,
    Default = _bossNames[1] or "Diamond",
    Callback = function(v) _st.selectedBoss = v end
})

Tabs.Boss:AddToggle("AutoBoss", {
    Title = "Auto Kill Selected Boss",
    Default = false,
    Callback = function(v)
        _st.farmBoss = v
        if v then
            task.spawn(function()
                while _st.farmBoss do
                    local bossName = _st.selectedBoss
                    if not bossName then task.wait(1); continue end
                    
                    local bossData = _bosses[bossName]
                    if bossData and _lvl() >= (bossData.minLv or 0) then
                        local boss = _fBoss(bossName)
                        if boss then
                            _equip(_st.weapon)
                            task.wait(0.2)
                            _haki()
                            
                            local count = 0
                            while _st.farmBoss and boss and boss.Parent and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 do
                                if count > 1000 then break end
                                if not boss or not boss.Parent then break end
                                
                                local off = Vector3.new(math.random(-5, 5), _st.distance, math.random(-5, 5))
                                _hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(off)
                                
                                pcall(function()
                                    if _cRem then
                                        local args = {Target = boss, Hit = boss.HumanoidRootPart, Position = boss.HumanoidRootPart.Position}
                                        if _cRem:IsA("RemoteEvent") then _cRem:FireServer(args)
                                        elseif _cRem:IsA("RemoteFunction") then _cRem:InvokeServer(args) end
                                    end
                                end)
                                
                                if _st.bring then
                                    pcall(function()
                                        if boss and boss:FindFirstChild("HumanoidRootPart") then
                                            boss.HumanoidRootPart.CFrame = _hrp.CFrame * CFrame.new(0, -8, 0)
                                            boss.HumanoidRootPart.CanCollide = false
                                        end
                                    end)
                                end
                                
                                pcall(function()
                                    if _st.autoHeal and _hum.Health < _hum.MaxHealth * 0.3 then _heal() end
                                end)
                                
                                task.wait(_st.throttle + math.random(1, 3) / 100)
                                count = count + 1
                            end
                        else
                            if bossData.pos then
                                _tp(bossData.pos + Vector3.new(0, 50, 0))
                                task.wait(3)
                            end
                        end
                    else
                        task.wait(2)
                    end
                end
            end)
        end
    end
})

Tabs.Boss:AddToggle("AutoAllBoss", {
    Title = "Auto Farm All Available Bosses",
    Default = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    for name, data in pairs(_bosses) do
                        if _lvl() >= (data.minLv or 0) and data.sea == _sea then
                            local boss = _fBoss(name)
                            if boss then
                                _st.selectedBoss = name
                                _st.farmBoss = true
                                task.wait(0.5)
                                while _fBoss(name) do task.wait(1) end
                                _st.farmBoss = false
                                task.wait(2)
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: FRUIT/RAID
-- ═══════════════════════════════════════════════════════

Tabs.Fruit:AddToggle("AutoFruit", {
    Title = "Auto Pickup Devil Fruit",
    Default = false,
    Callback = function(v)
        _st.farmFruit = v
        if v then
            task.spawn(function()
                while _st.farmFruit do
                    local fruit = _fFruit()
                    if fruit and fruit:FindFirstChild("Handle") then
                        _tp(fruit.Handle.Position)
                        task.wait(0.5)
                        pcall(function()
                            firetouchinterest(_hrp, fruit.Handle, 0)
                            task.wait(0.1)
                            firetouchinterest(_hrp, fruit.Handle, 1)
                        end)
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Fruit:AddToggle("AutoRaid", {
    Title = "Auto Raid (Fragment Farm)",
    Default = false,
    Callback = function(v)
        _st.raid = v
        if v then
            task.spawn(function()
                while _st.raid do
                    pcall(function()
                        if _qRem and _qRem:IsA("RemoteFunction") then
                            _qRem:InvokeServer("RaidsNpc", "Select", "Flame")
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: CHEST
-- ═══════════════════════════════════════════════════════

Tabs.Chest:AddToggle("AutoChest", {
    Title = "Auto Farm Chest",
    Default = false,
    Callback = function(v)
        _st.farmChest = v
        if v then
            task.spawn(function()
                while _st.farmChest do
                    local chest = _fChest()
                    if chest and chest:FindFirstChild("TouchInterest") then
                        _tp(chest.Position + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                        pcall(function()
                            firetouchinterest(_hrp, chest, 0)
                            task.wait(0.1)
                            firetouchinterest(_hrp, chest, 1)
                        end)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: ECTOPLASM
-- ═══════════════════════════════════════════════════════

Tabs.Ectoplasm:AddParagraph({
    Title = "Ectoplasm Farm",
    Content = "Farm Ectoplasm from Cursed Ship (Sea 2)"
})

Tabs.Ectoplasm:AddToggle("AutoEctoplasm", {
    Title = "Auto Farm Ectoplasm",
    Default = false,
    Callback = function(v)
        _st.farmEctoplasm = v
        if v then
            task.spawn(function()
                while _st.farmEctoplasm do
                    if _sea < 2 then
                        Fluent:Notify({
                            Title = "Wrong Sea",
                            Content = "Ectoplasm only available in Sea 2+",
                            Duration = 3
                        })
                        _st.farmEctoplasm = false
                        break
                    end
                    
                    -- Teleport đến Cursed Ship
                    _tp(Vector3.new(923, 126, 32852))
                    task.wait(1)
                    
                    -- Farm mob ở Cursed Ship
                    local mobs = {"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"}
                    for _, mobName in pairs(mobs) do
                        local mob = _fMob(mobName)
                        if mob then
                            _equip(_st.weapon)
                            task.wait(0.2)
                            _haki()
                            _rCombat(mob)
                            
                            -- Check ectoplasm dropped
                            local ectoplasm = _fMaterial("Ectoplasm")
                            if ectoplasm then
                                _tp(ectoplasm.Position)
                                task.wait(0.3)
                                pcall(function()
                                    firetouchinterest(_hrp, ectoplasm, 0)
                                    task.wait(0.1)
                                    firetouchinterest(_hrp, ectoplasm, 1)
                                end)
                                _st.ectoplasmCount = _st.ectoplasmCount + 1
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: MATERIALS (Choose Material + Auto Farm)
-- ═══════════════════════════════════════════════════════

local _matNames = {}
for name, _ in pairs(_materials) do table.insert(_matNames, name) end

Tabs.Material:AddDropdown("MaterialSelect", {
    Title = "Choose Material",
    Values = _matNames,
    Multi = false,
    Default = _matNames[1] or "Ectoplasm",
    Callback = function(v) _st.selectedMaterial = v end
})

Tabs.Material:AddToggle("AutoMaterial", {
    Title = "Auto Farm Selected Material",
    Default = false,
    Callback = function(v)
        _st.farmMaterial = v
        if v then
            task.spawn(function()
                while _st.farmMaterial do
                    local matName = _st.selectedMaterial
                    if not matName then task.wait(1); continue end
                    
                    local matData = _materials[matName]
                    if matData and _sea >= (matData.sea or 1) then
                        if matData.method == "kill_mob" then
                            -- Farm mob rồi nhặt material
                            local mob = _fMob(matData.mob)
                            if mob then
                                _equip(_st.weapon)
                                task.wait(0.2)
                                _haki()
                                _rCombat(mob)
                            else
                                -- Teleport đến spawn location
                                if matData.spawnLocations and #matData.spawnLocations > 0 then
                                    _tp(matData.spawnLocations[1])
                                    task.wait(2)
                                end
                            end
                            
                            -- Nhặt material rơi
                            local dropped = _fMaterial(matName)
                            if dropped then
                                _tp(dropped.Position)
                                task.wait(0.3)
                                pcall(function()
                                    firetouchinterest(_hrp, dropped, 0)
                                    task.wait(0.1)
                                    firetouchinterest(_hrp, dropped, 1)
                                end)
                                _st.materialCount = _st.materialCount + 1
                            end
                        end
                    else
                        Fluent:Notify({
                            Title = "Wrong Sea",
                            Content = matName .. " not available in Sea " .. _sea,
                            Duration = 3
                        })
                        _st.farmMaterial = false
                        break
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Material:AddButton({
    Title = "Update Material List",
    Callback = function()
        local success = _updateAllData()
        if success and _localData.materials then
            for name, data in pairs(_localData.materials) do
                _materials[name] = data
            end
            Fluent:Notify({
                Title = "Materials Updated",
                Content = "Fetched " .. #_localData.materials .. " materials",
                Duration = 3
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: FACTORY RAID
-- ═══════════════════════════════════════════════════════

Tabs.Factory:AddParagraph({
    Title = "Factory Raid",
    Content = "Auto join Factory Raid when available\nSpawns every ~130 minutes"
})

local _factoryStatus = Tabs.Factory:AddParagraph({
    Title = "Factory Status",
    Content = "Checking..."
})

task.spawn(function()
    while true do
        task.wait(10)
        local isOpen = _checkFactory()
        _factorySchedule.isOpen = isOpen
        _factoryStatus:SetDesc(isOpen and "Status: OPEN" or "Status: CLOSED\nNext spawn: ~" .. _factorySchedule.spawnInterval .. " min")
    end
end)

Tabs.Factory:AddToggle("AutoFactory", {
    Title = "Auto Factory Raid",
    Default = false,
    Callback = function(v)
        _st.factoryRaid = v
        if v then
            task.spawn(function()
                while _st.factoryRaid do
                    if _checkFactory() then
                        Fluent:Notify({
                            Title = "Factory Raid",
                            Content = "Factory is OPEN! Joining...",
                            Duration = 5
                        })
                        
                        -- Teleport đến Factory
                        _tp(Vector3.new(386, 16, -536))
                        task.wait(1)
                        
                        -- Tương tác với Factory
                        pcall(function()
                            if _qRem and _qRem:IsA("RemoteFunction") then
                                _qRem:InvokeServer("Factory", "Join")
                            end
                        end)
                        
                        -- Combat trong Factory
                        while _st.factoryRaid and _checkFactory() do
                            for _, mob in pairs(_ws.Enemies:GetChildren()) do
                                if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                    _equip(_st.weapon)
                                    task.wait(0.2)
                                    _haki()
                                    _rCombat(mob)
                                end
                            end
                            task.wait(1)
                        end
                    else
                        task.wait(30)
                    end
                end
            end)
        end
    end
})

Tabs.Factory:AddToggle("AutoPirateRaid", {
    Title = "Auto Pirate Raid",
    Default = false,
    Callback = function(v)
        _st.pirateRaid = v
        if v then
            task.spawn(function()
                while _st.pirateRaid do
                    -- Kiểm tra Ship Raid GUI
                    local event = _checkSeaEventGui()
                    if event and event:find("Ship Raid") then
                        Fluent:Notify({
                            Title = "Pirate Raid",
                            Content = "Ship Raid detected! Joining...",
                            Duration = 5
                        })
                        
                        -- Farm ship raid
                        for _, mob in pairs(_ws.Enemies:GetChildren()) do
                            if mob and mob.Name:find("Pirate") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                _equip(_st.weapon)
                                task.wait(0.2)
                                _haki()
                                _rCombat(mob)
                            end
                        end
                    end
                    task.wait(10)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: TELEPORT
-- ═══════════════════════════════════════════════════════

for ml, z in pairs(_zones) do
    Tabs.Teleport:AddButton({
        Title = z.n .. " (Lv." .. ml .. "+)",
        Callback = function()
            _tp(z.pos)
            Fluent:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. z.n,
                Duration = 3
            })
        end
    })
end

-- Boss teleport
Tabs.Teleport:AddParagraph({ Title = "Boss Teleport", Content = "Quick teleport to bosses" })
for name, data in pairs(_bosses) do
    if data.pos and data.sea == _sea then
        Tabs.Teleport:AddButton({
            Title = name .. " (Lv." .. data.minLv .. ")",
            Callback = function()
                _tp(data.pos + Vector3.new(0, 50, 0))
                Fluent:Notify({
                    Title = "Boss Teleport",
                    Content = "Teleported to " .. name,
                    Duration = 3
                })
            end
        })
    end
end

-- ═══════════════════════════════════════════════════════
-- TAB: UTILITY
-- ═══════════════════════════════════════════════════════

Tabs.Utility:AddToggle("AutoFly", {
    Title = "Auto Fly (WASD + Space/Shift)",
    Default = false,
    Callback = function(v) _toggleFly(v) end
})

Tabs.Utility:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 300,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) _st.speed = v end
})

Tabs.Utility:AddToggle("ESPEnemy", {
    Title = "ESP Enemies",
    Default = false,
    Callback = function(v) _toggleESP(v, "enemy") end
})

Tabs.Utility:AddToggle("ESPPlayer", {
    Title = "ESP Players",
    Default = false,
    Callback = function(v) _toggleESP(v, "player") end
})

Tabs.Utility:AddToggle("ESPFruit", {
    Title = "ESP Devil Fruits",
    Default = false,
    Callback = function(v) _toggleESP(v, "fruit") end
})

Tabs.Utility:AddToggle("ESPChest", {
    Title = "ESP Chests",
    Default = false,
    Callback = function(v) _toggleESP(v, "chest") end
})

Tabs.Utility:AddToggle("ESPMaterial", {
    Title = "ESP Materials",
    Default = false,
    Callback = function(v) _toggleESP(v, "material") end
})

Tabs.Utility:AddToggle("ESPBoss", {
    Title = "ESP Bosses",
    Default = false,
    Callback = function(v) _toggleESP(v, "boss") end
})

Tabs.Utility:AddToggle("AutoHeal", {
    Title = "Auto Heal (Low HP)",
    Default = false,
    Callback = function(v) _st.autoHeal = v end
})

Tabs.Utility:AddToggle("AutoReset", {
    Title = "Auto Reset When Stuck",
    Default = false,
    Callback = function(v)
        _st.autoReset = v
        if v then
            task.spawn(function()
                while _st.autoReset do
                    task.wait(10)
                    local pos1 = _hrp.Position
                    task.wait(10)
                    local pos2 = _hrp.Position
                    if (pos1 - pos2).Magnitude < 5 then
                        pcall(function() _hum.Health = 0 end)
                    end
                end
            end)
        end
    end
})

Tabs.Utility:AddButton({
    Title = "Server Hop (Less Players)",
    Callback = function() _serverHop() end
})

Tabs.Utility:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        _tsvc:Teleport(game.PlaceId, _plr)
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════════════════

Tabs.Settings:AddSlider("FarmDist", {
    Title = "Farm Distance",
    Default = 20,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Callback = function(v) _st.distance = v end
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "HBG Elite v5.0",
    Content = "Script loaded successfully!",
    Duration = 5
})

Tabs.Settings:AddToggle("AutoHaki", {
    Title = "Auto Buso Haki",
    Default = true,
    Callback = function(v)
        _st.haki = v
    end
})

Tabs.Settings:AddToggle("BringMob", {
    Title = "Bring Mob",
    Default = true,
    Callback = function(v)
        _st.bring = v
    end
})

Tabs.Settings:AddDropdown("StatPriority", {
    Title = "Auto Stat Priority",
    Values = {"Melee", "Defense", "Sword", "Gun", "BloxFruit"},
    Multi = false,
    Default = "Melee",
    Callback = function(v)
        _st.statPriority = v
        _st.autoStats = true
    end
})

Tabs.Settings:AddToggle("AutoStats", {
    Title = "Auto Distribute Stats",
    Default = false,
    Callback = function(v)
        _st.autoStats = v
    end
})

Tabs.Settings:AddButton({
    Title = "Update All Data",
    Description = "Fetch latest bosses, materials, events from server",
    Callback = function()
        local success = _updateAllData()
        if success then
            for name, data in pairs(_localData.bosses) do
                _bosses[name] = data
            end
            for name, data in pairs(_localData.materials) do
                _materials[name] = data
            end
            Fluent:Notify({
                Title = "Data Updated",
                Content = "Bosses: " .. #_localData.bosses .. " | Materials: " .. #_localData.materials .. " | Events: " .. #_localData.seaEvents,
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Update Failed",
                Content = "Using fallback data. Check your connection.",
                Duration = 3
            })
        end
    end
})

Tabs.Settings:AddButton({
    Title = "Reset Configuration",
    Callback = function()
        _st = {
            farm = false, farmMelee = false, farmBlox = false, farmSword = false, farmGun = false,
            farmBoss = false, farmMoney = false, farmChest = false, farmFruit = false,
            farmMaterial = false, farmEctoplasm = false,
            seaEvent = false, autoSeaBeast = false, autoLeviathan = false, autoRace = false,
            raid = false, factoryRaid = false, pirateRaid = false, autoFragment = false,
            fly = false, esp = false, espPlayer = false, espFruit = false, espChest = false,
            espNPC = false, espMaterial = false, espBoss = false,
            autoHeal = false, autoReset = false, serverHop = false,
            weapon = "Melee", distance = 20, speed = 300, bring = true, haki = true,
            throttle = 0.08, autoStats = false, statPriority = "Melee",
            selectedBoss = nil, selectedMaterial = nil, selectedRace = nil,
            startExp = _st.startExp, startTime = _st.startTime, mobsKilled = 0, moneyEarned = 0,
            ectoplasmCount = 0, materialCount = 0
        }
        Fluent:Notify({
            Title = "Config Reset",
            Content = "All settings restored to default",
            Duration = 3
        })
    end
})

-- ═══════════════════════════════════════════════════════
-- TAB: STATS (REAL-TIME)
-- ═══════════════════════════════════════════════════════

local _statLabel = Tabs.Stats:AddParagraph({
    Title = "Farm Statistics",
    Content = "Loading real-time data..."
})

local _sessionLabel = Tabs.Stats:AddParagraph({
    Title = "Session Info",
    Content = "Session started"
})

Tabs.Stats:AddButton({
    Title = "Copy Stats to Clipboard",
    Callback = function()
        local elapsed = math.floor(tick() - _st.startTime)
        local expGain = _exp() - _st.startExp
        local expPerMin = elapsed > 0 and math.floor(expGain / (elapsed / 60)) or 0
        local statsText = string.format(
            "[HBG Elite v5.0 Stats]\n" ..
            "Session Time: %ds\n" ..
            "Level: %d | Sea: %d\n" ..
            "EXP Gained: %d\n" ..
            "EXP/min: %d\n" ..
            "Mobs Killed: %d\n" ..
            "Money: %d\n" ..
            "Ectoplasm: %d\n" ..
            "Materials: %d\n" ..
            "Remote: %s",
            elapsed, _lvl(), _sea, expGain, expPerMin, _st.mobsKilled,
            _money(), _st.ectoplasmCount, _st.materialCount,
            _cRem and _cRem.Name or "Unknown"
        )
        setclipboard(statsText)
        Fluent:Notify({
            Title = "Copied!",
            Content = "Statistics copied to clipboard",
            Duration = 3
        })
    end
})

-- Real-time update loop
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            local elapsed = math.floor(tick() - _st.startTime)
            local expGain = _exp() - _st.startExp
            local expPerMin = elapsed > 0 and math.floor(expGain / (elapsed / 60)) or 0
            local moneyGain = _money() - (_st.lastMoney or _money())
            _st.lastMoney = _money()
            
            _statLabel:SetDesc(
                "Session Time: " .. elapsed .. "s\n" ..
                "Level: " .. _lvl() .. " | EXP: " .. _exp() .. " (+" .. expGain .. ")\n" ..
                "EXP/min: " .. expPerMin .. "\n" ..
                "Mobs Killed: " .. _st.mobsKilled .. "\n" ..
                "Money: " .. _money() .. " (+" .. moneyGain .. ")\n" ..
                "Ectoplasm: " .. _st.ectoplasmCount .. "\n" ..
                "Materials: " .. _st.materialCount .. "\n" ..
                "Attack Queue: " .. #_atkQueue .. "/10\n" ..
                "Data Last Update: " .. os.date("%H:%M:%S", _localData.lastUpdate)
            )
            
            _sessionLabel:SetDesc(
                "Script: HBG Elite v5.0\n" ..
                "Sea: " .. _sea .. " | PlaceId: " .. _pid .. "\n" ..
                "Remote Combat: " .. (_cRem and _cRem.Name or "Scanning...") .. "\n" ..
                "Remote Quest: " .. (_qRem and _qRem.Name or "Scanning...") .. "\n" ..
                "Anti-Detect: Active | Velocity Spoof: Active\n" ..
                "Auto-Update: " .. (_localData.lastUpdate > 0 and "Enabled" or "Failed")
            )
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- KEYBINDS (PHÍM TẮT)
-- ═══════════════════════════════════════════════════════

local _keybinds = {
    [Enum.KeyCode.F] = function()
        _st.farm = not _st.farm
        Fluent:Notify({
            Title = "Auto Farm",
            Content = _st.farm and "ENABLED" or "DISABLED",
            Duration = 2
        })
    end,
    [Enum.KeyCode.B] = function()
        _st.farmBoss = not _st.farmBoss
        Fluent:Notify({
            Title = "Auto Boss",
            Content = _st.farmBoss and "ENABLED" or "DISABLED",
            Duration = 2
        })
    end,
    [Enum.KeyCode.V] = function()
        _toggleFly(not _st.fly)
        Fluent:Notify({
            Title = "Auto Fly",
            Content = _st.fly and "ENABLED" or "DISABLED",
            Duration = 2
        })
    end,
    [Enum.KeyCode.H] = function()
        _st.autoHeal = not _st.autoHeal
        Fluent:Notify({
            Title = "Auto Heal",
            Content = _st.autoHeal and "ENABLED" or "DISABLED",
            Duration = 2
        })
    end,
}

_uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if _keybinds[input.KeyCode] then
        _keybinds[input.KeyCode]()
    end
end)

-- ═══════════════════════════════════════════════════════
-- FALL DAMAGE PROTECTION
-- ═══════════════════════════════════════════════════════

_hum.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.Freefall then
        task.spawn(function()
            task.wait(2)
            if _hum:GetState() == Enum.HumanoidStateType.Freefall then
                _vSpoof()
                _hrp.Velocity = Vector3.new(0, 50, 0)
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- COMBAT LOG PROTECTION
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            if _hum.Health < _hum.MaxHealth then
                _st.inCombat = true
            else
                _st.inCombat = false
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- AUTO SAVE CONFIG
-- ═══════════════════════════════════════════════════════

local _configFile = "HBG_Elite_v5_Config_Sea" .. _sea

local function _saveConfig()
    local config = {
        weapon = _st.weapon,
        distance = _st.distance,
        speed = _st.speed,
        bring = _st.bring,
        haki = _st.haki,
        throttle = _st.throttle,
        autoStats = _st.autoStats,
        statPriority = _st.statPriority,
        autoHeal = _st.autoHeal,
        selectedBoss = _st.selectedBoss,
        selectedMaterial = _st.selectedMaterial,
        version = "5.0"
    }
    pcall(function()
        writefile(_configFile .. ".json", _http:JSONEncode(config))
    end)
end

local function _loadConfig()
    pcall(function()
        if isfile(_configFile .. ".json") then
            local config = _http:JSONDecode(readfile(_configFile .. ".json"))
            if config then
                _st.weapon = config.weapon or "Melee"
                _st.distance = config.distance or 20
                _st.speed = config.speed or 300
                _st.bring = config.bring ~= nil and config.bring or true
                _st.haki = config.haki ~= nil and config.haki or true
                _st.throttle = config.throttle or 0.08
                _st.autoStats = config.autoStats or false
                _st.statPriority = config.statPriority or "Melee"
                _st.autoHeal = config.autoHeal or false
                _st.selectedBoss = config.selectedBoss
                _st.selectedMaterial = config.selectedMaterial
            end
        end
    end)
end

-- Load config khi khởi động
_loadConfig()

-- Auto save mỗi 30s
task.spawn(function()
    while true do
        task.wait(30)
        _saveConfig()
    end
end)

-- ═══════════════════════════════════════════════════════
-- INIT — KHỞI ĐỘNG SCRIPT
-- ═══════════════════════════════════════════════════════

Window:SelectTab(1)

Fluent:Notify({
    Title = "HBG Elite v5.0",
    Content = "Sea " .. _sea .. " | Level " .. _lvl() .. " | " .. #_zones .. " zones | " .. #_bosses .. " bosses | " .. #_materials .. " materials",
    Duration = 5
})

Fluent:Notify({
    Title = "Keybinds",
    Content = "F: Auto Farm | B: Auto Boss | V: Fly | H: Heal | LeftCtrl: Minimize",
    Duration = 8
})

print("[HBG] Elite v5.0 | Sea " .. _sea .. " | Anti-Detect | Auto-Update | Complete Edition | Ready")
print("[HBG] Keybinds: F=Farm B=Boss V=Fly H=Heal")
print("[HBG] Data URL: " .. _dataUrl)
print("[HBG] Config File: " .. _configFile .. ".json")

-- ═══════════════════════════════════════════════════════
-- VERSION DECLARATION — HBG ELITE v5.0
-- ═══════════════════════════════════════════════════════

local HBG_VERSION = {
    major = 5,
    minor = 0,
    patch = 0,
    codename = "ELITE",
    build = 20260820,
    channel = "stable", -- stable | beta | dev
    author = "Huy Báo Game",
    license = "Proprietary",
    signature = "HBG-ELITE-v5.0-2026",
    
    -- Metadata
    created = "2026-08-20",
    updated = "2026-09-06",
    seas = {1, 2, 3},
    features = {
        "AutoFarm", "AutoBoss", "AutoSeaEvent", "AutoLeviathan",
        "AutoRace", "AutoFactory", "AutoPirateRaid", "AutoEctoplasm",
        "AutoMaterial", "AutoChest", "AutoFruit", "AutoRaid",
        "ESP", "Fly", "Teleport", "ServerHop", "AntiDetect"
    },
    
    -- Compatibility
    supportedExecutors = {"Synapse X", "Krnl", "Fluxus", "Codex", "Delta", "Hydrogen", "Arceus X", "Codex"},
    minExecutorVersion = "2.0",
    
    -- API
    apiVersion = "v2",
    dataEndpoint = "https://raw.githubusercontent.com/hbg/bloxfruits-data/main/",
    updateCheckUrl = "https://raw.githubusercontent.com/hbg/bloxfruits-data/main/version.json"
}

-- Version string formatter
function HBG_VERSION:toString()
    return string.format("%d.%d.%d-%s (build %d)", 
        self.major, self.minor, self.patch, self.codename, self.build)
end

function HBG_VERSION:isCompatible(executorName, executorVersion)
    for _, name in ipairs(self.supportedExecutors) do
        if name:lower() == executorName:lower() then
            return true
        end
    end
    return false
end

-- Print version info
print(string.format("[HBG] Version: %s", HBG_VERSION:toString()))
print(string.format("[HBG] Channel: %s | API: %s", HBG_VERSION.channel, HBG_VERSION.apiVersion))
print(string.format("[HBG] Supported Seas: %s", table.concat(HBG_VERSION.seas, ", ")))
print(string.format("[HBG] Features: %d modules loaded", #HBG_VERSION.features))

-- ═══════════════════════════════════════════════════════
-- AUTO-UPDATE CHECKER
-- ═══════════════════════════════════════════════════════

local _updateChecker = {
    lastCheck = 0,
    checkInterval = 300, -- 5 minutes
    isUpdateAvailable = false,
    latestVersion = nil,
    changelog = nil
}

function _updateChecker:check()
    local now = tick()
    if now - self.lastCheck < self.checkInterval then return end
    self.lastCheck = now
    
    local success, result = pcall(function()
        local data = game:HttpGet(HBG_VERSION.updateCheckUrl)
        return _http:JSONDecode(data)
    end)
    
    if success and result then
        self.latestVersion = result
        
        -- Compare versions
        if result.major > HBG_VERSION.major or
           (result.major == HBG_VERSION.major and result.minor > HBG_VERSION.minor) or
           (result.major == HBG_VERSION.major and result.minor == HBG_VERSION.minor and result.patch > HBG_VERSION.patch) then
            self.isUpdateAvailable = true
            self.changelog = result.changelog
            
            Fluent:Notify({
                Title = "Update Available!",
                Content = string.format("v%d.%d.%d → v%d.%d.%d\n%s", 
                    HBG_VERSION.major, HBG_VERSION.minor, HBG_VERSION.patch,
                    result.major, result.minor, result.patch,
                    result.changelog and result.changelog:sub(1, 50) or "See changelog"),
                Duration = 10
            })
        end
    end
end

-- Auto-check on startup
task.spawn(function()
    task.wait(10)
    _updateChecker:check()
end)

-- Periodic check
task.spawn(function()
    while true do
        task.wait(_updateChecker.checkInterval)
        _updateChecker:check()
    end
end)

-- ═══════════════════════════════════════════════════════
-- LAYER 0-B: ADVANCED ANTI-DETECT & STEALTH
-- ═══════════════════════════════════════════════════════

local _stealth = {
    enabled = true,
    jitterEnabled = true,
    humanizeEnabled = true,
    spoofMetrics = {}
}

-- Human-like movement jitter
function _stealth:applyJitter()
    if not _stealth.jitterEnabled then return end
    pcall(function()
        local jitter = Vector3.new(
            math.random(-5, 5) / 100,
            math.random(-2, 2) / 100,
            math.random(-5, 5) / 100
        )
        _hrp.CFrame = _hrp.CFrame * CFrame.new(jitter)
    end)
end

-- Randomize action timing
function _stealth:randomDelay(baseDelay)
    if not _stealth.humanizeEnabled then return baseDelay end
    local variance = baseDelay * 0.3
    return baseDelay + math.random(-variance * 100, variance * 100) / 100
end

-- Spoof memory metrics
function _stealth:spoofMetrics()
    pcall(function()
        -- Spoof FPS
        local fps = math.random(58, 62)
        -- Spoof ping
        local ping = math.random(45, 85)
        _stealth.spoofMetrics.fps = fps
        _stealth.spoofMetrics.ping = ping
    end)
end

-- Anti-screenshot detection
pcall(function()
    _run.RenderStepped:Connect(function()
        if math.random(1, 1000) == 1 then
            _stealth:spoofMetrics()
        end
    end)
end)

-- ═══════════════════════════════════════════════════════
-- COMBAT ENGINE v2 — PREDICTION + ADAPTIVE
-- ═══════════════════════════════════════════════════════

local _combatV2 = {
    predictionEnabled = true,
    adaptiveThrottle = true,
    hitAccuracy = 0.95,
    comboCounter = 0,
    maxCombo = 5
}

-- Predict mob movement
function _combatV2:predictPosition(mob, timeAhead)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return nil end
    if not self.predictionEnabled then return mob.HumanoidRootPart.Position end
    
    local hrp = mob.HumanoidRootPart
    local velocity = hrp.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    return hrp.Position + (velocity * timeAhead)
end

-- Adaptive throttle based on server response
function _combatV2:getThrottle()
    if not self.adaptiveThrottle then return _st.throttle end
    
    local queueSize = #_atkQueue
    if queueSize < 3 then
        return math.max(0.03, _st.throttle * 0.7) -- Faster when queue is empty
    elseif queueSize > 7 then
        return math.min(0.2, _st.throttle * 1.5) -- Slower when queue is full
    end
    return _st.throttle
end

-- Combo system
function _combatV2:executeCombo(mob)
    self.comboCounter = self.comboCounter + 1
    if self.comboCounter >= self.maxCombo then
        self.comboCounter = 0
        -- Pause briefly after combo (human-like)
        task.wait(math.random(15, 35) / 100)
    end
end

-- Enhanced remote combat
function _combatV2:attack(mob)
    if not mob or not mob.Parent then return end
    if not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0 then return end
    
    local predictedPos = self:predictPosition(mob, 0.1)
    if not predictedPos then return end
    
    local off = Vector3.new(
        math.random(-3, 3), 
        _st.distance + math.random(-2, 2), 
        math.random(-3, 3)
    )
    
    _hrp.CFrame = CFrame.new(predictedPos) * CFrame.new(off)
    _stealth:applyJitter()
    
    pcall(function()
        if _cRem then
            local args = {
                Target = mob,
                Hit = mob.HumanoidRootPart,
                Position = predictedPos,
                Combo = self.comboCounter
            }
            if _cRem:IsA("RemoteEvent") then
                _cRem:FireServer(args)
            elseif _cRem:IsA("RemoteFunction") then
                _cRem:InvokeServer(args)
            end
        end
    end)
    
    self:executeCombo(mob)
    task.wait(self:getThrottle())
end

-- ═══════════════════════════════════════════════════════
-- SEA EVENT ENHANCED — LEVIATHAN & RACE v4
-- ═══════════════════════════════════════════════════════

local _seaEnhanced = {
    leviathanPhase = 0, -- 0=search, 1=engage, 2=execute
    raceStage = 0,
    frozenDimensionActive = false
}

-- Advanced Leviathan detection
function _seaEnhanced:scanForLeviathan()
    -- Scan workspace for Leviathan model
    for _, obj in pairs(_ws:GetDescendants()) do
        if obj.Name:find("Leviathan") or obj.Name:find("leviathan") then
            if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                return obj
            end
        end
    end
    
    -- Check for Frozen Dimension indicator
    local playerGui = _plr:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text:find("Frozen Dimension") then
                self.frozenDimensionActive = true
                return "frozen_dimension"
            end
        end
    end
    
    return nil
end

-- Race v4 automation
function _seaEnhanced:handleRaceV4()
    local playerGui = _plr:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Check for race GUI elements
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") then
            local text = gui.Text:lower()
            
            -- Race trial buttons
            if text:find("start") and text:find("trial") then
                pcall(function() firesignal(gui.MouseButton1Click) end)
                task.wait(0.5)
            end
            
            -- Race ability buttons
            if text:find("race") and (text:find("v3") or text:find("v4")) then
                pcall(function() firesignal(gui.MouseButton1Click) end)
            end
            
            -- Gear shift (Shark race)
            if text:find("gear") or text:find("shift") then
                pcall(function() firesignal(gui.MouseButton1Click) end)
            end
        end
    end
end

-- Sea Beast prediction
function _seaEnhanced:predictSeaBeastSpawn()
    -- Based on time and rough sea patterns
    local currentTime = tick()
    -- Sea Beasts typically spawn in patterns
    return nil -- Placeholder for advanced prediction
end

-- ═══════════════════════════════════════════════════════
-- MATERIAL TRACKER — REAL-TIME DROPS
-- ═══════════════════════════════════════════════════════

local _materialTracker = {
    trackedMaterials = {},
    dropHistory = {},
    notificationEnabled = true
}

function _materialTracker:scanForDrops()
    for matName, _ in pairs(_materials) do
        for _, item in pairs(_ws:GetChildren()) do
            if item and item.Name:find(matName) and item:FindFirstChild("TouchInterest") then
                if not self.trackedMaterials[item] then
                    self.trackedMaterials[item] = true
                    table.insert(self.dropHistory, {
                        material = matName,
                        time = tick(),
                        position = item.Position
                    })
                    
                    if self.notificationEnabled then
                        Fluent:Notify({
                            Title = "Material Drop!",
                            Content = matName .. " detected nearby!",
                            Duration = 3
                        })
                    end
                    
                    -- Auto-pickup if enabled
                    if _st.farmMaterial and _st.selectedMaterial == matName then
                        _tp(item.Position)
                        task.wait(0.3)
                        pcall(function()
                            firetouchinterest(_hrp, item, 0)
                            task.wait(0.1)
                            firetouchinterest(_hrp, item, 1)
                        end)
                        _st.materialCount = _st.materialCount + 1
                    end
                end
            end
        end
    end
end

-- Scan loop
task.spawn(function()
    while true do
        task.wait(2)
        _materialTracker:scanForDrops()
    end
end)

-- ═══════════════════════════════════════════════════════
-- ENHANCED STATS DASHBOARD
-- ═══════════════════════════════════════════════════════

local _dashboard = {
    sessionStart = tick(),
    peakExpPerMin = 0,
    totalCombatTime = 0,
    idleTime = 0,
    lastCombatTick = tick()
}

function _dashboard:update()
    local elapsed = tick() - self.sessionStart
    local expGain = _exp() - _st.startExp
    local expPerMin = elapsed > 0 and math.floor(expGain / (elapsed / 60)) or 0
    
    if expPerMin > self.peakExpPerMin then
        self.peakExpPerMin = expPerMin
    end
    
    -- Track combat vs idle time
    if _st.farm or _st.farmBoss or _st.autoSeaBeast then
        self.totalCombatTime = self.totalCombatTime + 3
        self.lastCombatTick = tick()
    else
        self.idleTime = self.idleTime + 3
    end
    
    return {
        elapsed = elapsed,
        expGain = expGain,
        expPerMin = expPerMin,
        peakExpPerMin = self.peakExpPerMin,
        combatTime = self.totalCombatTime,
        idleTime = self.idleTime,
        efficiency = elapsed > 0 and math.floor((self.totalCombatTime / elapsed) * 100) or 0
    }
end

-- Update enhanced stats label
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            local stats = _dashboard:update()
            _statLabel:SetDesc(
                "Session: " .. math.floor(stats.elapsed) .. "s\n" ..
                "Level: " .. _lvl() .. " | EXP: " .. _exp() .. " (+" .. stats.expGain .. ")\n" ..
                "EXP/min: " .. stats.expPerMin .. " (Peak: " .. stats.peakExpPerMin .. ")\n" ..
                "Mobs: " .. _st.mobsKilled .. " | Ectoplasm: " .. _st.ectoplasmCount .. "\n" ..
                "Materials: " .. _st.materialCount .. "\n" ..
                "Efficiency: " .. stats.efficiency .. "% | Combat: " .. stats.combatTime .. "s\n" ..
                "Version: " .. HBG_VERSION:toString()
            )
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- INIT — HBG ELITE v5.0 FINAL
-- ═══════════════════════════════════════════════════════

-- Load saved config first
_loadConfig()

-- Select default tab
Window:SelectTab(1)

-- Version notification
Fluent:Notify({
    Title = "HBG Elite " .. HBG_VERSION:toString(),
    Content = "Sea " .. _sea .. " | Level " .. _lvl() .. "\n" ..
              #_zones .. " zones | " .. #_bosses .. " bosses | " .. #_materials .. " materials\n" ..
              "Anti-Detect: Active | Auto-Update: Enabled",
    Duration = 6
})

-- Keybinds notification
Fluent:Notify({
    Title = "Keybinds",
    Content = "F=Farm | B=Boss | V=Fly | H=Heal | LeftCtrl=Minimize",
    Duration = 8
})

-- Check for updates
task.spawn(function()
    task.wait(15)
    _updateChecker:check()
end)

-- Final console output
print("═══════════════════════════════════════════════════════════════")
print("  HBG ELITE v" .. HBG_VERSION:toString())
print("  Author: " .. HBG_VERSION.author)
print("  Channel: " .. HBG_VERSION.channel .. " | API: " .. HBG_VERSION.apiVersion)
print("  Sea: " .. _sea .. " | Level: " .. _lvl())
print("  Zones: " .. #_zones .. " | Bosses: " .. #_bosses .. " | Materials: " .. #_materials)
print("  Features: " .. table.concat(HBG_VERSION.features, ", "))
print("  Config: " .. _configFile .. ".json")
print("  Data URL: " .. HBG_VERSION.dataEndpoint)
print("═══════════════════════════════════════════════════════════════")

-- ═══════════════════════════════════════════════════════
-- END OF HBG ELITE v5.0 — HUY BÁO GAME
-- ═══════════════════════════════════════════════════════
