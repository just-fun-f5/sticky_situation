extends KinematicBody2D

const UP = Vector2.UP
const WALL_JUMP_VELOCITY = Vector2(400, -250)
const UNIT_SIZE = 16

#Movement and jump variables
var velocity = Vector2()
var move_speed = 9 * UNIT_SIZE
var gravity
var max_jump_velocity 
var min_jump_velocity 
var max_jump_height = 6.25 * UNIT_SIZE
var min_jump_height = 1 * UNIT_SIZE
var jump_duration = 0.5

#Direction variables
var is_grounded
var facing
var wall_direction = 1
var move_direction

#Animation nodes
onready var body = $SlimeNode
onready var anim_player = $SlimeNode/Slime2Animation/AnimationPlayer2

onready var hook_map = get_node("../HookMap")
#onready var hook_map = get_node("../AutoTile")

#Raycast nodes
onready var left_wall_raycasts = $WallRaycast/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycast/RightWallRaycasts

#CooldwonNodes
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer

#Calculate kinematic equations
func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

#Determine move direction (-1, 0 or 1)
func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	#If near two walls player move direction corresponds to move direction
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
		
func _handle_move_input():
#	Apply horizontal velocity 
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
#	Orient sprite to move direction
	if move_direction != 0:
		body.scale.x = move_direction
		facing = move_direction

#Apply gravity
func _apply_gravity(delta):
	velocity.y += gravity * delta

func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity

#Caps gravity if player is wallsliding unless they press down	
func _cap_gravity_wall_slide():
	var max_velocity = 16 if !Input.is_action_pressed("down") else 15 * UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)

#func _paint():
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision.collider.has_method("collide_with"):
#			collision.collider.collide_with(collision,self)
#			var x = int(position.x)/16
#			var y = int(position.y)/16
#			if  wall_direction != 0:
#				print(wall_direction)
#				if hook_map.get_cell(x + wall_direction,y) == 0:
#					hook_map.set_cell(x + wall_direction,y,1)
#					hook_map.update_bitmask_area(Vector2(x,y))
#			if is_on_ceiling():
#				if hook_map.get_cell(x,y - 1) == 0:
#					hook_map.set_cell(x,y - 1,1)
#					hook_map.update_bitmask_area(Vector2(x,y))
#
#			else:
#				if hook_map.get_cell(x, y + 1) == 0:
#					hook_map.set_cell(x, y + 1, 1)
#					hook_map.update_bitmask_area(Vector2(x,y))

func _apply_movement():
	velocity = move_and_slide(velocity,UP)
	
	_paint()
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.has_method("collide_with"):
			collision.collider.collide_with(collision,self)
#			emit_signal("collided",collision)

	is_grounded = is_on_floor()
	
func _paint():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.has_method("collide_with_paint"):
#			collision.collider.collide_with_paint(collision,self)
			var tile_pos = collision.collider.world_to_map(position)
			tile_pos -= collision.normal
			var tile = collision.collider.get_cellv(tile_pos)
			if tile == 0:
				collision.collider.set_cellv(tile_pos, 1)
				hook_map.set_cellv(tile_pos, 1)
				collision.collider.update_bitmask_area(tile_pos)

func _check_is_valid_wall(wall_raycasts):
	#Check if raycasts are colliding
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			#Relevant when using slopes:
				#var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
				#if dot > PI * 0.35 and dot < PI * 0.55:
			return true
	return false

#Starts timmer to stop player from immedeatly sticking to wall again
func _handle_wall_slide_sticking():
	if move_direction != 0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
		else:
			wall_slide_sticky_timer.stop()

#Throw Stuff:

#func _spawn_slime():
#	if held_item == null:
#		held_item = RockProjectile_PS.instance()
#		held_item_position.add_child(held_item)
#
#func _throw_held_item():
#	held_item.launch(facing)
#	held_item = null
#
