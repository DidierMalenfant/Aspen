-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

aspen = aspen or {}

class('Player', { image = nil }, aspen).extends(AnimatedSprite)

function aspen.Player:init(image_path, states_path, physics)
    self.image_table = gfx.imagetable.new(image_path)
    assert(self.image_table, 'Error loading image table from '..image_path..'.')

    local states = AnimatedSprite.loadStates(states_path)
    assert(states, 'Error loading states file from '..states_path..'.')
    
    -- Call our parent init() method.
    aspen.Player.super.init(self, self.image_table, states)    
    self:playAnimation()
    
    self:setZIndex(10)

    self.dx = 0.0
    self.dy = 0.0

    self:moveTo(0, 0)

    self.jump_sound = nil

    self.physics = physics
end

function aspen.Player:update()
    -- Call our parent update() method.
    aspen.Player.super.update(self)

    local p = self.physics

    self.dy += p.gravity
    if self.dy > 0.0 then
        self.dy = math.max(self.dy, p.max_fall_speed)
    end

    local wanted_x = self.x + self.dx
    local wanted_y = self.y + self.dy

    local actual_x, actual_y, _, _ = self:moveWithCollisions(wanted_x, wanted_y)

    if actual_x ~= wanted_x then
        self.dx = 0.0
    elseif self.dx > 0.0 then
        self.dx -= math.min(p.lateral_friction, self.dx)
    elseif self.dx < 0.0 then
        self.dx += math.min(p.lateral_friction, -self.dx)
    end

    if actual_y ~= wanted_y then
        self.dy = 0.0
    end
end

function aspen.Player:goLeft()
    local p = self.physics
    
    if self:isJumping() == true then
        self.dx -= p.move_force_in_air
    else
        self.dx -= p.move_force_on_ground
    end

    self.dx = math.max(-p.max_move_force, self.dx)
end

function aspen.Player:goRight()
    local p = self.physics
    
    if self:isJumping() == true then
        self.dx += p.move_force_in_air
    else
        self.dx += p.move_force_on_ground
    end

    self.dx = math.min(p.max_move_force, self.dx)
end

function aspen.Player:setJumpSound(sample_path)
    self.jump_sound = playdate.sound.sampleplayer.new(sample_path)
    assert(self.jump_sound, 'Error loading jump sound.')    
end

function aspen.Player:jump()
    local p = self.physics
    
    if self:isJumping() ~= true then
        if self.jump_sound then
            self.jump_sound:play()
        end

        self.dy = -p.jump_force
    end
end

function aspen.Player:isJumping()
    return self.dy ~= 0.0
end

function aspen.Player:collisionResponse(other) -- luacheck: ignore self other
    return gfx.sprite.kCollisionTypeSlide
end
