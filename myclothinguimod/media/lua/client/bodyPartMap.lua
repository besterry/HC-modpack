-- Maps clothing BodyLocation / category -> MiniHealth limb indices (1-based, same as mhpBodyParts).
-- BodyPartType indices 0..16 -> lua 1..17

local BodyPartMap = {}

-- 1-based limb indices matching ISMiniHealth mhpBodyParts
local L = {
    Hand_L = 1,
    Hand_R = 2,
    ForeArm_L = 3,
    ForeArm_R = 4,
    UpperArm_L = 5,
    UpperArm_R = 6,
    Torso_Upper = 7,
    Torso_Lower = 8,
    Head = 9,
    Neck = 10,
    Groin = 11,
    UpperLeg_L = 12,
    UpperLeg_R = 13,
    LowerLeg_L = 14,
    LowerLeg_R = 15,
    Foot_L = 16,
    Foot_R = 17,
}

local HEAD = { L.Head }
local NECK = { L.Neck }
local TORSO = { L.Torso_Upper, L.Torso_Lower }
local ARMS = { L.UpperArm_L, L.UpperArm_R, L.ForeArm_L, L.ForeArm_R, L.Hand_L, L.Hand_R }
local HANDS = { L.Hand_L, L.Hand_R }
local LEGS = { L.Groin, L.UpperLeg_L, L.UpperLeg_R, L.LowerLeg_L, L.LowerLeg_R }
local FEET = { L.Foot_L, L.Foot_R }
local WAIST = { L.Torso_Lower, L.Groin }

local LOCATION_LIMBS = {
    Hat = HEAD,
    Mask = HEAD,
    FullHat = HEAD,
    MaskEyes = HEAD,
    MaskFull = HEAD,
    FullHelmet = HEAD,
    Eyes = HEAD,
    LeftEye = HEAD,
    RightEye = HEAD,
    SpecialMask = HEAD,

    Neck = NECK,
    Scarf = NECK,
    Necklace = NECK,
    Necklace_Long = NECK,

    TankTop = TORSO,
    Tshirt = TORSO,
    ShortSleeveShirt = TORSO,
    Shirt = TORSO,
    Jacket = TORSO,
    JacketHat = TORSO,
    Sweater = TORSO,
    SweaterHat = TORSO,
    Dress = TORSO,
    FullTop = TORSO,
    TorsoExtra = TORSO,
    Torso1Legs1 = TORSO,
    BathRobe = TORSO,
    FullSuit = TORSO,
    FullSuitHead = HEAD,
    TorsoRig = TORSO,
    TorsoRig2 = TORSO,
    Pauldrons = { L.UpperArm_L, L.UpperArm_R, L.Torso_Upper },
    UnderwearTop = TORSO,
    Underwear = TORSO,
    UnderwearInner = TORSO,
    UnderwearExtra1 = TORSO,
    UnderwearExtra2 = TORSO,

    Hands = HANDS,
    RightWrist = { L.Hand_R, L.ForeArm_R },
    LeftWrist = { L.Hand_L, L.ForeArm_L },
    HandPlateLeft = { L.Hand_L },
    HandPlateRight = { L.Hand_R },
    UpperArmLeft = { L.UpperArm_L },
    UpperArmRight = { L.UpperArm_R },

    Legs1 = LEGS,
    Pants = LEGS,
    Skirt = LEGS,
    UnderwearBottom = { L.Groin, L.UpperLeg_L, L.UpperLeg_R },
    LowerBody = LEGS,
    ThighLeft = { L.UpperLeg_L },
    ThighRight = { L.UpperLeg_R },
    ShinPlateLeft = { L.LowerLeg_L },
    ShinPlateRight = { L.LowerLeg_R },

    Socks = FEET,
    Shoes = FEET,

    Belt = WAIST,
    BeltExtra = WAIST,
    AmmoStrap = TORSO,
    FannyPackFront = WAIST,
    FannyPackBack = WAIST,
    SpecialBelt = WAIST,
    SwordSheath = WAIST,
    waistbags = WAIST,
    Tail = WAIST,

    Nose = HEAD,
    Ears = HEAD,
    EarTop = HEAD,
    BellyButton = { L.Torso_Lower },
    Right_MiddleFinger = { L.Hand_R },
    Left_MiddleFinger = { L.Hand_L },
    Right_RingFinger = { L.Hand_R },
    Left_RingFinger = { L.Hand_L },
}

local CATEGORY_LIMBS = {
    HEAD = HEAD,
    BODY = TORSO,
    UNDIES = TORSO,
    HANDS = ARMS,
    LEGS = LEGS,
    FEET = FEET,
    ACC = WAIST,
    TRINKET = { L.Head, L.Neck, L.Hand_L, L.Hand_R },
}

function BodyPartMap.getLimbsForLocation(bodyLocation)
    return LOCATION_LIMBS[bodyLocation]
end

function BodyPartMap.getLimbsForCategory(category)
    return CATEGORY_LIMBS[category]
end

--- Build map: limbIndex(1-based) -> { damaged=true, severity=0..1, holes=n }
--- severity 1 = worst. Injury limbs should ignore clothing paint (caller decides).
function BodyPartMap.buildDamagedLimbState(equippedItems, threshold, clothingCategories)
    local result = {}
    if not equippedItems then
        return result
    end
    threshold = threshold or 0.5
    local utils = require "utils/utils"

    for bodyLocation, item in pairs(equippedItems) do
        if utils.isItemDamaged(item, threshold) then
            local limbs = LOCATION_LIMBS[bodyLocation]
            if not limbs and clothingCategories then
                for category, data in pairs(clothingCategories) do
                    if data[bodyLocation] then
                        limbs = CATEGORY_LIMBS[category]
                        break
                    end
                end
            end
            if limbs then
                local ratio = utils.getItemConditionRatio(item)
                local holes = utils.getItemHoles(item)
                local severity = 1 - ratio
                if holes > 0 then
                    severity = math.max(severity, 0.35 + math.min(holes, 5) * 0.1)
                end
                for i = 1, #limbs do
                    local idx = limbs[i]
                    local cur = result[idx]
                    if not cur or severity > cur.severity then
                        result[idx] = {
                            damaged = true,
                            severity = severity,
                            holes = holes,
                            bodyLocation = bodyLocation,
                            item = item,
                        }
                    end
                end
            end
        end
    end

    return result
end

BodyPartMap.LIMB = L

return BodyPartMap
