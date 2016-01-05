define () ->
	class GameMap
		constructor: (id_user, players, ghosts, treasures, websocket) ->
			
			@space_width = $("#conf_space_width").val()
			@space_height = $("#conf_space_height").val()
			@icon_size = $("#conf_icon_size").val()
			@move = 5
			@ghost_radius = $("#conf_ghost_radius").val()
			@treasure_radius = $("#conf_treasure_radius").val()
			
			@ws = websocket
			@user_id = id_user
			# Y position of buster
			@canvas = document.getElementById("gameArena")
			@canvas.width = @space_width
			@canvas.height = @space_height
			# canvas
			@ctx = undefined
			# context
			@emptyBack = new Image
			
			@busters = []
			@busters_images = []
			
			@addBuster(
				buster.uid, buster.name, buster.team, buster.pos.x, buster.pos.y
			) for buster in players
			
			@ghosts = []
			@ghosts_images = []
			
			@addGhost(
				ghost.uid, ghost.level, ghost.mood, ghost.pos.x, ghost.pos.y
			) for ghost in ghosts
			
			@treasures = []
			@treasures_images = []
			
			@addTreasure(
				treasure.uid, treasure.status, treasure.pos.x, treasure.pos.y
			) for treasure in treasures
			
			@sensible_area = new Image
			@sensible_area.src = '/assets/images/Area.png'
			
			@team_red = new Image
			@team_red.src = '/assets/images/Team_red.png'
			
			@team_blue = new Image
			@team_blue.src = '/assets/images/Team_blue.png'
			
		startGame: ->
			console.log("Start Game!")
			# Make sure you got the context.
			if @canvas.getContext
				# If you have it, create a canvas user interface element.
				# Specify 2d canvas type.
				@ctx = @canvas.getContext('2d')
				# Paint it black.
				@ctx.fillStyle = 'grey'
				@ctx.rect 0, 0, @space_width, @space_height
				@ctx.fill()
				# Save the initial background.
				@emptyBack = @ctx.getImageData(0, 0, @space_width, @space_height)
			# Play the game until the until the game is over.
			callback_interval = @doGameLoop.bind(this)
			gameLoop = setInterval(callback_interval, 60)
			# Add keyboard listener.
			callback_key = @whatKey.bind(this)
			window.addEventListener 'keydown', @whatKey.bind(this), true
			return
		
		addBuster: (uid, name, team, x, y) ->
			buster = {}
			buster.uid = uid
			buster.name = name
			buster.team = team
			buster.x = x
			# current buster position X
			buster.y = y
			# current buster position Y
			buster.old_x = x
			# old buster position X
			buster.old_y = y
			# old buster position Y
			@busters.push buster
			buster_img = new Image
			# buster
			buster_img.src = '/assets/images/G' + @busters.length + '.png'
			@busters_images.push buster_img
			return
		
		busterMove: (uid, x, y) ->
			for buster, i in @busters when buster.uid == uid
				@busters[i].old_x = buster.x
				@busters[i].old_y = buster.y
				@busters[i].x = x
				@busters[i].y = y
			return
			
		addGhost: (uid, level, mood, x, y) ->
			ghost = {}
			ghost.uid = uid
			ghost.level = level
			ghost.mood = mood
			ghost.x = x
			# current ghost position X
			ghost.y = y
			# current ghost position Y
			ghost.old_x = x
			# old ghost position X
			ghost.old_y = y
			# old ghost position Y
			@ghosts.push ghost
			ghost_img = new Image
			# ghost
			ghost_img.src = '/assets/images/Ghost_L' + level + '_right.png'
			@ghosts_images.push ghost_img
			return
		
		ghostMove: (uid, mood, x, y) ->
			console.log "GHOST MOVE: {uid: " + uid + ", mood:" + mood + ", x: " + x + ", y: " + y + "}"
			for ghost, i in @ghosts when ghost.uid == uid
				@ghosts[i].mood = mood
				if @ghosts[i].mood == 1 // Oh oh, someone is angry...
					alert "fantasma incazzato!"
					if ghost.x > x
						@ghosts_images[i].src = '/assets/images/Ghost_L' + @ghosts[i].level + '_Angry_left.png'
					else
						@ghosts_images[i].src = '/assets/images/Ghost_L' + @ghosts[i].level + '_Angry_right.png'
				else
					if ghost.x > x
						@ghosts_images[i].src = '/assets/images/Ghost_L' + @ghosts[i].level + '_left.png'
					else
						@ghosts_images[i].src = '/assets/images/Ghost_L' + @ghosts[i].level + '_right.png'
				@ghosts[i].old_x = ghost.x
				@ghosts[i].old_y = ghost.y
				@ghosts[i].x = x
				@ghosts[i].y = y
			return
		
		addTreasure: (uid, status, x, y) ->
			treasure = {}
			treasure.uid = uid
			treasure.name = name
			treasure.x = x
			# current buster position X
			treasure.y = y
			# current buster position Y
			@treasures.push treasure
			treasure_img = new Image
			# buster
			if status == 0 #close
				treasure_img.src = '/assets/images/Treasure_close.png'
			else if status == 1 #open
				treasure_img.src = '/assets/images/Treasure_open.png'
			@treasures_images.push treasure_img
			return
		
		updateTreasure: (uid, status) ->
			for treasure, i in @treasures when treasure.uid == uid
				@treasures[i].status = status
				if status == 0 #close
					@treasures_images[i].src = '/assets/images/Treasure_close.png'
				else if status == 1 #open
					@treasures_images[i].src = '/assets/images/Treasure_open.png'
			return
			
		doGameLoop: ->
			
			@ctx.putImageData(@emptyBack, 0, 0);
			
			for treasure, i in @treasures
				# To center the images in their position point
				treasure_x = @treasures[i].x - (@icon_size / 2)
				treasure_y = @treasures[i].y - (@icon_size / 2)
				area_x =  @treasures[i].x -  @treasure_radius
				area_y =  @treasures[i].y -  @treasure_radius
				# Drawings
				@ctx.drawImage(
					@sensible_area
					area_x 
					area_y 
					(@treasure_radius * 2)
					(@treasure_radius * 2)
				)
				@ctx.drawImage(
					@treasures_images[i]
					treasure_x
					treasure_y
					@icon_size
					@icon_size
				) 
				
			for buster, i in @busters
				# To center the image in its position point
				buster_x = @busters[i].x - (@icon_size / 2)
				buster_y = @busters[i].y - (@icon_size / 2)
				# Drawings
				@ctx.drawImage(
					@busters_images[i]
					buster_x
					buster_y
					@icon_size
					@icon_size
				)
				# Draw team square color in the corner bottom-right
				if buster.team == 0
					team_img = @team_red
				else if buster.team == 1
					team_img = @team_blue
				@ctx.drawImage(
						team_img
						(buster_x + (@icon_size - 8))
						(buster_y + (@icon_size - 8))
						8
						8
					)
			
			for ghost, i in @ghosts
				# To center the images in their position point
				ghost_x = @ghosts[i].x - (@icon_size / 2)
				ghost_y = @ghosts[i].y - (@icon_size / 2)
				area_x =  @ghosts[i].x - (@ghost_radius * @ghosts[i].level)
				area_y =  @ghosts[i].y - (@ghost_radius * @ghosts[i].level)
				# Drawings
				@ctx.drawImage(
					@sensible_area
					area_x
					area_y
					(@ghost_radius * 2 * @ghosts[i].level)
					(@ghost_radius * 2 * @ghosts[i].level)
				)
				@ctx.drawImage(
					@ghosts_images[i]
					ghost_x
					ghost_y
					@icon_size
					@icon_size
				)
				
			return
		
		# Get key press.
		
		whatKey: (evt) ->
			for buster, i in @busters when buster.uid == @user_id
				
				# Arrows keys
				arrows = [
					37
					38
					39
					40
				]
				# Flag to put variables back if we hit an edge of the board.
				flag = 0
				# Get where the buster was before key process.
				@busters[i].old_x = @busters[i].x
				@busters[i].old_y = @busters[i].y
				if arrows.indexOf(evt.keyCode) == -1
					return false
				evt.preventDefault();
				switch evt.keyCode
					# Left arrow.
					when 37
						@busters[i].x = @busters[i].x - @move
						if @busters[i].x < (@icon_size / 2)
							# If at edge, reset buster position and set flag.
							@busters[i].x = (@icon_size / 2)
							flag = 1
					# Right arrow.
					when 39
						@busters[i].x = @busters[i].x + @move
						if @busters[i].x > @space_width - (@icon_size / 2)
							# If at edge, reset buster position and set flag.
							@busters[i].x = @space_width - @move
							flag = 1
					# Down arrow
					when 40
						@busters[i].y = @busters[i].y + @move
						if @busters[i].y > @space_height - (@icon_size / 2)
							# If at edge, reset buster position and set flag.
							@busters[i].y = @space_height - @move
							flag = 1
					# Up arrow 
					when 38
						@busters[i].y = @busters[i].y - @move
						if @busters[i].y < (@icon_size / 2)
							# If at edge, reset buster position and set flag.
							@busters[i].y = (@icon_size / 2)
							flag = 1
				
				# If flag is set, the buster did not move.
				# Put everything backBuster the way it was.
				if flag
					@busters[i].x = @busters[i].old_x
					@busters[i].y = @busters[i].old_y
				
				@ws.send(JSON.stringify
					event: "update_player_position"
					pos:
						x: @busters[i].x
						y: @busters[i].y
				)
				
			return
	        	
	return GameMap