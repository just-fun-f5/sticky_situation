extends ToolButton


var text_off = preload("res://assets/art/tileset/AutoBrick/brickTileset.png")
var text_on = preload("res://assets/art/tileset/AutoBrick/brickTilesetslime.png")


func _process(delta):
	if is_hovered():
		$NinePatchRect.texture = text_on
	else:
		$NinePatchRect.texture = text_off
