extends Area2D


func _ready():
	var img = load("res://icon.svg")
	var carte = ObjetCarteCombat.new("test", 3, "Le test a fonctionné gros ;)", 999,img)
	add_child(carte)
	
	var info = CarteDeCombat.new(carte, 3, 2, 9)
	print(info.getNiveau())
	print(info.getDegat())
	print(info.getCout())
