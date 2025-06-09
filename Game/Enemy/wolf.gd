extends CharacterBody2D

var SPEED = 200
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
var player_in_contact = null
func _ready():
	get_node("AnimatedSprite2D").play("idle")
func _physics_process(delta):
	# Add gravity so the wolf falls naturally
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset when grounded

	if chase and $AnimatedSprite2D.animation != "death":
		if player and player.has_method("is_dead") and player.is_dead:
			chase = false
			velocity.x = 0
			$AnimatedSprite2D.play("idle")
			return

		$AnimatedSprite2D.play("attack")

		if not player:
			player = get_node("../../player/player")

		var direction = (player.position - self.position).normalized()
		$AnimatedSprite2D.flip_h = direction.x > 0
		velocity.x = direction.x * SPEED
	else:
		if $AnimatedSprite2D.animation != "death":
			$AnimatedSprite2D.play("idle")
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
		var is_above = body.global_position.y + 10 < global_position.y  # +10 helps fine-tune stomp check
		var is_falling = body.velocity.y > 0  # only if falling

		if is_above and is_falling:
			death()  #  enemy dies
		else:
			player_in_contact = body  #  start damage timer
			$DamageTimer.start()

func _on_player_collision_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_contact = null
		$DamageTimer.stop()
		
func death():
	chase = false
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()


func _on_damage_timer_timeout() -> void:
	if player_in_contact and player_in_contact.has_method("take_damage"):
		if player_in_contact.is_dead:
			$AnimatedSprite2D.play("idle")
			chase = false
			velocity.x = 0
			$DamageTimer.stop()
			return

		player_in_contact.take_damage(20)
		#print("⚠️ Wolf damaged player. HP:", player_in_contact.health)
