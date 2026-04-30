--// FEVHub GOD MODE (Clean / Original / Modular)

--================ SERVICES =================--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--================ THEME =================--
local Theme = {
    Primary = Color3.fromRGB(150, 90, 255),
    Dark    = Color3.fromRGB(18,18,28),
    Light   = Color3.fromRGB(40,40,60),
    Accent  = Color3.fromRGB(90,60,180),
    Text    = Color3.fromRGB(255,255,255)
}

--================ ENGINE =================--
local Engine = {
    State = {},
    Events = {},
    Modules = {}
}

function Engine:On(evt, fn)
    self.Events[evt] = self.Events[evt] or {}
    table.insert(self.Events[evt], fn)
end

function Engine:Emit(evt, ...)
    local list = self.Events[evt]
    if not list then return end
    for _, fn in ipairs(list) do
        task.spawn(fn, ...)
    end
end

function Engine:Set(k, v)
    self.State[k] = v
    self:Emit("stateChanged", k, v)
    self:_debouncedSave()
end

function Engine:Get(k) return self.State[k] end

--================ CONFIG =================--
local FILE = "fevhub_clean.json"

function Engine:Load()
    if isfile and isfile(FILE) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FILE))
        end)
        if ok and type(data) == "table" then
            self.State = data
        end
    end
end

function Engine:Save()
    if writefile then
        writefile(FILE, HttpService:JSONEncode(self.State))
    end
end

local saveTick = 0
function Engine:_debouncedSave()
    saveTick += 1
    local id = saveTick
    task.delay(0.8, function()
        if id == saveTick then
            Engine:Save()
        end
    end)
end

Engine:Load()

--================ UI ROOT =================--
local gui = Instance.new("ScreenGui")
gui.Name = "FEVHubClean"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.42,0,0.52,0) -- mobile-friendly
main.Position = UDim2.new(0.5,0,0.5,0)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Theme.Dark
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

--================ TITLE + DRAG =================--
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "FEVHub X"
title.TextColor3 = Theme.Primary
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

do
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
        
