LIBS=-lstdc++ -lexpat
CXXFLAGS=-std=c++14 -O3 -mtune=native

.PHONY: all clean distclean

all: bin build bin/magento-helper bin/magento-modules bin/magento-config bin/xml-lister bin/block-lister bin/position data/events.txt

bin:
	mkdir bin
build:
	mkdir build
data:
	mkdir data

bin/magento-config: build/magento-config.o
	gcc $^ -o $@ $(LIBS)

bin/position: build/position.o
	gcc $^ -o $@ $(LIBS)

bin/block-lister: build/block-lister.o
	gcc $^ -o $@ $(LIBS)

bin/xml-lister: build/xml-lister.o
	gcc $^ -o $@ $(LIBS)

bin/magento-helper: build/magento-helpers.o
	gcc $^ -o $@ $(LIBS)

bin/magento-modules: build/magento-modules.o
	gcc $^ -o $@ $(LIBS)

build/%.o: src/%.cpp
	gcc -c $< -o $@ $(CXXFLAGS)

data/events.txt: data script/all-events.pl
	find /var/www/html/magento/app/code -type f -name '*.php' | xargs perl script/all-events.pl | sort | uniq > data/events.txt

build/magento-modules.o: src/fs.hpp src/xml.hpp
build/magento-config.o: src/fs.hpp src/xml.hpp

distclean: clean
	-rm -rf bin

clean:
	-rm -rf build
