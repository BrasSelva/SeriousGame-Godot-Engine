extends Control

const SCENARIO_PATH = "res://Data/scenario_youcef.json"
var scenario_data: Dictionary = {}

@onready var story_text = $StoryText
@onready var choices_container = $ChoicesContainer

func _ready():
	# Charge bien le fichier Youcef
	scenario_data = load_scenario_from_file("res://Data/scenario_youcef.json")	# Appel du TOUT PREMIER noeud défini dans ton JSON
	afficher_noeud("start")

func load_scenario_from_file(file_path: String) -> Dictionary:
	print("--- 2. Recherche du fichier à : ", file_path)
	if not FileAccess.file_exists(file_path):
		print("❌ ERREUR : Fichier introuvable !")
		return {} # Renvoie un dictionnaire vide si erreur
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		print("✅ JSON chargé avec succès !")
		return json.data # Renvoie les données du scénario
	else:
		print("❌ ERREUR de lecture JSON")
		return {}

func afficher_noeud(node_id: String):
	for child in choices_container.get_children():
		child.queue_free()
		
	if not scenario_data.has("nodes") or not scenario_data["nodes"].has(node_id):
		story_text.text = "ERREUR DE NOEUD"
		return
		
	var current_node = scenario_data["nodes"][node_id]
	
	# Mise à jour des Labels (SORTIS de la boucle for)
	$HBoxContainer/LabelHumain.text = "Humain: " + str(GameManager.human_score) + "%"
	$HBoxContainer/LabelAI.text = "IA: " + str(GameManager.ai_score) + "%"
	$HBoxContainer/LabelTemps.text = "Temps: " + str(GameManager.time_left) + "h"
	
	# Effet machine à écrire
	story_text.text = current_node["text"]
	story_text.visible_characters = 0
	var tween = create_tween()
	var vitesse = 0.03
	var temps_total = current_node["text"].length() * vitesse
	tween.tween_property(story_text, "visible_characters", current_node["text"].length(), temps_total)
	
	var options = current_node["options"]
	
	if options.size() == 0:
		await get_tree().create_timer(2.0).timeout # On laisse le temps de lire le texte final
		get_tree().change_scene_to_file("res://Scenes/Core/Bilan.tscn")
		return
		
	for opt in options:
		var btn = Button.new()
		var text_bouton = opt["text"]
		
		# Vérification de condition
		var est_bloque = false
		if opt.has("condition_skill"):
			if not GameManager.has_skill(opt["condition_skill"]):
				est_bloque = true
				text_bouton = "[BLOQUÉ] " + text_bouton
		
		btn.text = text_bouton
		btn.custom_minimum_size = Vector2(0, 50)
		
		if est_bloque:
			btn.disabled = true # On le voit mais on ne peut pas cliquer
		else:
			btn.pressed.connect(_on_choice_made.bind(opt))
			
		choices_container.add_child(btn)

func _on_choice_made(opt: Dictionary):

	# On récupère les valeurs du JSON ou 0 si elles n'existent pas
	var h_impact = opt.get("impact_human_core", 0)
	var ai_impact = opt.get("impact_ai_synergy", 0)
	var q_impact = opt.get("impact_quality", 0)
	var t_spent = opt.get("time_cost", 0)
	
	# On met à jour le GameManager (On va créer cette fonction juste après)
	GameManager.update_youcef_stats(h_impact, ai_impact, q_impact, t_spent)
	
	if opt.has("unlock_skill"):
		GameManager.unlock_skill(opt["unlock_skill"])
	# On passe à la suite
	afficher_noeud(opt["next_node"])
