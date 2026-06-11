#  You & AI - Serious Game

Bienvenue sur le dépôt officiel du projet **You & AI**, un serious game interactif développé sous Godot Engine. 

Ce projet s'inscrit dans le cadre du Master 2 EEDSI (Développement Informatique) à H3 Hitema. Il a pour but d'accompagner les professionnels face à l'automatisation de leurs tâches à l'horizon 2035, en transformant la peur de l'IA en stratégie d'évolution.

##  Fonctionnalités Principales
- **Moteur narratif dynamique :** Parsing de fichiers JSON locaux pour générer l'histoire, les choix et les interfaces à la volée.
- **Système de jauges en temps réel :** Calcul dynamique des scores *Human Core* (compétences humaines) et *Synergie IA* selon les décisions du joueur.
- **Sauvegarde asynchrone :** Envoi des choix et des bilans de session vers une base de données distante via API REST.
- **Multiprofils :** Scénarios adaptés à différents personas (Artiste, Ingénieur, Consultant).

##  Stack Technologique
- **Moteur de jeu :** Godot Engine 4.x (Export WebAssembly / HTML5)
- **Langage :** GDScript
- **Backend & Base de données :** Supabase (PostgreSQL, Auth, API REST)
- **Hébergement :** itch.io / GitHub Pages

## 📂 Architecture du Projet
Le projet est structuré pour séparer strictement la logique globale, les interfaces et les données narratives :
- `res://Autoloads/` : Scripts globaux tournant en tâche de fond (`GameManager.gd`, `Network.gd`).
- `res://Scenes/` : Interfaces graphiques découpées en scènes indépendantes (`ScenarioParser.tscn`, `CharacterSelection.tscn`...).
- `res://Data/` : Base de données locale contenant les arbres de décisions au format JSON (`scenario_youcef.json`, etc.).
- `res://Assets/` : Ressources visuelles et UI Kit.

##  Installation et Lancement en local

### Prérequis
- Télécharger et installer [Godot Engine 4.x](https://godotengine.org/download) (Version Standard).
- Avoir Git installé sur sa machine.

### Cloner le repository
Pour récupérer le projet en local, ouvrez votre terminal et exécutez la commande suivante :
```bash
git clone [https://github.com/BrasSelva/SeriousGame-Godot-Engine.git](https://github.com/BrasSelva/SeriousGame-Godot-Engine.git)
