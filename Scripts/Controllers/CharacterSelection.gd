extends Control

@onready var play_button = $PlayButton
@onready var artiste_button = $ArtisteName
@onready var ingenieur_button = $IngenieurName
@onready var consultant_button = $ConsultantName
@onready var perso_youcef = $VBoxContainer/HBoxContainer/Node2D
@onready var perso_ingenieur = $VBoxContainer/HBoxContainer/Node2D_Ingenieur
@onready var perso_consultant = $VBoxContainer/HBoxContainer/Node2D_Consultant

func _ready():
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
		play_button.disabled = true

	if artiste_button:
		artiste_button.pressed.connect(_on_artiste_button_pressed)

	if ingenieur_button:
		ingenieur_button.pressed.connect(_on_ingenieur_button_pressed)

	if consultant_button:
		consultant_button.pressed.connect(_on_consultant_button_pressed)

	# Animation idle Artiste
	if perso_youcef and perso_youcef.has_node("AnimatedSprite2D"):
		perso_youcef.get_node("AnimatedSprite2D").play("idle")
		print("Artiste est animé !")

	# Animation idle Ingénieur
	if perso_ingenieur and perso_ingenieur.has_node("AnimatedSprite2D"):
		perso_ingenieur.get_node("AnimatedSprite2D").play("idle")
		print("Ingénieur est animé !")

	# Animation idle Consultant
	if perso_consultant and perso_consultant.has_node("AnimatedSprite2D"):
		perso_consultant.get_node("AnimatedSprite2D").play("idle")
		print("Consultant est animé !")

func _deselect_all():
	if perso_youcef and perso_youcef.has_method("deselect"):
		perso_youcef.deselect()
	if perso_ingenieur and perso_ingenieur.has_method("deselect"):
		perso_ingenieur.deselect()
	if perso_consultant and perso_consultant.has_method("deselect"):
		perso_consultant.deselect()

func _on_artiste_button_pressed():
	print("Personnage Artiste sélectionné !")
	GameManager.current_persona = "artiste"
	GameManager.current_mission = 1
	play_button.disabled = false
	_deselect_all()
	if perso_youcef and perso_youcef.has_method("select"):
		perso_youcef.select()
	else:
		print("❌ ALERTE : Le script du cercle n'est pas attaché à l'Artiste !")

func _on_ingenieur_button_pressed():
	print("Personnage Ingénieur sélectionné !")
	GameManager.current_persona = "ingenieur"
	GameManager.current_mission = 1
	play_button.disabled = false
	_deselect_all()
	if perso_ingenieur and perso_ingenieur.has_method("select"):
		perso_ingenieur.select()
	else:
		print("❌ ALERTE : Le script du cercle n'est pas attaché à l'Ingénieur !")

func _on_consultant_button_pressed():
	print("Personnage Consultant sélectionné !")
	GameManager.current_persona = "consultant"
	GameManager.current_mission = 1
	play_button.disabled = false
	_deselect_all()
	if perso_consultant and perso_consultant.has_method("select"):
		perso_consultant.select()
	else:
		print("❌ ALERTE : Le script du cercle n'est pas attaché au Consultant !")

func _on_play_button_pressed():
	if GameManager.current_persona == "":
		print("❌ Aucun personnage sélectionné !")
		return
	print("Lancement du jeu ! Persona : ", GameManager.current_persona)
	GameManager.human_score = 50
	GameManager.ai_score = 50
	GameManager.time_left = 4
	get_tree().change_scene_to_file("res://Scenes/Core/ScenarioParser.tscn")
