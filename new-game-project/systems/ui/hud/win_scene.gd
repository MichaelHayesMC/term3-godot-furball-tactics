extends Control

@onready var win_lb: Label = %WinLb

var winner = "[PLAYER]"

func _ready() -> void:
	win_lb.text = (winner + " IS THE WINNER")

func _on_leave_button_pressed() -> void:
	Network.leave_server()
	$".".hide()
