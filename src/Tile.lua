--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- rarely, spawn a shiny block
    if math.random(25) == 1 then
        self.shiny = true
        Tile:initParticleSystem()      
    else
        self.shiny = false
    end
end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- if shiny, add something extra
    if self.shiny then
        self.psystem:emit(32)
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
    end
end

function Tile:update(dt)
    if self.shiny then
        self.psystem:update(dt)
    end
end


-- method for setting up our particle system for shiny tiles
function Tile:initParticleSystem()
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 32)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-20, -20, 20, 20)
    self.psystem:setAreaSpread('normal', 5, 5)
    self.psystem:setColors(
        255, -- r
        255, -- g
        255, -- b
        50, -- a
        255, -- r
        255, -- g
        255, -- b
        0    -- a
    )
    self.psystem:setSizes(0.5, 0)
end