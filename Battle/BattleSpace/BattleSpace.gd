extends Node2D

var asteroidL = load("res://Battle/Enemies/Asteroid/AsteroidL.tscn")
var size = 600

func _input(event):
	if event.is_action_pressed("debug_spawn_asteroid"):
		spawn_asteroid('l')

func _ready():
	spawn_asteroid('l')

func _draw():
	draw_rect(Rect2(-size/2, -size/2, size, size), Color.aqua, false, 1, false)

func _on_Player_ready():
	$Player.edge_warp_thresh = size/2
	
func spawn_asteroid(s):
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var a = null
	if s == 'l':
		a = asteroidL.instance()
	if s == 's':
		pass
	a.angular_velocity = rand.randf_range(0,50)
	a.linear_velocity = Vector2(0, rand.randf_range(50, 300)).rotated(rand.randf_range(0,360))
	a.edge_warp_thresh = size/2
	while(true):
		a.position.y = rand.randf_range(-size/2, size/2)
		a.position.x = rand.randf_range(-size/2, size/2)
	a.connect("destroyed", self, "on_large_asteroid_destroyed")
	add_child(a)

func on_large_asteroid_destroyed(position):
	print(position)

