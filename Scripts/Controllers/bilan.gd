extends Control

# On fait le lien avec le Label de ton interface
@onready var label_affichage = $LabelBilan 

func _ready():
	# On affiche les scores
	label_affichage.text = "Scores : " + str(GameManager.human_score) # etc...
	
	# FORCE la connexion du bouton par le code
	# Remplace $SendButton par le nom exact de ton bouton dans la scène
	$SendButton.pressed.connect(_on_send_scores_pressed)

	var texte = "--- BILAN DE LA MISSION ---\n\n"
	texte += "Score Humain : " + str(GameManager.human_score) + "%\n"
	texte += "Score IA : " + str(GameManager.ai_score) + "%\n"
	texte += "Qualité : " + str(GameManager.quality_score) + "%\n"
	texte += "Temps utilisé : " + str(4 - GameManager.time_left) + "h"
	
	label_affichage.text = texte

func _on_send_scores_pressed():
	print("--- LE BOUTON A ÉTÉ CLIQUÉ ! ---") # Ajoute cette ligne
	var scores_pour_supabase = {
		"human": GameManager.human_score,
		"ai": GameManager.ai_score
	}
	Network.send_score_to_db("joueur_youcef_test", scores_pour_supabase)
