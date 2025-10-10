extends Panel
signal poleRH(nomPole)
signal poleEconomie
signal poleFournitures
signal poleBienEtre

func _on_pole_economie_pressed():
	poleEconomie.emit("Economie")

func _on_pole_rh_pressed():
	poleRH.emit("RH")

func _on_pole_fournitures_pressed():
	poleFournitures.emit("Fourniture")

func _on_pole_bien_etre_pressed():
	poleBienEtre.emit("BienEtre")
