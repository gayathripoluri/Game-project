extends Area2D

signal gem_collected

@export var base_disappear_time: float = 60.0
var is_collected: bool = false
var player: Node = null
const COLLECT_DISTANCE: float = 50.0
var velocity: Vector2 = Vector2.ZERO
const GRAVITY: float = 300.0
var is_on_ground: bool = false

signal gem_disappeared

func _start_disappear_timer():
	var timer = $Timer
	timer.start()

func _on_Timer_timeout():
	emit_signal("gem_disappeared")
	queue_free()
	
func _ready():
	add_to_group("gems")
	set_size()
	if base_disappear_time > 0:
		var disappear_timer = Timer.new()
		disappear_timer.wait_time = randf_range(base_disappear_time, base_disappear_time * 1.5)
		disappear_timer.one_shot = true
		disappear_timer.connect("timeout", Callable(self, "_on_disappear_timeout"))
		add_child(disappear_timer)
		disappear_timer.name = "DisappearTimer"
		disappear_timer.start()

func _physics_process(delta):
	if is_collected:
		return

	if not is_on_ground:
		velocity.y += GRAVITY * delta
		position += velocity * delta
		if $RayCast2D.is_colliding():
			var collision_point = $RayCast2D.get_collision_point()
			position.y = collision_point.y - ($CollisionShape2D.shape.radius * 0.15)
			velocity.y = 0
			is_on_ground = true

	if not player:
		player = get_tree().get_nodes_in_group("player")[0]
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= COLLECT_DISTANCE:
		collect_gem()

func set_size():
	var scale_factor = 0.15
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = 16 * scale_factor

func collect_gem():
	if not is_collected:
		is_collected = true
		print("Gem collected at position: ", position)
		emit_signal("gem_collected")
		queue_free()

func _on_disappear_timeout():
	if not is_collected:
		print("Gem disappeared at position: ", position)
		queue_free()

func _on_body_entered(body):
	if body.name == "Player" and not is_collected:
		collect_gem()
