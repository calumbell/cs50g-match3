--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level
    self.colours = {
        -- debug colours
        --1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
       
        2 * math.random(2), -- pinks
        2 * math.random(0,2) + 1, -- brown/green
        2 * math.random(0,1) + 6, -- reds
        2 * math.random(0,1) + 7, -- brighter greens
        2 * math.random(0,1) + 10, -- orange/brown
        2 * math.random(0,1) + 11, -- blues
        2 * math.random(0,2) + 14, -- greys
        2 * math.random(0,1) + 15 -- purples
    }

    self.transitionAlpha = 255

    self:initializeTiles(level)
end



function Board:initializeTiles(level)
    self.tiles = {}

    -- iterate over rows
    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        -- iterate over tiles in a row
        for tileX = 1, 8 do
            local variety = math.random(math.min(level, 6))
            table.insert(self.tiles[tileY], Tile(tileX, tileY, self.colours[math.random(#self.colours)], variety))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles(level)
    end
end


function Board:reinitializeTiles(level)
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })
    :finish(function ()
        self:initializeTiles(level)
        Timer.tween(1, {
            [self] = {transitionAlpha = 255}
        })
    end)
end
--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]

function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- check if any tile in our match is shiny
                    local shinyFound = false
                    for x2 = x - 1, x - matchNum, -1 do
                        if self.tiles[y][x2].shiny then shinyFound = true end
                    end

                    -- if shiny not found, add tiles to match
                    if not shinyFound then
                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end

                    -- but if we have a shiny in the match, add all tiles in that row
                    else
                        for x2 = 1, 8 do
                            table.insert(match, self.tiles[y][x2])
                        end
                    end
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- check if any tile in our match is shiny
            local shinyFound = false
            for x = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then shinyFound = true end
            end

            -- if shiny not found, add tiles to match
            if not shinyFound then
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end

            -- but if we have a shiny in the match, add all tiles in that row
            else
                for x = 1, 8 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}


                    -- iterate across all tiles in the match
                    for y2 = y - 1, y - matchNum, -1 do

                        -- add each tile to the match table
                        table.insert(match, self.tiles[y2][x])

                        -- if tile is shiny, also add the row it is part of
                        if self.tiles[y2][x].shiny then
                            for x2 = 1, 8 do
                                table.insert(match, self.tiles[y2][x2])
                            end
                        end
                    end



                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- iterate across all tiles in the match
            for y2 = 8, 8 - matchNum + 1, -1 do

                -- add each tile to the match table
                table.insert(match, self.tiles[y2][x])

                -- if tile is shiny, also add the row it is part of
                if self.tiles[y2][x].shiny then
                    for x2 = 1, 8 do
                        table.insert(match, self.tiles[y2][x2])
                    end
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]


function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Returns true if swapping the tiles at the two sets of coordinates returns in a match
    otherwise returns false.
]]

function Board:checkForMatch(x1, y1, x2, y2)
    -- create a virtual board for testing
    local vBoard = self:createVirtualBoard(8)

    -- swap tiles at (x1, y1) and (x2, y2)
    local tempTile = vBoard[y1][x1]
    vBoard[y1][x1] = vBoard[y2][x2]
    vBoard[y2][x2] = tempTile

    local matchFound = false

    -- check for matches starting at (x1, y1)
    matchFound = matchFound or self:checkForMatchInRow(y1, vBoard)  
    matchFound = matchFound or self:checkForMatchInColumn(x1, vBoard)

    -- check for matches starting at (x2, y2)
    if x1 == x2 then
        matchFound = matchFound or self:checkForMatchInRow(y2, vBoard)
    else
        matchFound = matchFound or self:checkForMatchInColumn(x2, vBoard) 
    end

    return matchFound
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]

function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, self.colours[math.random(#self.colours)], math.min(math.random(self.level+1), 6))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y, self.transitionAlpha)
        end
    end
end

function Board:checkForMoves()
    local tiles = self:createVirtualBoard(8)
    local centerTile = nil

    -- iterate across x + y in chunks of 2
    for xi = 1, 7, 2 do
        for yi = 1, 7, 2 do

            -- check for tile swaps at both (x, y) and (x+1, y+1) 
            for i = 0, 1 do

                local x = xi + i
                local y = yi + i

                centerTile = tiles[y][x]

                if x > 1 then
                    -- swap with tile to the left
                    tiles[y][x] = tiles[y][x-1]
                    tiles[y][x-1] = centerTile

                    -- check for matches in row y and columns x, x-1
                    if self:checkForMatchInRow(y, tiles, math.max(x-2, 1), math.min(x+3, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x, tiles, math.max(y-2, 1), math.min(y+2, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x-1, tiles, math.max(y-2, 1), math.min(y+2, 8)) then
                        return tiles[y][x]
                    end

                    -- reset the board
                    tiles[y][x-1] = tiles[y][x]
                    tiles[y][x] = centerTile
                end

                if x < 8 then
                    -- swap with tile to the right
                    tiles[y][x] = tiles[y][x+1]
                    tiles[y][x+1] = centerTile
                
                    -- check for matches in row y and columns x, x+1
                    if self:checkForMatchInRow(y, tiles, math.max(x-2, 1), math.min(x+3, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x, tiles, math.max(y-2, 1), math.min(y+2, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x+1, tiles, math.max(y-2, 1), math.min(y+2, 8)) then
                        return tiles[y][x]
                    end

                    -- reset the board
                    tiles[y][x+1] = tiles[y][x]
                    tiles[y][x] = centerTile
                end

                if y > 1 then
                    -- swap with tile above
                    tiles[y][x] = tiles[y-1][x]
                    tiles[y-1][x] = centerTile

                    -- check for matches in row y and columns x, x-1
                    if self:checkForMatchInRow(y, tiles, math.max(x-2, 1), math.min(x+3, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInRow(y-1, tiles, math.max(y-2, 1), math.min(y+3, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x, tiles, math.max(y-2, 1), math.min(y+2, 8)) then
                        return tiles[y][x]
                    end

                    -- reset the board
                    tiles[y-1][x] = tiles[y][x]
                    tiles[y][x] = centerTile
                end


                if y < 8 then
                    -- swap with tile below
                    tiles[y][x] = tiles[y+1][x]
                    tiles[y+1][x] = centerTile

                    -- check for matches in rows y, y+1 and column x
                    if self:checkForMatchInRow(y, tiles, math.max(x-2, 1), math.min(x+2, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInRow(y+1, tiles, math.max(x-2, 1), math.min(x+2, 8)) then
                        return tiles[y][x]
                    elseif self:checkForMatchInColumn(x, tiles, math.max(y-2, 1), math.min(y+3, 8)) then
                        return tiles[y][x]
                    end

                    -- reset board
                    tiles[y+1][x] = tiles[y][x]
                    tiles[y][x] = centerTile
                end
            end
        end
    end

    return false

end


--[[
    Searches a given row (y) of a 2D array of tiles for matches
    Return true if one if found, else returns false
]]

function Board:checkForMatchInRow(y, tiles, x1, x2)
    -- determine start and end points of row
    local start = x1 or 1
    local finish = x2 or 8

    if start == finish then return false end

    -- lastColor keeps track of the color we are trying to match
    local lastColor = tiles[y][start].color

    -- colorsMatched keeps track of how many colors we have matched so far
    local colorsMatched = 1

    -- iterate over row
    for x = start + 1, finish do

        if tiles[y][x].color == lastColor then

            -- the colors match, increment colorsMatched
            colorsMatched = colorsMatched + 1

            -- if we match 3 colors, return true
            if colorsMatched >= 3 then
                return true
            end
        else
            -- if there isn't a match, reset our variables
            colorsMatched = 1
            lastColor = tiles[y][x].color
        end
    end

    return false
end

--[[
    Searches a given column (x) of a 2D array of tiles for matches
    Return true if one if found, else returns false
    If we only want to check a subsection of a column, use the optional
    first and last arguments.
]]
function Board:checkForMatchInColumn(x, tiles, y1, y2)
    -- determine start and end points of column
    local start = y1 or 1
    local finish = y2 or 8

    if start == finish then return false end

    -- lastColor keeps track of the color we are trying to match
    local lastColor = tiles[start][x].color

    -- colorsMatched keeps track of how many colors we have matched so far
    local colorsMatched = 1


    -- iterate over row
    for y = start+1, finish do

        if tiles[y][x].color == lastColor then

            -- the colors match, increment colorsMatched
            colorsMatched = colorsMatched + 1

            -- if we match 3 colors, return true
            if colorsMatched >= 3 then
                return true
            end
        else
            -- if there isn't a match, reset our variables
            colorsMatched = 1
            lastColor = tiles[y][x].color
        end
    end

    return false
end

--[[
    Returns a copy of the current board, useful for checking for swaps without
    updating the game board
]]

function Board:createVirtualBoard(size)
    -- create a virtual board for testing
    local virtualBoard = {}

    for y = 1, size do
        table.insert(virtualBoard, {})
        for x = 1, size do
            table.insert(virtualBoard[y], Tile(x, y, self.tiles[y][x].color, 1))
        end
    end

    return virtualBoard
end