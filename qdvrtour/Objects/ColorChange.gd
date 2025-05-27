
#Déclaration de la classe qui hérites d'une classe permettant d'être ramassée en VR
@tool
class_name ColorChange
extends XRToolsPickable

#Couleurs extremes que prendra la bille a vitesse maximale et à l'arret
@export var fastColor : Color = Color(1,0,0)
@export var slowColor : Color = Color(0,1,0)
#Reference du mesh de la sphère
@onready var mesh3D : MeshInstance3D = $MeshInstance3D
#Maximum speed expected
@export var maxSpeed : int = 100

func _physics_process(delta: float) -> void:
	var material = mesh3D.mesh.surface_get_material(0)
	var interpval = clamp(linear_velocity.length(), 0, maxSpeed)/maxSpeed
	material.albedo_color = slowColor.lerp(fastColor, interpval)
	
