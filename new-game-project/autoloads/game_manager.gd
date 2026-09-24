extends Node

var game_start = true

var players_moving = true

var players : Array

var players_ready = 0

var player_chosen = false


#var username = ''
## peer id : { score : 0, username : str }
#var session_info: Dictionary = { }
#signal signal_session_info(new_info)
#
#func _ready() -> void:
	#Network.tube_client.session_created.connect(set_up_scoreboard)
	#
#func set_up_scoreboard():
	#multiplayer.peer_connected.connect(add_session)
	#multiplayer.peer_disconnected.connect(erase_session)
	#signal_session_info.emit(session_info)
	#
#func add_session(peer_id: int):
	#await get_tree().create_timer(1).timeout
	#var new_player = get_player(peer_id)
	#print(new_player)
	#replicate_session_info.rpc(new_player)
	#
#func erase_session(peer_id: int):
	#pass
	#
#@rpc("authority", "call_local")
#func replicate_session_info(new_info):
	#signal_session_info.emit(new_info)
#
#func get_player(peer_id: int) -> Player:
	#var player_to_find: Player
	#for current_player in get_tree().get_nodes_in_group("Players"):
		#if current_player.name == str(peer_id):
			#player_to_find = current_player
			#break
#
	#return player_to_find
