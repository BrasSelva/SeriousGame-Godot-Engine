extends Control

# --- RÉFÉRENCES AUX NŒUDS ---
# Chemins exacts basés sur ton arbre de scène
@onready var texte_humain = $ColorRect/PanelContainer/VBoxContainer/TexteHumain
@onready var barre_humain = $ColorRect/PanelContainer/VBoxContainer/BarreHumain

@onready var texte_ia = $ColorRect/PanelContainer/VBoxContainer/TexteIA
@onready var barre_ia = $ColorRect/PanelContainer/VBoxContainer/BarreIA

@onready var texte_qualite = $ColorRect/PanelContainer/VBoxContainer/TexteQualite
@onready var texte_temps = $ColorRect/PanelContainer/VBoxContainer/TexteTemps

@onready var send_button = $ColorRect/PanelContainer/VBoxContainer/SendButton

func _ready():
	# 1. MISE À JOUR DE L'INTERFACE VISUELLE
	# On récupère les valeurs stockées dans le GameManager et on les affiche à l'écran
	texte_humain.text = "Score Humain : " + str(GameManager.human_score)
	barre_humain.value = GameManager.human_score
	
	texte_ia.text = "Score IA : " + str(GameManager.ai_score)
	barre_ia.value = GameManager.ai_score
	
	texte_qualite.text = "Qualité : " + str(GameManager.quality_score)
	texte_temps.text = "Temps : " + str(GameManager.time_left) + "h"

	# 2. CONNEXION DU BOUTON D'ENVOI
	if not send_button.pressed.is_connected(_on_send_button_pressed):
		send_button.pressed.connect(_on_send_button_pressed)

# 3. ENVOI DES DONNÉES VERS SUPABASE
func _on_send_button_pressed():
	# On bloque le bouton pour éviter les clics multiples pendant le chargement
	send_button.disabled = true
	send_button.text = "Envoi en cours..."
	
	# On prépare le paquet de données avec les scores finaux
	var scores_finaux = {
		"human": GameManager.human_score,
		"ai": GameManager.ai_score,
		"quality": GameManager.quality_score,
		"time": GameManager.time_left
	}
	
	var user_id = GameManager.current_user_id
	var scenario_id = "a7700388-f339-4637-8127-63c1a95d7ac8"
	
	# On lance la requête réseau
	if user_id != "":
		Network.send_score_to_db(user_id, scenario_id, scores_finaux)
	else:
		send_button.text = "Erreur : Non connecté"
