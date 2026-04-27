extends Control

# Le symbole $ permet au script d'aller chercher les noeuds que tu as créés
@onready var score_label = $ScoreLabel
@onready var send_button = $SendButton

func _ready():
	# 1. On prépare le texte à afficher en allant chercher les valeurs dans le GameManager
	var texte_bilan = "--- BILAN DE LA SIMULATION ---\n\n"
	texte_bilan += "Score Human Core : " + str(GameManager.human_core_score) + "%\n"
	texte_bilan += "Score Synergie IA : " + str(GameManager.ai_synergy_score) + "%\n"
	
	# 2. On injecte ce texte dans notre Label pour qu'il apparaisse à l'écran
	score_label.text = texte_bilan
	
	# 3. On "écoute" le bouton : si on clique dessus, ça lance la fonction en bas
	send_button.pressed.connect(_on_send_button_pressed)

# --- FONCTION DÉCLENCHÉE PAR LE CLIC SUR LE BOUTON ---
func _on_send_button_pressed():
	# On désactive le bouton pour que le joueur ne clique pas 50 fois dessus
	send_button.disabled = true
	send_button.text = "Envoi en cours..."
	
	# On prépare la petite "boîte" de données (Dictionnaire) pour Supabase
	var dict_scores = {
		"human": GameManager.human_core_score,
		"ai": GameManager.ai_synergy_score
	}
	
	# On appelle le script Network pour envoyer tout ça
	var faux_user_id = "joueur_test_123" # Plus tard, ça sera le vrai nom du joueur
	Network.send_score_to_db(faux_user_id, dict_scores)
