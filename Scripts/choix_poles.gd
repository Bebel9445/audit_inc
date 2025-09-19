extends Panel
signal poleEconomie

func _on_pole_economie_pressed():
	emit_signal("poleEconomie")
