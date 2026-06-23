extends Control

var scenario_data: Dictionary = {}

var current_node_id: String = ""
var step_counter: int = 0

@onready var mission_title = $TopTitles/MissionTitle
@onready var story_text = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/StoryText
@onready var choices_container = $MainLayout/CenterPanel_Story/ChoicesContainer
@onready var label_temps = $MainLayout/RightPanel_Stats/TimeBox/VBoxContainer/LabelTemps

# Personnage Artiste
@onready var scene_idle = $MainLayout/LeftPanel_Perso/Node2D
@onready var scene_arms = $MainLayout/LeftPanel_Perso/Node2D3_Artiste

# Personnage Ingénieur
@onready var scene_ingenieur = $MainLayout/LeftPanel_Perso/Node2D_Ingenieur

# Personnage Consultant
@onready var scene_consultant = $MainLayout/LeftPanel_Perso/Node2D_Consultant

@onready var cadre_rouge = $MainLayout/CenterPanel_Story/StoryBox/VBoxContainer/BorderIllustration

var ecriture_tween: Tween

func _ready():
	if scene_idle:
		scene_idle.hide()
	if scene_arms:
		scene_arms.hide()
	if scene_ingenieur:
		scene_ingenieur.hide()
	if scene_consultant:
		scene_consultant.hide()

	match GameManager.current_persona:
		"artiste":
			_init_artiste()
		"ingenieur":
			_init_ingenieur()
		"consultant":
			_init_consultant()

	scenario_data = load_scenario_from_file(GameManager.get_scenario_path())
	afficher_noeud("start")

func _init_artiste():
	if scene_idle != null and is_instance_valid(scene_idle):
		scene_idle.show()
		var sprite_idle = scene_idle.get_node_or_null("AnimatedSprite2D")
		if sprite_idle:
			sprite_idle.play("idle")
	if scene_arms != null and is_instance_valid(scene_arms):
		scene_arms.hide()

func _init_ingenieur():
	if scene_ingenieur != null and is_instance_valid(scene_ingenieur):
		scene_ingenieur.show()
		var sprite = scene_ingenieur.get_node_or_null("AnimatedSprite2D")
		if sprite:
			sprite.play("idle")
			print("Ingénieur animé dans ScenarioParser !")

func _init_consultant():
	if scene_consultant != null and is_instance_valid(scene_consultant):
		scene_consultant.show()
		var sprite = scene_consultant.get_node_or_null("AnimatedSprite2D")
		if sprite:
			sprite.play("idle")
			print("Consultant animé dans ScenarioParser !")

# --- SÉQUENCE D'ANIMATION (artiste uniquement) ---
func lancer_sequence_animation():
	if GameManager.current_persona != "artiste":
		return

	if not scene_idle or not scene_arms:
		return

	scene_idle.hide()
	scene_arms.show()

	var sprite_arms = scene_arms.get_node_or_null("AnimatedSprite2D")
	if not sprite_arms:
		return

	sprite_arms.play("arms_cross_in")
	await sprite_arms.animation_finished

	sprite_arms.play("arms_hold")
	await get_tree().create_timer(2.0).timeout

	sprite_arms.play("arms_cross_out")
	await sprite_arms.animation_finished

	scene_arms.hide()
	scene_idle.show()

	var sprite_idle = scene_idle.get_node_or_null("AnimatedSprite2D")
	if sprite_idle:
		sprite_idle.play("idle")

func load_scenario_from_file(file_path: String) -> Dictionary:
	print("--- Chargement du fichier : ", file_path)
	if not FileAccess.file_exists(file_path):
		print("❌ Fichier introuvable !")
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		print("✅ JSON chargé avec succès !")
		return json.data
	print("❌ Erreur de lecture JSON")
	return {}

func afficher_noeud(node_id: String):
	current_node_id = node_id
	for child in choices_container.get_children():
		child.queue_free()

	if not scenario_data.has("nodes") or not scenario_data["nodes"].has(node_id):
		story_text.text = "❌ ERREUR : Le nœud '" + node_id + "' est introuvable."
		return

	var current_node = scenario_data["nodes"][node_id]

	if label_temps:
		label_temps.text = str(GameManager.time_left) + "H"

	var illustration = null
	if cadre_rouge:
		illustration = cadre_rouge.get_node_or_null("Illustration")

	if node_id == "start":
		if mission_title:
			mission_title.text = current_node["text"]
		story_text.text = current_node.get("description", current_node["text"])
		if cadre_rouge:
			cadre_rouge.hide()

	elif node_id.begins_with("fin_echec"):
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.RED)
		if illustration:
			var img_path = current_node.get("image", "res://_Assets/Images/saxophone.png")
			illustration.texture = load(img_path)
		if cadre_rouge:
			cadre_rouge.show()

	else:
		story_text.text = current_node["text"]
		story_text.add_theme_color_override("default_color", Color.WHITE)
		if cadre_rouge:
			cadre_rouge.hide()

	if ecriture_tween and ecriture_tween.is_running():
		ecriture_tween.kill()

	story_text.visible_characters = 0
	ecriture_tween = create_tween()
	var temps_ecriture = story_text.text.length() * 0.02
	ecriture_tween.tween_property(story_text, "visible_characters", story_text.text.length(), temps_ecriture)

	var options = current_node["options"]

	if options.size() == 0:
		var opt_fin = {
			"text": "Voir mon Bilan",
			"is_end_button": true
		}
		creer_bouton_choix(opt_fin)
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
	if opt.has("is_end_button") and opt["is_end_button"] == true:
		get_tree().change_scene_to_file("res://Scenes/Core/Bilan.tscn")
		return

	step_counter += 1
	var user_id = GameManager.current_user_id
	var nom_du_choix = opt["text"]
	var vrai_scenario_id = GameManager.scenarios_uuids.get(GameManager.current_mission, "")

	if user_id != "" and vrai_scenario_id != "":
		Network.send_choice_to_db(vrai_scenario_id, current_node_id, nom_du_choix, step_counter, user_id)

	var h_impact = opt.get("impact_human_core", 0)
	var ai_impact = opt.get("impact_ai_synergy", 0)
	var q_impact = opt.get("impact_quality", 0)
	var t_spent = opt.get("time_cost", 0)

	GameManager.update_youcef_stats(h_impact, ai_impact, q_impact, t_spent)

	if opt.has("unlock_skill"):
		GameManager.unlock_skill(opt["unlock_skill"])

	lancer_sequence_animation()

	if opt.has("next_node") and opt["next_node"] == "aller_vers_arbre":
		get_tree().change_scene_to_file("res://Scenes/Core/ArbreCompetence.tscn")
		return

	afficher_noeud(opt["next_node"])
