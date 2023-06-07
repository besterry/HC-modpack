
# Introduction

NVAPI is a Night Vision API designed to help modders integrate night vision capability to their assets.

# Features

* it works!
* 4 filter mods: noiseless, linear blur, infrared and xray
* many sound effects
* item shatters if it falls in the ground
* item can be repaired
* item is battery powered
* item shutdowns when it runs out of battery


# Who is using the NVAPI?

https://steamcommunity.com/sharedfiles/filedetails/?id=2769995104



# Integrating the NVAPI into a mod

You just need to do two things:

1) tag your item as NVITEM. Here's an example:

```
module Base
{
  item NVAviator
  {
    Tags             = NVITEM,
    DisplayName      = NVAviator,
    DisplayCategory  = Accessory,
    ClothingItem     = Glasses_Aviators,
    Type             = Clothing,
    BodyLocation     = Eyes,    
    Icon             = GlassesAviator,    
  }
}
```

2) assign a specific key to toggle the night vision view:

```
local nvctrl = require "NVAPI/ctrl/instance"

Events.OnKeyPressed( function(key)
  if key == 20 then
    nvctrl:toggle()
  end
end )
```

and that's it. Everything is managed by the API
