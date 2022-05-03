extends Sprite


var t = 1.0


func _process(delta):
	t -= delta
	modulate.a = t
	if t <= 0.0:
		queue_free()

