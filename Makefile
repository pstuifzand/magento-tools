LIBS=-lstdc++ -lexpat
CXXFLAGS=-std=c++11

.PHONY: all clean distclean

all: magento-helper

magento-helper: magento-helpers.o
	gcc $^ -o $@ $(LIBS)

.cpp.o:
	gcc -c $< -o $@ $(CXXFLAGS)

distclean: clean
	-rm ./magento-helper

clean:
	-rm magento-helpers.o
