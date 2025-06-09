extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_area: Rect2 = Rect2(Vector2(0, 0), Vector2(11000, 600))
@export var max_enemies: int = 12
@export var min_enemy_distance: float = 300.0
@export var min_player_distance: float = 300.0
@export var ground_y: float = 500.0
@export var ground_check_offset: float = 50.0

var active_enemies: Array = []
var player

func _ready():
	player = get_node_or_null("/root/World/player/player")
	if not player:
		push_error("❌ Player node not found! Check the path.")
		return

	if not enemy_scene:
		push_error("❌ Enemy scene not assigned! Assign it in the Inspector.")
		return

	spawn_initial_enemies()

func spawn_initial_enemies():
	var segment_width = spawn_area.size.x / max_enemies
	for i in range(max_enemies):
		var segment_start = spawn_area.position.x + i * segment_width
		var segment_area = Rect2(Vector2(segment_start, spawn_area.position.y), Vector2(segment_width, spawn_area.size.y))
		spawn_enemy_in_area(segment_area)

func spawn_enemy_in_area(area: Rect2) -> void:
	var enemy = enemy_scene.instantiate()
	var spawn_position = find_valid_spawn_position_in_area(area)

	if spawn_position != Vector2.ZERO:
		enemy.position = spawn_position
		get_parent().add_child.call_deferred(enemy)
		active_enemies.append(enemy)
		enemy.connect("tree_exited", Callable(self, "_on_enemy_died").bind(enemy))
		#print("✅ Spawned enemy at:", spawn_position)
	else:
		#print("❌ No valid spawn position found in area:", area)
		await get_tree().create_timer(0.5).timeout
		spawn_enemy_in_area(area)  # Try again in the same segment

func find_valid_spawn_position_in_area(area: Rect2) -> Vector2:
	const MAX_ATTEMPTS = 20
	var attempts = 0

	while attempts < MAX_ATTEMPTS:
		var x = randf_range(area.position.x, area.position.x + area.size.x)
		var spawn_pos = Vector2(x, ground_y)

		if is_position_valid(spawn_pos):
			return spawn_pos

		attempts += 1

	return Vector2.ZERO

func is_position_valid(spawn_pos: Vector2) -> bool:
	# Too close to player?
	if player and spawn_pos.distance_to(player.global_position) < min_player_distance:
		return false

	# Too close to other wolves?
	for enemy in active_enemies:
		if enemy and is_instance_valid(enemy) and spawn_pos.distance_to(enemy.global_position) < min_enemy_distance:
			return false

	# Check collision with terrain
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(40, 20)
	shape_query.shape = shape
	shape_query.transform = Transform2D(0, spawn_pos)
	shape_query.collide_with_areas = false
	shape_query.collision_mask = 1

	if not space_state.intersect_shape(shape_query).is_empty():
		return false

	# Ground check below wolf
	var ray = PhysicsRayQueryParameters2D.new()
	ray.from = spawn_pos
	ray.to = spawn_pos + Vector2(0, ground_check_offset)
	ray.collision_mask = 1
	var result = space_state.intersect_ray(ray)

	if result.is_empty():
		return false

	return true

func _on_enemy_died(enemy):
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		
		if is_inside_tree() and active_enemies.size() < max_enemies:
			await get_tree().create_timer(0.5).timeout

			# ➕ Spawn enemy in a new random segment
			var segment_width = spawn_area.size.x / max_enemies
			var segment_index = randi() % max_enemies
			var segment_start = spawn_area.position.x + segment_index * segment_width
			var segment_area = Rect2(Vector2(segment_start, spawn_area.position.y), Vector2(segment_width, spawn_area.size.y))
			
			spawn_enemy_in_area(segment_area)
