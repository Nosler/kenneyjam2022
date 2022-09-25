extends AnimatedSprite

func force_scale(size):
    scale.x = range_lerp(size, 90, 1000, .01, .1)
    scale.y = range_lerp(size, 90, 1000, .01, .1)
