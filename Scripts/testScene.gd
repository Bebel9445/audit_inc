extends Area2D


func _ready():
	var img = load("res://icon.svg")
	#var carte = ObjetCarteCombat.new("test", 0, "Le test a fonctionné gros ;)", 0, img)
	#add_child(carte)
	#
	#var info = CarteDeCombat.new(carte, 3, 10, 10)
	#print(info.getNiveau())
	
	var carteCompetence = ObjetCarteCompetence.new("test", 0, img, 100, 20)
	add_child(carteCompetence)
	var info1 = CarteDeCompetence.new(carteCompetence, 0, "test")
	print(info1.getNiveau())
	var autreCarteCompetence = ObjetCarteCompetence.new("test", 0, img, 800, 20)
	add_child(autreCarteCompetence)
	var CarteCompetenceNiv2 = ObjetCarteCompetence.new("test2", 2, img, 400, 400)
	add_child(CarteCompetenceNiv2)
	var CarteCompetenceNiv1 = ObjetCarteCompetence.new("test", 1, img, 10, 400)
	add_child(CarteCompetenceNiv1)
	var CarteCompetenceNiv3 = ObjetCarteCompetence.new("test", 3, img, 700, 400)
	add_child(CarteCompetenceNiv3)
	
	var slot = Slot.new(400,20)
	add_child(slot)
