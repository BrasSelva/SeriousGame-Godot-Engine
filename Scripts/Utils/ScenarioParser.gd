extends Control

var scenario_data: Dictionary = {}

# Références vers les nœuds de ton interface
@onready var mission_title = $MainLayout/CenterPanel_Story/MissionTitle
@onready var story_text = $MainLayout/CenterPanel_Story/StoryBox/StoryText
@onready var choices_container = $MainLayout/CenterPanel_Story/ChoicesContainer
@onready var label_temps = $MainLayout/RightPanel_Stats/TimeBox/VBoxContainer/LabelTemps

@onready var perso_youcef = $MainLayout/LeftPanel_Perso/Node2D

var ecriture_tween: Tween

func _ready():
	# ---> NOUVEAU : Lance l'animation de Youcef au démarrage <---
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
	var illustration = $MainLayout/CenterPanel_Story/StoryBox/Illustration
	
	if node_id == "start":
		mission_title.text = current_node["text"]
		story_text.text = "Le Directeur Artistique du Blue Moon Club vous confie la création de l'affiche officielle du festival. Il exige un visuel capturant la mélancolie futuriste des nuits de 2035."
		if illustration:
			illustration.hide()
	elif node_id == "fin_echec_ia":
		story_text.text = current_node["text"]
		if illustration:
			illustration.texture = load("res://_Assets/Images/saxophone.jpg") # Ajuste si ton dossier s'appelle autrement !
			illustration.show()
	else:
		story_text.text = current_node["text"]
		if illustration:
			illustration.hide()

	# --- EFFET MACHINE À ÉCRIRE SÉCURISÉ ---
	# Si un effet d'écriture tournait déjà, on l'arrête proprement
	if ecriture_tween and ecriture_tween.is_running():
		ecriture_tween.kill()
		
	story_text.visible_characters = 0
	ecriture_tween = create_tween()
	var vitesse = 0.02
	var temps_ecriture = story_text.text.length() * vitesse
	ecriture_tween.tween_property(story_text, "visible_characters", story_text.text.length(), temps_ecriture)
	# ----------------------------------------
	
	var options = current_node["options"]
	
	# Si aucun choix (fin du scénario), on attend et on change de scène
	if options.size() == 0:
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Core/Bilan.tscn")
		return
		
	# Génération des boutons pour chaque option disponible
	for opt in options:
		creer_bouton_choix(opt)

func creer_bouton_choix(opt: Dictionary):
	var btn = Button.new()
	var text_bouton = opt["text"]
	var est_bloque = false
	
	# Vérification de la compétence requise
	if opt.has("condition_skill"):
		if not GameManager.has_skill(opt["condition_skill"]):
			est_bloque = true
			text_bouton = "[BLOQUÉ] " + text_bouton
	
	btn.text = text_bouton
	btn.custom_minimum_size = Vector2(0, 60) # Hauteur confortable pour le clic
	
	# Design "Cyber" dynamique des boutons par code
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0A1020CC") # Fond sombre translucide
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color("#00FFFF") # Bordure Cyan
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	
	if est_bloque:
		style.border_color = Color("#FF0000") # Bordure rouge si bloqué
		btn.disabled = true
	else:
		btn.pressed.connect(_on_choice_made.bind(opt))
		
	btn.add_theme_stylebox_override("normal", style)
	choices_container.add_child(btn)

func _on_choice_made(opt: Dictionary):
	# Récupération des impacts sur les statistiques
	var h_impact = opt.get("impact_human_core", 0)
	var ai_impact = opt.get("impact_ai_synergy", 0)
	var q_impact = opt.get("impact_quality", 0)
	var t_spent = opt.get("time_cost", 0)
	
	# Mise à jour globale dans le GameManager
	GameManager.update_youcef_stats(h_impact, ai_impact, q_impact, t_spent)
	
	# Déblocage de compétence si mentionné
	if opt.has("unlock_skill"):
		GameManager.unlock_skill(opt["unlock_skill"])
		
	# Transition vers le nœud suivant
	afficher_noeud(opt["next_node"])
