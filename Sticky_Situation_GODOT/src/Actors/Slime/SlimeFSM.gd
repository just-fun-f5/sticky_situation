extends StateMachine

# Var error
var epsilon = 100

#Declare states
func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("set_state", states.idle)

#Jump input
func _input(event):
	if !Game.is_net_master(self):
		return
	if event.is_action_pressed("mb_right"):
		parent._use_skill()
	#Jump normally if run or idle state
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("jump"):
			parent.velocity.y = parent.max_jump_velocity
	
	#Perform wall jump if wall sliding
	elif state == states.wall_slide:
		if event.is_action_pressed("jump"):
			parent.wall_jump()
			set_state(states.jump)
		
	#Variable jump height if input is released
	elif state == states.jump:
		if event.is_action_released("jump") and parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity
	
	if event.is_action_pressed("skill_left"):
		get_parent()._change_skill(1)
	if event.is_action_pressed("skill_right"):
		get_parent()._change_skill(-1)

func _state_logic(delta):
	#We determine move direction
	parent._update_move_direction()
	#We determine wall direction based on move direction
	parent._update_wall_direction()
	#We receive normal input if not wall sliding
	if state != states.wall_slide:
		parent._handle_move_input() # Calcular la vel hor
	parent._apply_gravity(delta)
	#Use different inputs if 
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()  # caer más lento
		parent._handle_wall_slide_sticking() #! revisar
	#We apply the final movement vector
	parent._apply_movement()

#Transition conditions
func _get_transition(delta):
	match state:
		#Idle state
		states.idle:
			#If not on floor and y velocity postive transition to jump
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
			#If y velocity negative transition to fall
				elif parent.velocity.y > 0:
					return states.fall
			#If not falling or jumping and x velocity not 0 transition to run state
			elif abs(parent.velocity.x) >= epsilon:
				return states.run
		#Run state
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif abs(parent.velocity.x) <= epsilon:
				return states.idle
		#Jump state
		states.jump:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		#Fall state
		states.fall:
			if parent.wall_direction != 0:
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		#Wall Slide state
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
				
	return null

func _enter_state(new_state, old_state):
	#Apply animations when entering a new state:
	match new_state:
		states.idle:
			parent.anim_player.play("Idle")
		states.run:
			parent.anim_player.play("run")	
		states.jump:
			parent.anim_player.play("Jump")
		states.fall:
			parent.anim_player.play("Fall")
		states.wall_slide:
			parent.anim_player.play("wall_slide")
			#Make sprite face away from wall
			parent.body.scale.y = -parent.wall_direction
			#Rotate sprite 
			parent.body.set_rotation(1.5708)

func _exit_state(old_state, new_state):
	match old_state:
		#Start wallslide cooldown and reset rotation when exiting wallslide state
		states.wall_slide:
			parent.wall_slide_cooldown.start()
			parent.body.set_rotation(0)
			parent.body.scale.y = 1

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
