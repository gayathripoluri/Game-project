extends Node2D

var red_style = StyleBoxFlat.new()
var green_style = StyleBoxFlat.new()

var gem_count: int = 0
var total_gems: int = 5
@onready var gem_label = $GemCount/Label

func _ready():
	red_style.bg_color = Color(1, 0, 0)
	green_style.bg_color = Color(0, 1, 0)
	if gem_label:
		gem_label.text = "Gems: %d/%d" % [gem_count, total_gems]
	
	call_deferred("connect_to_gems")

func connect_to_gems():
	await get_tree().create_timer(0.2).timeout
	for gem in get_tree().get_nodes_in_group("gems"):
		if not gem.is_connected("gem_collected", Callable(self, "_on_gem_collected")):
			gem.connect("gem_collected", Callable(self, "_on_gem_collected"))
			print("Connected gem_collected signal for gem at position: ", gem.position)

func _process(_delta):
	var player = get_node("player/player")
	print("Player Health:", player.health)
	
	var health_bar = get_node("HealthBar/ProgressBar")
	var hp_label = get_node("HealthBar/Hp")
	health_bar.value = player.health
	hp_label.text = "HP: " + str(player.health) + "/10"
	
	if player.health <= 3:
		health_bar.set("theme_override_styles/fill", red_style)
	else:
		health_bar.set("theme_override_styles/fill", green_style)

func _on_gem_collected():
	if gem_count < total_gems:  # Prevent overshooting
		gem_count += 1
		if gem_label:
			gem_label.text = "Gems: %d/%d" % [gem_count, total_gems]
		print("Gem collected! Total: ", gem_count)
