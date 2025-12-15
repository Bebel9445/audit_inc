extends Node2D
class_name Enemy # C'est pratique de lui donner un nom de classe

signal enemy_dead

# On suppose que ton Sprite2D s'appelle "Sprite2D" dans l'arbre de scène de l'Enemy
@onready var sprite_visuel = $Sprite2D 
@onready var health_bar = $HealthBar

func _ready():
	pass

func setHealthBar(pv: int):
	health_bar.max_value = pv
	health_bar.min_value = 0
	health_bar.value = pv

# --- NOUVELLE FONCTION ---
# Dans Enemy.gd

func change_visual(image_path: String):
	print("Enemy reçoit la demande pour : ", image_path)
	
	# 1. VÉRIFICATION CRITIQUE : Est-ce que j'ai bien mon noeud Sprite2D ?
	if sprite_visuel == null:
		push_error("ERREUR CRITIQUE DANS ENEMY : Je ne trouve pas mon enfant '$Sprite2D' ! Vérifie le nom dans la scène.")
		return # On arrête tout pour ne pas faire planter le jeu

	# 2. Le reste du code normal...
	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		if texture:
			sprite_visuel.texture = texture
			print("Succès ! Texture appliquée sur le sprite.") 
		else:
			push_error("Erreur : Le fichier existe mais n'est pas une texture valide.")
	else:
		push_error("ERREUR FATALE : Image introuvable à ce chemin -> " + image_path)

func take_damage(damage: int):
	print("Dégâts reçus : ", damage)
	health_bar.value -= damage
	
	if health_bar.value <= 0:
		health_bar.value = 0 
		enemy_dead.emit()
