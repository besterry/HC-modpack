local CONFIG = {
  ITEM_TAG          = "NVITEM",
  CHARGE_DRAIN_RATE = 0.0005,
  CHARGE_KEY        = "NVAPI_CHARGE",

  -- dayLightStrength: 0 = ночь, 1 = полдень
  DAYLIGHT_BLOCK_ON  = 0.35,
  DAYLIGHT_AUTO_OFF  = 0.40,

  -- false: ПНВ можно включать днём (игрок сам решает)
  BLOCK_DAYLIGHT_NV = false,

  -- множитель альфы зерна оверлея (NVAPI использует ~0.2-0.4)
  GRAIN_OVERLAY_SCALE = 1.3,
}

return CONFIG
