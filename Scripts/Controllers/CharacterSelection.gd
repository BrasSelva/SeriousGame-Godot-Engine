extends Control

# Les chemins sont corrigés et mis à jour !
@onready var play_button = $PlayButton
@onready var artiste_button = $ArtisteName
@onready var perso_youcef = $VBoxContainer/Node2D

func _ready():
	# Connexion du bouton Play
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
		
	# Connexion du bouton Artiste
	if artiste_button:
		artiste_button.pressed.connect(_on_artiste_button_pressed)
	
	# Lancement de l'animation Idle au démarrage
	if perso_youcef and perso_youcef.has_node("AnimatedSprite2D"):
		perso_youcef.get_node("AnimatedSprite2D").play("idle")
		print("Youcef est animé !")

func _on_artiste_button_pressed():
	print("Personnage Artiste sélectionné !") 
	
	# On lance l'animation du cercle dessiné
	if perso_youcef and perso_youcef.has_method("select"):
		perso_youcef.select()
	else:
		print("❌ ALERTE : Le script du cercle n'est pas attaché à Youcef !")

func _on_play_button_pressed():
	print("Lancement du jeu !")
	GameManager.human_score = 50
	GameManager.ai_score = 50
	GameManager.time_left = 4
	get_tree().change_scene_to_file("res://Scenes/Core/ScenarioParser.tscn")
