extends Node2D

var Prisoner = preload("res://src/Actors/Prisoner/Prisoner.tscn")
var Slime = preload("res://src/Actors/Slime/Slime 2.tscn")
var existHost = false

func _ready() -> void:
	
	Game.connect("player_disconnected", self, "_end_game_id")
	Game.connect("server_disconnected", self, "_end_game")
	
	if Game.players.keys().size() >= 1:
		var nid = Game.players.keys()[0]
		create_slime(nid)
		if Game.players.keys().size() >= 2:
			nid = Game.players.keys()[1]	
			create_prisoner(nid)


func _end_game_id(id):
	_end_game()
	
func _end_game():
	Game.call_deferred("end_game")
	get_tree().change_scene("res://scenes/Lobby.tscn")

func create_prisoner(nid):
	var prisoner = Prisoner.instance()
	prisoner.init(nid)
	prisoner.global_position = $Positions.get_child(1).global_position
	$Players.add_child(prisoner)
	return prisoner
	
func create_slime(nid):
	var slime = Slime.instance()
	slime.init(nid)
	slime.global_position = $Positions.get_child(0).global_position
	$Players.add_child(slime)
	return slime
	
