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
	sb.bg_color = Color(0,0,0,0)
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

func _init(position_x, position_y) -> void:
	position.x = position_x
	position.y = position_y
	size.x = 230
	size.y = 230
	
	var couleur_slot = ColorRect.new()
	couleur_slot.color = Color.DARK_GRAY
	couleur_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	couleur_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(couleur_slot)
