extends Node

# Statistiques globales du joueur
var human_score: int = 50
var ai_score: int = 50
var quality_score: int = 0
var time_left: int = 4

# Gestion des missions
var current_mission: int = 1
var max_missions: int = 3

# Liste des compétences débloquées
var unlocked_skills: Array = []

func update_youcef_stats(h_delta: int, ai_delta: int, q_delta: int, t_delta: int):
	human_score = clamp(human_score + h_delta, 0, 100)
	ai_score = clamp(ai_score + ai_delta, 0, 100)
	quality_score = clamp(quality_score + q_delta, 0, 100)
	time_left = clamp(time_left - t_delta, 0, 24)
	print("Stats: H:", human_score, " IA:", ai_score, " Q:", quality_score, " T:", time_left)

func has_skill(skill_name: String) -> bool:
	return unlocked_skills.has(skill_name)

func unlock_skill(skill_name: String):
	if not has_skill(skill_name):
		unlocked_skills.append(skill_name)
		print("⚡ Compétence débloquée : ", skill_name)

func reset_stats():
	human_score = 50
	ai_score = 50
	quality_score = 0
	time_left = 4
	print("🔄 Stats réinitialisées pour la mission ", current_mission)

func next_mission():
	current_mission += 1
	reset_stats()
	print("➡️ Passage à la mission ", current_mission)

func get_scenario_path() -> String:
	match current_mission:
		1:
			return "res://Data/scenario_youcef.json"
		2:
			return "res://Data/scenario_mission2_artiste.json"
		3:
			return "res://Data/scenario_mission3_artiste.json"
		_:
			return "res://Data/scenario_youcef.json"
