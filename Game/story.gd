extends Control

@onready var image = $StoryImage
@onready var prev_button = $NavButtons/PrevButton
@onready var next_button = $NavButtons/NextButton

var story_images = []
var current_index = 0

func _ready():
	story_images = [
		preload("res://assets/Story/Story1.png"),
		preload("res://assets/Story/Story2.png"),
		preload("res://assets/Story/Story3.png"),
		preload("res://assets/Story/Story4.png"),
		preload("res://assets/Story/Story5.png"),
		preload("res://assets/Story/Story6.png"),
		preload("res://assets/Story/Story7.png")
	]
	update_panel()

func update_panel():
	image.texture = story_images[current_index]
	prev_button.disabled = current_index == 0
	next_button.disabled = current_index == story_images.size() - 1


func _on_prev_button_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		update_panel()


func _on_next_button_pressed() -> void:
	if current_index < story_images.size() - 1:
		current_index += 1
		update_panel()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main/main.tscn")
