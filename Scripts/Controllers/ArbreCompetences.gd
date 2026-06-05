extends Control

# --- RÉFÉRENCES ---
@onready var btn_retour = $MainColumn/BtnRetour
@onready var skill_popup = $SkillPopup
@onready var btn_dir_art = $MainColumn/BrainArea/MainLayout/BrainImage/Nodes/BtnDirArt

@onready var choice_a = $SkillPopup/VBoxContainer/ChoiceA
@onready var choice_b = $SkillPopup/VBoxContainer/ChoiceB
@onready var badge_text = $SkillPopup/VBoxContainer/BadgeText

func _ready():
	# Au démarrage, on cache et on bloque
	btn_retour.disabled = true
	skill_popup.hide()
	badge_text.hide()
	
	# --- CONNEXION DES CLICS ---
	btn_dir_art.pressed.connect(_on_btn_dir_art_pressed)
	# On utilise bind() pour envoyer "A" ou "B" à la fonction
	choice_a.pressed.connect(_on_choice_made.bind("A"))
	choice_b.pressed.connect(_on_choice_made.bind("B"))
	btn_retour.pressed.connect(_on_btn_retour_pressed)

func _on_btn_dir_art_pressed():
	skill_popup.show()

# La fonction qui gère le quiz
# La fonction qui gère le quiz
func _on_choice_made(choix: String):
	# 1. DÈS QU'ON CLIQUE, ON BLOQUE TOUT POUR EMPÊCHER DE TRICHER
	choice_a.disabled = true
	choice_b.disabled = true
	
	# 2. ON DÉBLOQUE LE RETOUR (Le joueur doit assumer et repartir)
	btn_retour.disabled = false
	
	# 3. ON VÉRIFIE LA RÉPONSE
	if choix == "B":
		# SUCCÈS
		badge_text.text = "BADGE DÉBLOQUÉ : DIRECTION ARTISTIQUE"
		badge_text.add_theme_color_override("font_color", Color.GREEN)
		badge_text.show()
		
		# On informe le GameManager du succès
		if GameManager:
			GameManager.unlock_skill("dir_art")
		
	elif choix == "A":
		# ÉCHEC CRITIQUE
		badge_text.text = "ÉCHEC : L'approche purement technique ne donne aucune âme."
		badge_text.add_theme_color_override("font_color", Color.RED)
		badge_text.show()
		# On ne débloque pas la compétence ! Le joueur devra faire sans.

func _on_btn_retour_pressed():
	# Retour à la scène d'histoire (Vérifie bien que le chemin est exact !)
	get_tree().change_scene_to_file("res://Scenes/Core/ScenarioParser.tscn")
