extends Panel

@onready var player_pfp: TextureRect = $MarginContainer/VBoxContainer/Player_Pfp
@onready var player_pfp_2: TextureRect = $MarginContainer/VBoxContainer/Player_Pfp2
@onready var player_pfp_3: TextureRect = $MarginContainer/VBoxContainer/Player_Pfp3
@onready var player_pfp_4: TextureRect = $MarginContainer/VBoxContainer/Player_Pfp4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if len(GameManager.players) >= 4:
		player_pfp.show()
		player_pfp_2.show()
		player_pfp_3.show()
		player_pfp_4.show()
	elif len(GameManager.players) >= 3:
		player_pfp_4.hide()
	elif len(GameManager.players) >= 2:
		player_pfp_3.hide()
		player_pfp_4.hide()
	
