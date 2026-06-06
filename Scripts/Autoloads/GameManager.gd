extends Node

# --- RÉSEAU ET PROGRESSION ---
# L'ID unique du joueur (récupéré via Supabase lors de la connexion)
var current_user_id: String = ""
# Historique des missions terminées pour débloquer la suite
var missions_terminees: Array = []


# --- STATISTIQUES GLOBALES ---
var human_score: int = 50  # Neutre au début
var ai_score: int = 50     # Neutre au début
var quality_score: int = 0 # L'affiche n'est pas encore créée
var time_left: int = 4

# Liste des compétences débloquées
var unlocked_skills: Array = []


# --- FONCTIONS ---
# On ajoute le typage ': int' aux arguments pour éviter les bugs
func update_youcef_stats(h_delta: int, ai_delta: int, q_delta: int, t_delta: int):
	human_score = clamp(human_score + h_delta, 0, 100)
	ai_score = clamp(ai_score + ai_delta, 0, 100)
	quality_score = clamp(quality_score + q_delta, 0, 100)
	
	# Sécurité : On utilise '-' car 't_delta' (time_cost) dans le JSON est positif (ex: 1 ou 2)
	# On ajoute un 'clamp' pour éviter que le temps ne devienne négatif sous 0
	time_left = clamp(time_left - t_delta, 0, 24)
	
	print("Stats: H:", human_score, " IA:", ai_score, " Q:", quality_score, " T:", time_left)

func has_skill(skill_name: String) -> bool:
	return unlocked_skills.has(skill_name)

func unlock_skill(skill_name: String):
	if not has_skill(skill_name):
		unlocked_skills.append(skill_name)
		print("⚡ Compétence débloquée : ", skill_name)
