extends Panel
signal start_game(difficulty)

func _on_facile_pressed():
	start_game.emit(1)


func _on_moyen_pressed():
	start_game.emit(2)


func _on_difficile_pressed():
	start_game.emit(4)
