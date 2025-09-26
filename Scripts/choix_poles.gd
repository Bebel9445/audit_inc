extends Panel
signal poleRH
signal poleEconomie
signal poleFournitures
signal poleBienEtre

func _on_pole_economie_pressed():
	poleEconomie.emit()

func _on_pole_rh_pressed():
	poleRH.emit()

func _on_pole_fournitures_pressed():
	poleFournitures.emit()

func _on_pole_bien_etre_pressed():
	poleBienEtre.emit()
