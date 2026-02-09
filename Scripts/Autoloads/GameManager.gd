extends Node

# Variables Globales (Accessibles partout via GameManager.human_score)
var human_core_score: int = 50
var ai_synergy_score: int = 50
var current_persona: String = "" # Ex: "Youcef", "Marc", "Alyssa"

# Fonction pour mettre à jour les scores
func update_scores(human_delta: int, ai_delta: int):
	# clamp permet de garder le score entre 0 et 100
	human_core_score = clamp(human_core_score + human_delta, 0, 100)
	ai_synergy_score = clamp(ai_synergy_score + ai_delta, 0, 100)
	print("Scores MAJ : Human=", human_core_score, " AI=", ai_synergy_score)
