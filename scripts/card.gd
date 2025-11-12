extends Control

signal card_played(card)
var data

func setup(card_data):
	data = card_data
	$Panel/CardName.text = card_data.name
	$Panel/Description.text = card_data.description


func _on_play_button_pressed() -> void:
		emit_signal("card_played", data)
