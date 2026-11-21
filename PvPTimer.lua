-- PvPTimer: shows a countdown while your PvP flag is about to drop.

local ADDON = ...
local UPDATE_INTERVAL = 0.1

local frame = CreateFrame("Frame", "PvPTimerFrame", UIParent, "BackdropTemplate")
frame:SetSize(110, 50)
frame:SetFrameStrata("MEDIUM")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(false)
frame:RegisterForDrag("LeftButton")
frame:Hide()

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, 0.6)
frame:SetBackdropBorderColor(0.8, 0.1, 0.1, 0.9)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -7)
title:SetText("PvP: ON")

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("BOTTOM", 0, 7)

-- Quick pulse used when the timer resets
local pulse = frame:CreateAnimationGroup()
local fadeOut = pulse:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1); fadeOut:SetToAlpha(0.2); fadeOut:SetDuration(0.15); fadeOut:SetOrder(1)
local fadeIn = pulse:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0.2); fadeIn:SetToAlpha(1); fadeIn:SetDuration(0.15); fadeIn:SetOrder(2)
pulse:SetLooping("NONE")

local lastSecs -- remaining time seen on the previous update

local function OnTimerReset()
    pulse:Stop()
    pulse:Play()
    if PvPTimerDB.sound then
        PlaySound(SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959, "Master")
    end
end

local function IsSecret(v)
    return issecretvalue and issecretvalue(v)
end

local function FormatTime(seconds)
    seconds = math.max(0, math.ceil(seconds))
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function SavePosition()
    local point, _, relPoint, x, y = frame:GetPoint()
    PvPTimerDB.point = { point, relPoint, x, y }
end

local function RestorePosition()
    frame:ClearAllPoints()
    local p = PvPTimerDB.point
    if p then
        frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -120)
    end
end

local function SetLocked(locked)
    PvPTimerDB.locked = locked
    frame:EnableMouse(not locked)
end

-- Returns: state ("timer", "flagged" or nil), secondsLeft
local function GetState()
    local flagged = UnitIsPVP("player")
    if IsSecret(flagged) or not flagged then
        return nil
    end
    if IsPVPTimerRunning and IsPVPTimerRunning() then
        local ms = GetPVPTimer()
        if not IsSecret(ms) and ms and ms > 0 then
            return "timer", ms / 1000
        end
    end
    return "flagged"
end

local elapsedSince = 0
local function Refresh()
    local state, secs = GetState()

    if state == "timer" then
        -- Reflagged: the game pushes the timer back up, so restart our display
        if lastSecs and secs > lastSecs + 1 then
            OnTimerReset()
        end
        lastSecs = secs
        title:SetTextColor(1, 0.25, 0.25)
        text:SetText(FormatTime(secs))
        if secs <= 30 then
            text:SetTextColor(0.2, 1, 0.2)      -- almost free
        elseif secs <= 60 then
            text:SetTextColor(1, 0.85, 0)       -- under a minute
        else
            text:SetTextColor(1, 0.25, 0.25)
        end
        frame:Show()
        return
    end

    -- Not counting down (e.g. re-engaged in PvP): next countdown starts fresh at 5:00
    lastSecs = nil

    if state == "flagged" and PvPTimerDB.showFlagged then
        -- Flagged but the game isn't counting down yet: hold at the full 5:00
        title:SetTextColor(1, 0.25, 0.25)
        text:SetText("5:00")
        text:SetTextColor(1, 0.25, 0.25)
        frame:Show()
    elseif not PvPTimerDB.locked then
        -- keep visible while unlocked so it can be positioned
        title:SetTextColor(0.7, 0.7, 0.7)
        text:SetText("5:00")
        text:SetTextColor(0.7, 0.7, 0.7)
        frame:Show()
    else
        frame:Hide()
    end
end

frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedSince = elapsedSince + elapsed
    if elapsedSince >= UPDATE_INTERVAL then
        elapsedSince = 0
        Refresh()
    end
end)

frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

-- Events: a hidden driver frame so we still get events while the display is hidden
local driver = CreateFrame("Frame")
driver:RegisterEvent("ADDON_LOADED")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("PLAYER_FLAGS_CHANGED")
driver:RegisterEvent("UNIT_FACTION")
driver:RegisterEvent("ZONE_CHANGED_NEW_AREA")

driver:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        PvPTimerDB = PvPTimerDB or {}
        if PvPTimerDB.locked == nil then PvPTimerDB.locked = true end
        if PvPTimerDB.showFlagged == nil then PvPTimerDB.showFlagged = true end
        if PvPTimerDB.sound == nil then PvPTimerDB.sound = false end
        RestorePosition()
        SetLocked(PvPTimerDB.locked)
        return
    end
    if (event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FACTION") and arg1 ~= "player" then
        return
    end
    if PvPTimerDB then Refresh() end
end)

-- Slash commands
SLASH_PVPTIMER1 = "/pvptimer"
SLASH_PVPTIMER2 = "/pvpt"
SlashCmdList.PVPTIMER = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "unlock" then
        SetLocked(false)
        print("|cffff4040PvPTimer|r unlocked - drag to move, /pvpt lock when done.")
    elseif msg == "lock" then
        SetLocked(true)
        print("|cffff4040PvPTimer|r locked.")
    elseif msg == "reset" then
        PvPTimerDB.point = nil
        RestorePosition()
        print("|cffff4040PvPTimer|r position reset.")
    elseif msg == "flagged" then
        PvPTimerDB.showFlagged = not PvPTimerDB.showFlagged
        print("|cffff4040PvPTimer|r show 5:00 while flagged before the countdown starts: " ..
            (PvPTimerDB.showFlagged and "on" or "off"))
    elseif msg == "sound" then
        PvPTimerDB.sound = not PvPTimerDB.sound
        print("|cffff4040PvPTimer|r sound on timer reset: " ..
            (PvPTimerDB.sound and "on" or "off"))
    else
        print("|cffff4040PvPTimer|r commands: /pvpt unlock | lock | reset | flagged | sound")
    end
    Refresh()
end
