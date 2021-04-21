extends TileMap

var is_triggered = false

func collide_with_paint(collision : KinematicCollision2D, collider : KinematicBody2D):
	if !is_triggered:
		is_triggered = true
