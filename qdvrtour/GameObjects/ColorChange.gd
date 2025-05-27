
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
@export var maxSpeed : int = 1

func _physics_process(delta: float) -> void:
	#On récupère le matériau de la sphère
	var material = mesh3D.mesh.surface_get_material(0)
	#On va calculer la valeur utilisée dans l'interpolation à l'aide de la vitesse de la balle
	var interp_value = clamp(linear_velocity.length(), 0, maxSpeed)/maxSpeed
	#on change la couleur du materiau par l'interpolation entre les deux couleurs
	material.albedo_color = slowColor.lerp(fastColor, interp_value)
	
