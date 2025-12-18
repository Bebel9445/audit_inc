extends Node2D
class_name Enemy

# --- SIGNAUX ---

## Signal émis lorsque les PV de l'ennemi tombent à 0.
signal enemy_dead

# --- RÉFÉRENCES ---

## Le Sprite visuel de l'ennemi (changé dynamiquement selon le type de service).
@onready var sprite_visuel = $Sprite2D 

## La barre de progression visuelle.
@onready var health_bar = $HealthBar

## Le Label texte affiché par-dessus la barre (ex: "150 / 200").
@onready var hp_label = $HealthBar/HPLabel 

# --- VARIABLES ---

## Stocke la valeur maximale de PV pour l'affichage (car health_bar.max_value est un float).
var max_pv_cache: int = 0

func _ready():
	pass

# --- INITIALISATION ---

## Configure l'ennemi au début du combat.
## Définit les PV max, les PV actuels et met à jour l'affichage.
func setHealthBar(pv: int):
	max_pv_cache = pv # On retient le max pour l'affichage texte
	
	health_bar.max_value = pv
	health_bar.min_value = 0
	health_bar.value = pv
	
	update_text_display()

## Change l'image de l'ennemi dynamiquement.
## Charge la texture depuis le chemin fourni par le JSON.
func change_visual(image_path: String):
	print("Enemy reçoit la demande pour : ", image_path)
	
	# Sécurité critique : On vérifie que le noeud existe
	if sprite_visuel == null:
		push_error("ERREUR CRITIQUE : Noeud '$Sprite2D' introuvable dans Enemy !")
		return 

	# Chargement sécurisé de la ressource
	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		if texture:
			sprite_visuel.texture = texture
			print("Succès ! Texture appliquée.") 
		else:
			push_error("Erreur : Fichier texture invalide.")
	else:
		# Fallback ou erreur si l'image n'existe pas dans les fichiers du jeu
		push_error("ERREUR FATALE : Image introuvable -> " + image_path)

# --- LOGIQUE DE COMBAT ---

## Applique des dégâts à l'ennemi.
## Gère la réduction de PV, le feedback visuel (clignotement) et la mort.
func take_damage(damage: int):
	print("Dégâts reçus : ", damage)
	
	# 1. Application des dégâts
	health_bar.value -= damage
	
	# 2. Mise à jour du texte (ex: 80 / 100)
	update_text_display()
	
	# 3. Feedback Visuel (Tween)
	# Fait clignoter le sprite en rouge pendant 0.1s
	if sprite_visuel:
		var tween = create_tween()
		tween.tween_property(sprite_visuel, "modulate", Color(1, 0, 0), 0.1) # Rouge
		tween.tween_property(sprite_visuel, "modulate", Color(1, 1, 1), 0.1) # Retour normal
	
	# 4. Vérification de la mort
	if health_bar.value <= 0:
		health_bar.value = 0 
		emit_signal("enemy_dead")

## Met à jour le label de texte sur la barre de vie.
func update_text_display():
	if hp_label:
		var current = int(health_bar.value)
		# Formatage : "Actuel / Max"
		hp_label.text = str(current) + " / " + str(max_pv_cache)
