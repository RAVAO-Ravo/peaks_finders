#-*- coding:utf-8 -*-


# Importation des modules
import numpy as np
from distutils.core import setup
from Cython.Build import cythonize
from config import MODULE_LIST, LANGUAGE_LEVEL


setup(
	ext_modules = cythonize(module_list=MODULE_LIST, language_level=LANGUAGE_LEVEL),
	include_dirs = [np.get_include()]
)