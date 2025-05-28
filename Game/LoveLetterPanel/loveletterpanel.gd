extends Control

@onready var text_edit = $TextEdit
@onready var submit_button = $Submit
@onready var cheater_label = $CheaterLabel
@onready var background = $Background

var known_phrases = ["I love you", "dear princess", "forever yours"]

func _ready():
	print("LoveLetterPanel initialized")
	background.color = Color(1, 0.8, 0.8)
	
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5).set_ease(Tween.EASE_OUT)
	
	text_edit.editable = true
	text_edit.context_menu_enabled = false
	#text_edit.text_drag_enabled = false
	
	submit_button.add_theme_stylebox_override("normal", create_heart_style())
	submit_button.add_theme_stylebox_override("hover", create_heart_style_hover())
	submit_button.add_theme_color_override("font_color", Color(1, 1, 1))
	submit_button.add_theme_color_override("font_color_hover", Color(1, 0.9, 0.9))
	submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed or event.command_pressed:
			get_viewport().set_input_as_handled()

func _on_submit_pressed():
	print("Submit button pressed")
	var letter_text = text_edit.text.strip_edges()
	if is_plagiarism_detected(letter_text):
		cheater_label.text = "Cheater! 💔"
		cheater_label.show()
		shake_label()
	elif is_good_letter(letter_text):
		cheater_label.hide()
		print("Good letter submitted, triggering happy_end")
		var world = get_tree().get_root().get_node("World")
		if world:
			world.play_ending("happy_end")
		else:
			print("World node not found!")
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5).set_ease(Tween.EASE_IN)
		await tween.finished
		get_tree().paused = false
		var player = get_tree().get_root().get_node("World/player/player")
		if player:
			player.set_physics_process(true)
		queue_free()
	else:
		cheater_label.text = "Try again, my love! 💕"
		cheater_label.show()
		shake_label()

func is_plagiarism_detected(text):
	for phrase in known_phrases:
		if text.to_lower().find(phrase.to_lower()) != -1:
			return true
	return false

func is_good_letter(text):
	return text.length() > 20 and text.to_lower().find("love") != -1 and text.to_lower().find("princess") != -1

func create_heart_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 0.5, 0.5)
	style.corner_radius = 10
	style.border_width = 2
	style.border_color = Color(1, 0, 0)
	return style

func create_heart_style_hover():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 0.6, 0.6)
	style.corner_radius = 10
	style.border_width = 2
	style.border_color = Color(1, 0, 0)
	return style

func shake_label():
	var original_pos = cheater_label.position
	var tween = create_tween()
	tween.tween_property(cheater_label, "position", original_pos + Vector2(5, 0), 0.1)
	tween.tween_property(cheater_label, "position", original_pos + Vector2(-5, 0), 0.1)
	tween.tween_property(cheater_label, "position", original_pos, 0.1)
