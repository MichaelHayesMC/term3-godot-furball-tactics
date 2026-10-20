extends Node
class_name World

@onready var world = get_tree().current_scene

@onready var title_screen: CanvasLayer = $TitleScreen
@onready var HUD = preload("uid://eo30kruldshw")
@export var levels : Array[PackedScene]

@export var modifiers_hud : PackedScene

signal player_elim

func _ready() -> void:
	set_process(false)
	
	GameManager.can_shoot = false
	GameManager.players = []
	GameManager.players_moving = true
	GameManager.players_ready = 0
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	Network.host_creation.connect(host_creation)
	
	$TitleScreen.show()
	$LobbyUI.hide()
	$Cursors.show()

func _process(delta: float) -> void:
	if len(GameManager.players) > 1 and GameManager.players_remaining <= 1:
		player_elim.emit()

func host_creation():
	$LobbyUI.show()

# Calls function to change scene with all player clients changing with it
func _on_start_pressed() -> void:
	set_process(true)
	
	if !multiplayer.is_server(): return
	
	if len(GameManager.players) >= 2: 
		HUD_display.rpc()
		level_pick()
		
	GameManager.players_remaining = len(GameManager.players)

func level_pick():
	GameManager.players_remaining = len(GameManager.players)
	if !multiplayer.is_server():
		return

	if levels.is_empty():
		push_error("No levels have been assigned!")
		return

	var chosen_level: PackedScene = levels.pick_random()

	if chosen_level == null:
		push_error("A level in the levels array is null!")
		return

	Level_change(chosen_level)

func Level_change(chosen_level):
	if not multiplayer.is_server():
		return

	level_sync.rpc(chosen_level.resource_path)

@rpc("authority", "call_local", "reliable")
func level_sync(level_path):
	GameManager.can_shoot = true

	for child in $Platform.get_children():
		child.queue_free()

	var current_level = load(level_path).instantiate()
	$Platform.add_child(current_level)

@rpc("call_local", "reliable")
func HUD_display():
	if $LobbyUI:
		$LobbyUI.hide()
	var new_HUD = HUD.instantiate()
	add_child(new_HUD)
