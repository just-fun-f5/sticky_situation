extends KinematicBody2D
const THROW_VELOCITY = 300

var velocity = Vector2(0,0)
var gravity = 200

#func _ready():
#	set_physics_process(false)
	
func _physics_process(delta):
	launch()
	velocity.y += gravity * delta

	var collision = move_and_collide(velocity * delta)
	if collision:
		queue_free()
		
func launch():
#	var temp = global_transform
#	var scene = get_tree().current_scene
#	get_parent().remove_child(self)
#	scene.add_child(self)
#	global_transform = temp
	velocity = Vector2(cos(rotation),sin(rotation)) * THROW_VELOCITY
#	set_physics_process(true)
	
func _on_impact(normal: Vector2):	
	velocity = Vector2.ZERO

