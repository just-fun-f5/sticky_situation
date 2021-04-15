extends Node2D

var PORT = 1800
var MAX_CLIENTS = 2


var _player_status = {}		# {id: ready}
var _player_label = {}		# {id: label_id }
var _player_types = {Game.SLIME: "Slime", Game.PRISONER: "Prisoner"}

onready var name_label = $CanvasLayer/Panel/Connect/HBoxContainer/Name
onready var players_container = $CanvasLayer/Panel/Waiting/PanelContainer/Players

func _ready():
	Game.connect("player_connected", self, "_player_connected")
	Game.connect("player_disconnected", self, "_player_disconnected")
	Game.connect("connected_ok", self, "_connected_ok")
	Game.connect("connected_fail", self, "_connected_fail")
	Game.connect("server_disconnected", self, "_server_disconnected")
	
	Game.connect("port_opened", self, "_port_opened")
	
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		name_label.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		name_label.text = desktop_path[desktop_path.size() - 2]
	
	$CanvasLayer/Panel/Connect/HBoxContainer/Host.connect("pressed", self, "_host_pressed")
	$CanvasLayer/Panel/Connect/HBoxContainer2/Join.connect("pressed", self, "_join_pressed")


# ---------- CONNECTION_HANDLING ----------  #
func _player_connected(id):
	var nid = get_tree().get_network_unique_id()
	rpc_id(id, "send_info", Game.players[nid])

func _player_disconnected(id):
	_remove_player(id)

func _connected_ok():
	pass

func _connected_fail():
	pass

func _server_disconnected():
	get_tree().network_peer = null
	_show_connect()


# ---------- BUTTONS  ----------  #
func _host_pressed():
	#	When the host button is pressed, the server is creater
	#	lthe the port is open, a player is created
	#	and the view changes to waiting Container
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	
	Game.open_port(PORT)
	
	print("Server Created: %s:%s" % [$CanvasLayer/Panel/Connect/HBoxContainer2/IP.text, PORT])
	
	_add_slime_player()
	_show_waiting()

func _join_pressed():
	#	When the join button is pressed, user joins
	#	to an exinting server, a player is created
	#	and the view changes to waiting Container
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client($CanvasLayer/Panel/Connect/HBoxContainer2/IP.text, PORT)
	get_tree().network_peer = peer
	
	print("Client Connected: %s:%s" % [$CanvasLayer/Panel/Connect/HBoxContainer2/IP.text, PORT])
	
	_add_prisoner_player()
	_show_waiting()

func _on_Ready_toggled(button_pressed):
	_update_player_status(button_pressed)
	
	if button_pressed == false:
		var nid = get_tree().get_network_unique_id()
		if(_player_status[nid]):
			_update_player_status(false)
		else:
			if get_tree().get_network_unique_id() == 1:
				print("Server Closed")
			else:
				print("Client Disconected")
			get_tree().network_peer = null
			
			_show_connect()

# ---------- SYNC_PLAYER_INFO  ----------  #
# arriving info
remote func send_info(info):
	# New info has arrived
	var nid = get_tree().get_rpc_sender_id()
	
	_add_player_info(nid, info)
	_add_player_ui(nid)

remote func _set_slot(slot):
	var nid = get_tree().get_network_unique_id()
	Game.players[nid]["slot"] = slot

sync func _player_is_ready(is_ready):
	var nid = get_tree().get_rpc_sender_id()
	_player_status[nid] = is_ready
	_player_is_ready_ui(nid, is_ready)
	_check_players_ready()

sync func _set_player_type(type):
	var nid = get_tree().get_rpc_sender_id()
	_update_player_ui(nid, type)
	
	
# ---------- PLAYER_SET_UP  ----------  #
func _update_player_status(is_ready):
	var nid = get_tree().get_network_unique_id()
	rpc("_player_is_ready", is_ready)

func _update_player_type (id, type):
	# Gets a type an actualices player info
	var nid = get_tree().get_network_unique_id()
	Game.players[id]["player_type"] = type
	if nid == 1 and id != 1:
		rpc_id(id, "_set_player_type", type)
	
func _check_players_ready():
	var all_ready = true
	for is_ready in _player_status.values():
		if not is_ready:
			all_ready = false
			break
	if all_ready:
		get_tree().change_scene("res://src/Main/Main.tscn")

func _add_slime_player():
	var nid = get_tree().get_network_unique_id()
	var info = {"name": $CanvasLayer/Panel/Connect/HBoxContainer/Name.text, "player_type" : Game.SLIME}
	_add_player_info(nid, info)
	_add_player_ui(nid)

func _add_prisoner_player():
	var nid = get_tree().get_network_unique_id()
	var info = {"name": $CanvasLayer/Panel/Connect/HBoxContainer/Name.text, "player_type" : Game.PRISONER }
	_add_player_info(nid, info)
	_add_player_ui(nid)

func _add_player_info(id, info):
	var nid = get_tree().get_network_unique_id()
	Game.players[id] = info
	_player_status[id] = false
	
	var slot = 0 if id == 1 else Game.players.size() - 1
	if (id != nid or nid == 1) and not Game.players[id].has("slot"):
			Game.players[id]["slot"] = slot
	
	if nid == 1 and id != 1:
		rpc_id(id, "_set_slot", slot)

func _remove_player(id):
	var slot = Game.players[id]["slot"]
	Game.players.erase(id)
	for pid in Game.players.keys():
		if Game.players[pid]["slot"] > slot:
			Game.players[pid]["slot"] -= 1
	_player_status.erase(id)
	_remove_player_ui(id)
	
# ---------- UI_UPDATES  ----------  #
func _add_player_ui(id):
	var info = Game.players[id]
	var label = Label.new()
	label.text = info["name"] + " is a " + _player_types[info["player_type"]]
	label.name = str(id)
	players_container.add_child(label)
	# Can get Data races?
	var label_id = players_container.get_child_count() - 1
	_player_label[id] = label_id

func _update_player_ui(id, new_type):
	var label = (players_container.get_child(_player_label[id]) as Label)
	label.text = new_type

func _remove_player_ui(id):
	var sid = str(id)
	for child in players_container.get_children():
		if child.name == sid:
			players_container.remove_child(child)
			break

func _player_is_ready_ui(nid, is_ready):
	var snid = str(nid)
	for child in players_container.get_children():
		if child.name == snid:
			child.modulate = Color.green if is_ready else Color.white
			break

func _show_waiting():
	$CanvasLayer/Panel/Connect.hide()
	$CanvasLayer/Panel/Waiting.show()

func _show_connect():
	$CanvasLayer/Panel/Waiting.hide()
	$CanvasLayer/Panel/Connect.show()
	_clear_ui()
	_player_status = {}
	Game.end_game()

func _clear_ui():
	for child in players_container.get_children():
		players_container.remove_child(child)

# ---------- DEBUGGING  ----------  #
func _port_opened(result):
	print("_port_opened %s" % result)
	if not result:
		_show_connect()
		$CanvasLayer/Panel/Connect/Error.text = "Port %d couldn't be opened!" % PORT

