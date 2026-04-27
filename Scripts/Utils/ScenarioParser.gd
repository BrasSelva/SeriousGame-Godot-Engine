extends Control

const SCENARIO_PATH = "res://Data/scenario_youcef.json"
var scenario_data: Dictionary = {}

@onready var story_text = $StoryText
@onready var choices_container = $ChoicesContainer

func _ready():
	print("--- 1. LE SCRIPT DÉMARRE BIEN ! ---")
	story_text.text = "Chargement en cours..."
	
	if load_scenario_from_file(SCENARIO_PATH):
		print("--- 4. JSON CHARGÉ AVEC SUCCÈS ---")
		afficher_noeud("node_001")
	else:
		print("--- ERREUR CRITIQUE AU CHARGEMENT ---")

func load_scenario_from_file(file_path: String) -> bool:
	print("--- 2. Recherche du fichier à : ", file_path)
	if not FileAccess.file_exists(file_path):
		print("❌ ERREUR : Fichier introuvable !")
		story_text.text = "ERREUR : Fichier introuvable à " + file_path
		return false
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	print("--- 3. Fichier trouvé. Tentative de lecture du JSON... ---")
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		scenario_data = json.data
		return true
	else:
		print("❌ ERREUR JSON : ", json.get_error_message(), " à la ligne ", json.get_error_line())
		story_text.text = "ERREUR DANS LE TEXTE DU FICHIER JSON (voir console)"
		return false

func afficher_noeud(node_id: String):
	print("--- 5. Affichage du noeud : ", node_id, " ---")
	for child in choices_container.get_children():
		child.queue_free()
		
	if not scenario_data.has("nodes") or not scenario_data["nodes"].has(node_id):
		story_text.text = "ERREUR DE NOEUD"
		return
		
	var current_node = scenario_data["nodes"][node_id]
	story_text.text = current_node["text"]
	var options = current_node["options"]
	
	if options.size() == 0:
		print("--- FIN DE L'HISTOIRE ---")
		get_tree().change_scene_to_file("res://Scenes/Core/Bilan.tscn")
		return
	
	for opt in options:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.custom_minimum_size = Vector2(0, 50) 
		btn.pressed.connect(_on_choice_made.bind(opt))
		choices_container.add_child(btn)

func _on_choice_made(opt: Dictionary):
	GameManager.update_scores(opt["impact_human_core"], opt["impact_ai_synergy"])
	afficher_noeud(opt["next_node"])
