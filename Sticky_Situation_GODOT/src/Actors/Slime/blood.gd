extends Area2D

var is_colliding = false

var vspeed = rand_range(-7,3)
var hspeed = rand_range(-4,4)

var blood_acc = rand_range(0.05,0.1)


var do_wobble = false

var max_count = rand_range(5,50)
var count  = 0

onready var draw_surface : paint = $"/root/Surface"

func _physics_process(delta: float) -> void:
	if(!is_colliding): # in the air
		do_wobble = false
		vspeed = lerp(vspeed,5,0.02)
		hspeed = lerp(hspeed,0,0.02)
		visible = true
		
	else: # touching platform
		draw_surface.draw_blood(position) # draw blood to surface
		
		#Count increase until max_count, then delete
		count += 1
		if(count > max_count) : queue_free()
		
		#We make sure blood drop faster than 3, slowly reduce speed
		if (vspeed > 1.5) : vspeed = 1.5
		vspeed = lerp(vspeed,0.1,blood_acc)
		
		#If we're moving downwards in a line, add wobble
		if(hspeed > 0.1 or hspeed < -0.1):
			hspeed = lerp(hspeed,0,0.1)
		else:
			do_wobble = true

		visible = false
		
	#we add random wobble when moving downwards to avoid str8 lines
	if(do_wobble):
		hspeed += rand_range(-0.07,0.07)
		hspeed = clamp(hspeed,-0.1,0.1)
		
	#update our position based on the vspeed and hspeed
	position.y += vspeed
	position.x += hspeed
	
	#delete this object if it left the screen downwards
#	if(position.y > 1000):
#		queue_free()

func _on_blood_body_entered(body: Node) -> void:
	is_colliding = true
	pass # Replace with function body.


func _on_blood_body_exited(body: Node) -> void:
	is_colliding = false
	pass # Replace with function body.
