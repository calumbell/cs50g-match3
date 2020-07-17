ResetBoardState = Class{__includes = BaseState}

function ResetBoardState:init()
	self.transitionAlpha = 0
	self.labelY = -64
end

function ResetBoardState:enter(params)
	self.board = params.board
	self.timer = params.timer
	self.score = params.score
	self.level = params.level
	
	Timer.tween(0.25, {
		[self] = {transitionAlpha = 255},
		[self] = {labelY = VIRTUAL_HEIGHT / 2}
	}):finish(function()
		Timer.after(0.75, function()
			self.board:initializeTiles()
	        Timer.tween(0.5, {
	            [self] = {transitionAlpha = 0},
	            [self] = {labelY = VIRTUAL_HEIGHT + 64}
	        }):finish(function()
	    		gStateMachine:change('play', {
	    			board = self.board,
	    			timer = self.timer,
	    			score = self.score,
	    			level = self.level
	    		})
	    	end)
		end)
	end)
end

function ResetBoardState:update(dt)
	if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

	Timer.update(dt)
end

function ResetBoardState:render()
	love.graphics.setColor(255, 255, 255, transitionAlpha)
	self.board:render()

	-- draw rectangle with tweened alpha
	love.graphics.setColor(255, 255, 255, transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('No Matches Left!',
        0, self.labelY, VIRTUAL_WIDTH, 'center')
end