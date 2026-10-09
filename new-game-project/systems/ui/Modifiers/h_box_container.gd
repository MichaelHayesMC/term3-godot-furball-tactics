extends HBoxContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(GameManager.players) >= 4:
		$PlayerPfp.show()
		$PlayerPfp2.show()
		$PlayerPfp3.show()
		$PlayerPfp4.show()
	elif len(GameManager.players) >= 3:
		$PlayerPfp4.hide()
	elif len(GameManager.players) >= 2:
		$PlayerPfp3.hide()
		$PlayerPfp4.hide()
	
