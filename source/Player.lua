-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

dm = dm or {}
dm.aspen = dm.aspen or {}

class('Player', { image_table = nil, states = nil, sprite = nil, direction = 0 }, dm.aspen).extends()

local Player <const> = dm.aspen.Player
local Plupdate <const> = dm.Plupdate
local debug <const> = dm.debug
local clamp <const> =  dm.math.clamp
local gfx <const> = playdate.graphics

Player.State = dm.enum({
    'idle',
    'walking',
    'jumping'
})

function Player:init(image_path, states_path, physics)
    -- Call our parent init() method.
    Player.super.init(self)

    self.image_table = gfx.imagetable.new(image_path)
    assert(self.image_table, 'Error loading image table from '..image_path..'.')

    local states = AnimatedSprite.loadStates(states_path)
    assert(states, 'Error loading states file from '..states_path..'.')

    self.sprite = AnimatedSprite(self.image_table, states)
    self.sprite:playAnimation()
    self.sprite:setZIndex(10)
    self.sprite.collisionResponse = gfx.sprite.kCollisionTypeSlide

    -- This will be set based on the sprite animation frames eventually.
    self.sprite:setCollideRect(64, 30, 20, 59)

    self.level_height = playdate.display.getSize()

    self.state = Player.State.idle

    self.x = 0.0
    self.y = 0.0

    self.dx = 0.0
    self.dy = 0.0

    self.direction = 1
    self.previous_direction = 1

    self.jump_sound = nil

    self.physics = physics

    self.player_moved_callback = nil

    self:goIdle()

    Plupdate.iWillBeUsingSprites()
    Plupdate.addCallback(self.update, self)
    Plupdate.addPostCallback(function()
        debug.drawText(Player.stateName(self.state), 5, 3)
        debug.drawText(self.sprite.currentState, 5, 15)
    end)
end

function Player.stateName(state)
    local state_names = {
        'idle',
        'walk',
        'jump'
    }

    return state_names[state]
end

function Player:setCenter(x, y)
    self.sprite:setCenter(x / self.sprite.width, y / self.sprite.height)
end

function Player:setCollideRect(x, y, w, h)
    self.sprite:setCollideRect(x, y, w, h)
end

function Player:setJumpSound(sample_path)
    self.jump_sound = playdate.sound.sampleplayer.new(sample_path)
    assert(self.jump_sound, 'Error loading jump sound.')
end

function Player:setPlayerMovedCallback(callback)
    self.player_moved_callback = callback
end

function Player:setPos(x, y)
    self.sprite:moveTo(x, self.level_height - y)

    self:moveTo(x, y)
end

function Player:moveTo(x, y)
    if self.x == x and self.y == y then
        return
    end

    self.x = x
    self.y = y

    if self.player_moved_callback ~= nil then
        self.player_moved_callback(x, y)
    end
end

function Player:lateralPush(direction, force)
    if direction ~= self.direction then
        self.previous_direction = self.direction
        self.direction = direction
    end

    local max = self.physics.max_move_force
    self.dx = clamp(self.dx + (direction * force), -max, max)
end

function Player:goJump()
    if self.jump_sound then
        self.jump_sound:play()
    end

    local p = self.physics
    self.dy = p.jump_force

    self.state = Player.State.jumping
end

function Player:goIdle()
    if self.direction > 0 then
        self.sprite:changeState('walkrightstop')
    else
        self.sprite:changeState('walkleftstop')
    end

    self.state = Player.State.idle
end

function Player:goWalking()
    if self.direction > 0 then
        self.sprite:changeState('walkrightstart')
    else
        self.sprite:changeState('walkleftstart')
    end

    self.state = Player.State.walking
end

function Player:applyPhysics()
    local p = self.physics

    local wanted_x = self.x + self.dx
    local wanted_y = self.level_height - (self.y + self.dy)

    local actual_x, actual_y, _, _ = self.sprite:moveWithCollisions(wanted_x, wanted_y)
    self:moveTo(actual_x, self.level_height - actual_y)

    if actual_x ~= wanted_x then
        self.dx = 0.0
    end

    if actual_y ~= wanted_y then
        self.dy = 0.0
    else
        self.dy = math.max(self.dy - p.gravity, -p.max_fall_speed)
    end
end

function Player:update()
    if self.state == Player.State.idle then
        self:idle()
    elseif self.state == Player.State.walking then
        self:walking()
    elseif self.state == Player.State.jumping then
        self:jumping()
    end
end

function Player:idle()
    local p = self.physics

    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self:lateralPush(1, p.move_force_on_ground)
    elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
        self:lateralPush(-1, p.move_force_on_ground)
    end

    if playdate.buttonIsPressed(playdate.kButtonA) then
        self:goJump()
    end

    self:applyPhysics()

    if self.dx ~= 0.0 then
        self.previous_direction = self.direction
        self:goWalking()
    end
end

function Player:walking()
    local p = self.physics

    local stopping = false

    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self:lateralPush(1, p.move_force_on_ground)
    elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
        self:lateralPush(-1, p.move_force_on_ground)
    else
        self:lateralPush(self.direction, -math.min(p.lateral_friction, (self.direction * self.dx)))
        stopping = true
    end

    if playdate.buttonIsPressed(playdate.kButtonA) then
        self:goJump()
    end

    self:applyPhysics()

    if self.dx == 0.0 then
        if stopping then
            self:goIdle()
        end
    elseif self.direction ~= self.previous_direction then
        if self.direction > 0 then
            self.sprite:changeState('turnlefttoright')
        else
            self.sprite:changeState('turnrighttoleft')
        end

        self.previous_direction = self.direction
    end
end

function Player:jumping()
    local p = self.physics

    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self:lateralPush(1, p.move_force_in_air)
    elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
        self:lateralPush(-1, p.move_force_in_air)
    end

    self:applyPhysics()

    if self.dy == 0.0 then
        if self.dx == 0.0 then
            self:goIdle()
        else
            self:goWalking()
        end
    end
end
