extends Control
class_name MainHand

# --- SIGNAUX ---

## Signal émis quand la souris survole (ou quitte) une carte.
## Renvoie les DONNÉES logiques (FightCards) de la carte pour l'afficher dans l'inspecteur.
signal card_hovered(card_data) 

# --- CONFIGURATION VISUELLE ---

## Liste des objets visuels (FightCardsObject) actuellement en main.
var cartes: Array[FightCardsObject] = []

## Espace horizontal entre chaque carte (en pixels).
var spacing := 80        

## Hauteur de l'arc de cercle (plus c'est haut, plus la main est courbée).
var arc_height := 30     

## De combien de pixels la carte remonte quand on la survole.
var hover_raise := 60    

## Grossissement de la carte survolée (1.25 = +25%).
var hover_scale := 1.25  

## Ecartement des cartes voisines quand on en survole une (pour faire de la place).
var hover_spread := 30   

## Vitesse de l'animation (Lerp). Plus c'est bas (ex: 0.1), plus c'est "mou/fluide".
var animation_speed := 0.15

## Référence vers la carte actuellement sous la souris.
var hovered_card: FightCardsObject = null

# --- GESTION DE LA MAIN ---

## Vide complètement la main (visuellement et logiquement).
func clear_hand():
	cartes.clear()
	for child in get_children():
		remove_child(child)
		child.queue_free() # Important de libérer la mémoire

## Ajoute une carte visuelle à la main et connecte les événements souris.
func add_card(carte: FightCardsObject):
	cartes.append(carte)
	add_child(carte)

	# On connecte les signaux de la carte pour gérer le survol
	if not carte.is_connected("mouse_entered", Callable(self, "_on_card_mouse_enter")):
		carte.mouse_entered.connect(_on_card_mouse_enter.bind(carte))
	if not carte.is_connected("mouse_exited", Callable(self, "_on_card_mouse_exit")):
		carte.mouse_exited.connect(_on_card_mouse_exit.bind(carte))

	# On force une mise à jour immédiate (true) pour qu'elle apparaisse direct au bon endroit
	_update_positions(true)

## Retire une carte de la main (ex: quand elle est jouée).
func remove_card(carte: FightCardsObject):
	if cartes.has(carte):
		cartes.erase(carte)
	
	if carte.get_parent() == self:
		remove_child(carte)
		
	# On réorganise les cartes restantes
	_update_positions(true)

# --- GESTION DES ÉVÉNEMENTS SOURIS ---

func _on_card_mouse_enter(carte):
	hovered_card = carte
	_update_positions() # On lance l'animation de survol
	
	# On envoie les DONNÉES au Main/CombatManager pour l'inspecteur
	if carte.assigned_class:
		emit_signal("card_hovered", carte.assigned_class)

func _on_card_mouse_exit(carte):
	if hovered_card == carte:
		hovered_card = null
		# On signale que plus rien n'est survolé (null)
		emit_signal("card_hovered", null)
		
	_update_positions() # On remet les cartes en place

# --- CALCUL DES POSITIONS (L'Algorithme de l'Arc) ---

## Calcule la position, rotation et échelle de chaque carte.
## @param instantly: Si true, téléporte les cartes. Si false, anime le mouvement.
func _update_positions(instantly := false):
	if cartes.is_empty(): return
	
	var count := cartes.size()
	var center_x := size.x / 2
	
	# Largeur totale occupée par les cartes
	var total_width := (count - 1) * spacing
	var start_x := center_x - total_width / 2

	for i in range(count):
		var card := cartes[i]
		
		# Sécurité si la carte a été supprimée entre temps
		if not is_instance_valid(card): continue
		
		# 't' est une valeur centrée autour de 0.
		# Ex pour 5 cartes : -2, -1, 0, 1, 2
		var t := (i - (count - 1) / 2.0)
		
		# 1. Calcul Position X de base
		var target_x := start_x + i * spacing - card.size.x / 2
		
		# 2. Calcul Position Y (Courbe quadratique pour faire l'arc)
		# Formule : y = x^2 (parabole inversée)
		var target_y = -abs(t) * abs(t) * 2 + arc_height + 40 
		
		# 3. Calcul Rotation (en radians)
		# Plus on est sur les bords, plus on tourne
		var target_rot = deg_to_rad(t * 5)
		
		var target_scale := 1.0

		# --- GESTION DU SURVOL (HOVER) ---
		if card == hovered_card:
			# La carte survolée monte, grossit et devient droite
			target_y -= hover_raise
			target_scale = hover_scale
			target_rot = 0 # On remet droit pour lire
			# La carte passe au premier plan
			card.z_index = 10 
		
		elif hovered_card != null:
			# Les cartes voisines s'écartent pour laisser voir celle survolée
			card.z_index = i # Ordre normal
			var hover_index := cartes.find(hovered_card)
			var distance = abs(i - hover_index)
			
			# Si c'est un voisin direct (gauche ou droite)
			if distance == 1:
				if (i < hover_index): target_x -= hover_spread # Pousse à gauche
				else: target_x += hover_spread # Pousse à droite
		else:
			# Pas de survol, z-index standard
			card.z_index = i

		# --- APPLICATION DU MOUVEMENT ---
		if instantly:
			card.position = Vector2(target_x, target_y)
			card.rotation = target_rot
			card.scale = Vector2.ONE * target_scale
		else:
			# Interpolation linéaire (Lerp) pour une animation fluide
			card.position = card.position.lerp(Vector2(target_x, target_y), animation_speed)
			card.rotation = lerp_angle(card.rotation, target_rot, animation_speed)
			card.scale = card.scale.lerp(Vector2.ONE * target_scale, animation_speed)
