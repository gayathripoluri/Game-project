extends Node2D


var red_style = StyleBoxFlat.new()
var green_style = StyleBoxFlat.new()

func _ready():
	red_style.bg_color = Color(1, 0, 0)    # Red
	green_style.bg_color = Color(0, 1, 0)  # Green

func _process(_delta):
	var player = get_node("player/player")
	print("Player Health:", player.health)
	var health_bar = get_node("UI/ProgressBar")
	var hp_label = get_node("UI/Hp")

	health_bar.value = player.health
	hp_label.text = "HP: " + str(player.health) + "/10"
	hp_label.text = "HP: " + str(player.health)
	if player.health <= 3:
		health_bar.set("theme_override_styles/fill", red_style)
	else:
		health_bar.set("theme_override_styles/fill", green_style)
	
