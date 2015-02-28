LIBS=-lstdc++ -lexpat
CXXFLAGS=-std=c++11 -O2

.PHONY: all clean distclean

all: magento-helper magento-modules

magento-helper: magento-helpers.o
	gcc $^ -o $@ $(LIBS)

magento-modules: magento-modules.o
	gcc $^ -o $@ $(LIBS)

.cpp.o:
	gcc -c $< -o $@ $(CXXFLAGS)
magento-modules.o: fs.hpp

distclean: clean
	-rm ./magento-helper
	-rm ./magento-modules

clean:
	-rm magento-helpers.o
	-rm magento-modules.o
