extends Node

enum {PLACE_HOLDER, SLIME, PRISONER}

# {nid: info}
var players = {}

signal player_connected(id)
signal player_disconnected(id)
signal connected_ok()
signal connected_fail()
signal server_disconnected()

var upnp = UPNP.new()
var thread = Thread.new()

signal port_opened(result)

func open_port(port):
	thread.start(self, "_thread_open_port", port)
#	emit_signal("port_opened", true)

func _thread_open_port(port):
	var res = upnp.discover()
	if res != UPNP.UPNP_RESULT_SUCCESS:
		emit_signal("port_opened", false)
		return
	var gateway = upnp.get_gateway()
	res = gateway.add_port_mapping(port, 0, "MultiplayerTest", "UDP")
#	print(res)
	if res != UPNP.UPNP_RESULT_SUCCESS:
		emit_signal("port_opened", false)
		return
	gateway.add_port_mapping(port, 0, "MultiplayerTest", "TCP")
#	print(res)
	if res != UPNP.UPNP_RESULT_SUCCESS:
		emit_signal("port_opened", false)
		return
	emit_signal("port_opened", true)
	thread.call_deferred("wait_to_finish")

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	print("_player_connected %d" % id)
	# Called on both clients and server when a peer connects. Send my info to it.
	emit_signal("player_connected", id)

func _player_disconnected(id):
	print("_player_disconnected %d" % id)
#	player_info.erase(id) # Erase player from info.
	emit_signal("player_disconnected", id)

func _connected_ok():
	print("_connected_ok")
	# Only called on clients, not server. Will go unused; not useful here.
	emit_signal("connected_ok")

func _connected_fail():
	print("_connected_fail")
	# Could not even connect to server; abort.
	emit_signal("connected_fail")

func _server_disconnected():
	print("_server_disconnected")
	# Server kicked us; show error and abort.
	emit_signal("server_disconnected")

func end_game():
	players = {}
	get_tree().network_peer = null

#func _process(delta: float) -> void:
#	print(Game.players)

func is_net_master(node):
	return !get_tree().network_peer or node.is_network_master()
