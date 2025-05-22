extends Node2D

@export var enemy_scene: PackedScene  # The wolf scene to instantiate
@export var spawn_area: Rect2 = Rect2(Vector2(0, 0), Vector2(11000, 600))  # Area where wolves can spawn
@export var max_enemies: int = 8  # Maximum number of wolves (5)
@export var min_enemy_distance: float = 300.0  # Minimum distance between wolves
@export var min_player_distance: float = 400.0  # Minimum distance from player
@export var ground_y: float = 500.0  # Y-position of the ground (adjust to your game’s ground level)

var active_enemies: Array = []  # Tracks spawned wolves
var player  # Reference to the player node

func _ready():
	# Find the player node (adjust path if different in your scene tree)
	player = get_node("/root/World/Mobs/EnemySpawner")  # Update path as needed
	if not player:
		push_error("Player node not found! Check the node path.")
		return
	spawn_initial_enemies()

func spawn_initial_enemies():
	# Spawn up to max_enemies wolves at the start
	for i in range(max_enemies):
		spawn_enemy()

func spawn_enemy():
	if active_enemies.size() >= max_enemies:
		return  # Don’t spawn if max enemies reached

	var enemy = enemy_scene.instantiate()
	var spawn_position = find_valid_spawn_position()
	
	if spawn_position != Vector2.ZERO:  # Valid position found
		enemy.position = spawn_position
		get_parent().add_child.call_deferred(enemy)
		active_enemies.append(enemy)
		# Connect to a signal to detect enemy death (assuming enemy emits "tree_exited" when freed)
		enemy.connect("tree_exited", Callable(self, "_on_enemy_died").bind(enemy))
	else:
		# Retry spawning after a short delay if no valid position found
		get_tree().create_timer(0.5).timeout.connect(spawn_enemy)

func find_valid_spawn_position() -> Vector2:
	var attempts = 0
	const MAX_ATTEMPTS = 20  # Increased attempts for robustness
	var spawn_position = Vector2.ZERO

	while attempts < MAX_ATTEMPTS:
		# Random x within spawn area, fixed y at ground level
		var x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
		spawn_position = Vector2(x, ground_y)

		# Check if position is valid (no overlap with player or enemies)
		if is_position_valid(spawn_position):
			return spawn_position
		attempts += 1

	# Return Vector2.ZERO if no valid position found
	return Vector2.ZERO

func is_position_valid(spawn_pos: Vector2) -> bool:
	if player and spawn_pos.distance_to(player.global_position) < min_player_distance:
		return false
	for enemy in active_enemies:
		if enemy and is_instance_valid(enemy) and spawn_pos.distance_to(enemy.global_position) < min_enemy_distance:
			return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = spawn_pos
	query.collision_mask = 1
	var results = space_state.intersect_point(query, 1)
	return results.is_empty()

func _on_enemy_died(enemy):
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		if is_inside_tree():  # Check if the node is still in the scene tree
			get_tree().create_timer(1.0).timeout.connect(spawn_enemy)
		else:
			print("EnemySpawner is no longer in the scene tree, skipping spawn.")
