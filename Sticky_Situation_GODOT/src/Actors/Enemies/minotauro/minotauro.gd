extends KinematicBody2D


var speed=200

onready var hmc = $hmc

var damage=1

var direction=1


# Called when the node enters the scene tree for the first time.
func _ready():

	set_physics_process(true)

func _physics_process(delta):
	
	if(is_on_wall()):
		
		direction *= -1
		
	if(test_move(Transform2D(0,Vector2(position.x+64*direction,position.y)),Vector2(0,32))):
		
		direction *= -1
	move_and_slide(Vector2(speed*direction,0),Vector2(0,-1))
