extends Panel
signal poleRH(nomPole)
signal poleEconomie
signal poleFournitures
signal poleBienEtre

func _on_pole_economie_pressed():
	$PopUpEconomie.show()

func _on_pole_rh_pressed():
	$PopUpRH.show()

func _on_pole_fournitures_pressed():
	$PopUpFournitures.show()

func _on_pole_bien_etre_pressed():
	$PopUpBienEtre.show()


func _on_pop_up_economie_confirmed():
	poleEconomie.emit("Economie")


func _on_pop_up_rh_confirmed():
	poleRH.emit("RH")


func _on_pop_up_fournitures_confirmed():
	poleFournitures.emit("Fourniture")


func _on_pop_up_bien_etre_confirmed():
	poleBienEtre.emit("BienEtre")
