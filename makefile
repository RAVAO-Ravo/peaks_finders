all:
	python3 setup.py build_ext --inplace
	rm -f *.c
	rm -rf build

rebuild:
	rm -rf build
	rm -f *.c
	rm -f *.so
	python3 setup.py build_ext --inplace
	rm -f *.c
	rm -rf build

clean:
	rm -rf build
	rm -f *.c
	rm -f *.so