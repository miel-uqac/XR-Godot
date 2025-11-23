extends XROrigin3D

var xr_interface : OpenXRInterface
var left_controller : XRController3D
var right_controller : XRController3D
var recenter_button_pressed : bool = false

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("Quest 3 connecté")
	
	# Récupérez vos contrôleurs (ajustez les chemins selon votre scène)
	left_controller = $LeftController  # ou le bon chemin
	right_controller = $RightController
	
	# Connectez les signaux des boutons comme dans le pickup
	if left_controller:
		left_controller.button_pressed.connect(_on_button_pressed)
	if right_controller:
		right_controller.button_pressed.connect(_on_button_pressed)

func _on_button_pressed(button_name: String) -> void:
	print("Bouton pressé: ", button_name)
	
	# Utilisez ax_button (bouton X sur gauche, A sur droit)
	# ou by_button (bouton Y sur gauche, B sur droit)
	if button_name == "by_button":  # Bouton Y ou B
		recenter_view()

func recenter_view():
	if xr_interface:
		XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)
		print("Vue recentrée !")
