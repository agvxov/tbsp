.PHONY: main test

main:
	g++ source/tbc.cpp $$(pkg-config --cflags --libs tree-sitter tree-sitter-c) -ggdb

test:
	python source/tbc.py test/convert.tbsp > object/kek.cpp
	bake object/kek.cpp
	./object/a.out test/input.md
