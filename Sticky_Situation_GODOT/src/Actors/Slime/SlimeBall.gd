extends KinematicBody2D

const THROW_VELOCITY = Vector2(400,-200)

var velocity = Vector2.ZERO
var gravity = 200

func _ready():
	set_physics_process(false)
	

func _physics_process(delta):
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_impact(collision.nomrmal)
		
func launch(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = THROW_VELOCITY * Vector2(direction, 1)
	set_physics_process(true)
	
func _on_impact(normal: Vector2):	
	velocity = velocity.bounce(normal)
	velocity *= 0.5 + rand_range(-0.05, 0.05)
