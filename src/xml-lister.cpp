#include <expat.h>
#include <cstring>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <experimental/string_view>
#include "xml.hpp"

using std::experimental::string_view;

struct user_data {
    char* filename;
    std::vector<std::string> stack;
    std::vector<std::string> atts;

    std::string current;
    int keys_only;
    int show_filename;
};

template <typename I>
I trim_front(I f, I l)
{
    return std::find_if_not(f, l, isspace);
}

template <typename I, typename P>
I find_backward_if_not(I f, I l, P p)
{
    if (f == l) return l;
    while (f != l) {
        --l;
        if (!isspace(*l)) break;
    }
    return ++l;
}

template <typename I>
I trim_back(I f, I l)
{
    return find_backward_if_not(f, l, isspace);
}

template <class S>
S trim(const S& s)
{
    auto f = trim_front(s.begin(), s.end());
    auto l = trim_back(f, s.end());

    return S{f, (size_t)std::distance(f, l)};
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
void print_atts(I f0, I l0, I f1, I l1, user_data* data)
{
    if (f1 != l1) {
        while (f1 != l1) {
            if (data->show_filename) {
                std::cout << data->filename << ": ";
            }
            print_stack(f0, l0);
            std::cout << "@" << *f1;
            ++f1;
            if (!data->keys_only) {
                std::cout << "\t" << *f1;
            }
            ++f1;
            std::cout << "\n";
        }
    }
}

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts)
{
    user_data* data = (user_data*)udata;
    data->stack.emplace_back(name);
    while (*atts) {
        data->atts.emplace_back(*atts);
        ++atts;
    }
}

void root_end_element_handler(void* udata, const XML_Char* name)
{
    user_data* data = (user_data*)udata;

    if (data->show_filename) {
        std::cout << data->filename << ": ";
    }

    print_stack(data->stack.begin(), data->stack.end());
    if (!data->keys_only) {
        std::cout << "\t";
        std::cout.write(data->current.data(), data->current.size());
    }
    std::cout << "\n";

    print_atts(data->stack.begin(), data->stack.end(), data->atts.begin(), data->atts.end(), data);

    data->stack.pop_back();
    data->atts.clear();
    data->current.clear();
}

void character_data_handler(void* udata, const XML_Char* s, int len)
{
    user_data* data = (user_data*)udata;
    string_view x{s, size_t(len)};

    auto trimmed = trim(x);

    if (trimmed.size()) {
        data->current.append(trimmed.begin(), trimmed.end());
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

    int keys_only = 0;
    int show_filename = 0;

    while (argv[0][0] == '-' && argv[0][1] == '-') {
        if (strcmp(*argv, "--keys") == 0) {
            keys_only = 1;
            ++argv;
            --argc;
        }
        if (strcmp(*argv, "--filename") == 0) {
            show_filename = 1;
            ++argv;
            --argc;
        }
    }

    // create parser
    xml_parser parser;

    while (argc) {
        user_data data;
        data.filename = *argv;
        data.keys_only = keys_only;
        data.show_filename = show_filename;

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
