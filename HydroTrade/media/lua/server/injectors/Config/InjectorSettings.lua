-- Duration units ~= real seconds (see TickInflictions).
-- Balance target (day = 3 real hours): city trip 1-1.5h, Louisville exit ~10-15 min.
-- Escape / medical: ~6-10 min so 1-3 syringes cover the run out.
-- Combat: ~5-6 min fight window.
-- March / carry: ~20 min per syringe (loot sector, not the whole trip).

Adrenaline_S = {
    Painkill = {
        delay = 0,
        duration = 300,
        func = Painkill,
        args = {2}
    },
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 300, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 300, true
        }
    },
    Health = {
        delay = 1,
        duration = 45,
        func = AlterHealth,
        args = {2}
    },
    Stress = {
        delay = 1,
        duration = 300,
        func = AlterStress,
        args = {1}
    },
    Hunger = {
        delay = 220,
        duration = 80,
        func = AlterHunger,
        args = {0.5}
    },
    Thirst = {
        delay = 220,
        duration = 80,
        func = AlterThirst,
        args = {0.3}
    }
}

AHF1_S = {
    Mend = {
        delay = 1,
        duration = 360,
        func = MendWounds,
        args = {0.1}
    },
    Health = {
        delay = 1,
        duration = 360,
        func = AlterHealth,
        args = {1}
    },
    Thirst = {
        delay = 1,
        duration = 420,
        func = AlterThirst,
        args = {0.3}
    }
}

BTG2A2_S = {
    Nimble = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 1200, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 1200, true
        }
    },
    WeightCapA = {
        delay = 1,
        duration = 1,
        func = AlterWeightCap,
        args = {15}
    },
    WeightCapB = {
        delay = 1200,
        duration = 1,
        func = AlterWeightCap,
        args = {-15}
    },
    Thirst = {
        delay = 1,
        duration = 1200,
        func = AlterThirst,
        args = {0.2}
    }
}

BTG3_S = {
    Nimble = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 360, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 360, true
        }
    },
    Strength = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 360, true
        }
    },
    Stamina = {
        delay = 1,
        duration = 360,
        func = AlterEndurance,
        args = {0.4}
    },
    Hunger = {
        delay = 180,
        duration = 180,
        func = AlterHunger,
        args = {0.25}
    }
}

ETG_S = {
    Metabolism = {
        delay = 1,
        duration = 180,
        func = AlterCalories,
        args = {10}
    },
    Immunity = {
        delay = 1,
        duration = 180,
        func = AlterCold,
        args = {0.5}
    },
    Limbs = {
        delay = 1,
        duration = 150,
        func = AlterLimbHealth,
        args = {1}
    },
    Satiety = {
        delay = 1,
        duration = 150,
        func = AlterHunger,
        args = {-0.25}
    },
    Hunger = {
        delay = 150,
        duration = 40,
        func = AlterHunger,
        args = {1.5}
    },
    Health = {
        delay = 150,
        duration = 90,
        func = AlterHealth,
        args = {-0.5}
    },
    Fitness = {
        delay = 150,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 120, false
        }
    }
}

Meldonin_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 1200, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 4,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 1200, true
        }
    },
    Stamina = {
        delay = 1,
        duration = 1200,
        func = AlterEndurance,
        args = {0.5}
    },
    Thirst = {
        delay = 30,
        duration = 1200,
        func = AlterThirst,
        args = {0.1}
    },
    Hunger = {
        delay = 30,
        duration = 1200,
        func = AlterHunger,
        args = {0.1}
    }
}

Morphine_S = {
    Painkill = {
        delay = 1,
        duration = 420,
        func = Painkill,
        args = {0.8}
    },
    Hunger = {
        delay = 1,
        duration = 1,
        func = AlterHunger,
        args = {10}
    },
    Thirst = {
        delay = 1,
        duration = 1,
        func = AlterThirst,
        args = {15}
    }
}

MULE_S = {
    WeightCapA = {
        delay = 1,
        duration = 1,
        func = AlterWeightCap,
        args = {50}
    },
    WeightCapB = {
        delay = 1200,
        duration = 1,
        func = AlterWeightCap,
        args = {-50}
    },
    Health = {
        delay = 1,
        duration = 1200,
        func = AlterHealth,
        -- Was -0.09 over 900s; scaled so total drain stays similar.
        args = {-0.07}
    }
}

Norepinephrine_S = {
    Painkill = {
        delay = 1,
        duration = 300,
        func = Painkill,
        args = {0.8}
    },
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 300, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 300, true
        }
    },
    Stamina = {
        delay = 1,
        duration = 1,
        func = AlterEndurance,
        args = {30}
    },
    Hungry = {
        delay = 1,
        duration = 180,
        func = AlterHunger,
        args = {0.2}
    },
    Thirst = {
        delay = 1,
        duration = 180,
        func = AlterThirst,
        args = {0.2}
    }
}

Obdolbos2_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 1500, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 1500, true
        }
    },
    Nimble = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 1500, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 1500, true
        }
    },
    WeightCapA = {
        delay = 1,
        duration = 1,
        func = AlterWeightCap,
        args = {45}
    },
    WeightCapB = {
        delay = 1500,
        duration = 1,
        func = AlterWeightCap,
        args = {-45}
    },
    Health = {
        delay = 1,
        duration = 1500,
        func = AlterHealth,
        args = {-0.2}
    },
    Endurance = {
        delay = 1,
        duration = 1500,
        func = AlterEndurance,
        args = {-0.2}
    },
    Stamina = {
        delay = 1,
        duration = 1,
        func = AlterEndurance,
        args = {-20}
    }
}

P22_S = {
    Stress = {
        delay = 1,
        duration = 300,
        func = AlterStress,
        args = {-0.5}
    },
    Health = {
        delay = 1,
        duration = 300,
        func = AlterHealth,
        args = {0.5}
    },
    Damage = {
        delay = 300,
        duration = 180,
        func = AlterHealth,
        args = {-0.5}
    },
    Doctor = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 300, true
        }
    },
    Aiming = {
        delay = 305,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 180, false
        }
    },
    Hunger = {
        delay = 305,
        duration = 180,
        func = AlterHunger,
        args = {0.5}
    }
}

Perfotoran_S = {
    Metabolism = {
        delay = 1,
        duration = 480,
        func = AlterCalories,
        args = {5}
    },
    Health = {
        delay = 1,
        duration = 480,
        func = AlterHealth,
        args = {0.45}
    },
    Antidote = {
        delay = 1,
        duration = 480,
        func = FreezeInfection,
        args = {}
    },
    Mend = {
        delay = 1,
        duration = 480,
        func = MendWounds,
        args = {0.1}
    },
    Damage = {
        delay = 480,
        duration = 1,
        func = AlterHealth,
        args = {-15}
    },
    Heal = {
        delay = 540,
        duration = 1,
        func = AlterHealth,
        args = {15}
    },
    Hunger = {
        delay = 480,
        duration = 120,
        func = AlterHunger,
        args = {0.5}
    }
}

PNB_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 90, true
        }
    },
    Health = {
        delay = 1,
        duration = 90,
        func = AlterHealth,
        args = {0.6}
    },
    Doctor = {
        delay = 91,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 180, false
        }
    },
    Damage = {
        delay = 91,
        duration = 1,
        func = AlterHealth,
        args = {-20}
    },
    Heal = {
        delay = 150,
        duration = 1,
        func = AlterHealth,
        args = {20}
    },
    Tremor = {
        delay = 91,
        duration = 30,
        func = Tremor,
        args = {10}
    }
}

Propital_S = {
    Painkill = {
        delay = 1,
        duration = 360,
        func = Painkill,
        args = {0.8}
    },
    Metabolism = {
        delay = 1,
        duration = 420,
        func = AlterCalories,
        args = {5}
    },
    Heal = {
        delay = 1,
        duration = 1,
        func = AlterHealth,
        args = {20}
    },
    Damage = {
        delay = 420,
        duration = 1,
        func = AlterHealth,
        args = {-20}
    },
    Doctor = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 420, true
        }
    },
}

SJ1_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 360, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 360, true
        }
    },
    Stress = {
        delay = 1,
        duration = 360,
        func = AlterStress,
        args = {-0.3}
    },
    Hunger = {
        delay = 200,
        duration = 200,
        func = AlterHunger,
        args = {0.15}
    },
    Thirst = {
        delay = 200,
        duration = 200,
        func = AlterThirst,
        args = {0.2}
    }
}

SJ6_S = {
    Endurance = {
        delay = 1,
        duration = 1,
        func = AlterEndurance,
        args = {30}
    },
    Stamina = {
        delay = 1,
        duration = 360,
        func = AlterEndurance,
        args = {0.1}
    },
    Tremor = {
        delay = 300,
        duration = 60,
        func = Tremor,
        args = {20}
    }
}

SJ9_S = {
    Sprinting = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Sprinting:getName(), 480, true
        }
    },
    Lightfoot = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Lightfoot:getName(), 480, true
        }
    },
    Nimble = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 480, true
        }
    },
    Sneak = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Sneak:getName(), 480, true
        }
    },
    Metabolism = {
        delay = 6,
        duration = 480,
        func = AlterCalories,
        args = {-4}
    },
    Health = {
        delay = 6,
        duration = 540,
        func = AlterHealth,
        args = {-0.06}
    },
    Tremor = {
        delay = 60,
        duration = 40,
        func = Tremor,
        args = {20}
    },
    Pain = {
        delay = 1,
        duration = 180,
        func = AddPain,
        args = {1, 8}
    }
}

SJ12_S = {
    Aiming = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 600, true
        }
    },
    SprintingA = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Sprinting:getName(), 600, true
        }
    },
    LightfootA = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Lightfoot:getName(), 600, true
        }
    },
    NimbleA = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 600, true
        }
    },
    SneakA = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Sneak:getName(), 600, true
        }
    },
    Hunger = {
        delay = 1,
        duration = 600,
        func = AlterHunger,
        args = {0.03}
    },
    Thirst = {
        delay = 1,
        duration = 600,
        func = AlterThirst,
        args = {0.03}
    },
    SprintingB = {
        delay = 606,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Sprinting:getName(), 300, false
        }
    },
    LightfootB = {
        delay = 606,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Lightfoot:getName(), 300, false
        }
    },
    NimbleB = {
        delay = 606,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 300, false
        }
    },
    SneakB = {
        delay = 606,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Sneak:getName(), 300, false
        }
    }
}

Trimadol_S = {
    Painkill = {
        delay = 1,
        duration = 360,
        func = Painkill,
        args = {0.8}
    },
    Strength = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 360, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 360, true
        }
    },
    Nimble = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 360, true
        }
    },
    Stress = {
        delay = 1,
        duration = 360,
        func = AlterStress,
        args = {-0.2}
    },
    Endurance = {
        delay = 1,
        duration = 1,
        func = AlterEndurance,
        args = {15}
    },
    Stamina = {
        delay = 1,
        duration = 360,
        func = AlterEndurance,
        args = {0.2}
    },
    Hunger = {
        delay = 1,
        duration = 360,
        func = AlterHunger,
        args = {0.25}
    },
    Thirst = {
        delay = 1,
        duration = 360,
        func = AlterThirst,
        args = {0.25}
    }
}

XTG_S = {
    Antidote = {
        delay = 6,
        duration = 600,
        func = FreezeInfection,
        args = {}
    },
    Damage = {
        delay = 6,
        duration = 1,
        func = AlterHealth,
        args = {-15}
    },
    Heal = {
        delay = 610,
        duration = 1,
        func = AlterHealth,
        args = {15}
    },
}

Zagustin_S = {
    Mend = {
        delay = 1,
        duration = 360,
        func = MendWounds,
        args = {0.1}
    },
    Doctor = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 360, true
        }
    },
    Metabolism = {
        delay = 1,
        duration = 360,
        func = AlterCalories,
        args = {-7}
    },
    Thirst = {
        delay = 320,
        duration = 60,
        func = AlterThirst,
        args = {0.85}
    },
    Tremor = {
        delay = 320,
        duration = 60,
        func = Tremor,
        args = {20}
    }
}
