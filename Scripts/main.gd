extends Node
@export var choixPoles_scene : PackedScene
@export var carte_scene : PackedScene

var choixPoles_instance
var current_difficulte : int

func _ready():
	pass
	

func new_game(difficulte : int):
	print(difficulte)
	current_difficulte = difficulte
	$Menu.queue_free()
	choixPoles_instance = choixPoles_scene.instantiate()
	add_child(choixPoles_instance)	
	choixPoles_instance.poleEconomie.connect(lancer_audit)
	
	#Initialiser les states en fonction de la difficulté choisi	

func lancer_audit():
	var carte_instance = carte_scene.instantiate()
	add_child(carte_instance)
	choixPoles_instance.hide()
