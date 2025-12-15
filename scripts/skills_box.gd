extends ScrollContainer

func _can_drop_data(position, data):
	return data is object_skill_card

func _drop_data(position, data):
	var container = get_node("SkillsBox")
	
	if container == null:
		push_error("Erreur : Impossible de trouver le conteneur 'SkillsBox' dans CardZone2")
		return
	
	if data.get_parent():
		data.get_parent().remove_child(data)
		
	data.custom_minimum_size = Vector2(180, 310)
	
	# On l'ajoute au conteneur
	container.add_child(data)
	
	# Reset de position standard
	data.position = Vector2.ZERO
