local Control      = require "HydroNV/Control"
local ChargeUI     = require "HydroNV/ChargeUI"
local Daylight     = require "HydroNV/Daylight"
local Debug        = require "HydroNV/Debug"
local Hooks        = require "HydroNV/Hooks"
local NVAPIPatch   = require "HydroNV/NVAPIPatch"
local ShaderBridge = require "HydroNV/ShaderBridge"
local VisionBoost  = require "HydroNV/VisionBoost"
local ModKeymap   = require "ModKeymap_Main"
local Sound       = require "NVAPI/item/ItemSound"

local initialized = false
local updateTick  = 0

local function registerKeybind()
  local keymap = ModKeymap.getInstance("NVG")
  keymap:add("ToggleNightVision", function()
    Control:toggle()
  end, 49)

  keymap:add("HydroNV_ToggleDaylightTest", function()
    Debug:toggleSessionTest()
  end, 21)
end

local function onGameStart()
  if not initialized then
    NVAPIPatch.apply()
    initialized = true
  end

  Hooks.install()
  ChargeUI.install()
  Control:clear()
  Debug:notifyStartupState()
end

Events.OnGameStart.Add(onGameStart)

Events.OnCreatePlayer.Add(function()
  Control:clear()
end)

Events.OnPlayerDeath.Add(function()
  Control:clear()
end)

Events.OnPlayerUpdate.Add(function(player)
  if player ~= getPlayer() then
    return
  end

  updateTick = updateTick + 1
  if updateTick % 20 ~= 0 then
    return
  end

  if Control:isOn() and Daylight.isTooBrightToKeepOn() then
    Sound:playToggleFail()
    Control:turnOff(false)
    return
  end

  if Control:isOn() then
    VisionBoost:tick()
    Control:syncActiveItem()
  else
    ShaderBridge:clear(player)
  end
end)

registerKeybind()
