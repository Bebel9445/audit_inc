extends Node
@export var choixPoles_scene : PackedScene
@export var carte_scene : PackedScene

var choixPoles_instance

func _ready():
	pass
	

func new_game():
	$Menu.queue_free()
	
	choixPoles_instance = choixPoles_scene.instantiate()
	add_child(choixPoles_instance)	
	choixPoles_instance.poleRH.connect(Callable(self, "lancer_audit").bind("RH")) #Mettre "RH" en paramètre ( = lancer_audit("RH"))
	choixPoles_instance.poleEconomie.connect(Callable(self, "lancer_audit").bind("Economie"))
	choixPoles_instance.poleFournitures.connect(Callable(self, "lancer_audit").bind("Fournitures"))
	choixPoles_instance.poleBienEtre.connect(Callable(self, "lancer_audit").bind("BienEtre"))
	
	#Initialiser les states en fonction de la difficulté choisi	

func lancer_audit(nomPole):
	var carte_instance = carte_scene.instantiate()
	add_child(carte_instance)
	choixPoles_instance.hide()
	
	if (nomPole == "RH") :
		var img = load("res://icon.svg")
		carte_instance.set_card(img, "Voici le pole RH !")
	elif (nomPole == "Economie") :
		pass
	elif (nomPole == "Fournitures") :
		pass
	else :
		pass
