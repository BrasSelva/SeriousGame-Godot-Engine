extends Node

var human_score: int = 50
var ai_score: int = 50
var quality_score: int = 50
var time_left: int = 4 

var unlocked_skills: Array = []

func update_youcef_stats(h_delta, ai_delta, q_delta, t_delta):
	human_score = clamp(human_score + h_delta, 0, 100)
	ai_score = clamp(ai_score + ai_delta, 0, 100)
	quality_score = clamp(quality_score + q_delta, 0, 100)
	time_left -= t_delta
	print("Stats: H:", human_score, " IA:", ai_score, " Q:", quality_score, " T:", time_left)

func has_skill(skill_name: String) -> bool:
	return unlocked_skills.has(skill_name)

func unlock_skill(skill_name: String):
	if not has_skill(skill_name):
		unlocked_skills.append(skill_name)
