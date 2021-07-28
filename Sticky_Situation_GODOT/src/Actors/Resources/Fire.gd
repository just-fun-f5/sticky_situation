extends Area2D

export (Resource) var element


func _on_StaticBody2D_body_entered(body):
	if body.is_in_group("Slime"):
		body._absorb(element)
		call_deferred("queue_free")
		

