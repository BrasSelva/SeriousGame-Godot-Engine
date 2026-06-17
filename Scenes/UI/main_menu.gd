extends Control

# On récupère le bouton à son nouvel emplacement
# Le $ indique le chemin depuis la racine (MainMenu)
@onready var start_button = $Content/StartButton

func _ready():
	# Sécurité : on vérifie que le bouton existe
	if start_button:
		# On écoute le clic sur le bouton
		start_button.pressed.connect(_on_btn_jouer_pressed)
		print("Menu Principal prêt !")

func _on_btn_jouer_pressed():
	# L'astuce : glisse-dépose ton fichier Login.tscn directement entre les guillemets
	# depuis ton panneau "Système de fichiers" à gauche pour éviter toute erreur de frappe !
	get_tree().change_scene_to_file("res://Scenes/Core/Login.tscn")
