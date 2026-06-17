extends Control

signal competence_debloquee(competence_id)

var competence_data = {}

@onready var label_question = $PanelContainer/VBoxContainer/LabelQuestion
@onready var btn_a = $PanelContainer/VBoxContainer/BtnReponseA
@onready var btn_b = $PanelContainer/VBoxContainer/BtnReponseB
@onready var label_badge = $PanelContainer/VBoxContainer/LabelBadge
@onready var btn_fermer = $PanelContainer/VBoxContainer/BtnFermer

func _ready():
	label_badge.visible = false
	btn_fermer.visible = false
	btn_a.pressed.connect(_on_reponse_pressed.bind(0))
	btn_b.pressed.connect(_on_reponse_pressed.bind(1))
	btn_fermer.pressed.connect(_on_fermer_pressed)

func ouvrir(data: Dictionary):
	competence_data = data
	label_question.text = data["question"]
	btn_a.text = "A - " + data["reponses"][0]["texte"]
	btn_b.text = "B - " + data["reponses"][1]["texte"]
	label_badge.visible = false
	btn_fermer.visible = false
	btn_a.disabled = false
	btn_b.disabled = false
	visible = true

func _on_reponse_pressed(index: int):
	var reponse = competence_data["reponses"][index]
	if reponse["correcte"]:
		label_badge.text = competence_data["badge"]
		label_badge.visible = true
		btn_fermer.visible = true
		btn_a.disabled = true
		btn_b.disabled = true
		emit_signal("competence_debloquee", competence_data["id"])
	else:
		label_badge.text = "Mauvaise réponse, réessaie !"
		label_badge.visible = true

func _on_fermer_pressed():
	visible = false
