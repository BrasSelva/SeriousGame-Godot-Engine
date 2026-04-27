extends Control

# On va chercher notre bouton Jouer
@onready var play_button = $PlayButton

func _ready():
	# On écoute le clic sur le bouton
	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	print("Lancement du jeu !")
	# On réinitialise les scores du GameManager au cas où on rejoue
	GameManager.human_core_score = 50
	GameManager.ai_synergy_score = 50
	
	# On ferme le menu et on ouvre la scène de l'histoire
	get_tree().change_scene_to_file("res://Scenes/Core/TestParser.tscn")
