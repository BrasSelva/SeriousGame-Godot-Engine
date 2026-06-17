extends Node2D

var progress = 0.0
var animating = false

func _draw():
	if progress > 0:
		draw_arc(
			Vector2.ZERO,
			280,
			-PI/2,
			-PI/2 + (2 * PI * progress),
			64,
			Color(1, 0.85, 0, 1),
			3.0
		)

func _process(delta):
	if animating:
		progress = min(progress + delta * 2.0, 1.0)
		queue_redraw()
		if progress >= 1.0:
			animating = false

func select():
	progress = 0.0
	animating = true

func deselect():
	progress = 0.0
	queue_redraw()
