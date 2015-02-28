#ifndef XML_HPP
#define XML_HPP

#include <expat.h>

class xml_parser {
    private:
        XML_Parser parser;
    public:
        xml_parser() : parser(XML_ParserCreate(0)) {}
        ~xml_parser() {
            XML_ParserFree(parser);
        }

        XML_Parser handle() { return parser; }

        void reset() {
            XML_ParserReset(parser, 0);
        }
};

#endif
