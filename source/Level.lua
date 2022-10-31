-- SPDX-FileCopyrightText: 2022-present Didier Malenfant <coding@malenfant.net>
--
-- SPDX-License-Identifier: MIT

import "CoreLibs/graphics"
import 'CoreLibs/sprites'
import 'CoreLibs/object'

dm = dm or {}
dm.aspen = dm.aspen or {}

class('Level', { level = nil }, dm.aspen).extends(playdate.graphics.sprite)

local Level <const> = dm.aspen.Level
local tiledup <const> = dm.tiledup
local gfx <const> = playdate.graphics
local Plupdate <const> = dm.Plupdate
local max <const> =  math.max
local clamp <const> =  dm.math.clamp

local display_width <const>, display_height <const> = playdate.display.getSize()

function Level:init(pathToLevelJSON)
	-- Call our parent init() method.
	Level.super.init(self)

	self:setZIndex(0)
	self:setCenter(0, 0)	-- set center point to center bottom

	self.level = tiledup.Level(pathToLevelJSON)
	assert(self.level, 'Error importing Tiled level file.')

	self.width = 0
	self.height = 0

	for _, layer in pairs(self.level.layers) do
		self.width = max(self.width, layer.pixelWidth)
		self.height = max(self.height, layer.pixelHeight)
	end

	-- This is to make sure our level 'sprite' always gets drawn.
	self:setBounds(0, 0, self.width, self.height)

	self.min_x = 0
	self.max_x = self.width - display_width - self.level.tile_width

	self.camera_x = 0
	self.camera_y = 0

	self:setupWallSprites()

	self:addSprite()

	Plupdate.iWillBeUsingSprites()
end

function Level:size()
	return self.width, self.height
end

function Level:setupWallSprites()
	for _, layer in pairs(self.level.layers) do
		local tilemap = layer.tilemap
		local empty_ids = layer.empty_ids
		local width, height = tilemap:getSize()

		local x = 0
		local y = 0
		for row = 1, height do
			local column = 1
			while column <= width do
				local gid = tilemap:getTileAtPosition(column, row)
				if gid and empty_ids[gid] == nil then
					local cellWidth = self.level.tile_width
					local cellHeight = self.level.tile_height

					local w = gfx.sprite.new()
					w:setBounds(x, y, cellWidth, cellHeight)
					w:setCollideRect(0, 0, cellWidth, cellHeight)
					w:setUpdatesEnabled(false) -- remove from update cycle
					w:setVisible(false) -- invisible sprites can still collide
					w:setImageDrawMode(playdate.graphics.kDrawModeCopy)
					w:addSprite()

					w.gid = gid
					w.column = column
					w.row = row
					w.isWall = true
				end

				x += self.level.tile_width
				column += 1
			end

			x = 0
			y += self.level.tile_height
		end
	end

	-- We add left, right and bottom borders to the entire level
	gfx.sprite.addEmptyCollisionSprite(-1, -1, -1, self.height)
	gfx.sprite.addEmptyCollisionSprite(self.width, -1, self.width, self.height)
	gfx.sprite.addEmptyCollisionSprite(-1, self.height, self.width, self.height)
	gfx.sprite.addEmptyCollisionSprite(-1, -1, self.width, -1)
end

function Level:updateCameraPosition(x, y)
	self.camera_x = clamp(x, 0, self.width - display_width)
	self.camera_y = clamp(self.height - y, 0, self.height - display_height)
end

function Level:update()
	-- TODO: dynamically load and unload collision sprites as the player moves around the level
	gfx.setDrawOffset(-self.camera_x, -self.camera_y)
end

function Level:draw(_x, _y, _width, _height)
	for _, layer in pairs(self.level.layers) do
		layer.tilemap:draw(0, 0)
	end
end
