extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var timer = $ResetTimer

onready var reset_position = global_position

var gravity = 400
var velocity = Vector2()
var is_triggered = false

export var reset_time :float = 1.0

func _ready():
	set_physics_process(false)
	
	
func _physics_process(delta):
	velocity.y += gravity * delta
	position += velocity *delta
	
func collide_with(collision : KinematicCollision2D, collider : KinematicBody2D):
	if !is_triggered:
		is_triggered = true
		animation_player.play("shake")
		velocity = Vector2.ZERO

func _on_ResetTimer_timeout():
	set_physics_process(false)
	yield(get_tree(), "physics_frame")
	var temp = collision_layer
	collision_layer = 0
	global_position = reset_position 
	collision_layer = temp
	is_triggered = false

func _on_AnimationPlayer_animation_finished(anim_name):
	set_physics_process(true)
	timer.start()
