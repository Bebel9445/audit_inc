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
	if (nomPole == "RH") :
		pass
	elif (nomPole == "Economie") :
		pass
	elif (nomPole == "Fournitures") :
		pass
	else :
		pass
	
	var carte_instance = carte_scene.instantiate()
	add_child(carte_instance)
	#carte_instance.set_card(TextureRect e, "ldn,dkkd")
	choixPoles_instance.hide()
