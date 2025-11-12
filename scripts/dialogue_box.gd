extends Control

signal dialogue_finished

@onready var dialogue_text = $Panel/DialogueText
@onready var next_button = $Panel/NextButton

var lines: Array[String] = []
var current_index := 0
var is_typing := false
var typing_speed := 0.03

func _ready():
	hide()
	next_button.connect("pressed", Callable(self, "_on_next_pressed"))

# 🟢 Charger une ressource DialogueResource
func load_dialogue_resource(dialogue_res):
	if dialogue_res and dialogue_res is DialogueResource:
		start_dialogue(dialogue_res.lines)

func start_dialogue(new_lines: Array[String]):
	lines = new_lines
	current_index = 0
	show_line()

func show_text(text: String):
	is_typing = false
	lines = [text]
	current_index = 0
	show_line()

func show_line():
	if current_index < lines.size():
		show()
		type_text(lines[current_index])
	else:
		hide()
		emit_signal("dialogue_finished")

func type_text(text: String):
	is_typing = true
	dialogue_text.text = ""
	for char in text:
		dialogue_text.text += char
		await get_tree().create_timer(typing_speed).timeout
		if not is_typing:
			dialogue_text.text = text
			break
	is_typing = false

func _on_next_pressed():
	if is_typing:
		is_typing = false
		return
	current_index += 1
	show_line()
