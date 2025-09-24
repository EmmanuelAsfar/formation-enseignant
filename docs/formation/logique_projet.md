# Logique du projet – formation-enseignant

## 1. Finalité
Créer une chaîne cohérente de formation sur la résolution de problèmes (C2/C3), de la base documentaire officielle jusqu’à un accompagnement outillé (site + feedback IA), entièrement en français.

## 2. Ingrédients
- Sources officielles: Éduscol (programmes 2025, docs d’accompagnement)
- Réseau Canopé: guides et ressources
- Modèles internes: gabarits (séance, cheatsheet, feedback, QCM)

## 3. Pipeline documentaire
1) Collecte (Éduscol/Canopé) → `source/`
2) Curation des URLs → `docs/sources/LISTE-LIENS.md` + `tools/urls.csv`
3) Téléchargement scripté → `tools/download.ps1`
4) Synthèse en Markdown → `docs/syntheses/...` (gabarit `templates/modele-synthese.md`)

## 4. Parcours pédagogique
- Pré-séance: questionnaire, lecture préparatoire (programmes, guides)
- Présentiel (3h): apprendre à créer une séance explicite (problèmes additifs C2)
- Post-séance: polycopié, cheatsheet, entraînement + feedback IA

## 5. Production de supports
- Séance modèle + slides + QCM + cheatsheet A4 (Lot 1)
- Extensions par familles de problèmes (Lot 2)
- Programmations annuelles (Lot 3)
- Mini-site (docs, exercices, soumission séance, feedback IA) (Lot 4)
- Déclinaisons audio/vidéo et accessibilité (Lot 5)

## 6. Feedback IA (Alia)
- Entrée: préparation de séance (gabarit)
- Sortie: feedback structuré (synthèse, points forts, axes d’amélioration, priorités)
- Grille critériée (0–3): objectifs, séquencement explicite, étayage, différenciation, évaluation, alignement programmes

## 7. Organisation des répertoires
- `source/` originaux, `docs/syntheses/` résumés, `modules/lot1/` supports
- `tools/` scripts, `templates/` gabarits
- `site/` pages statiques

## 8. Gouvernance et qualité
- Style: académique pédagogique, clair, sans jargon
- Citations systématiques, URLs et date d’accès
- Accessibilité (malvoyants), différenciation
- Respect vie privée (anonymisation)

## 9. Jalons
- Lot 1 (MVP pédagogique): séance explicite C2 + supports
- Lot 2–3: extensions et programmations
- Lot 4–5: plateforme et médias

## 10. Suivi
- TODOs du projet
- Dépouillement cohorte (questionnaire) → adaptation
- Revue régulière des sources (mises à jour Éduscol)
