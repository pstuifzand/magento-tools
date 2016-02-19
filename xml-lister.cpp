#include <expat.h>
#include <cstring>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "xml.hpp"

struct user_data {
    char* filename;
    std::vector<std::string> stack;
    std::vector<std::string> atts;

    std::string current;
};

struct string_view {
    string_view(const char* d, size_t n) : d(d), s(s) {}

    const char* data() { return d; }
    size_t size() { return s; }

    const char* d;
    size_t s;
};

std::string trim(const std::string& s)
{
    auto p = s.begin();
    auto l = s.end();

    while (p != l) {
        if (!isspace(*p)) break;
        ++p;
    }

    auto p2 = p;
    auto l2 = s.end();

    while (1) {
        if (p2 == l2) break;
        if (!isspace(*p2)) break;
        --l2;
    }

    return std::string{ p, l2 };
}

template <typename I>
void print_stack(I p, I l)
{
    if (p != l) { std::cout << *p; ++p; }
    while (p != l) {
        std::cout << "/" << *p;
        ++p;
    }
}

template <typename I>
void print_atts(I f0, I l0, I f1, I l1)
{
    if (f1 != l1) {
        while (f1 != l1) {
            print_stack(f0, l0);
            std::cout << "@" << *f1;
            ++f1;
            std::cout << "\t" << *f1;
            ++f1;
            std::cout << "\n";
        }
    }
}

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts)
{
    user_data* data = (user_data*)udata;
    data->stack.push_back(std::string(name));
    while (*atts) {
        data->atts.push_back(std::string(*atts));
        ++atts;
    }
}

void root_end_element_handler(void* udata, const XML_Char* name)
{
    user_data* data = (user_data*)udata;

    print_stack(data->stack.begin(), data->stack.end());
    std::cout << "\t";
    std::cout.write(data->current.data(), data->current.size());
    std::cout << "\n";

    print_atts(data->stack.begin(), data->stack.end(), data->atts.begin(), data->atts.end());

    data->stack.pop_back();
    data->atts.clear();
    data->current.clear();
}

void character_data_handler(void* udata, const XML_Char* s, int len)
{
    user_data* data = (user_data*)udata;
    std::string x = std::string(s,len);

    auto trimmed = trim(x);

    if (trimmed.size()) {
        data->current.append(trimmed);
    }
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
