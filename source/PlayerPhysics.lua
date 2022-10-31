-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/object"

dm = dm or {}
dm.aspen = dm.aspen or {}

class('PlayerPhysics', { }, dm.aspen).extends()

local PlayerPhysics <const> = dm.aspen.PlayerPhysics

function PlayerPhysics:init()
    -- Call our parent init() method.
    PlayerPhysics.super.init(self)

    self.gravity = 1.3
    self.jump_force = 14.0
    self.max_fall_speed = 20.0
    self.move_force_on_ground = 1.5
    self.move_force_in_air = 1.0
    self.max_move_force = 5.0
    self.lateral_friction = 0.4
end
