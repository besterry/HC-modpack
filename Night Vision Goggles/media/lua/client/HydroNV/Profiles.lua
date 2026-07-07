local CONFIG = require "HydroNV/CONFIG"

local Profiles = {}

local DEFAULT_PROFILE = {
  tier         = 2,
  drain        = CONFIG.CHARGE_DRAIN_RATE,
  viewDist     = 68,
  viewDistMax  = 78,
  grain        = 0.26,
  grainTex     = "fine",
  coneBoost    = true,
  phosphor     = "green",
  shaderGrain  = 0.04,
}

Profiles.TEXTURES = {
  fine   = "media/textures/overlay-noiseless.png",
  coarse = "media/textures/overlay-linearblur.png",
}

Profiles.BY_TYPE = {
  ["Base.Hat_PVS_5"]              = { tier = 1, drain = 0.001,  viewDist = 58, viewDistMax = 66, shaderGrain = 0.05 },
  ["Base.Hat_PVS15"]              = { tier = 2, drain = 0.0006, viewDist = 70, viewDistMax = 80, shaderGrain = 0.025 },
  ["Base.Hat_PVS15_ON"]           = { tier = 2, drain = 0.0005, viewDist = 72, viewDistMax = 82, shaderGrain = 0.025 },
  ["Base.Hat_PVS15_Harness_ON"]   = { tier = 2, drain = 0.0005, viewDist = 72, viewDistMax = 82, shaderGrain = 0.025 },
  ["Base.Hat_NV18_ON"]            = { tier = 3, drain = 0.0003, viewDist = 88, viewDistMax = 100, shaderGrain = 0.010 },
  ["Base.Hat_NV18_Harness_ON"]    = { tier = 3, drain = 0.0003, viewDist = 88, viewDistMax = 100, shaderGrain = 0.010 },
  ["Base.Hat_Sam_NV"]             = { tier = 3, drain = 0.0004, viewDist = 85, viewDistMax = 96, shaderGrain = 0.010, phosphor = "white" },
  ["Base.FMA_GP_NVG_18"]          = { tier = 3, drain = 0.0003, viewDist = 88, viewDistMax = 100, shaderGrain = 0.005 },
}

function Profiles.get(item)
  if item == nil then
    return DEFAULT_PROFILE
  end

  local profile = Profiles.BY_TYPE[item:getFullType()]
  if profile == nil then
    return DEFAULT_PROFILE
  end

  local merged = {}
  for key, value in pairs(DEFAULT_PROFILE) do
    merged[key] = value
  end
  for key, value in pairs(profile) do
    merged[key] = value
  end

  return merged
end

function Profiles.getShaderGrain(item)
  return Profiles.get(item).shaderGrain or DEFAULT_PROFILE.shaderGrain
end

function Profiles.getDrainRate(item)
  return Profiles.get(item).drain
end

function Profiles.getGrainTexture(item)
  local profile = Profiles.get(item)
  return Profiles.getGrainTextureByKey(profile.grainTex)
end

function Profiles.getGrainTextureByKey(key)
  if key == nil then
    return nil
  end
  return Profiles.TEXTURES[key] or Profiles.TEXTURES.fine
end

return Profiles
