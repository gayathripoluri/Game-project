extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("AnimationPlayer")
var health = 100
var is_dead = false
func _ready():
	add_to_group("player")  # Add player to the "player" group
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var player_pos = global_position
		for gem in get_tree().get_nodes_in_group("gems"):
			var distance = player_pos.distance_to(gem.global_position)
			if distance <= 50.0 and not gem.is_collected:  # 50 pixels is COLLECT_DISTANCE
				gem.collect_gem()
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("jump")

	# Movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false

	if direction:
		velocity.x = direction * SPEED
		anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("Idle")
		elif velocity.y > 0:
			anim.play("fall")

	move_and_slide()

	if health <= 0 and not is_dead:
		die()
func take_damage(amount):
	if is_dead:
		return
	health -= amount
	#print("Player HP now:", health)
	if health <= 0:
		die()
func die():
	is_dead = true
	anim.play("dead")
	velocity = Vector2.ZERO
	await anim.animation_finished
	print("Player Died")
	get_tree().change_scene_to_file("res://gameEnd.tscn")
