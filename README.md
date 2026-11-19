# GitHub Achievements Toolkit & Sandbox

Un dépôt bac à sable contenant des scripts d'automatisation PowerShell et un guide pratique pour comprendre et débloquer les succès de profil GitHub.

---

## Sommaire des badges et scripts associés

### 1. Quickdraw
* **Condition :** Fermer une issue ou une PR en moins de 5 minutes après sa création.
* **Script :** [`scripts/quickdraw.ps1`](./scripts/quickdraw.ps1)
* **Utilisation :**
  ```powershell
  ./scripts/quickdraw.ps1 -RepoOwner "Pseudo" -RepoName "achievements-playground" -Token "ghp_xxx"
  ```

---

### 2. YOLO
* **Condition :** Fusionner une Pull Request sur la branche par défaut sans passer par une revue de code.
* **Méthode :** Créer une branche locale, pousser une modification, ouvrir une PR sur GitHub et cliquer directement sur *Merge* sans assigner de relecteur.

---

### 3. Pair Extraordinaire
* **Condition :** Fusionner une PR dont au moins un commit crédite un co-auteur humain valide via la syntaxe Git trailer.
* **Format du commit :**
  ```text
  Titre du commit

  Description du changement.

  Co-authored-by: NomDuCoauteur <email-du-coauteur@example.com>
  ```
* **Script :** [`scripts/pair-extraordinaire.ps1`](./scripts/pair-extraordinaire.ps1)
* **Paliers :** Base (1 PR), Bronze (10 PRs), Argent (24 PRs), Or (48 PRs).

---

### 4. Galaxy Brain
* **Condition :** Répondre à des questions dans la section *Discussions* (catégorie Q&A) et voir ses réponses sélectionnées comme réponse acceptée.
* **Script :** [`scripts/galaxy-brain.ps1`](./scripts/galaxy-brain.ps1)
* **Paliers :** Base (2 réponses), Bronze (8), Argent (16), Or (32).

---

### 5. Pull Shark
* **Condition :** Fusionner des Pull Requests sur la branche principale.
* **Script :** [`scripts/pull-shark.ps1`](./scripts/pull-shark.ps1)
* **Paliers :** Base (2 PRs), Bronze (16), Argent (128), Or (1024).

---

### 6. Public Sponsor
* **Condition :** Effectuer un don (ponctuel ou mensuel) à un contributeur open-source sur GitHub Sponsors.
* **Méthode :** Rendez-vous sur la page GitHub Sponsors d'un développeur et validez un soutien à partir de 1 $.

---

### 7. Starstruck
* **Condition :** Recevoir 16 étoiles sur un même dépôt public pour débloquer le premier palier.
* **Recommandation :** Partagez des projets utiles et documentés sur les communautés de développeurs pour récolter des étoiles authentiques.

---

## Structure du dépôt

```text
├── scripts/
│   ├── quickdraw.ps1
│   ├── pair-extraordinaire.ps1
│   ├── pull-shark.ps1
│   └── galaxy-brain.ps1
├── prs/
└── README.md
```

## Licence
Ce projet est mis à disposition sous licence MIT.
