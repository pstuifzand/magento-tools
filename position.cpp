#include <expat.h>
#include <cstring>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "xml.hpp"

enum class State {
    NOT_FOUND,
    FOUND,
};

struct user_data {
    char* filename;
    std::vector<std::string> stack;
    xml_parser* parser;

    int line;
    int col;

    State state;
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

std::string trim(const std::string& s)
{
    auto f = trim_front(s.begin(), s.end());
    auto l = trim_back(f, s.end());

    return std::string{f,l};
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
            print_stack(f0, l0);
            std::cout << "\n";
        }
    }
}

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts)
{
    user_data* data = (user_data*)udata;
    data->stack.push_back(std::string(name));

    if (data->state == State::NOT_FOUND) {
        if (XML_GetCurrentLineNumber(data->parser->handle()) >= data->line
         && XML_GetCurrentColumnNumber(data->parser->handle()) >= data->col) {
            data->state = State::FOUND;
            print_stack(data->stack.begin(), data->stack.end());
            std::cout << "\n";
        }
    }
}

void root_end_element_handler(void* udata, const XML_Char* name)
{
    user_data* data = (user_data*)udata;
    if (data->state == State::NOT_FOUND) {
        if (XML_GetCurrentLineNumber(data->parser->handle()) >= data->line
         && XML_GetCurrentColumnNumber(data->parser->handle()) >= data->col) {
            data->state = State::FOUND;
            print_stack(data->stack.begin(), data->stack.end());
            std::cout << "\n";
        }
    }
    data->stack.pop_back();
}

void character_data_handler(void* udata, const XML_Char* s, int len)
{
    user_data* data = (user_data*)udata;
    if (data->state == State::NOT_FOUND) {
        if (XML_GetCurrentLineNumber(data->parser->handle()) >= data->line
         && XML_GetCurrentColumnNumber(data->parser->handle()) >= data->col) {
            data->state = State::FOUND;
            print_stack(data->stack.begin(), data->stack.end());
            std::cout << "\n";
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

    int line = 0;
    int col  = 0;

    if (argc >= 2) {
        line = std::stoi(argv[0]);
        col = std::stoi(argv[1]);
        argc -= 2;
        argv += 2;
    }

    // create parser
    xml_parser parser;

    while (argc) {
        user_data data;
        data.filename = *argv;
        data.parser = &parser;
        data.line = line;
        data.col = col;
        data.state = State::NOT_FOUND;

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

