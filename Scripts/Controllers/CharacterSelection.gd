extends Control

@onready var play_button = $PlayButton # Vérifie bien le nom du bouton dans ton arbre

func _ready():
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	print("Lancement du jeu !")
	# On réinitialise tout dans le GameManager avant de commencer
	GameManager.human_score = 50
	GameManager.ai_score = 50
	GameManager.quality_score = 50
	GameManager.time_left = 4
	GameManager.unlocked_skills.clear() # On vide les compétences pour une nouvelle partie
	
	# ICI : On lance le moteur de jeu (StoryParser ou TestParser)
	get_tree().change_scene_to_file("res://Scenes/Core/TestParser.tscn")
