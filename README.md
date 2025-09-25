# Formation Enseignant — Résolution de problèmes (C2 & C3)

Un dossier prêt à l’emploi pour produire des supports de formation (polycopiés A4, QCM, slides) et les exporter en PDF/HTML automatiquement.

## 1) Prendre en main (5 minutes)
- Ouvrir ce dossier dans VS Code
- Extensions recommandées: “Markdown All in One”, “PowerShell”, “Marp for VS Code”
- Récupérer le projet:
  - Méthode simple (graphique): sur GitLab → bouton “Download” → “Download ZIP”, décompressez puis ouvrez le dossier dans VS Code.
  - Méthode Git (optionnelle): `git clone https://gitlab.com/emmanuel-asfar/formation-enseignant.git`

## 2) Générer les supports
Dans le Terminal VS Code à la racine du projet. Le script installe normalement les prérequis (MARP, utilitaires) si besoin.

- Tout exporter (PDF + HTML):
  ```powershell
  .\export.ps1
  ```
- Un seul fichier:
  ```powershell
  .\export.ps1 -Path modules/lot1/formation/formation_180min.md
  ```
- Un dossier entier:
  ```powershell
  .\export.ps1 -Path modules/lot1/formation/
  ```
- PDF uniquement (désactiver HTML):
  ```powershell
  .\export.ps1 -HTML:$false
  ```
- HTML uniquement (désactiver PDF):
  ```powershell
  .\export.ps1 -PDF:$false
  ```
Résultats dans `exports/pdf/...` et `exports/html/...` (HTML auto‑contenus pour slides et, si possible, documents).

## 3) Règles simples pour écrire un document
En tête YAML au début du fichier `.md`:
```yaml
---
marp: false       # true = slides MARP ; false = document A4
paginate: true
class: lead
size: A4
document:
  html: yes       # exporter en HTML
  pdf: yes        # exporter en PDF
---
```
Le script choisit automatiquement la bonne feuille de style:
- Slides (`marp: true`) → `css/slides.css` (16:9)
- QCM (fichiers dans `qcm/`) → `css/qcm.css` (A4 compact)
- Autres documents → `css/a4.css` (A4 compact)

Bonnes pratiques:
- Markdown pur (pas de `<div>` ni de style inline)
- Images locales avec chemin relatif (ex: `media/etapes_de_resolutions.png`)
- Titres clairs, listes courtes, tableaux simples

## 4) Demander quelque chose à l’IA (modèle de requête)
Copier-coller dans l’outil d’IA de votre choix:
```
Lis le README.md. Crée un nouveau module “lot2” sur le thème [THÈME] en reprenant la structure de lot1 :
- Polycopié A4 (document.pdf/html)
- Slides (slides.pdf/html)
- QCM (qcm.pdf)
Respecte la logique CSS (a4.css / slides.css / qcm.css). Fournis du Markdown pur et des images locales dans media/.
```

## 5) Consignes IA (résumé non technique)
- Tout en français, clair et pédagogique (sans jargon inutile).
- Formats: Markdown pur + en‑tête YAML simple (cf. section 3).
- Styles: ne pas embarquer de CSS inline; le script applique `a4.css`, `qcm.css`, `slides.css`.
- Images: locales (répertoire `media/`), noms explicites; pictogrammes natifs (✅, ⚠️, 🧩…).
- Cohérence: s’inspirer de `modules/lot1` pour la structure et le ton.
- Accessibilité: contrastes, police lisible, descriptions d’images si utile.
- Qualité: objectifs observables, démarches explicites (Lire → Représenter → Résoudre → Vérifier), exemples travaillés + erreurs typiques + remédiations.

## 6) Dépannage rapide
- PDF “moche” (grande police / paysage): vérifiez que le fichier n’est pas un slide (marp: false) et qu’il n’y a pas de CSS locale concurrente.
- Image introuvable dans les slides: placez l’image dans `modules/.../formation/media/` et utilisez `media/mon_image.png`.
- HTML non généré pour les documents: Pandoc n’est peut‑être pas installé; les PDFs sont quand même produits. Pour l’installer:
  ```powershell
  winget install --id JohnMacFarlane.Pandoc
  ```
- Export partiel: utilisez `-Path` sur un fichier/dossier; combinez avec `-PDF:$false` ou `-HTML:$false` selon besoin.

## 7) Où ranger vos fichiers
```
modules/lotX/
├─ formation/      # Polycopiés + slides + media/
└─ qcm/            # QCM papier (avec corrigé)
```
Le script recrée automatiquement l’arborescence dans `exports/`.

—
Projet hébergé sur GitLab. Pour toute question, ouvrez le dossier dans VS Code, lisez ce README, puis lancez `export.ps1`.