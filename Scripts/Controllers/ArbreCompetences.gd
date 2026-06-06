extends Control

# --- RÉFÉRENCES ---
@onready var btn_retour = $MainColumn/BtnRetour
@onready var skill_popup = $SkillPopup
@onready var btn_humain = $MainColumn/BrainArea/MainLayout/BrainImage/Nodes/BtnDirArt
@onready var btn_ia = $MainColumn/BrainArea/MainLayout/LeftIA/BtnCompIA
@onready var choice_a = $SkillPopup/VBoxContainer/ChoiceA
@onready var choice_b = $SkillPopup/VBoxContainer/ChoiceB
@onready var badge_text = $SkillPopup/VBoxContainer/BadgeText
@onready var title = $SkillPopup/VBoxContainer/Title
@onready var desc = $SkillPopup/VBoxContainer/Desc

var competence_data = {}
var btn_actif: Button

func _ready():
	btn_retour.disabled = true
	skill_popup.hide()
	badge_text.hide()

	_charger_competence()

	btn_humain.pressed.connect(_on_btn_competence_pressed)
	btn_ia.pressed.connect(_on_btn_competence_pressed)
	choice_a.pressed.connect(_on_choice_made.bind("A"))
	choice_b.pressed.connect(_on_choice_made.bind("B"))
	btn_retour.pressed.connect(_on_btn_retour_pressed)

	if GameManager.has_skill(competence_data.get("id", "")):
		btn_actif.modulate = Color.GREEN

func _charger_competence():
	var file_path = GameManager.get_scenario_path()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		file.close()
		if data.has("competence"):
			competence_data = data["competence"]
			print("✅ Compétence chargée : ", competence_data.get("label", "???"))

			var label = competence_data.get("label", "Compétence")
			title.text = label
			desc.text = competence_data.get("question", "")
			choice_a.text = "A - " + competence_data.get("reponse_a", "")
			choice_b.text = "B - " + competence_data.get("reponse_b", "")

			var cote = competence_data.get("cote", "humain")
			print("cote : ", cote)

			if cote == "ia":
				btn_ia.text = label
				btn_ia.show()
				btn_humain.hide()
				btn_actif = btn_ia
			else:
				btn_humain.text = label
				btn_humain.show()
				btn_ia.hide()
				btn_actif = btn_humain
		else:
			print("❌ Pas de bloc competence trouvé dans le JSON !")

func _on_btn_competence_pressed():
	skill_popup.show()

func _on_choice_made(choix: String):
	choice_a.disabled = true
	choice_b.disabled = true
	btn_retour.disabled = false

	var bonne_reponse = competence_data.get("bonne_reponse", "B")

	if choix == bonne_reponse:
		badge_text.text = competence_data.get("badge", "BADGE DÉBLOQUÉ !")
		badge_text.add_theme_color_override("font_color", Color.GREEN)
		badge_text.show()
		if GameManager:
			GameManager.unlock_skill(competence_data.get("id", ""))
		btn_actif.modulate = Color.GREEN
	else:
		badge_text.text = "ÉCHEC : Mauvaise approche. Réfléchis bien avant de recommencer."
		badge_text.add_theme_color_override("font_color", Color.RED)
		badge_text.show()

func _on_btn_retour_pressed():
	get_tree().change_scene_to_file("res://Scenes/Core/ScenarioParser.tscn")
