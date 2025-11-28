extends Panel
class_name Slot

var carte_occupee = null  # la carte actuellement dans le slot

func add_yellow_border():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0,0,0,0)
	sb.border_color = Color(1,1,0)
	sb.border_width_bottom = 4
	sb.border_width_left = 4
	sb.border_width_right = 4
	sb.border_width_top = 4
	add_theme_stylebox_override("panel", sb)

func add_red_border():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0,0,0,0)
	sb.border_color = Color(0.7,0,0)
	sb.border_width_bottom = 4
	sb.border_width_left = 4
	sb.border_width_right = 4
	sb.border_width_top = 4
	add_theme_stylebox_override("panel", sb)

func remove_border():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0,0,0,0)
	sb.border_color = Color(0.0,0,0)
	sb.border_width_bottom = 4
	sb.border_width_left = 4
	sb.border_width_right = 4
	sb.border_width_top = 4
	add_theme_stylebox_override("panel", sb)

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		remove_border()

func _can_drop_data(position, donnee):
	# donnee est envoyé par la carte
	if typeof(donnee) == TYPE_OBJECT and donnee is MarginContainer:
		add_yellow_border()
		return true
	else:
		add_red_border()
		return false

func _drop_data(position, donnee):
	if carte_occupee == null:
		carte_occupee = donnee
		donnee.get_parent().remove_child(donnee)
		add_child(donnee)
		donnee.position = Vector2.ZERO
		
		donnee.slot_actuel = self
		donnee.connect("quit_slot", self._on_carte_quit_slot)

func _on_carte_quit_slot(slot):
	if slot == self:
		carte_occupee = null


func _init() -> void:
	size.x = 230
	size.y = 230
