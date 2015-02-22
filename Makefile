LIBS=-lstdc++ -lexpat
CXXFLAGS=-std=c++11

.PHONY: all clean distclean

all: mh

mh: magento-helpers.o
	gcc $^ -o $@ $(LIBS)

.cpp.o:
	gcc -c $< -o $@ $(CXXFLAGS)

distclean: clean
	-rm ./mh

clean:
	-rm magento-helpers.o
