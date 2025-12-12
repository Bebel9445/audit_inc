extends Panel
class_name Slot

signal slot_updated # Signal émis quand une carte est déposée ou retirée

var carte_occupee = null 


func _init() -> void:

	custom_minimum_size = Vector2(200, 330) 
	
	remove_border()

# --- Gestion Bordures (Drag & Drop) ---
func add_yellow_border():
	var sb = _create_border(Color(1,1,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

func add_red_border():
	var sb = _create_border(Color(0.7,0,0), Color(0.2, 0.2, 0.2, 0.8))
	add_theme_stylebox_override("panel", sb)

func remove_border():
	var sb = _create_border(Color(0.5, 0.5, 0.5), Color(0, 0, 0, 0.5)) 
	add_theme_stylebox_override("panel", sb)

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

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		remove_border()

# --- Drop Logic ---
func _can_drop_data(position, donnee):
	if typeof(donnee) == TYPE_OBJECT and donnee is MarginContainer:
		add_yellow_border()
		return true
	else:
		add_red_border()
		return false

func _drop_data(position, donnee):
	if carte_occupee == null:
		carte_occupee = donnee
		
		if donnee.get_parent():
			donnee.get_parent().remove_child(donnee)
		add_child(donnee)
		
		var center_pos = (self.custom_minimum_size - donnee.custom_minimum_size) / 2
		donnee.position = center_pos
		
		donnee.slot_actuel = self
		donnee.connect("quit_slot", self._on_carte_quit_slot)
		
		emit_signal("slot_updated") # On prévient le manager

func _on_carte_quit_slot(slot):
	if slot == self:
		carte_occupee = null
		emit_signal("slot_updated") # On prévient le manager
