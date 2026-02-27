extends Node

# Chemin vers notre faux fichier de test
const SCENARIO_PATH = "res://Data/scenario_youcef.json"

# Variable qui va contenir tout le JSON une fois décodé
var scenario_data: Dictionary = {}

# On lance le test dès que la scène démarre
func _ready():
	print("--- DÉMARRAGE DU TEST PARSER JSON ---")
	var success = load_scenario_from_file(SCENARIO_PATH)
	
	if success:
		test_affichage_noeud("node_001")


# Fonction principale qui lit le fichier JSON
func load_scenario_from_file(file_path: String) -> bool:
	# 1. Vérifier si le fichier existe
	if not FileAccess.file_exists(file_path):
		print("ERREUR : Le fichier ", file_path, " n'existe pas !")
		return false
		
	# 2. Ouvrir et lire le texte brut
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# 3. Transformer le texte brut en dictionnaire (JSON)
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		scenario_data = json.data
		print("SUCCÈS : Scénario chargé -> ", scenario_data["title"])
		return true
	else:
		print("ERREUR JSON à la ligne ", json.get_error_line(), " : ", json.get_error_message())
		return false


# Fonction pour simuler l'affichage d'un moment de l'histoire
func test_affichage_noeud(node_id: String):
	if not scenario_data.has("nodes") or not scenario_data["nodes"].has(node_id):
		print("Erreur : Le noeud ", node_id, " n'existe pas.")
		return
		
	var current_node = scenario_data["nodes"][node_id]
	
	# Afficher le texte principal (Plus tard, ça ira dans le Label de Lydia)
	print("\n[HISTOIRE] : ", current_node["text"])
	
	# S'il y a des choix, on les affiche (Plus tard, ça ira dans les Boutons)
	var options = current_node["options"]
	if options.size() > 0:
		print("Choix possibles :")
		for i in range(options.size()):
			var opt = options[i]
			print("  ", i + 1, ". ", opt["text"])
			print("     (Impact : Human ", opt["impact_human_core"], " | AI ", opt["impact_ai_synergy"], ") -> Mène vers: ", opt["next_node"])
	else:
		print("--- FIN DU SCÉNARIO ---")
