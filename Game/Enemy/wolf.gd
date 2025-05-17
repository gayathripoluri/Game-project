extends CharacterBody2D

var SPEED = 90
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
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
		body.health-=3
		death()
		
		
func death():
	chase = false
	get_node("AnimatedSprite2D").play("death")
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()
