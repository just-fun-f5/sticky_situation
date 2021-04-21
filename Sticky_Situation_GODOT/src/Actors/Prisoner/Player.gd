"""
This script controls the player character.
"""
extends KinematicBody2D

const JUMP_FORCE = 700			# Force applied on jumping
const MOVE_SPEED = 200			# Speed to walk with
const GRAVITY = 50				# Gravity applied every second
const MAX_SPEED = 1000			# Maximum speed the player is allowed to move
const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground
const CHAIN_PULL = 60

var velocity = Vector2(0,0)		# The velocity of the player (kept over time)
var chain_velocity := Vector2(0,0)
var can_jump = false			# Whether the player used their air-jump
onready var Animated_Sprite= $AnimatedSprite
onready var body = $Prisoner
var grounded
var move_direction

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			$Chain.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release()
			$Chain.release()

# This function is called every physics frame
func _physics_process(_delta: float) -> void:
	if is_network_master():
		pass
	
func _assign_animation():
	var anim = "Idle"
	if !grounded:
		anim = "Jump"
	elif velocity.x != 0:
		anim = "Run"
		
	if Animated_Sprite.animation != anim:
		Animated_Sprite.play(anim)	

func init(nid):
	set_network_master(nid)
	var info = Game.players[nid]
	$Name.text = info["name"]
	name = str(nid)
