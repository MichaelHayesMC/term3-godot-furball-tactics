extends Node

@export var levels : Array[PackedScene]

const HUD = preload("uid://eo30kruldshw")

#signal player_colour
const PLAYER = preload("uid://ddc8k6gybq8ur")
const MOUSE = preload("uid://cluva5choy51f")

var enet_peer = ENetMultiplayerPeer.new()
var tube_client := TubeClient.new()
var tube_enabled = true

const TUBE_CONTEXT = preload("uid://bjcuq8aag84wf")
var IP_ADDRESS = "localhost"

var players: Dictionary = {}
signal player_list_updated(player_list)

signal host_creation

func _ready() -> void:
	if tube_enabled:
		tube_client.context = TUBE_CONTEXT
		get_tree().root.add_child.call_deferred(tube_client)

func tube_create():
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	tube_client.create_session()
	add_player(1)
	host_creation.emit()

func tube_join(session_id: String):
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	tube_client.join_session(session_id)

func on_connected_to_server():
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	if peer_id == 1 and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return

	players[peer_id] = true

	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	get_tree().current_scene.add_child(player, true)
	
	var mouse = MOUSE.instantiate()
	mouse.name = str(peer_id)
	get_tree().current_scene.get_node("Cursors/Mouse").add_child(mouse)
	
	sync_player_list.rpc(players)

func remove_player(peer_id):
	#if peer_id == 1:
		#leave_server()
		#return
	
	leave_server()

@rpc("authority", "call_local", "reliable")
func sync_player_list(new_player_list: Dictionary):
	players = new_player_list.duplicate(true)
	
	player_list_updated.emit(players)

func _exit_tree() -> void:
	if tube_enabled:
		tube_client.leave_session()

func clean_up_signals():
	multiplayer.peer_connected.disconnect(add_player) 
	multiplayer.peer_disconnected.disconnect(remove_player)
	multiplayer.connected_to_server.disconnect(on_connected_to_server)

func leave_server() -> void:
	print("Terminating lobby...")

	# Notify all remaining clients before closing connections.
	if multiplayer.is_server():
		shutdown_lobby.rpc()

	_close_local_session()

@rpc("authority", "call_local", "reliable")
func shutdown_lobby() -> void:
	_close_local_session()

func _close_local_session() -> void:
	if tube_enabled:
		tube_client.leave_session()

	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	players.clear()
	player_list_updated.emit(players)

	get_tree().reload_current_scene()
