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
var max_jump_height = 4.25 * UNIT_SIZE
var min_jump_height = 1 * UNIT_SIZE
var jump_duration = 0.5

#Direction variables
var is_grounded
var facing
var wall_direction = 1
var move_direction = 0

var Arrow = preload("res://src/Actors/Prisoner/Arrow.tscn")

# networking
puppet var puppet_pos = Vector2()
puppet var puppet_direction = 0

onready var hmc = $hmc

#Animation nodes
onready var body = $SlimeNode
onready var anim_player = $SlimeNode/AnimatedSprite2

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
	if !Game.is_net_master(self):
		hmc.visible(false)

# Configure for multiplayer
func init(nid):
	set_network_master(nid)
	$Camera2D.current = Game.is_net_master(self)
	var info = Game.players[nid]
	$Name.text = info["name"]
	name = str(nid)



func _update_move_direction():
	# Actualizar movimiento a izquerda o dercha
	if Game.is_net_master(self):
		move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
		rset("puppet_direction", move_direction)
	else:
		move_direction = puppet_direction
	# puppet ->

func _update_wall_direction():
	# Verficar a que lado tiene la muraya estoy pegado
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	#If near two walls player move direction corresponds to move direction
	
	# Wall_direction 0 1 -1: Se usa para multiplicar el valor horizontal
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
		
func _handle_move_input():
	# Moverse horizontalmente Obtiene la velocidad en x
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)

	# flippear el sprite para que mire d??nde se esta moviendo
	if move_direction != 0:
		body.scale.x = move_direction
		facing = move_direction

#Apply gravity
func _apply_gravity(delta):
	# Siempre, aplica gravedad (pegado al piso, caer)
	velocity.y += gravity * delta

func wall_jump():
	# Saltar desde una pared (estado wall_slide)
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity

#Caps gravity if player is wallsliding unless they press down	
func _cap_gravity_wall_slide():
	# Caer m?? lento cuando estoy haciendo walljump
	var max_velocity = 16 if !Input.is_action_pressed("down") else 15 * UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)

func _apply_movement():
	# Esta funci??n finalmente lo mueve
	velocity = move_and_slide(velocity,UP)
	is_grounded = is_on_floor() # !revisar
	
	if Game.is_net_master(self):
		rset_unreliable("puppet_pos", position) #rset_unreliable
	else:
		position = lerp(position, puppet_pos, 0.5)
		puppet_pos = position

func _check_is_valid_wall(wall_raycasts):
	#Check if raycasts are colliding
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			#Relevant when using slopes:
				#var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
				#if dot > PI * 0.35 and dot < PI * 0.55:
				return true
	return false

func _handle_wall_slide_sticking():
	# Es para salir del wall slide sin tener que saltar necesariamente
	if move_direction != 0 and move_direction != wall_direction:
		#print("----", move_direction, wall_direction)
		if wall_slide_sticky_timer.is_stopped():
			#print("Timer Started")
			wall_slide_sticky_timer.start()
		else:
			#print("Timer Stopped")
			wall_slide_sticky_timer.stop()
			
func _shoot():
	var arrow = Arrow.instance()
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	arrow.rotation = (get_global_mouse_position() - global_position).angle()
	arrow.launch()
