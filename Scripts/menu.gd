extends Panel
signal start_game

func _on_facile_pressed():
	start_game.emit()


func _on_moyen_pressed():
	start_game.emit()


func _on_difficile_pressed():
	start_game.emit()
