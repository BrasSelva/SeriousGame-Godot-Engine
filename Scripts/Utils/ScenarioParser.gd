extends Control

var scenario_data: Dictionary = {}

# --- [NOUVEAU] VARIABLES DE TRACKING ---
var current_node_id: String = ""
var step_counter: int = 0
var current_scenario_id: String = "a7700388-f339-4637-8127-63c1a95d7ac8" # Ton ID de mission
# ---------------------------------------

# Références vers les nœuds de ton interface
@onready var mission_title = $TopTitles/MissionTitle
@onready var story_text = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/StoryText
@onready var choices_container = $MainLayout/CenterPanel_Story/ChoicesContainer
@onready var label_temps = $MainLayout/RightPanel_Stats/TimeBox/VBoxContainer/LabelTemps

@onready var perso_youcef = $MainLayout/LeftPanel_Perso/Node2D

var ecriture_tween: Tween

func _ready():
	# Lance l'animation de Youcef au démarrage
	if perso_youcef and perso_youcef.has_node("AnimatedSprite2D"):
		perso_youcef.get_node("AnimatedSprite2D").play("idle")
		print("Youcef est animé dans la scène principale !")
		
	# Charge le fichier JSON de Youcef
	scenario_data = load_scenario_from_file("res://Data/scenario_youcef.json")
	# Lance le premier nœud du scénario
	afficher_noeud("start")

func load_scenario_from_file(file_path: String) -> Dictionary:
	print("--- Recherche du fichier à : ", file_path)
	if not FileAccess.file_exists(file_path):
		print("❌ ERREUR : Fichier scénario introuvable !")
		return {}
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		print("✅ JSON chargé avec succès !")
		return json.data
	else:
		print("❌ ERREUR de lecture JSON")
		return {}

func afficher_noeud(node_id: String):
	# --- [NOUVEAU] On mémorise le nœud actuel pour le tracking ---
	current_node_id = node_id
	# --------------------------------------------------------------
	
	# On nettoie les anciens boutons d'options
	for child in choices_container.get_children():
		child.queue_free()
		
	# Vérification de sécurité sur l'existence du nœud
	if not scenario_data.has("nodes") or not scenario_data["nodes"].has(node_id):
		story_text.text = "❌ ERREUR : Le nœud '" + node_id + "' est introuvable."
		return
		
	var current_node = scenario_data["nodes"][node_id]
	label_temps.text = str(GameManager.time_left) + "H"

	# Gestion des affichages spécifiques aux nœuds et des images
	var cadre_rouge = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/BorderIllustration
	var illustration = cadre_rouge.get_node("Illustration")
	
	if node_id == "start":
		mission_title.text = current_node["text"]
		story_text.text = "Le Directeur Artistique du Blue Moon Club vous confie la création de l'affiche officielle du festival. Il exige un visuel capturant la mélancolie futuriste des nuits de 2035."
		if cadre_rouge:
			cadre_rouge.hide()
			
	elif node_id == "fin_echec_ia":
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.RED)
		if illustration:
			illustration.texture = load("res://_Assets/Images/saxophone.png")
		if cadre_rouge:
			cadre_rouge.show()
			
	else:
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.WHITE)
		if cadre_rouge:
			cadre_rouge.hide()

	# --- EFFET MACHINE À ÉCRIRE SÉCURISÉ ---
	if ecriture_tween and ecriture_tween.is_running():
		ecriture_tween.kill()
		
	story_text.visible_characters = 0
	ecriture_tween = create_tween()
	var vitesse = 0.02
	var temps_ecriture = story_text.text.length() * vitesse
	ecriture_tween.tween_property(story_text, "visible_characters", story_text.text.length(), temps_ecriture)
	# ----------------------------------------
	
	var options = current_node["options"]
	
	if options.size() == 0:
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Core/Bilan.tscn")
		return
		
	for opt in options:
		creer_bouton_choix(opt)

func creer_bouton_choix(opt: Dictionary):
	var btn = Button.new()
	var text_bouton = opt["text"]
	var est_bloque = false
	
	if opt.has("condition_skill"):
		if not GameManager.has_skill(opt["condition_skill"]):
			est_bloque = true
			text_bouton = "[BLOQUÉ] " + text_bouton
	
	btn.text = text_bouton
	btn.custom_minimum_size = Vector2(0, 60) 
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#2D3773", 0.8) 
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color("#6871E8") 
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	
	var style_hover = style.duplicate()
	style_hover.bg_color = Color("#3A4694", 0.95) 
	style_hover.border_color = Color("#8D95FF") 
	
	if est_bloque:
		style.border_color = Color("#FF0000") 
		btn.disabled = true
	else:
		btn.pressed.connect(_on_choice_made.bind(opt))
		
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style_hover) 
	btn.add_theme_stylebox_override("pressed", style_hover) 
	btn.add_theme_stylebox_override("focus", style) 
	
	choices_container.add_child(btn)

func _on_choice_made(opt: Dictionary):
	# --- [NOUVEAU] ENVOI DU TRACKING A SUPABASE ---
	step_counter += 1
	var user_id = GameManager.current_user_id
	var nom_du_choix = opt["text"] # On utilise le texte du bouton comme ID de l'option
	
	if user_id != "":
		Network.send_choice_to_db(current_scenario_id, current_node_id, nom_du_choix, step_counter, user_id)
	# ----------------------------------------------
	
	var h_impact = opt.get("impact_human_core", 0)
	var ai_impact = opt.get("impact_ai_synergy", 0)
	var q_impact = opt.get("impact_quality", 0)
	var t_spent = opt.get("time_cost", 0)
	
	GameManager.update_youcef_stats(h_impact, ai_impact, q_impact, t_spent)
	
	if opt.has("unlock_skill"):
		GameManager.unlock_skill(opt["unlock_skill"])
		
	if opt.has("next_node") and opt["next_node"] == "aller_vers_arbre":
		get_tree().change_scene_to_file("res://Scenes/Core/ArbreCompetence.tscn")
		return 
		
	afficher_noeud(opt["next_node"])
