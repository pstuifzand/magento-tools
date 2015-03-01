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

template <class T>
void parse_xml(xml_parser& parser, std::ifstream& in, T* data) {
    const int size = 1024;
    char buf[size];
    while (in) {
        in.read(buf, size);
        XML_Status ret = XML_Parse(parser.handle(), buf, in.gcount(), in ? 0 : 1);
        if (!ret) {
            XML_Error error = XML_GetErrorCode(parser.handle());
            int line = XML_GetCurrentLineNumber(parser.handle());
            std::cerr << data->filename << ":" << line << ": error: " << XML_ErrorString(error) << "\n";
            break;
        }
    }
}


#endif
