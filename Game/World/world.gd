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
	
	if timer_scene and timer_scene.has_signal("game_over"):
		timer_scene.connect("game_over", Callable(self, "on_game_over"))
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
	
	print("Player Health:", player.health, "X:", player.global_position.x, "Y:", player.global_position.y)
	var health_bar = get_node("HealthBar/ProgressBar")
	var hp_label = get_node("HealthBar/Hp")
	if health_bar and hp_label:
		health_bar.value = player.health
		health_bar.max_value = 10
		hp_label.text = "HP: " + str(player.health) + "/10"
		
		if player.health <= 3:
			health_bar.set("theme_override_styles/fill", red_style)
		else:
			health_bar.set("theme_override_styles/fill", green_style)
	else:
		print("HealthBar or Hp label not found")

	print("Trigger Check - X >= 11500:", player.global_position.x >= 11500, "Not Dead:", not player.is_dead, "Not Triggered:", not has_triggered_end)
	if player.global_position.x >= 11500 and not player.is_dead and not has_triggered_end:
		print("Player reached trigger position at x =", player.global_position.x)
		if timer_scene:
			timer_scene.is_running = false
		get_tree().paused = true
		if player:
			player.set_physics_process(false)
		check_end_condition()

func on_game_over():
	print("Time's up!")
	if not has_triggered_end:
		check_end_condition()

func check_end_condition():
	if has_triggered_end:
		print("Ending already triggered, skipping")
		return
	
	var time_left = timer_scene.time_left if timer_scene else 0
	print("Checking end condition: gem_count =", gem_count, "time_left =", time_left, "player x =", player.global_position.x if player else "N/A")
	
	if player and player.global_position.x >= 11500:
		has_triggered_end = true
		print("Player reached end at x =", player.global_position.x, "with gem_count =", gem_count)
		if gem_count == 5:
			print("All gems collected, triggering happy_end")
			play_ending("happy_end")
		elif gem_count < 4:
			print("Not enough gems, triggering sad_end (gems =", gem_count, ")")
			play_ending("sad_end")
		elif gem_count == 4:
			print("Exactly 4 gems, attempting to show love letter panel")
			show_love_letter_panel()
	elif time_left > 0 and gem_count == 5:
		has_triggered_end = true
		print("Time remaining and all gems collected, triggering happy_end")
		play_ending("happy_end")
	elif time_left <= 0 and gem_count < 4:
		has_triggered_end = true
		print("Time ran out and not enough gems, triggering sad_end")
		play_ending("sad_end")
	else:
		print("No ending triggered: player x =", player.global_position.x, "gems =", gem_count, "time_left =", time_left)

func land_player():
	if player:
		var space_state = get_world_2d().direct_space_state
		var ray_start = player.global_position + Vector2(0, -50)
		var ray_end = player.global_position + Vector2(0, 50000)
		var ray_query = PhysicsRayQueryParameters2D.create(ray_start, ray_end, 1, [player])
		var result = space_state.intersect_ray(ray_query)
		
		print("Raycast:", result)
		if result:
			var collision_shape = player.get_node("CollisionShape2D")
			var vertical_offset = 0.0
			if collision_shape and collision_shape.shape:
				if collision_shape.shape is CapsuleShape2D:
					vertical_offset = collision_shape.shape.height + 2 * collision_shape.shape.radius
				elif collision_shape.shape is RectangleShape2D:
					vertical_offset = collision_shape.shape.extents.y
				else:
					vertical_offset = 0.0
					print("Unknown collision shape type, using default offset")
			else:
				print("CollisionShape2D or shape not found, using default offset")
				vertical_offset = 0.0
			
			var ground_y = result.position.y - vertical_offset
			player.global_position = Vector2(11500, ground_y)
			print("Landed at y =", ground_y, "with offset =", vertical_offset)
		else:
			var default_ground_y = 550.0
			player.global_position = Vector2(11500, default_ground_y)
			print("No ground, landed at y =", default_ground_y)
		
		player.set_physics_process(true)
		await get_tree().create_timer(0.5).timeout
		player.set_physics_process(false)

func play_ending(animation_name: String):
	print("Attempting to play ending:", animation_name)
	if player:
		player.queue_free()
		print("Player freed")
	
	var ending_scene = preload("res://Endings/Endings.tscn").instantiate()
	ending_scene.animation_to_play = animation_name
	ending_scene.visible = true
	
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		add_child(canvas_layer)
		print("Created new CanvasLayer")
	
	canvas_layer.add_child(ending_scene)
	print("Ending scene added to CanvasLayer, visible:", ending_scene.visible)
	ending_scene.position = get_viewport_rect().size / 2
	print("Ending scene positioned at:", ending_scene.position)

func show_love_letter_panel():
	print("Initiating love letter panel display")
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		add_child(canvas_layer)
		print("Created new CanvasLayer for panel")
	
	var love_letter_scene = preload("res://LoveLetterPanel/LoveLetterPanel.tscn").instantiate()
	if love_letter_scene:
		canvas_layer.add_child(love_letter_scene)
		print("Love letter scene added to CanvasLayer")
		love_letter_scene.position = (get_viewport_rect().size - love_letter_scene.size) / 2
		print("Love letter panel positioned at:", love_letter_scene.position)
	else:
		print("Failed to instantiate LoveLetterPanel.tscn")
	
	get_tree().paused = true
	if player:
		player.set_physics_process(false)

func _on_gem_collected():
	if gem_count < total_gems:
		gem_count += 1
		if gem_label:
			gem_label.text = "Gems: %d/%d" % [gem_count, total_gems]
		print("Gem collected! Total: ", gem_count)
