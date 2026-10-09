extends Control

@onready var player_1: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player1UI/Score
@onready var player_2: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player2UI/Score
@onready var player_3: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player3UI/Score
@onready var player_4: Label = $ScoreboardBackground/MarginContainer/VBoxContainer/Player4UI/Score


@onready var player_1ui: HBoxContainer = %Player1UI
@onready var player_2ui: HBoxContainer = %Player2UI
@onready var player_3ui: HBoxContainer = %Player3UI
@onready var player_4ui: HBoxContainer = %Player4UI

var score_labels: Array[Label]


func _ready() -> void:
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
	var player_index := GameManager.players.find(player.name)

	if player_index == -1:
		return

	if player_index >= score_labels.size():
		return
	
	label_update.rpc(player_index, new_score)

@rpc("call_local")
func label_update(player_index, new_score):
	score_labels[player_index].text = str(new_score)
