extends StaticBody2D

signal destroyed

var hp = 300
var shoot_left_gun = false
var player_node = null
var edge_warp_thresh = 0 #never used lol
func _ready():
	pass
	
func _physics_process(delta):
	if is_instance_valid(player_node):
		rotation = lerp_angle(rotation, rotation + get_angle_to(player_node.position) + PI/2, .01)

func take_dmg(n):
	hp -= n
	$HitSound.play()
	if hp <= 0:
		emit_signal("destroyed")

func _on_LaserTimer_timeout():
	$LeftGun.shoot()
	$RightGun.shoot()

func _on_FrontGunTimer_timeout():
	if shoot_left_gun:
		$LeftFrontGun.shoot()
	else:
		$RightFrontGun.shoot()
	shoot_left_gun = !shoot_left_gun

func _on_Area2D_body_entered(body):
	if body.is_in_group('player'):
		player_node = body

func force_scale(size):
	var s = range_lerp(size, 4500, 500, 1, .3)
	scale = Vector2(s,s)


