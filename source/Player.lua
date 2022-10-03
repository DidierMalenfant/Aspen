-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

local gravity <const> = 1.2
local jump_force <const> = 15.0
local max_fall_speed <const> = 3.0
local move_force_on_ground <const> = 5.0
local move_force_in_air <const> = 1.0
local max_move_force <const> = 5.0
local lateral_friction <const> = 0.4

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
end

function aspen.Player:update()
    self.dy += gravity
    if self.dy > 0.0 then
        self.dy = math.max(self.dy, max_fall_speed)
    end

    local wanted_x = self.x + self.dx
    local wanted_y = self.y + self.dy

    local actual_x, actual_y, _, _ = self:moveWithCollisions(wanted_x, wanted_y)

    if actual_x ~= wanted_x then
        self.dx = 0.0
    elseif self.dx > 0.0 then
        self.dx -= math.min(lateral_friction, self.dx)
    elseif self.dx < 0.0 then
        self.dx -= math.max(-lateral_friction, self.dx)
    end

    if actual_y ~= wanted_y then
        self.dy = 0.0
    end
end

function aspen.Player:goLeft()
    if self:isJumping() == true then
        self.dx -= move_force_in_air
    else
        self.dx -= move_force_on_ground
    end

    self.dx = math.max(-max_move_force, self.dx)
end

function aspen.Player:goRight()
    if self:isJumping() == true then
        self.dx += move_force_in_air
    else
        self.dx += move_force_on_ground
    end

    self.dx = math.min(max_move_force, self.dx)
end

function aspen.Player:setJumpSound(sound)
    self.jump_sound = sound
end

function aspen.Player:jump()
    if self:isJumping() ~= true then
        if self.jump_sound then
            self.jump_sound:play()
        end

        self.dy = -jump_force
    end
end

function aspen.Player:turn(angle)
    self:setRotation(angle)
end

function aspen.Player:isJumping()
    return self.dy ~= 0.0
end

function aspen.Player:collisionResponse(other) -- luacheck: ignore self other
    return gfx.sprite.kCollisionTypeSlide
end
