extends KinematicBody2D

# MOVEMENT
const SPEED = 100
var velocity
var direction = Vector2(0,0)

# SKILLS
var HP = 100

func hit(damage):
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
			print("idle")
			anim_player.play("Idle")
			if lef_raycast.is_colliding():
				current_state = states.run
				moveTo(-1)
				
			if right_raycast.is_colliding():
				current_state = states.run
				moveTo(1)
				
		states.attack:
			print("attack")
			anim_player.play("Attack")
		states.walk:
			print("walk")
			anim_player.play("Walk")
		states.run:
			print("Run")
			anim_player.play("Run")
		states.dead:
			print("Dead")
			anim_player.play("Dead")
			dead_timer.start()
			
func moveTo(direction):
	velocity.x = SPEED * direction
	move_and_slide(velocity)
	
#DIE
func _on_DeadAnim_timeout():
	call_deferred("queue_free")
