Adrenaline_S = {
    Painkill = {
        delay = 0,
        duration = 65,
        func = Painkill,
        args = {2}
    },
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 60, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 60, true
        }
    },
    Health = {
        delay = 1,
        duration = 15,
        func = AlterHealth,
        args = {2}
    },
    Stress = {
        delay = 1,
        duration = 60,
        func = AlterStress,
        args = {1}
    },
    Hunger = {
        delay = 50,
        duration = 30,
        func = AlterHunger,
        args = {0.5}
    },
    Thirst = {
        delay = 50,
        duration = 30,
        func = AlterThirst,
        args = {0.3}
    }
}

AHF1_S = {
    Mend = {
        delay = 1,
        duration = 60,
        func = MendWounds,
        args = {0.1}
    },
    Health = {
        delay = 1,
        duration = 60,
        func = AlterHealth,
        args = {1}
    },
    Thirst = {
        delay = 1,
        duration = 120,
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
            Perks.Nimble:getName(), 900, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 900, true
        }
    },
    WeightCapA = {
        delay = 1,
        duration = 1,
        func = AlterWeightCap,
        args = {15}
    },
    WeightCapB = {
        delay = 900,
        duration = 1,
        func = AlterWeightCap,
        args = {-15}
    },
    Thirst = {
        delay = 1,
        duration = 900,
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
            Perks.Nimble:getName(), 240, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 240, true
        }
    },
    Strength = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 240, true
        }
    },
    Stamina = {
        delay = 1,
        duration = 240,
        func = AlterEndurance,
        args = {0.4}
    },
    Hunger = {
        delay = 120,
        duration = 120,
        func = AlterHunger,
        args = {0.25}
    }
}

ETG_S = {
    Metabolism = {
        delay = 1,
        duration = 90,
        func = AlterCalories,
        args = {10}
    },
    Immunity = {
        delay = 1,
        duration = 90,
        func = AlterCold,
        args = {0.5}
    },
    Limbs = {
        delay = 1,
        duration = 60,
        func = AlterLimbHealth,
        args = {1}
    },
    Satiety = {
        delay = 1,
        duration = 60,
        func = AlterHunger,
        args = {-0.25}
    },
    Hunger = {
        delay = 65,
        duration = 20,
        func = AlterHunger,
        args = {1.5}
    },
    Health = {
        delay = 65,
        duration = 60,
        func = AlterHealth,
        args = {-0.5}
    },
    Fitness = {
        delay = 65,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 60, false
        }
    }
}

Meldonin_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 900, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 4,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 900, true
        }
    },
        Stamina = {
            delay = 1,
            duration = 900,
            func = AlterEndurance,
            args = {0.5}
        },
    Thirst = {
        delay = 30,
        duration = 900,
        func = AlterThirst,
        args = {0.1}
    },
    Hunger = {
        delay = 30,
        duration = 900,
        func = AlterHunger,
        args = {0.1}
    }
}

Morphine_S = {
    Painkill = {
        delay = 1,
        duration = 305,
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
        delay = 900,
        duration = 1,
        func = AlterWeightCap,
        args = {-50}
    },
    Health = {
        delay = 1,
        duration = 900,
        func = AlterHealth,
        args = {-0.09}
    }
}

Norepinephrine_S = {
    Painkill = {
        delay = 1,
        duration = 120,
        func = Painkill,
        args = {0.8}
    },
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 120, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 120, true
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
        duration = 60,
        func = AlterHunger,
        args = {0.2}
    },
    Thirst = {
        delay = 1,
        duration = 60,
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
            Perks.Strength:getName(), 1800, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 1800, true
        }
    },
    Nimble = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 1800, true
        }
    },
    Aiming = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 1800, true
        }
    },
    WeightCapA = {
        delay = 1,
        duration = 1,
        func = AlterWeightCap,
        args = {45}
    },
    WeightCapB = {
        delay = 1800,
        duration = 1,
        func = AlterWeightCap,
        args = {-45}
    },
    Health = {
        delay = 1,
        duration = 1800,
        func = AlterHealth,
        args = {-0.2}
    },
    Endurance = {
        delay = 1,
        duration = 1800,
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
        duration = 60,
        func = AlterStress,
        args = {-0.5}
    },
    Health = {
        delay = 1,
        duration = 60,
        func = AlterHealth,
        args = {0.5}
    },
    Damage = {
        delay = 60,
        duration = 60,
        func = AlterHealth,
        args = {-0.5}
    },
    Doctor = {
        delay = 1,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 60, true
        }
    },
    Aiming = {
        delay = 65,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Aiming:getName(), 60, false
        }
    },
    Hunger = {
        delay = 65,
        duration = 60,
        func = AlterHunger,
        args = {0.5}
    }
}

Perfotoran_S = {
    Metabolism = {
        delay = 1,
        duration = 60,
        func = AlterCalories,
        args = {5}
    },
    Health = {
        delay = 1,
        duration = 60,
        func = AlterHealth,
        args = {0.45}
    },
    Antidote = {
        delay = 1,
        duration = 60,
        func = FreezeInfection,
        args = {}
    },
    Mend = {
        delay = 1,
        duration = 60,
        func = MendWounds,
        args = {0.1}
    },
    Damage = {
        delay = 60,
        duration = 1,
        func = AlterHealth,
        args = {-15}
    },
    Heal = {
        delay = 120,
        duration = 1,
        func = AlterHealth,
        args = {15}
    },
    Hunger = {
        delay = 60,
        duration = 60,
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
            Perks.Strength:getName(), 40, true
        }
    },
    Health = {
        delay = 1,
        duration = 40,
        func = AlterHealth,
        args = {0.6}
    },
    Doctor = {
        delay = 41,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 180, false
        }
    },
    Damage = {
        delay = 41,
        duration = 1,
        func = AlterHealth,
        args = {-20}
    },
    Heal = {
        delay = 82,
        duration = 1,
        func = AlterHealth,
        args = {20}
    },
    Tremor = {
        delay = 41,
        duration = 20,
        func = Tremor,
        args = {10}
    }
}

Propital_S = {
    Painkill = {
        delay = 1,
        duration = 245,
        func = Painkill,
        args = {0.8}
    },
    Metabolism = {
        delay = 1,
        duration = 300,
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
        delay = 300,
        duration = 1,
        func = AlterHealth,
        args = {-20}
    },
    Doctor = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 300, true
        }
    },
}

SJ1_S = {
    Strength = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 180, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 180, true
        }
    },
    Stress = {
        delay = 1,
        duration = 180,
        func = AlterStress,
        args = {-0.3}
    },
    Hunger = {
        delay = 100,
        duration = 200,
        func = AlterHunger,
        args = {0.15}
    },
    Thirst = {
        delay = 100,
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
        duration = 240,
        func = AlterEndurance,
        args = {0.1}
    },
    Tremor = {
        delay = 200,
        duration = 40,
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
            Perks.Sprinting:getName(), 300, true
        }
    },
    Lightfoot = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Lightfoot:getName(), 300, true
        }
    },
    Nimble = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 300, true
        }
    },
    Sneak = {
        delay = 6,
        duration = 3,
        func = AlterSkill,
        args = {
            Perks.Sneak:getName(), 300, true
        }
    },
    Metabolism = {
        delay = 6,
        duration = 300,
        func = AlterCalories,
        args = {-4}
    },
    Health = {
        delay = 6,
        duration = 420,
        func = AlterHealth,
        args = {-0.08}
    },
    Tremor = {
        delay = 41,
        duration = 20,
        func = Tremor,
        args = {20}
    },
    Pain = {
        delay = 1,
        duration = 120,
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
        duration = 185,
        func = Painkill,
        args = {0.8}
    },
    Strength = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Strength:getName(), 180, true
        }
    },
    Fitness = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Fitness:getName(), 180, true
        }
    },
    Nimble = {
        delay = 1,
        duration = 1,
        func = AlterSkill,
        args = {
            Perks.Nimble:getName(), 180, true
        }
    },
    Stress = {
        delay = 1,
        duration = 180,
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
        duration = 180,
        func = AlterEndurance,
        args = {0.2}
    },
    Hunger = {
        delay = 1,
        duration = 180,
        func = AlterHunger,
        args = {0.25}
    },
    Thirst = {
        delay = 1,
        duration = 180,
        func = AlterThirst,
        args = {0.25}
    }
}

XTG_S = {
    Antidote = {
        delay = 6,
        duration = 60,
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
        delay = 66,
        duration = 1,
        func = AlterHealth,
        args = {15}
    },
}

Zagustin_S = {
    Mend = {
        delay = 1,
        duration = 180,
        func = MendWounds,
        args = {0.1}
    },
    Doctor = {
        delay = 1,
        duration = 2,
        func = AlterSkill,
        args = {
            Perks.Doctor:getName(), 180, true
        }
    },
    Metabolism = {
        delay = 1,
        duration = 180,
        func = AlterCalories,
        args = {-7}
    },
    Thirst = {
        delay = 170,
        duration = 40,
        func = AlterThirst,
        args = {0.85}
    },
    Tremor = {
        delay = 170,
        duration = 40,
        func = Tremor,
        args = {20}
    }
}