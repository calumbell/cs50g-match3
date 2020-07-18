ResetBoardState = Class{__includes = BaseState}

-- Virtual methods inherited from BaseState

function ResetBoardState:init()
	self.transitionAlpha = 0
	self.labelY = -64
end

function ResetBoardState:enter(params)
	self.board = params.board
	self.timer = params.timer
	self.score = params.score
	self.level = params.level
	
	self:animateAndReturn()

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


-- Helper functions

-- animateAndReturn runs all of the asynchronious logic for the ResetBoardState.
-- The background is whited out, text is animated, and finally we return to the PlayState


function ResetBoardState:animateAndReturn()
	Chain(
		function(go)
			Timer.tween(0.5, {
				[self] = {transitionAlpha = 255}
			})
			Timer.after(0.5, go)
		end,

		function(go)
			Timer.tween(0.25, {
				[self] = {labelY = VIRTUAL_HEIGHT / 2}
			})
			Timer.after(0.25, go)
		end,

		function(go)
			self.board:initializeTiles(self.level)
			Timer.after(0.75, go)
		end,

		function(go)
			Timer.tween(0.75, {
				[self] = {transitionAlpha = 0},
				[self] = {labelY = VIRTUAL_HEIGHT +64}
			})
			Timer.after(0.75, go)
		end,

		function(go)
			gStateMachine:change('play', {
	    		board = self.board,
	    		timer = self.timer,
	    		score = self.score,
	    		level = self.level
	    	})
	    end
	)()
end

