extends Control

@onready var texte_humain = $ColorRect/PanelContainer/VBoxContainer/TexteHumain
@onready var barre_humain = $ColorRect/PanelContainer/VBoxContainer/BarreHumain
@onready var texte_ia = $ColorRect/PanelContainer/VBoxContainer/TexteIA
@onready var barre_ia = $ColorRect/PanelContainer/VBoxContainer/BarreIA
@onready var texte_qualite = $ColorRect/PanelContainer/VBoxContainer/TexteQualite
@onready var texte_temps = $ColorRect/PanelContainer/VBoxContainer/TexteTemps
@onready var btn_envoyer = $ColorRect/PanelContainer/VBoxContainer/SendButton

func _ready():
	texte_humain.text = "Symbiose Humaine : " + str(GameManager.human_score) + "%"
	texte_ia.text = "Efficacité IA : " + str(GameManager.ai_score) + "%"
	texte_qualite.text = "Qualité finale de l'œuvre : " + str(GameManager.quality_score) + "%"
	
	var temps_utilise = 4 - GameManager.time_left
	texte_temps.text = "Temps de production utilisé : " + str(temps_utilise) + "h"
	
	barre_humain.value = 0
	barre_ia.value = 0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(barre_humain, "value", float(GameManager.human_score), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(barre_ia, "value", float(GameManager.ai_score), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	btn_envoyer.pressed.connect(_on_btn_envoyer_pressed)

func _on_btn_envoyer_pressed():
	# --- 1. ENVOI AU RÉSEAU ---
	var scores_finaux = {
		"human": GameManager.human_score,
		"ai": GameManager.ai_score,
		"quality": GameManager.quality_score,
		"time": GameManager.time_left
	}
	var user_id = GameManager.current_user_id
	var vrai_scenario_id = GameManager.scenarios_uuids.get(GameManager.current_mission, "")
	
	if user_id != "" and vrai_scenario_id != "":
		Network.send_score_to_db(user_id, vrai_scenario_id, scores_finaux)
	# --------------------------
	
	# --- 2. SUITE DU JEU ---
	if GameManager.current_mission < GameManager.max_missions:
		GameManager.next_mission()
		get_tree().change_scene_to_file("res://Scenes/Core/ScenarioParser.tscn")
	else:
		print("Toutes les missions terminées !")
		get_tree().quit()
