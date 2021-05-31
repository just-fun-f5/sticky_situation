extends Resource
class_name stats


const UP = Vector2.UP
const WALL_JUMP_VELOCITY = Vector2(400, -250)
const UNIT_SIZE = 16

#Movement and jump variables
var velocity = Vector2()
var move_speed = 9 * UNIT_SIZE
var gravity
var max_jump_velocity 
var min_jump_velocity 
var max_jump_height = 6.25 * UNIT_SIZE
var min_jump_height = 1 * UNIT_SIZE
var jump_duration = 0.5

#Direction variables
var is_grounded
var facing
var wall_direction = 1
var move_direction = 0

#Skill Variables
export (Resource) var current_element
enum {THROW, EXPLODE, EAT}
var skills = [
	"_throw",
	"_explode",
	"_eat"
]
var current_skill = THROW
const base_damage = 100
