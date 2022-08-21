extends Node2D

var speed = 600
var edge_warp_thresh

func _ready():
	$Lifespan.wait_time = .5 + PlayerDataHandler.PlayerData.ship.pewpews.projectile_range * .5
	speed = 500 + PlayerDataHandler.PlayerData.ship.pewpews.projectile_speed * 300

func _physics_process(delta):
	position -= transform.y * speed * delta
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))

func _on_Lifespan_timeout():
	queue_free()

func _on_PewPew_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_dmg(1)
		print("you hit nice")
		queue_free()
