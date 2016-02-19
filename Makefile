LIBS=-lstdc++ -lexpat
CXXFLAGS=-std=c++11 -O3 -mtune=native

.PHONY: all clean distclean

all: magento-helper magento-modules magento-config xml-lister

magento-config: magento-config.o
	gcc $^ -o $@ $(LIBS)

xml-lister: xml-lister.o
	gcc $^ -o $@ $(LIBS)

magento-helper: magento-helpers.o
	gcc $^ -o $@ $(LIBS)

magento-modules: magento-modules.o
	gcc $^ -o $@ $(LIBS)

.cpp.o:
	gcc -c $< -o $@ $(CXXFLAGS)
magento-modules.o: fs.hpp xml.hpp
magento-config.o: fs.hpp xml.hpp

distclean: clean
	-rm ./magento-helper
	-rm ./magento-config
	-rm ./magento-modules
	-rm ./xml-lister

clean:
	-rm magento-helpers.o
	-rm magento-modules.o
	-rm magento-config.o
	-rm xml-lister.o
