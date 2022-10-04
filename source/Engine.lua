-- SPDX-FileCopyrightText: 2022-present  Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import "CoreLibs/object"

import 'Level'
import 'Player'

local gfx <const> = playdate.graphics

local display_width <const>, display_height <const> = playdate.display.getSize()

aspen = aspen or {}

class('Engine', { background_image = nil, level = nil, player = nil }, aspen).extends()

function aspen.Engine:init()
    -- Call our parent init() method.
    aspen.Engine.super.init(self)
end

function aspen.Engine:createPlayer(image_table_path, states_path, physics)
    self.player = aspen.Player(image_table_path, states_path, physics)
    assert(self.player, 'Error loading character.')
end

function aspen.Engine:loadLevel(level_path)
    self.level = aspen.Level(level_path)
    assert(self.level, 'Error loading level.')
end

function aspen.Engine:setBackgroundImage(image_path)
    self.background_image = gfx.image.new(image_path)
    assert(self.background_image, 'Error loading background image.')
    
    gfx.sprite.setBackgroundDrawingCallback(function(_x, _y, _width, _height)
        -- _x, _y, _width, _height is the updated area in sprite-local coordinates
        -- The clip rect is already set to this area, so we don't need to set it ourselves
        gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
        self.background_image:draw(0, 0)
    end)    
end

function aspen.Engine:update()
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.player:goRight()
    elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.player:goLeft()
    end
    
    if playdate.buttonIsPressed(playdate.kButtonA) then
        self.player:jump()
    end
    
    self.level:updateCameraPosition(self.player.x - (display_width / 2),
                                    self.player.y - (display_height / 2) + 20)
end
