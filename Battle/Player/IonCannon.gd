extends Area2D

func _on_IonCannon_body_entered(body):
	if body.is_in_group('enemy'):
		body.take_dmg(1)

func set_enabled(x):
	monitorable = x
	monitoring = x