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

func lancer_audit(nomPole: String):
	var json_path = "res://Cartes/test.json"
	
	if not FileAccess.file_exists(json_path):
		push_error("Fichier JSON introuvable pour le pôle : " + nomPole)
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var data: Dictionary = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Erreur : JSON invalide pour le pôle " + nomPole)
		return
	
	var jeuActif = true
	var indexCarte = 0
	var banned_cards: Array = []
	var prochaine_carte_forcee: int = -1  # permet d'enchaîner des cartes non tirables

	while jeuActif:
		print("➡️ Index de la carte :", indexCarte)

		# fin de jeu
		if indexCarte > int(data["nbCartes"]):
			print("Toutes les cartes du pôle", nomPole, "ont été jouées.")
			break

		var carteData: Dictionary = data[str(indexCarte)]
		if carteData == null:
			print("Carte", indexCarte, "inexistante, fin du jeu.")
			break

		var carte_tirable: bool = carteData.get("tirable", false)
		var carte_id_str = str(indexCarte)

		# 🔸 Vérifie si la carte est bannie
		if carte_id_str in banned_cards:
			print("🚫 Carte", indexCarte, "bannie → on passe.")
			indexCarte += 1
			continue

		# 🔸 Vérifie si la carte peut être tirée
		# Elle doit être tirable OU appelée par une carte précédente
		if not carte_tirable and prochaine_carte_forcee != indexCarte:
			print("⏩ Carte", indexCarte, "non tirable et non appelée → on passe.")
			indexCarte += 1
			continue

		# ----- Affichage et interaction -----
		var carte_instance = carte_scene.instantiate()
		add_child(carte_instance)
		choixPoles_instance.hide()

		var img: Texture2D = null
		if carteData.has("image"):
			img = load(carteData["image"]) as Texture2D

		var perso = carteData.get("nomPerso", "")
		var question = carteData.get("question", "")
		var response = carteData.get("response", "")

		var choixGauche = carteData["choix"]["gauche"]
		var choixDroite = carteData["choix"]["droite"]

		carte_instance.set_card(
			img,
			"%s\n%s\n%s" % [perso, question, response],
			choixGauche["texte"],
			choixDroite["texte"]
		)

		var choix = await carte_instance.choixFait
		print("🃏 Choix joueur :", choix)

		var choixData = carteData["choix"][choix]
		var stats: Array = choixData["stats"]
		var prochaineCarte = choixData["prochaineCarte"]

		carte_instance.queue_free()

		# 🔸 Marquer les cartes bannies
		for banned in carteData.get("carteBan", []):
			if banned not in banned_cards:
				banned_cards.append(banned)

		# 🔸 Gestion de la prochaine carte
		if prochaineCarte != null:
			indexCarte = int(prochaineCarte)
			prochaine_carte_forcee = indexCarte  # permet de forcer la prochaine carte
		else:
			indexCarte += 1
			prochaine_carte_forcee = -1  # reset : prochaine carte non forcée

		# 🔸 Condition de fin de jeu
		if indexCarte > int(data["nbCartes"]):
			jeuActif = false




func choix(nomChoix):
	if (nomChoix == "gauche"):
		print("gauche")
	else:
		print("droite")
