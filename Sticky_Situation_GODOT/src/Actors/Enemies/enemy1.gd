extends Area2D

# SKILLS
var HP = 100

func hitSelf(damage):
	HP -= damage

func hitOther(damage, other):
	other.hit(damage)

# FSM
enum states  {idle, attack, walk, run, dead}
var current_state = states.idle
onready var anim_player = $AnimationPlayer

#Raycast
onready var lef_raycast = $viewLeft
onready var right_raycast = $viewRight

#Timers
onready var dead_timer= $timers/DeadAnim

func physics_process(delta):
	if HP <= 0:
		current_state = states.dead
	match current_state:
		states.idle:
			anim_player.play("Idle")
			if lef_raycast.is_colliding():
				current_state = states.run
			if right_raycast.is_colliding():
				current_state = states.run
		states.attack:
			anim_player.play("Attack")
		states.walk:
			anim_player.play("Walk")
		states.run:
			anim_player.play("Run")
		states.dead:
			anim_player.play("Dead")
			dead_timer.start()
			

#DIE
func _on_DeadAnim_timeout():
	call_deferred("queue_free")
