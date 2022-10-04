-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

local gfx <const> = playdate.graphics

aspen = aspen or {}

class('PlayerPhysics', { }, aspen).extends()

function aspen.PlayerPhysics:init()
    -- Call our parent init() method.
    aspen.PlayerPhysics.super.init(self)

    self.gravity = 1.2
    self.jump_force = 15.0
    self.max_fall_speed = 3.0
    self.move_force_on_ground = 5.0
    self.move_force_in_air = 1.0
    self.max_move_force = 5.0
    self.lateral_friction = 0.4    
end
