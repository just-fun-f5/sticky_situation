tool
extends TileSet

#const brick = 0
#const slime_brick = 1
#
#var binds = {
#	brick : [slime_brick],
#	slime_brick : [brick]
#}
#
#func _is_tile_bound(drawn_id, neighbor_id):
#	if drawn_id in binds:
#		return neighbor_id in binds[drawn_id]
#	return false
#
func _is_tile_bound(drawn_is, neighbor_id):
	return neighbor_id in get_tiles_ids()
