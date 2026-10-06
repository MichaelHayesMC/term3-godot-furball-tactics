extends Node

@onready var world = get_tree().current_scene

@onready var HUD = preload("res://systems/ui/HUD/hud.tscn")
@export var levels : Array[PackedScene]

#signal player_colour
const PLAYER = preload("res://entities/characters/player.tscn")
const MOUSE = preload("res://systems/ui/mouse_cursor/mouse_decal.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var tube_client := TubeClient.new()
var tube_enabled = true

const PORT = 9999
const TUBE_CONTEXT = preload("uid://bjcuq8aag84wf")
var ip_test = "localhost"

var players: Dictionary = {}
signal player_list_updated(player_list)

signal host_creation

func _ready() -> void:
	if tube_enabled:
		tube_client.context = TUBE_CONTEXT
		get_tree().root.add_child.call_deferred(tube_client)

func tube_create():
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	tube_client.create_session()
	add_player(1)
	host_creation.emit()

func tube_join(session_id: String):
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	tube_client.join_session(session_id)

func on_connected_to_server():
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	if !multiplayer.is_server() and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return

	players[peer_id] = true

	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	get_tree().current_scene.add_child(player)
	
	var mouse = MOUSE.instantiate()
	mouse.name = str(peer_id)
	get_tree().current_scene.get_node("CanvasLayer/PlayerCursors").add_child(mouse)
	
	sync_player_list.rpc(players)

@rpc("authority", "call_local", "reliable")
func sync_player_list(new_player_list: Dictionary):
	players = new_player_list.duplicate(true)
	
	player_list_updated.emit(players)
	

func clean_up_signals():
	multiplayer.peer_connected.disconnect(add_player) 
	#multiplayer.peer_disconnected.disconnect(remove_player)
	multiplayer.connected_to_server.disconnect(on_connected_to_server)

func _exit_tree() -> void:
	if tube_enabled:
		tube_client.leave_session()
