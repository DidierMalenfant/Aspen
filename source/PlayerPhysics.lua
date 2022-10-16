-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

aspen = aspen or {}

class('PlayerPhysics', { }, aspen).extends()

function aspen.PlayerPhysics:init()
    -- Call our parent init() method.
    aspen.PlayerPhysics.super.init(self)

    self.gravity = 1.3
    self.jump_force = 14.0
    self.max_fall_speed = 20.0
    self.move_force_on_ground = 1.5
    self.move_force_in_air = 1.0
    self.max_move_force = 5.0
    self.lateral_friction = 0.4
end
