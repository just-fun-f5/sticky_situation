extends Node2D

var Prisoner = preload("res://src/Actors/Prisoner/Prisoner s.tscn")
var Slime = preload("res://src/Actors/Slime/Slime.tscn")
var existHost = false

func _ready() -> void:
	
	Game.connect("player_disconnected", self, "_end_game_id")
	Game.connect("server_disconnected", self, "_end_game")
	
	for nid in Game.players.keys():
		var player_info = Game.players[nid]
		#print(player_info["slot"])
		if player_info["player_type"] == Game.SLIME:
			var player = create_slime(nid)
		else:
			var player = create_prisoner(nid)
		


func _end_game_id(id):
	_end_game()
	
func _end_game():
	Game.call_deferred("end_game")
	get_tree().change_scene("res://scenes/Lobby.tscn")

func create_prisoner(nid):
	var prisoner = Prisoner.instance()
	prisoner.init(nid)
	$Players.add_child(prisoner)
	prisoner.global_position = $Positions.get_child(1).global_position
	return prisoner
	
func create_slime(nid):
	var slime = Slime.instance()
	slime.init(nid)
	$Players.add_child(slime)
	slime.global_position = $Positions.get_child(0).global_position
	return slime

#Particulas 



export(PackedScene) var blood : PackedScene

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("mb_left")):
		for i in range(45):
			var blood_instance : Area2D = blood.instance()
#			blood_instance.global_position = slime_node.position
			blood_instance.global_position = get_global_mouse_position()
			add_child(blood_instance)
