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
	choixPoles_instance.poleRH.connect(lancer_audit) #Mettre "RH" en paramètre ( = lancer_audit("RH"))
	choixPoles_instance.poleEconomie.connect(lancer_audit)
	choixPoles_instance.poleFournitures.connect(lancer_audit)
	choixPoles_instance.poleBienEtre.connect(lancer_audit)
	
	#Initialiser les states en fonction de la difficulté choisi	

func lancer_audit(nomPole: String) -> void:
	var json_path := "res://Scripts/"+ nomPole +".json"
	
	if not FileAccess.file_exists(json_path):
		push_error("Fichier JSON introuvable pour le pôle : " + nomPole)
		return
	
	var file := FileAccess.open(json_path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	
	var data: Dictionary = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Erreur : JSON invalide pour le pôle " + nomPole)
		return
	
	# Créer la carte
	var carte_instance := carte_scene.instantiate()
	add_child(carte_instance)
	choixPoles_instance.hide()
	
	var jeuActif := true
	var indexCarte := 1
	
	while jeuActif:
		if indexCarte > int(data["nbCartes"]):
			print("Toutes les cartes du pôle " + nomPole + " ont été jouées.")
			break
		
		var carteData: Dictionary = data[str(indexCarte)]
		
		var img: Texture2D = null
		if carteData.has("image"):
			img = load(carteData["image"]) as Texture2D
		
		# On prépare les données de la carte
		var perso = carteData.get("nomPerso", "")
		var question = carteData.get("question", "")
		var response = carteData.get("response", "")
		
		var choixGauche = carteData["choix"]["gauche"]
		var choixDroite = carteData["choix"]["droite"]
		
		# Afficher la carte (fonction de ta scène)
		carte_instance.set_card(
			img,
			"%s\n%s\n%s" % [perso, question, response], 
			choixGauche["texte"],
			choixDroite["texte"]
		)
		
		#attente du choix ici jpense
		
		# Pour l’instant on enchaîne bêtement
		indexCarte += 1
		
		if indexCarte > int(data["nbCartes"]):
			jeuActif = false
