extends Control

@onready var skill_popup = $SkillPopup
@onready var btn_retour = $BtnRetour

func _ready():
	skill_popup.hide() # On cache la boîte au début
	
	# Si on a déjà la compétence, on peut changer l'apparence du bouton
	if GameManager.has_skill("dir_art"):
		$MainLayout/RightHuman/Nodes/BtnDirArt.modulate = Color.GREEN

# Quand on clique sur le bouton "Direction Artistique" dans le cerveau
func _on_btn_dir_art_pressed():
	skill_popup.show()

# Quand on choisit la bonne réponse (Réponse B)
func _on_choice_b_pressed():
	$SkillPopup/VBox/BadgeText.text = "BADGE DÉBLOQUÉ !"
	$SkillPopup/VBox/BadgeText.show()
	
	# On enregistre la compétence dans le GameManager
	GameManager.unlock_skill("dir_art")
	
	# On attend un peu et on ferme
	await get_tree().create_timer(1.5).timeout
	skill_popup.hide()

# Retour à la scène de jeu
func _on_btn_retour_pressed():
	get_tree().change_scene_to_file("res://Scenes/Core/TestParser.tscn")
