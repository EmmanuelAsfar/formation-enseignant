# Consigne Agent LLM - Formation Enseignant

## 🎯 Comportement général
- **Langue** : Français uniquement (réponses et fichiers)
- **Tone** : Académique pédagogique, clair, sans jargon
- **Portée** : Programmes officiels 2025, cycles 2 et 3
- **Format** : Markdown pur, sections standardisées

## 📝 Types de livrables
- **Polycopiés** : Documents de référence complets (30+ pages)
- **Slides** : Présentations MARP pour formation orale
- **QCM** : Questionnaires d'évaluation avec corrigés
- **Synthèses** : Résumés de documents officiels
- **Guides** : Instructions d'utilisation et bonnes pratiques

## 🎨 Logique des formats et CSS

### 📄 **Format A4 compact (par défaut)**
- **CSS** : `css/formation-a4.css` et `css/qcm.css`
- **Usage** : Polycopiés, QCM, documents imprimables
- **Caractéristiques** :
  - Marges : `1.5cm` (compact)
  - Interlignage : `1.4` (serré)
  - Typographie : Tailles réduites pour optimiser l'espace
  - Objectif : Moins de pages, meilleure utilisation du papier

### 🖥️ **Format présentation (slides)**
- **CSS** : `css/slides.css`
- **Usage** : Présentations orales, diaporamas
- **Caractéristiques** :
  - Format : `16:9` (écran large)
  - Marges : `1cm` (minimales)
  - Typographie : Tailles adaptées à la projection
  - Objectif : Lisibilité à distance, impact visuel

### 🔧 **Règle de répartition CSS**
- **Fichiers `*slides*.md`** → `css: ../../css/slides.css` (présentation)
- **Fichiers QCM** → `css: ../../css/qcm.css` (A4 compact)
- **Tous les autres** → `css: ../../css/formation-a4.css` (A4 compact)

## 📁 Structure des documents

### En-tête MARP standard
```markdown
---
marp: true
theme: default
paginate: true
class: lead
css: ../../css/[formation-a4.css|slides.css|qcm.css]
---
```

### Sections standardisées
- **Titre principal** : `# Titre`
- **Sections** : `## Section`
- **Sous-sections** : `### Sous-section`
- **Timing** : `**⏱️ 15 minutes**` (badges de timing)
- **Éléments importants** : `**Texte important**`

## ♿ Accessibilité et différenciation
- **Pictogrammes natifs** : Utiliser des emojis/symboles Unicode
- **Images** : Chemin relatif `media/nom_image.png`
- **Couleurs** : Palette cohérente (#2c5aa0, #e8f4fd)
- **Lisibilité** : Contraste suffisant, tailles adaptées

## 🔄 Adaptation par cohorte
- **Questionnaires** : Adapter selon le niveau des enseignants
- **Exemples** : Contextualiser selon l'établissement
- **Rythme** : Ajuster selon les retours terrain

## ✅ Contrôle qualité
- **Cohérence** : Vérifier citations et références
- **Complétude** : Tous les éléments requis présents
- **Format** : Respect des standards MARP
- **Sécurité** : Pas de contenu sensible

## 📤 Structure de sortie
- **Fichiers** : Un par type de livrable
- **Nommage** : `[type]_[contexte].md`
- **Répertoires** : `modules/lot1/[formation|qcm]/`
- **Export** : PDF et HTML automatiques

## 🎯 Référence pour les lots suivants
- **S'inspirer du Lot 1** comme modèle de structure et de qualité
- Reprendre la même organisation : formation/, qcm/, CSS dédiées
- Utiliser les mêmes formats : MARP, Markdown pur, export automatique
- Maintenir la cohérence avec les styles et l'arborescence établie
- Adapter le contenu selon le thème du lot (programmation, IA, etc.)
