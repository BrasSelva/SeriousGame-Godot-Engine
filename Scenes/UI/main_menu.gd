extends Control

# On récupère le bouton à son nouvel emplacement
# Le $ indique le chemin depuis la racine (MainMenu)
@onready var start_button = $Content/StartButton

func _ready():
	# Sécurité : on vérifie que le bouton existe
	if start_button:
		# On écoute le clic sur le bouton
		start_button.pressed.connect(_on_start_button_pressed)
		print("Menu Principal prêt !")

func _on_start_button_pressed():
	print("Lancement de l'expérience...")
	# On réinitialise les scores du GameManager au cas où on rejoue
	# C'est une bonne pratique de Tech Lead
	GameManager.human_score = 50
	GameManager.ai_score = 50
	GameManager.time_left = 4 
	
	# Lancement du jeu vers la scène de l'histoire !
	# ATTENTION : vérifie bien que ce chemin est le bon dans tes dossiers
	get_tree().change_scene_to_file("res://Scenes/Core/CharacterSelection.tscn")
