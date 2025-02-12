--------------------------------------------------------------------------
-- File     :  /cdimage/units/BAA0309/BAA0309_script.lua
-- Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos
-- Summary  :  Aeon T2 Transport Script
-- Copyright � 2006 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------

local AirTransport = import('/lua/defaultunits.lua').AirTransport
local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')
local aWeapons = import('/lua/aeonweapons.lua')
local AAASonicPulseBatteryWeapon = aWeapons.AAASonicPulseBatteryWeapon

BAA0309 = Class(AirTransport) {
    AirDestructionEffectBones = {'Exhaust', 'Wing_Right', 'Wing_Left', 'Turret_Right01', 'Turret_Left',
        'Slots_Left01', 'Slots_Left02', 'Slots_Right01', 'Slots_Right02',
        'Right_AttachPoint01', 'Right_AttachPoint02', 'Right_AttachPoint03', 'Right_AttachPoint04',
        'Left_AttachPoint01', 'Left_AttachPoint02', 'Left_AttachPoint03', 'Left_AttachPoint04',
    },

    Weapons = {
        SonicPulseBattery1 = Class(AAASonicPulseBatteryWeapon) {},
        SonicPulseBattery2 = Class(AAASonicPulseBatteryWeapon) {},
        SonicPulseBattery3 = Class(AAASonicPulseBatteryWeapon) {},
        SonicPulseBattery4 = Class(AAASonicPulseBatteryWeapon) {},
    },

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function(self, scale)
        self:ForkThread(self.AirDestructionEffectsThread, self)
    end,

    AirDestructionEffectsThread = function(self)
        local numExplosions = math.floor(table.getn(self.AirDestructionEffectBones) * 0.5)
        for i = 0, numExplosions do
            explosion.CreateDefaultHitExplosionAtBone(self, self.AirDestructionEffectBones[util.GetRandomInt(1, numExplosions)], 0.5)
            WaitSeconds(util.GetRandomFloat(0.2, 0.9))
        end
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        AirTransport.OnStopBeingBuilt(self,builder,layer)
        self:DisableUnitIntel('unitScript', 'CloakField') -- It's only used to denote the Tele range
    end,
}

TypeClass = BAA0309
