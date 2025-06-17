
#Déclaration de la classe qui hérites d'une classe permettant d'être ramassée en VR
@tool
class_name ColorChange
extends XRToolsPickable

#Couleurs extremes que prendra la bille a vitesse maximale et à l'arret



#Reference du mesh de la sphère
@onready var mesh3D : MeshInstance3D = $MeshInstance3D
#Maximum speed expected
@export var maxSpeed : int = 1

func _physics_process(_delta: float) -> void:
	#On récupère le matériau de la sphère
	var material = mesh3D.mesh.surface_get_material(0)
	#On va calculer la valeur utilisée dans l'interpolation à l'aide de la vitesse de la balle
	var interp_value = clamp(linear_velocity.length(), 0, maxSpeed)/maxSpeed
	#on change la couleur du materiau par l'interpolation entre les deux couleurs
	material.albedo_color = color_lerp(Color(0,1,0),Color(1,0,0), interp_value)




func color_lerp(color1 : Color, color2 : Color, interp : float) -> Color :
	var new_color = Vector3(color1.h, color1.s, color1.v).lerp(Vector3(color2.h, color2.s, color2.v), interp)
	return Color.from_hsv(new_color.x, new_color.y, new_color.z)
