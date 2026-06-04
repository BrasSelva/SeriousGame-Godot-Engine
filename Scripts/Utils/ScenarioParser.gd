extends Control

var scenario_data: Dictionary = {}

# Références vers les nœuds de ton interface
@onready var mission_title = $TopTitles/MissionTitle
@onready var story_text = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/StoryText
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
	# 1. On cible la boîte rouge pour pouvoir la cacher/afficher
	var cadre_rouge = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/BorderIllustration
	# 2. On cible l'image à l'intérieur pour changer la photo
	var illustration = cadre_rouge.get_node("Illustration")
	
	if node_id == "start":
		mission_title.text = current_node["text"]
		story_text.text = "Le Directeur Artistique du Blue Moon Club vous confie la création de l'affiche officielle du festival. Il exige un visuel capturant la mélancolie futuriste des nuits de 2035."
		# On cache TOUTE la boîte rouge
		if cadre_rouge:
			cadre_rouge.hide()
			
	elif node_id == "fin_echec_ia":
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.RED)
		if illustration:
			illustration.texture = load("res://_Assets/Images/saxophone.png") # Ajuste si besoin
		# On affiche TOUTE la boîte rouge avec l'image dedans
		if cadre_rouge:
			cadre_rouge.show()
			
	else:
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.WHITE)
		# On cache TOUTE la boîte rouge pour les autres moments de l'histoire
		if cadre_rouge:
			cadre_rouge.hide()

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
	
# Ton design "Cyber" normal
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#2D3773", 0.8) # Fond sombre translucide
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color("#6871E8") # Bordure
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	
	# ---> LA MAGIE POUR LE SURVOL (HOVER) <---
	# 1. On clone le style (ça copie les bordures et les coins ronds automatiquement !)
	var style_hover = style.duplicate()
	
	# 2. On modifie juste la couleur de fond et la bordure du clone pour qu'il s'illumine
	style_hover.bg_color = Color("#3A4694", 0.95) # Un bleu un peu plus clair et opaque
	style_hover.border_color = Color("#8D95FF") # Une bordure encore plus lumineuse
	
	# ---> APPLICATION DES STYLES AU BOUTON <---
	if est_bloque:
		style.border_color = Color("#FF0000") # Bordure rouge si bloqué
		btn.disabled = true
	else:
		btn.pressed.connect(_on_choice_made.bind(opt))
		
	# On dit à Godot d'utiliser nos styles au lieu du gris par défaut
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style_hover) # Quand la souris est dessus
	btn.add_theme_stylebox_override("pressed", style_hover) # Quand on clique dessus
	
	# Astuce de pro : on enlève aussi la bordure de "focus" (le cadre gris qui reste après avoir cliqué)
	btn.add_theme_stylebox_override("focus", style) 
	
	choices_container.add_child(btn)

func _on_choice_made(opt: Dictionary):
	# Récupération des impacts sur les statistiques
	var h_impact = opt.get("impact_human_core", 0)
	var ai_impact = opt.get("impact_ai_synergy", 0)
	var q_impact = opt.get("impact_quality", 0)
	var t_spent = opt.get("time_cost", 0)
	
	# Mise à jour globale dans le GameManager
	GameManager.update_youcef_stats(h_impact, ai_impact, q_impact, t_spent)
	
	# Déblocage de compétence si mentionné (au cas où on le fait via le texte)
	if opt.has("unlock_skill"):
		GameManager.unlock_skill(opt["unlock_skill"])
		
	# ---> LE PORTAIL VERS TON INTERFACE VISUELLE <---
	# On cherche le mot "aller_vers_arbre" défini dans le JSON
	if opt.has("next_node") and opt["next_node"] == "aller_vers_arbre":
		get_tree().change_scene_to_file("res://Scenes/Core/ArbreCompetence.tscn")
		return # On stoppe la fonction ici pour changer d'écran !
		
	# Transition vers le nœud suivant classique (si ce n'est pas l'arbre)
	afficher_noeud(opt["next_node"])
