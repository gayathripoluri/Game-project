extends Node2D

var animation_to_play: String = ""

@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

func _ready():
	if not animated_sprite:
		print("AnimatedSprite2D not found in Endings.tscn")
		return
	
	# Verify animation names in SpriteFrames
	var sprite_frames = animated_sprite.sprite_frames
	if sprite_frames:
		var animations = sprite_frames.get_animation_names()
		print("Available animations in SpriteFrames:", animations)
	else:
		print("SpriteFrames not set in AnimatedSprite2D")
		return
	
	# Play the appropriate animation
	if animation_to_play == "happy_end" and sprite_frames.has_animation("happy_end"):
		animated_sprite.play("happy_end")
		print("Playing happy_end animation")
	elif animation_to_play == "sad_end" and sprite_frames.has_animation("sad_end"):
		animated_sprite.play("sad_end")
		print("Playing sad_end animation")
	else:
		print("Invalid or missing animation_to_play value:", animation_to_play)
	
	# Do not set position here; rely on World.gd positioning
	animated_sprite.scale = Vector2(1, 1)
	animated_sprite.visible = true
	print("AnimatedSprite2D set with scale:", animated_sprite.scale)
	
	# Add a timer to return to main menu or restart
	var timer = Timer.new()
	timer.wait_time = 5.0  # Display for 5 seconds
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	# Return to main menu or restart (adjust path as needed)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
