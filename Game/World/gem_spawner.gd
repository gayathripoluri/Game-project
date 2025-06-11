extends Node2D

@export var gem_scene: PackedScene = preload("res://assets/Gems/gems.tscn")

var gem_zones = [
	
	Rect2(1300, 280, 100, 20),
	Rect2(6275, 280, 100, 20),
	Rect2(6530, 280, 100, 20),
	Rect2(9000, 280, 100, 20),
	Rect2(10700, 280, 100, 20)
]

var total_gems: int = 5
var spawned_gems: Array = []

var base_disappear_time: float = 40.0

func _ready():
	spawn_random_gems()

func spawn_random_gems():
	for i in range(total_gems):
		var gem = gem_scene.instantiate()
		gem.position = get_random_position_in_zone(i)
		gem.base_disappear_time = base_disappear_time
		if gem.has_node("Timer"):
			gem.get_node("Timer").wait_time = base_disappear_time
		add_child(gem)
		spawned_gems.append(gem)

func get_random_position_in_zone(zone_index: int) -> Vector2:
	var zone = gem_zones[zone_index]
	var x = randf_range(zone.position.x, zone.end.x)
	var y = randf_range(zone.position.y, zone.end.y)
	return Vector2(x, y)
