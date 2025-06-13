extends MeshInstance3D

@export var parent_script : Script

func _ready() -> void:
	get_parent().set_script(parent_script)
