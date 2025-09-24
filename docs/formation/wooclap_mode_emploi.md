# Wooclap — Mode d’emploi (QCM Formation 180 min)

## 1. Création de l’événement
- Aller sur wooclap.com → Créer un compte enseignant (gratuit)
- Nouveau → Créer un événement
- Paramètres → Activer mode asynchrone (si souhaité) et confidentialité

## 2. Import du QCM
- Outil d’import → Modèle Excel/CSV
- Utiliser notre fichier: `modules/lot1/qcm/wooclap_qcm_formation_180.csv`
  - Séparateur: point-virgule ; encodage UTF-8
  - Colonnes: question; option_a; option_b; option_c; option_d; correct; explication
- Vérifier l’aperçu question par question

## 3. Paramètres RGPD (recommandations)
- Anonymiser les réponses (désactiver collecte de nom/prénom) ou pseudonymes
- Ne pas activer la géolocalisation
- Mentionner la finalité (formation), durée de conservation (courte), destinataires (formateurs)
- Exporter les résultats anonymisés (CSV) et supprimer l’événement une fois le dépouillement terminé

## 4. Diffusion
- Lien participant ou QR code
- Mode temps réel (présentiel) ou asynchrone (avant/entre sessions)
- Informer les participants: anonymat/consentement (selon politique établissement)

## 5. Export et dépouillement
- Exporter résultats → CSV
- Ouvrir dans tableur; indicateurs clés:
  - Taux de complétion (% ayant répondu à toutes les questions)
  - Score moyen et médiane
  - Questions les plus/faibles (discrimination)
  - Répartition par question (A/B/C/D)
- Reporter dans notre modèle: `docs/formation/wooclap_depouillement_modele.xlsx` (à compléter)

## 6. Conseils pédagogiques
- Utiliser en pré‑séance (diagnostic) et en post‑séance (ancrage)
- Réviser les items faibles en synthèse/retour ciblé
- Publier un retour collectif anonymisé
