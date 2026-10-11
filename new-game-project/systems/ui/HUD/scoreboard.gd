extends Control

@onready var player_1: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player1UI/Score
@onready var player_2: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player2UI/Score
@onready var player_3: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player3UI/Score
@onready var player_4: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player4UI/Score

@onready var player_1ui: HBoxContainer = %Player1UI
@onready var player_2ui: HBoxContainer = %Player2UI
@onready var player_3ui: HBoxContainer = %Player3UI
@onready var player_4ui: HBoxContainer = %Player4UI

@export var win_scene : PackedScene

const WIN_SCENE = preload("uid://c3metd33t7f1m")

var score_labels: Array[Label]

var score_requirement := 2

func _ready() -> void:
	print("SCOREBOARD READY on peer: ", multiplayer.get_unique_id())
	
	score_labels = [
		player_1,
		player_2,
		player_3,
		player_4
	]
	
	if len(GameManager.players) >= 4:
		player_1ui.show()
		player_2ui.show()
		player_3ui.show()
		player_4ui.show()
	elif len(GameManager.players) >= 3:
		player_4ui.hide()
	elif len(GameManager.players) >= 2:
		player_3ui.hide()
		player_4ui.hide()
		
	# Wait one frame so networked players have time to spawn.
	await get_tree().process_frame

	connect_to_players()
	update_all_scores()

func connect_to_players() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if player is Player:
			if !player.score_changed.is_connected(_on_player_score_changed):
				player.score_changed.connect(_on_player_score_changed.bind(player))

func update_all_scores() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if player is Player:
			_on_player_score_changed(player.score, player)

func _on_player_score_changed(new_score: int, player: Player) -> void:
	print("PLAYER NAME: ", player.name)
	print("PLAYERS ARRAY: ", GameManager.players)
	print("PLAYER SEARCH: ", player.name.to_int())

	var player_index := GameManager.players.find(player.name.to_int())

	if player_index == -1:
		return
	
	if player_index >= score_labels.size():
		return

	score_labels[player_index].text = str(new_score)
	
	print(player, new_score, "HI")
	
	if new_score == score_requirement:
		$"../TimerHUD".playerhaswon = true
		print(player, " Winner")
		var WIN_LOAD = WIN_SCENE.instantiate()
		WIN_LOAD.winner = player
		get_tree().current_scene.add_child(WIN_LOAD)
