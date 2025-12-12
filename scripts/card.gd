extends Area2D


func _ready():
	var img = load("res://icon.svg")
	var carte = FightCardsObject.new("test", 0, "Le test a fonctionné gros ;)", 0, img)
	add_child(carte)
	
	#var carte = ObjetCarteCombat.new("test", 0, "Le test a fonctionné gros ;)", 0, img)
	#add_child(carte)
	#
	#var info = CarteDeCombat.new(carte, 3, 10, 10)
	#print(info.getNiveau())
	
