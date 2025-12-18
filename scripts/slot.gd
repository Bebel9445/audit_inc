extends Panel
class_name Slot

# --- SIGNAUX ---
## Signal émis à chaque fois qu'une carte entre ou sort du slot.
signal slot_updated

# --- VARIABLES ---
## Référence vers la carte (Control) qui occupe ce slot. 
## Si null, le slot est considéré comme vide.
var carte_occupee = null 

func _init() -> void:
	# Taille standard d'un slot
	custom_minimum_size = Vector2(200, 330) 
	# On initialise sans bordure colorée (état neutre)
	remove_border()

# --- GESTION VISUELLE (Feedback Drag & Drop) ---

## Affiche une bordure JAUNE pour indiquer que le dépôt est possible ici.
func add_yellow_border():
	var sb = _create_border(Color(1,1,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

## Affiche une bordure ROUGE pour indiquer un dépôt interdit ou invalide.
func add_red_border():
	var sb = _create_border(Color(0.7,0,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

## Remet le style par défaut (Gris) quand l'action est terminée.
func remove_border():
	var sb = _create_border(Color(0.5, 0.5, 0.5), Color(0, 0, 0, 0.5)) 
	add_theme_stylebox_override("panel", sb)

## Fonction utilitaire pour générer proprement un StyleBoxFlat.
## Permet d'éviter la répétition de code pour la création des bordures.
func _create_border(border_col: Color, bg_col: Color) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.border_width_bottom = 2
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.corner_radius_top_left = 5
	sb.corner_radius_top_right = 5
	sb.corner_radius_bottom_left = 5
	sb.corner_radius_bottom_right = 5
	return sb

# --- SYSTEME AUTO-REPARATEUR ---

## Gère les notifications système de Godot.
## On l'utilise ici pour détecter la fin d'un Drag & Drop, qu'il ait réussi ou échoué.
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		# Nettoyage visuel : on enlève les bordures jaunes/rouges
		remove_border()
		
		# Synchronisation : On force la vérification de l'état du slot.
		# Cela permet de corriger les cas où une carte est lâchée dans le vide
		# et revient visuellement sans que la logique le sache.
		_synchroniser_etat()

## Vérifie la cohérence entre la réalité physique (enfants du noeud) 
## et la mémoire logique (variable carte_occupee).
func _synchroniser_etat():
	var carte_trouvee = null
	
	# 1. Scan physique : On cherche si une carte est enfant de ce slot
	for child in get_children():
		if child is MarginContainer: # On suppose que les cartes sont des MarginContainer
			carte_trouvee = child
			break
	
	# 2. Mise à jour Logique : On aligne la variable carte_occupee
	var a_change = false
	
	if carte_trouvee != null:
		# Une carte est physiquement présente
		if carte_occupee != carte_trouvee:
			# Si on ne le savait pas, on met à jour la référence
			carte_occupee = carte_trouvee
			a_change = true
			
			# Reconnexion de sécurité du signal de départ
			if not carte_trouvee.is_connected("quit_slot", self._on_carte_quit_slot):
				carte_trouvee.connect("quit_slot", self._on_carte_quit_slot)
	else:
		# Aucune carte trouvée physiquement
		if carte_occupee != null:
			# Si on pensait en avoir une, on l'oublie
			carte_occupee = null
			a_change = true

	# 3. Notification : On prévient toujours les autres systèmes (CombatManager)
	# pour qu'ils recalculent les bonus si nécessaire.
	emit_signal("slot_updated")

# --- LOGIQUE DE DROP (API Godot) ---

## Vérifie si l'objet survolant le slot peut être déposé.
## Retourne true si c'est une carte valide, sinon false.
func _can_drop_data(_position, donnee):
	if typeof(donnee) == TYPE_OBJECT and donnee is MarginContainer:
		add_yellow_border() # Feedback positif
		return true
	else:
		add_red_border() # Feedback négatif
		return false

## Exécute le dépôt de la carte.
func _drop_data(_position, donnee):
	# On accepte uniquement si le slot est logiquement vide
	if carte_occupee == null:
		# 1. Transfert de propriété (Changement de parent)
		if donnee.get_parent():
			donnee.get_parent().remove_child(donnee)
		add_child(donnee)
		
		# 2. Centrage visuel de la carte dans le slot
		var center_pos = (self.custom_minimum_size - donnee.custom_minimum_size) / 2
		donnee.position = center_pos
		
		# 3. Mise à jour immédiate de l'état
		# On utilise la fonction de synchro pour être sûr que tout est carré
		_synchroniser_etat()

## Appelé par la carte elle-même quand on commence à la déplacer (Drag Start).
## Sert à vider logiquement le slot pendant que la carte est en l'air.
func _on_carte_quit_slot(slot):
	if slot == self:
		carte_occupee = null
		emit_signal("slot_updated")
