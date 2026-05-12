extends Control

@onready var skill_popup = $SkillPopup
@onready var btn_retour = $SkillPopup/BtnRetour
@onready var title = $SkillPopup/VBoxContainer/Title
@onready var desc = $SkillPopup/VBoxContainer/Desc
@onready var choice_a = $SkillPopup/VBoxContainer/ChoiceA
@onready var choice_b = $SkillPopup/VBoxContainer/ChoiceB
@onready var badge_text = $SkillPopup/VBoxContainer/BadgeText
@onready var btn_dir_art = $MainLayout/RightHuman/Nodes/BtnDirArt

var scenario = {}
var competence_active = {}

func _ready():
	skill_popup.hide()
	print("BtnRetour trouvé : ", btn_retour)
	print("SkillPopup trouvé : ", skill_popup)
	_charger_scenario()
	if GameManager.has_skill("dir_art"):
		btn_dir_art.modulate = Color.GREEN
	btn_dir_art.pressed.connect(_on_btn_competence_pressed.bind("dir_art"))
	btn_retour.pressed.connect(_on_btn_retour_pressed)
	choice_a.pressed.connect(_on_reponse_pressed.bind(0))
	choice_b.pressed.connect(_on_reponse_pressed.bind(1))

func _charger_scenario():
	var file = FileAccess.open("res://Data/scenario_youcef.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		scenario = json.get_data()
		file.close()

func _on_btn_competence_pressed(competence_id: String):
	if GameManager.has_skill(competence_id):
		return
	var competences = scenario["nodes"]["arbre_youcef"]["competences"]
	for comp in competences:
		if comp["id"] == competence_id:
			competence_active = comp
			title.text = "DÉBLOQUER COMPÉTENCE"
			desc.text = comp["question"]
			choice_a.text = "A - " + comp["reponses"][0]["texte"]
			choice_b.text = "B - " + comp["reponses"][1]["texte"]
			badge_text.visible = false
			choice_a.disabled = false
			choice_b.disabled = false
			skill_popup.show()
			break

func _on_reponse_pressed(index: int):
	var reponse = competence_active["reponses"][index]
	if reponse["correcte"]:
		badge_text.text = competence_active["badge"]
		badge_text.visible = true
		choice_a.disabled = true
		choice_b.disabled = true
		GameManager.unlock_skill(competence_active["id"])
		btn_dir_art.modulate = Color.GREEN
		await get_tree().create_timer(1.5).timeout
		skill_popup.hide()
	else:
		badge_text.text = "Mauvaise réponse, réessaie !"
		badge_text.visible = true

func _on_btn_retour_pressed():
	get_tree().change_scene_to_file("res://Scenes/Core/TestParser.tscn")
