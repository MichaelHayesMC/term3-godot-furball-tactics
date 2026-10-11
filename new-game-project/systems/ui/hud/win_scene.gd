extends Control

@onready var win_lb: Label = %WinLb

var winner = "[PLAYER]"

func _ready() -> void:
	win_lb.text = (str(winner.name) + " IS THE WINNER")

func _on_leave_button_pressed() -> void:
	Network.leave_server()
	$".".hide()
