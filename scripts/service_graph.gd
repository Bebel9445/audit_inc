extends Node2D

@export var service_scene : PackedScene = preload("res://scenes/ui/service_node.tscn")
var services := [] # array classique

func _ready():
	create_graph()

func create_graph():
	randomize() # pour avoir des valeurs différentes à chaque lancement

	var total_services = 5
	for i in range(total_services):
		var s_instance = service_scene.instantiate()
		var s : ServiceNode = s_instance as ServiceNode
		if s == null:
			print("Erreur : L'instance n'est pas un ServiceNode")
			continue

		s.name = "Service %d" % i
		s.nameService = "Service %d" % i
		s.state = get_random_state()
		s.position = get_circular_position(i, total_services, 200, Vector2(400,300))
		add_child(s)
		services.append(s)
		s.update_visual()
	
	# Création des liens (exemple simple : cercle)
	for i in range(total_services):
		services[i].add_link(services[(i+1) % total_services])
	
	update_links_visual()


	# Vérifier qu'il y a assez de services
	if services.size() < 2:
		print("Pas assez de services pour créer des liens")
		return

	# Créer des liens
	services[0].add_link(services[1])
	services[1].add_link(services[2])
	services[2].add_link(services[3])
	services[3].add_link(services[4])
	services[4].add_link(services[0])

	update_links_visual()

func update_links_visual():
	# Supprimer les anciennes lignes
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	# Dessiner les lignes sans doublons
	var drawn_links = {}
	for s in services:
		for l in s.links:
			if l == null:
				continue
			# Clé unique pour éviter doublons
			var key = str(min(s.get_instance_id(), l.get_instance_id())) + "_" + str(max(s.get_instance_id(), l.get_instance_id()))
			if drawn_links.has(key):
				continue
			drawn_links[key] = true

			var line = Line2D.new()
			line.width = 2
			line.default_color = Color(1,0,0) # rouge visible
			line.points = [s.get_edge_position(l.get_center_position()), l.get_edge_position(s.get_center_position())]
			add_child(line)

			
func get_random_state() -> String:
	var states = ["green","orange","red"]
	return states[randi() % states.size()]


func get_circular_position(index:int, total:int, radius:float = 200.0, center:Vector2 = Vector2(400,300)) -> Vector2:
	var angle = (TAU / total) * index
	return center + Vector2(cos(angle), sin(angle)) * radius
