-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

aspen = aspen or {}

class('Player', { image = nil }, aspen).extends(AnimatedSprite)

aspen.Player.State = enum({
    'idle',
    'walk',
    'jump'
})

local gfx <const> = playdate.graphics
local player <const> = aspen.Player

function aspen.Player:init(image_path, states_path, physics)
    self.image_table = gfx.imagetable.new(image_path)
    assert(self.image_table, 'Error loading image table from '..image_path..'.')

    local states = AnimatedSprite.loadStates(states_path)
    assert(states, 'Error loading states file from '..states_path..'.')
    
    -- Call our parent init() method.
    player.super.init(self, self.image_table, states)    
    self:playAnimation()
    
    self.state = player.State.idle
    
    self:setZIndex(10)

    self.dx = 0.0
    self.dy = 0.0

    self:moveTo(0, 0)

    self.jump_sound = nil

    self.physics = physics
    
    Plupdate.iWillBeUsingSprites()
end

function aspen.Player:applyPhysics()
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

function aspen.Player:update()
    -- Call our parent update() method.
    player.super.update(self)

    self:applyPhysics()
    
    if self.dy == 0.0 then
        self.state = player.State.idle
    end
end

function aspen.Player:goLeft()
    local p = self.physics
    
    if self.state == player.State.jump then
        self.dx -= p.move_force_in_air
    else
        self.dx -= p.move_force_on_ground
    end

    self.dx = math.max(-p.max_move_force, self.dx)
end

function aspen.Player:goRight()
    local p = self.physics
    
    if self.state == player.State.jump then
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
    if self.state ~= player.State.jump then
        if self.jump_sound then
            self.jump_sound:play()
        end

        local p = self.physics            
        self.dy = -p.jump_force

        self.state = player.State.jump
    end
end

function aspen.Player:collisionResponse(other) -- luacheck: ignore self other
    return gfx.sprite.kCollisionTypeSlide
end

function aspen.Player.stateName(state)
    local state_names = {
        'idle',
        'walk',
        'jump'
    }

    return state_names[state]
end
