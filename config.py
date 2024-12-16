#-*- coding:utf-8 -*-


# Importationd des modules
from typing import List

# Liste des modules à compiler
MODULE_LIST: List[str] = ["peaks_finders.pyx"]

# Niveau de compilation
LANGUAGE_LEVEL: int = 3

# Chemin ver le fichier de test
TEST_FILE: str = "./datas/pharma_PT6_replicate_1_subset.parquet"