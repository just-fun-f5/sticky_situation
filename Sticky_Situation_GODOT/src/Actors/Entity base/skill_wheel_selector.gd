extends Control

var canrot = true

# radio de la rueda
export var r = 20

# color con que se oscurecen los íconos traseros
export (Color) var dark_col = Color(0.8, 0.8, 0.8)

# punto en que un ícono pasa a estar "atrás" (0 <= z_thres <= 1)
export (float) var z_thres = 0.9

# si la distancia al centro es menor que light_margin, el ícono se ilumina
# depende de cúanto sea desplazado por el tween durante el "rebote"
export (float) var light_margin = 0.5

onready var wheel = $wheel
onready var tween: Tween = $Tween


func _ready():
	update_rects()
	
func _process(delta):
	update_rects()

func update_rects():
	for p in wheel.get_children():
		var rect: Sprite = p.get_node("Icon")
		var x_pos = p.to_global(p.translation).x
		var z_pos = p.to_global(p.translation).z
		rect.position.x = rect_position.x + r * x_pos
		rect.position.y = rect_position.y
		rect.z_index = 1 if z_pos > z_thres else 0
		
		# Uso self_modulate para que no sobrescriba el modulate
		# Si no usarán modulate, pueden reemplazar self_modulate por modulate
		if rect.z_index == 1 and abs(x_pos) < 0.5:
			rect.self_modulate = Color.white
		else:
			rect.self_modulate = dark_col

func move_wheel(dir):
	if not canrot: return
	canrot = false
	tween.interpolate_property(
		wheel, "rotation_degrees:y", null, 
		wheel.rotation_degrees.y + sign(dir) * 120, 0.25,
		tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	canrot = true

#func _input(event):
#	if event.is_action_pressed("skill_left"):
#		move_wheel(1)
#	if event.is_action_pressed("skill_right"):
#		move_wheel(-1)
