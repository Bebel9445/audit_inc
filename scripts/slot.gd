extends Panel
class_name Slot

## Signal émis lorsqu'une carte est déposée dans ce slot ou qu'elle le quitte.
signal slot_updated

## Référence vers la carte (Control) actuellement dans ce slot. Null si vide.
var carte_occupee = null 

func _init() -> void:
	custom_minimum_size = Vector2(200, 330) 
	remove_border()

# --- GESTION VISUELLE (Drag & Drop) ---

## Ajoute une bordure jaune (indique un dépôt valide).
func add_yellow_border():
	var sb = _create_border(Color(1,1,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

## Ajoute une bordure rouge (indique un dépôt invalide ou interdit).
func add_red_border():
	var sb = _create_border(Color(0.7,0,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

## Réinitialise la bordure à son état par défaut (gris).
func remove_border():
	var sb = _create_border(Color(0.5, 0.5, 0.5), Color(0, 0, 0, 0.5)) 
	add_theme_stylebox_override("panel", sb)

# Fonction utilitaire privée pour générer un StyleBoxFlat.
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

## Gère les notifications système, notamment la fin d'un drag & drop pour nettoyer l'UI.
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		remove_border()

# --- LOGIQUE DE DROP ---

## Vérifie si l'objet traîné peut être déposé ici.
## Retourne true si c'est une MarginContainer (notre carte), sinon false.
func _can_drop_data(_position, donnee):
	if typeof(donnee) == TYPE_OBJECT and donnee is MarginContainer:
		add_yellow_border()
		return true
	else:
		add_red_border()
		return false

## Exécute le dépôt de la carte.
## Reparente la carte, centre sa position et connecte les signaux.
func _drop_data(_position, donnee):
	# Si une carte est déjà présente, on pourrait gérer un échange ici (swap),
	# mais pour l'instant on écrase la référence.
	if carte_occupee == null:
		carte_occupee = donnee
		
		# Changement de parent (SceneTree)
		if donnee.get_parent():
			donnee.get_parent().remove_child(donnee)
		add_child(donnee)
		
		# Centrage visuel
		var center_pos = (self.custom_minimum_size - donnee.custom_minimum_size) / 2
		donnee.position = center_pos
		
		# Mise à jour des références de la carte
		donnee.slot_actuel = self
		# Connexion unique pour savoir quand la carte repart
		if not donnee.is_connected("quit_slot", self._on_carte_quit_slot):
			donnee.connect("quit_slot", self._on_carte_quit_slot)
		
		emit_signal("slot_updated")

## Callback appelé quand la carte commence à être dragguée hors du slot.
func _on_carte_quit_slot(slot):
	if slot == self:
		carte_occupee = null
		emit_signal("slot_updated")
