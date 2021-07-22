extends Label

#Shows current state

var start_position = Vector2()
onready var parent = get_parent()

func _ready():
	start_position = rect_position
	

func _physics_process(_delta):
	rect_position = parent.position + start_position
	if parent.state == parent.states.idle:
		set_text("Idle")
	elif parent.state == parent.states.run:
		set_text("Run")
	elif parent.state == parent.states.jump:
		set_text("Jump")
	elif parent.state == parent.states.fall:
		set_text("Fall")
#	elif parent.state == parent.states.wall_slide:
#		set_text("Wall Slide")
