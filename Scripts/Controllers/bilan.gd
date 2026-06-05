extends Control

# --- RÉFÉRENCES AUX NŒUDS ---
# (Vérifie bien que les chemins correspondent à ton arbre de scène !)
@onready var texte_humain = $ColorRect/PanelContainer/VBoxContainer/TexteHumain
@onready var barre_humain = $ColorRect/PanelContainer/VBoxContainer/BarreHumain

@onready var texte_ia = $ColorRect/PanelContainer/VBoxContainer/TexteIA
@onready var barre_ia = $ColorRect/PanelContainer/VBoxContainer/BarreIA

@onready var texte_qualite = $ColorRect/PanelContainer/VBoxContainer/TexteQualite
@onready var texte_temps = $ColorRect/PanelContainer/VBoxContainer/TexteTemps
@onready var btn_envoyer = $ColorRect/PanelContainer/VBoxContainer/SendButton

func _ready():
	# 1. MISE À JOUR DES TEXTES
	texte_humain.text = "Symbiose Humaine : " + str(GameManager.human_score) + "%"
	texte_ia.text = "Efficacité IA : " + str(GameManager.ai_score) + "%"
	texte_qualite.text = "Qualité finale de l'œuvre : " + str(GameManager.quality_score) + "%"
	
	# Petite astuce pour le temps : 
	# Le joueur a commencé avec 4h. S'il lui reste 2h, il a utilisé 2h.
	var temps_utilise = 4 - GameManager.time_left
	texte_temps.text = "Temps de production utilisé : " + str(temps_utilise) + "h"
	
	# 2. PRÉPARATION DES BARRES DE PROGRESSION
	# On s'assure qu'elles commencent à zéro pour l'effet visuel
	barre_humain.value = 0
	barre_ia.value = 0
	
	# 3. ANIMATION MAGIQUE (TWEEN)
	# On crée une animation qui lit les variables de ton GameManager
	var tween = create_tween().set_parallel(true)
	tween.tween_property(barre_humain, "value", float(GameManager.human_score), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(barre_ia, "value", float(GameManager.ai_score), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# 4. CONNEXION DU BOUTON
	btn_envoyer.pressed.connect(_on_btn_envoyer_pressed)

func _on_btn_envoyer_pressed():
	print("Scores envoyés à l'entreprise !")
	# Pour l'instant, on quitte le jeu. 
	# Plus tard, tu pourras charger ton menu principal ici !
	get_tree().quit()
