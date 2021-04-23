extends TileMap

#var is_triggered = false

func collide_with_paint(collision : KinematicCollision2D, collider : KinematicBody2D):
	
#	if !is_triggered:
#		is_triggered = true
	var tile_pos = world_to_map(collider.position)
	tile_pos -= collision.normal
	var tile = get_cellv(tile_pos)
	if tile == 0:
		set_cellv(tile_pos, 1)
		update_bitmask_area(tile_pos)
