extends Node

var human_score: int = 50
var ai_score: int = 50
var quality_score: int = 50
var time_left: int = 4 # Youcef commence avec 4 heures

func update_youcef_stats(h_delta, ai_delta, q_delta, t_delta):
	human_score = clamp(human_score + h_delta, 0, 100)
	ai_score = clamp(ai_score + ai_delta, 0, 100)
	quality_score = clamp(quality_score + q_delta, 0, 100)
	time_left -= t_delta
	
	print("MAJ Stats - Humain:", human_score, " AI:", ai_score, " Qualité:", quality_score, " Temps restant:", time_left)

var unlocked_skills: Array = [] # Liste des compétences obtenues

# Fonction pour ajouter une compétence
func unlock_skill(skill_name: String):
	if not unlocked_skills.has(skill_name):
		unlocked_skills.append(skill_name)
		print("🎯 Compétence débloquée : ", skill_name)
