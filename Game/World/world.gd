extends Node2D

var red_style = StyleBoxFlat.new()
var green_style = StyleBoxFlat.new()

var gem_count: int = 0
var total_gems: int = 5
var has_triggered_end: bool = false

@onready var gem_label = $GemCount/Label if has_node("GemCount/Label") else null
@onready var timer_scene = ($CanvasLayer/TimerSetup/Timer if has_node("CanvasLayer/TimerSetup/Timer") else $TimerSetup/Timer if has_node("TimerSetup/Timer") else null)
@onready var canvas_layer = $CanvasLayer if has_node("CanvasLayer") else null
@onready var player = $player/player if has_node("player/player") else null

func _ready():
	red_style.bg_color = Color(1, 0, 0)
	green_style.bg_color = Color(0, 1, 0)

	if gem_label:
		gem_label.text = "Gems: %d/%d" % [gem_count, total_gems]
	else:
		print("GemCount/Label not found")

	if timer_scene:
		timer_scene.connect("timeout", Callable(self, "on_game_over"))
		print("Timer connected successfully")
	else:
		print("TimerSetup/Timer not found")

	if not player:
		print("player/player not found")

	call_deferred("connect_to_gems")

func connect_to_gems():
	await get_tree().create_timer(0.1).timeout
	var gems = get_tree().get_nodes_in_group("gems")
	print("Found", gems.size(), "gems in group")
	for gem in gems:
		if not gem.is_connected("gem_collected", Callable(self, "_on_gem_collected")):
			gem.connect("gem_collected", Callable(self, "_on_gem_collected"))
			print("Connected gem_collected signal for gem at position: ", gem.position)

func _process(_delta):
	if not player or has_triggered_end:
		return

	var health_bar = get_node("HealthBar/ProgressBar")
	var hp_label = get_node("HealthBar/Hp")

	health_bar.value = player.health
	hp_label.text = "HP: %d/10" % player.health

	if player.health <= 3:
		health_bar.set("theme_override_styles/fill", red_style)
	else:
		health_bar.set("theme_override_styles/fill", green_style)

	if player.global_position.x >= 11400 and not player.is_dead and not has_triggered_end:
		print("Player reached trigger position at x =", player.global_position.x)
		if timer_scene:
			timer_scene.get_parent().is_running = false
		get_tree().paused = true
		player.set_physics_process(false)
		await land_player()
		check_end_condition()

func on_game_over():
	print("Time's up!")
	if not has_triggered_end:
		get_tree().paused = true
		player.set_physics_process(false)
		await land_player()
		check_end_condition()

func check_end_condition():
	if has_triggered_end:
		print("Ending already triggered, skipping")
		return

	var time_left = timer_scene.get_parent().time_left if timer_scene else 0
	print("Checking end condition: gem_count =", gem_count, "time_left =", time_left, "player x =", player.global_position.x if player else "N/A")

	if (player and player.global_position.x >= 11400) or time_left <= 0:
		has_triggered_end = true
		if gem_count == 5:
			print("All 5 gems collected, triggering happy_end")
			play_ending("happy_end")
		elif gem_count < 4:
			print("Not enough gems, triggering sad_end (gems =", gem_count, ")")
			play_ending("sad_end")
		else:
			print("Exactly 4 gems, showing love letter panel")
			show_love_letter_panel()
	else:
		get_tree().paused = false
		player.set_physics_process(true)
		print("No ending triggered: waiting for x >= 11500 or timer to run out")

func land_player():
	if player:
		var space_state = get_world_2d().direct_space_state
		var ray_start = player.global_position
		var ray_end = player.global_position + Vector2(0, 500)
		var ray_query = PhysicsRayQueryParameters2D.create(ray_start, ray_end, 1, [player])
		var result = space_state.intersect_ray(ray_query)

		if result:
			var ground_y = result.position.y
			player.global_position = Vector2(player.global_position.x, ground_y)
			print("Landed player at y =", ground_y)
		else:
			var default_ground_y = 200.0
			player.global_position = Vector2(player.global_position.x, default_ground_y)
			print("No ground detected, landed at default y =", default_ground_y)

		await get_tree().create_timer(0.1).timeout
		return player.global_position.y

func play_ending(animation_name: String):
	print("Playing ending:", animation_name)

	if player:
		player.visible = false
		player.set_physics_process(false)

	# Instantiate the ending scene
	var ending_scene = preload("res://Endings/Endings.tscn").instantiate()
	if not ending_scene:
		print("Failed to instantiate Endings.tscn")
		return

	# Set which animation to play
	ending_scene.animation_to_play = animation_name

	# Ensure CanvasLayer exists
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 20
		add_child(canvas_layer)
		print("Created new CanvasLayer at layer:", canvas_layer.layer)

	canvas_layer.add_child(ending_scene)

	# Land player and get Y position of ground
	var ground_y = await land_player()
	print("Ground y after landing:", ground_y)

	# Get AnimatedSprite2D from the scene
	var sprite = ending_scene.get_node("AnimatedSprite2D")
	var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	var sprite_height = frame_texture.get_height()

	# Set scale and adjust final Y position
	var desired_scale = Vector2(1.6, 1.6)
	ending_scene.scale = desired_scale

	var extra_offset = 20.0  # tweak upward if needed
	var final_position = Vector2(
		get_viewport().get_visible_rect().size.x / 2,
		ground_y - (sprite_height * desired_scale.y / 2) + extra_offset
	)
	ending_scene.position = final_position
	ending_scene.visible = true

	# Optional: Debug marker to visualize ground
	var marker = ColorRect.new()
	marker.color = Color(1, 0, 0)
	marker.size = Vector2(300, 2)
	marker.position = Vector2(0, ground_y)
	add_child(marker)

	print("Ending scene added to CanvasLayer at position:", final_position, "with scale:", desired_scale)


	



func show_love_letter_panel():
	print("Initiating love letter panel display")

	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		add_child(canvas_layer)

	var love_letter_scene = preload("res://LoveLetterPanel/LoveLetterPanel.tscn").instantiate()
	if love_letter_scene:
		canvas_layer.add_child(love_letter_scene)
		love_letter_scene.position = get_viewport_rect().size / 2
		print("Love letter panel positioned at:", love_letter_scene.position)
	else:
		print("Failed to instantiate LoveLetterPanel.tscn")

	get_tree().paused = true
	player.set_physics_process(false)

func _on_gem_collected():
	if gem_count < total_gems:
		gem_count += 1
		if gem_label:
			gem_label.text = "Gems: %d/%d" % [gem_count, total_gems]
		print("Gem collected! Total: ", gem_count)
