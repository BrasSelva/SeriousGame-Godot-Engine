extends Control

# On récupère le bouton
@onready var play_button = $PlayButton
# On récupère Youcef qui est DANS le VBoxContainer
@onready var perso_youcef = $VBoxContainer/Node2D 

func _ready():
	# Connexion du bouton
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	
	# Lancement de l'animation
	if perso_youcef:
		var sprite = perso_youcef.get_node("AnimatedSprite2D")
		if sprite:
			sprite.play("idle")
			print("Youcef est animé !")

func _on_play_button_pressed():
	print("Lancement du jeu !")
	# On réinitialise les stats dans le GameManager
	GameManager.human_score = 50
	GameManager.ai_score = 50
	GameManager.time_left = 4
	
	# Changement de scène (vérifie bien le dossier !)
	get_tree().change_scene_to_file("res://Scenes/Core/TestParser.tscn")
