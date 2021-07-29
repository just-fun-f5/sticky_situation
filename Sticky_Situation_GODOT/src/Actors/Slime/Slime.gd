extends KinematicBody2D

const UP = Vector2.UP
const WALL_JUMP_VELOCITY = Vector2(400, -250)
const UNIT_SIZE = 16

var slime_ball = preload("res://src/Actors/Slime/SlimeBall.tscn")

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
var facing = 1
var wall_direction = 1
var move_direction = 0

# networking
puppet var puppet_pos = Vector2()
puppet var puppet_direction = 0
#Animation nodes
onready var body = $Slime2Animation
onready var anim_player = $Slime2Animation/AnimationPlayer2
onready var sprites = {
	"fire" : $Slime2Animation/fire,
	"ice": $Slime2Animation/slime2,
	"slime": $Slime2Animation/slime,
}
#hmc
onready var hmc = $hmc
# FSM
onready var FSM = $SlimeFSM
#Raycast nodes
onready var left_wall_raycasts = $WallRaycast/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycast/RightWallRaycasts

#CooldwonNodes
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer

#Skill Variables
onready var skwh = $skill_wheel_selector/SkillWheel
export (Resource) var current_element
export (Array, Resource) var avaible_skills
var current_skill = 0
const base_damage = 100
var used_skill = ""
onready var enemy_pos = $EatArea/enemy
onready var eating_timer = $EatArea/eatingTimer
onready var passive_damage = $EatArea/passiveDamage
onready var eating_collision_shape = $EatArea/CollisionShape2D
var captured_enemy

#Calculate kinematic equations
func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	hmc._set_HP(100)
	hmc._set_MP(100)
	if !Game.is_net_master(self):
		$CanvasLayer/UI.hide()

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
	# flippear el sprite para que mire dónde se esta moviendo
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
	# Caer mś lento cuando estoy haciendo walljump
	var max_velocity = 16 if !Input.is_action_pressed("down") else 15 * UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)
	velocity.x = 1*wall_direction

func _apply_movement():
	# Esta función finalmente lo mueve
	velocity = move_and_slide(velocity,UP)
	_paint()
	is_grounded = is_on_floor() # !revisar
	
	if Game.is_net_master(self):
		rset_unreliable("puppet_pos", position) #rset_unreliable
	else:
		position = lerp(position, puppet_pos, 0.5)
		puppet_pos = position
		
func _paint():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.has_method("collide_with_paint"):
			collision.collider.collide_with_paint(collision,self)

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


# ---------------- SKILLS ----------------


func _throw():
	#	throw a "" of the current element,
	#	that affect the first object impacted.
	# var missil = 
	var slime_ball_instance = slime_ball.instance()
	get_parent().add_child(slime_ball_instance)
	slime_ball_instance.position = global_position
	slime_ball_instance.launch(facing)
	var damage = avaible_skills[current_skill].damage * current_element.damage_factor
	var mana  = avaible_skills[current_skill].mana
	hmc.hit_MP(mana)
	damage += 1
	# missil.launch
	
	
export(PackedScene) var blood : PackedScene

func _explode():
	#	make a radial explosion, that affects "x" area
	#	and drain all the remaining mana
	#$Current_Element.explode()
	var mana  = avaible_skills[current_skill].mana
	hmc.hit_MP(mana)
	
	for i in range(45):
		var blood_instance : Area2D = blood.instance()
#		blood_instance.global_position = slime_node.position
		blood_instance.global_position = position
		get_parent().add_child(blood_instance)
	
	return "explode"

func _on_EatArea_area_entered(area):
	if area.is_in_group("Enemies"):
		enemy_pos.texture = area.get_node("eated").texture
		captured_enemy = area
		enemy_pos.visible = true
		eating_timer.start()
		passive_damage.start(0.5)
		captured_enemy.visible = false
		FSM.set_state(FSM.states.eating)
		eating_collision_shape.disabled = true
		
		

func _on_eatingTimer_timeout():
	captured_enemy.visible = true
	captured_enemy = null
	enemy_pos.texture = null
	enemy_pos.visible = false
	FSM.set_state(FSM.states.idle)
	FSM.is_skill_used = false
	

func _on_passiveDamage_timeout():
	if captured_enemy != null:
		captured_enemy.hit(avaible_skills[current_skill].damage)

		
func _eat():
	#	eat the nearest enemy, which get a passive damage
	#	the partner can affect the enemy when is inside the
	# 	slime
	var mana  = avaible_skills[current_skill].mana
	
	if FSM.state in [FSM.states["idle"], FSM.states["run"]]:
		hmc.hit_MP(mana)
		return "eat"
	
func _change_skill(direction):
	var pos = 1 if (direction > 0) else 2
	current_skill = int(abs(current_skill + pos)) % 3
	skwh.move_wheel(direction)
	print(avaible_skills[current_skill].skill_name)

func _use_skill():
	#	Uses the current skill
	print(avaible_skills[current_skill].skill_name)
	if avaible_skills[current_skill].mana > hmc.MP:
		return
	
	
	used_skill = call(avaible_skills[current_skill].skill_name)
	$Slime2Animation/AnimationPlayer2.play(avaible_skills[current_skill].animation_name)
	return used_skill
# ---------------- ELEMENTS ----------------
func _absorb(element):
	current_element = element
	set_current_sprite(element.name.to_lower())
	
func set_current_sprite(element):
	for key in sprites.keys():
		sprites[key].visible = (key == element)

# ---------------- MANA/HP ---------------






