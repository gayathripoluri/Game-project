extends CharacterBody2D

@export var animation_to_play: String = "happy_end"
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	print("Endings scene initialized with animation:", animation_to_play)
	
	# Disable physics processing since we only need to display the sprite
	set_physics_process(false)
	
	# Ensure the node is visible
	move_to_front()
	get_tree().paused = true  # Pause the game during the ending
	
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_to_play):
		print("AnimatedSprite2D found, playing", animation_to_play)
		animated_sprite.play(animation_to_play)
		# Wait for a fixed duration since it's a single-frame animation
		await get_tree().create_timer(3.0).timeout
		print("Ending display finished:", animation_to_play)
	else:
		push_error("AnimatedSprite2D not found or animation '%s' missing!" % animation_to_play)
		# Fallback: wait 3 seconds before transitioning
		await get_tree().create_timer(3.0).timeout
	
	# Transition to appropriate scene based on the ending
	if animation_to_play == "happy_end":
		get_tree().change_scene_to_file("res://victory.tscn")
	else:
		get_tree().change_scene_to_file("res://gameEnd.tscn")
	
	get_tree().paused = false
	queue_free()
