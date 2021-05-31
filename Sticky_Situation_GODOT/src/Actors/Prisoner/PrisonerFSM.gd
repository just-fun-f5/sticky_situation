extends StateMachine

#Declare states
func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
#	add_state("wall_slide")
	call_deferred("set_state", states.idle)

#Jump input
func _input(event):
	
	if !Game.is_net_master(self):
		return
	#Jump normally if run or idle state
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("jump"):
			parent.velocity.y = parent.max_jump_velocity
		
	#Variable jump height if input is released
	elif state == states.jump:
		if event.is_action_released("jump") and parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity
	
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			print(event.position)
			$"../Chain".shoot(parent.get_global_mouse_position() - parent.global_position)
		else:
			# We released the mouse -> release()
			$"../Chain".release()

func _state_logic(delta):
	parent._update_move_direction()
	parent._handle_move_input() # Calcular la vel hor
	parent._apply_gravity(delta)
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
			elif parent.velocity.x != 0:
				return states.run
		#Run state
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		#Jump state
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		#Fall state
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump				
	return null

func _enter_state(new_state, old_state):
	#Apply animations when entering a new state:
	match new_state:
		states.idle:
			parent.anim_player.play("Idle")
		states.run:
			parent.anim_player.play("Run")	
		states.jump:
			parent.anim_player.play("Jump")
		states.fall:
			parent.anim_player.play("Fall")

func _exit_state(old_state, new_state):
	pass

