extends Control
class_name MainHand

var cartes: Array[FightCardsObject] = []
var spacing := 80          # espace horizontal entre cartes
var arc_height := 30       # courbure des cartes
var hover_raise := 60      # hauteur quand la carte est survolée
var hover_scale := 1.25    # zoom quand survol
var hover_spread := 30     # écartement des cartes voisines
var animation_speed := 0.15

var hovered_card: FightCardsObject = null


func add_card(carte: FightCardsObject):
	cartes.append(carte)
	add_child(carte)

	# Pour détecter le survol
	carte.mouse_entered.connect(_on_card_mouse_enter.bind(carte))
	carte.mouse_exited.connect(_on_card_mouse_exit.bind(carte))

	_update_positions(true)


func remove_card(carte: FightCardsObject):
	cartes.erase(carte)
	if is_instance_valid(carte):
		remove_child(carte)
	_update_positions(true)


func _on_card_mouse_enter(carte):
	hovered_card = carte
	_update_positions()


func _on_card_mouse_exit(carte):
	if hovered_card == carte:
		hovered_card = null
	_update_positions()


func _update_positions(instantly := false):
	if cartes.is_empty():
		return

	var count := cartes.size()
	var center_x := size.x / 2
	var total_width := (count - 1) * spacing
	var start_x := center_x - total_width / 2

	for i in range(count):
		var card := cartes[i]

		var t := (i - (count - 1) / 2.0)

		# Position de base
		var target_x := start_x + i * spacing - card.size.x / 2
		var target_y := -t * t * 2 + arc_height
		var target_rot = deg_to_rad(t * 5)
		var target_scale := 1.0

		# --- Style Hearthstone : carte survolée ---
		if card == hovered_card:
			target_y -= hover_raise
			target_scale = hover_scale

		# --- Style Hearthstone : écarter les cartes voisines ---
		elif hovered_card != null:
			var hover_index := cartes.find(hovered_card)
			var distance = abs(i - hover_index)

			if distance == 1:
				if (i < hover_index):
					target_x -= hover_spread
				else:
					target_x += hover_spread

		# --- Application (avec animation) ---
		if instantly:
			card.position = Vector2(target_x, target_y)
			card.rotation = target_rot
			card.scale = Vector2.ONE * target_scale
		else:
			card.position = card.position.lerp(Vector2(target_x, target_y), animation_speed)
			card.rotation = lerp_angle(card.rotation, target_rot, animation_speed)
			card.scale = card.scale.lerp(Vector2.ONE * target_scale, animation_speed)
