-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

aspen = aspen or {}

class('Player', { image = nil }, aspen).extends(gfx.sprite)

function aspen.Player:init(x, y, image_path)
    aspen.Player.super.init(self) -- this is critical

    self.image = gfx.image.new(image_path)
    assert(self.image, 'Error creating a new image.')

    self:setImage(self.image)
    self:setCollideRect(10, 0, self.width - 20, self.height)

    self:setZIndex(10)
    --self:setCenter(0, 0)	-- set center point to center bottom

    self.dx = 0.0
    self.dy = 0.0

    self:moveTo(x, y)
    self:add()

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
