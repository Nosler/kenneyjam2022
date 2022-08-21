extends StaticBody2D

var edge_warp_thresh
var speed = 1000
var target = null
var area_color = Color.green
func _ready():
	area_color.a = .05
	
func _draw():
	draw_circle(Vector2.ZERO, $Area2D/CollisionShape2D.shape.radius, area_color)
func _physics_process(delta):
	if position.x >= edge_warp_thresh or position.x <= -edge_warp_thresh:
		position = Vector2(clamp(-position.x, -edge_warp_thresh, edge_warp_thresh), clamp(position.y, -edge_warp_thresh, edge_warp_thresh))
	if position.y >= edge_warp_thresh or position.y <= -edge_warp_thresh:
		position = Vector2(clamp(position.x, -edge_warp_thresh, edge_warp_thresh), clamp(-position.y, -edge_warp_thresh, edge_warp_thresh))
		
	if target != null:
		look_at(target.position)
		rotation = rotation + PI/2
		position -= transform.y * speed * delta
	else:
		position -= transform.y * 150 * delta

func force_scale(size):
	var s = range_lerp(size, 4500, 500, 1, .1)
	scale = Vector2(s,s)

func _on_Area2D_body_entered(body):
	if body.is_in_group('player'):
		target = body

func _on_Area2D_body_exited(body):
	if body.is_in_group('player'):
		target = null

func _on_KamikazeBoy_body_entered(body):
	if body.is_in_group('player'):
		body.take_damage(1)
		queue_free()

func take_dmg(x):
	queue_free()
