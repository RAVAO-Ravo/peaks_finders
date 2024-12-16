# peaks_finders_fun

## Description du Projet

Ce projet propose une implémentation rapide et efficace de la détection de pics dans des signaux spectrométriques à l'aide de **Cython** pour accélérer les performances. Il est conçu pour traiter des données sous forme de DataFrame (par exemple, des fichiers au format **Parquet**) et permet une visualisation des pics détectés.

Le dépôt contient tout le nécessaire pour compiler, exécuter et visualiser les résultats de la détection de pics.

## Fonctionnalités
- **Chargement des données** : Lecture de fichiers Parquet filtrés par niveau de masse (MS1).
- **Détection de pics** : Implémentation en Cython pour une exécution optimisée.
- **Visualisation** : Graphique montrant le signal et les pics identifiés.

## Structure du Dépôt

Le dépôt est organisé comme suit :

```
.
├── config.py          # Configuration du module Cython
├── main.ipynb         # Notebook principal pour exécuter le détecteur de pics
├── makefile           # Commandes pour compiler le module Cython
├── peaks_finders.pyx  # Code Cython pour la détection de pics
├── setup.py           # Script d'installation et compilation
├── utils.py           # Fonctions utilitaires pour le chargement des données et la visualisation
└── datas/
    └── pharma_PT6_replicate_1_subset.parquet  # Exemple de fichier de données
```

## Installation

### Prérequis

- **Python 3.x**
- **Cython**
- **NumPy**
- **Pandas**
- **Matplotlib**

Installez les dépendances nécessaires avec :

```bash
pip3 install cython numpy pandas matplotlib pyarrow
```

### Compilation du Module Cython

Pour compiler le module `peaks_finders.pyx`, utilisez le `makefile` ou le script `setup.py` :

Avec le `makefile` :

```bash
make
```

Ou avec `setup.py` :

```bash
python3 setup.py build_ext --inplace
```

## Utilisation

### Chargement des Données

Utilisez la fonction `load_data` pour charger et préparer les données depuis un fichier Parquet :

```python
from utils import load_data

data = load_data(filepath="./datas/pharma_PT6_replicate_1_subset.parquet")
print(data.head())
```

### Détection de Pics

Utilisez le module `peaks_finders` pour détecter les pics dans le signal :

```python
from peaks_finders import PeaksFinder

# Exemple de détection de pics
peaks = PeaksFinder(ascd_min=1, dscd_min=1).peaks_detection(df=df, column="intensity")
print(peaks)
```

### Visualisation des Pics

Utilisez `plotting_datas` pour visualiser les pics identifiés :

```python
from utils import plotting_datas

# Exemple de signal et de pics
plotting_datas(signal=data, peaks=peaks)
```

## Licence

Ce projet est sous licence Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0). Vous êtes libre de :

- Partager : copier et redistribuer le matériel sous quelque support que ce soit ou sous n'importe quel format.
- Adapter : remixer, transformer et créer à partir du matériel.

Selon les conditions suivantes :

- Attribution : Vous devez donner le crédit approprié, fournir un lien vers la licence et indiquer si des modifications ont été apportées. Vous devez le faire de la manière suggérée par l'auteur, mais pas d'une manière qui suggère qu'il vous soutient ou soutient votre utilisation du matériel.

- Utilisation non commerciale : Vous ne pouvez pas utiliser le matériel à des fins commerciales.

[![Logo CC BY-NC 4.0](https://licensebuttons.net/l/by-nc/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc/4.0/)

[En savoir plus sur la licence CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)