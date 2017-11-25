#include <expat.h>
#include <cstring>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "xml.hpp"

struct user_data {
    char* filename;
    int in_action;
};

struct Block {
    std::string type;
    std::string name;
    std::string tmpl;
    std::string as;
};

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts)
{
    user_data* data = (user_data*)udata;

    if (strcmp(name, "action") == 0) {
        data->in_action = 1;
    }
    else if (strcmp(name, "block") == 0) {
        if (data->in_action) return;

        bool type_found = false;
        bool name_found = false;

        Block block;

        while (*atts) {
            if (strcmp(*atts, "type") == 0) {
                ++atts;
                block.type = *atts;
                type_found = true;
            }
            else if (strcmp(*atts, "name") == 0) {
                ++atts;
                block.name = *atts;
                name_found = true;
            }
            else if (strcmp(*atts, "template") == 0) {
                ++atts;
                block.tmpl = *atts;
            }
            else if (strcmp(*atts, "as") == 0) {
                ++atts;
                block.as = *atts;
            }
            else {
                ++atts;
            }

            ++atts;
        }

        std::cout << block.type << " " << block.name << " " << block.as << " " << block.tmpl << "\n";

        if (!name_found) {
            std::cerr << data->filename << ": No name found in block\n";
        }

        if (!type_found) {
            std::cerr << data->filename << ": No type found in block\n";
        }
    }
}

void root_end_element_handler(void* udata, const XML_Char* name)
{
    if (strcmp(name, "action") == 0) {
        user_data* data = (user_data*)udata;
        data->in_action = 0;
    }
}

void character_data_handler(void* udata, const XML_Char* s, int len)
{
}

void parse_xml(xml_parser& parser, std::ifstream& in, user_data* data) {
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

int main(int argc, char** argv)
{
    // remove program name
    argc--;
    argv++;

    // no arguments
    if (!argc) return 0;

    // create parser
    xml_parser parser;

    while (argc) {
        user_data data;
        data.in_action = 0;
        data.filename = *argv;

        XML_SetUserData(parser.handle(), &data);
        XML_SetElementHandler(parser.handle(), root_start_element_handler, root_end_element_handler);
        XML_SetCharacterDataHandler(parser.handle(), character_data_handler);

        std::ifstream in{data.filename};
        if (in) parse_xml(parser, in, &data);
        parser.reset();

        argc--;
        argv++;
    }
}
