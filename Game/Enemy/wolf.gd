extends CharacterBody2D

var SPEED = 90
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
var player_in_contact = null
func _ready():
	get_node("AnimatedSprite2D").play("idle")
func _physics_process(delta):
	# Gravity for Frog
	velocity.y += gravity * delta

	if chase == true and get_node("AnimatedSprite2D").animation != "death":
		get_node("AnimatedSprite2D").play("attack")

		player = get_node("../../player/player")
		var direction = (player.position - self.position).normalized()

		if direction.x > 0:
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false

		velocity.x = direction.x * SPEED
	else:
		if get_node("AnimatedSprite2D").animation != "death":
			get_node("AnimatedSprite2D").play("idle")
		velocity.x = 0

	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.name == "player":
		chase = true

func _on_player_death_body_entered(body):
	if body.name == "player":
		death()


func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var is_above = body.global_position.y < global_position.y - 10
		var is_falling = body.velocity.y > 0

		if is_above and is_falling:
			body.velocity.y = -200  # bounce after stomp
			death()
		else:
			# 🟩 Register the player in contact and start the timer
			player_in_contact = body
			$DamageTimer.start()

func _on_player_collision_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_contact = null
		$DamageTimer.stop()
		
func death():
	chase = false
	get_node("AnimatedSprite2D").play("dead")
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()


func _on_damage_timer_timeout() -> void:
	if player_in_contact and player_in_contact.has_method("take_damage"):
		player_in_contact.take_damage(3)
		print("⚠️ Wolf damaged player. HP:", player_in_contact.health)
