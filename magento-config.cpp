#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <iomanip>
#include <sstream>
#include <vector>
#include <algorithm>
#include "xml.hpp"

enum class State {
    ERROR,
    ROOT,
    IN_CONFIG,
    IN_SECTIONS,
    IN_SECTION,
    IN_GROUPS,
    IN_GROUP,
    IN_FIELDS,
    IN_FIELD,
};

const char* state_names[] = {
    "ERROR",
    "ROOT",
    "IN_CONFIG",
    "IN_SECTIONS",
    "IN_SECTION",
    "IN_GROUPS",
    "IN_GROUP",
    "IN_FIELDS",
    "IN_FIELD",
};

struct user_data {
    State state;
    const char* filename;
    std::string section, group, field;
    std::vector<std::string> names;
    user_data() : state(State::ROOT), filename(0) {}
};

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts) {
    user_data* data = (user_data*)udata;
    switch (data->state) {
        case State::ROOT:
            if (strcmp(name, "config") == 0) data->state = State::IN_CONFIG;
            break;
        case State::IN_CONFIG:
            if (strcmp(name, "sections") == 0) data->state = State::IN_SECTIONS;
            break;
        case State::IN_SECTIONS:
            data->state = State::IN_SECTION;
            data->section = name;
            break;
        case State::IN_SECTION:
            if (strcmp(name, "groups") == 0) data->state = State::IN_GROUPS;
            break;
        case State::IN_GROUPS:
            data->group = name;
            data->state = State::IN_GROUP;
            break;
        case State::IN_GROUP:
            if (strcmp(name, "fields") == 0) data->state = State::IN_FIELDS;
            break;
        case State::IN_FIELDS:
            data->field = name;
            data->state = State::IN_FIELD;
            std::stringstream ss;
            ss << data->section << "/" << data->group << "/" << data->field;
            data->names.push_back(ss.str());
            break;
    }
}

void root_end_element_handler(void* udata, const XML_Char* name) {
    user_data* data = (user_data*)udata;
    switch (data->state) {
        case State::ROOT:
            break;
        case State::IN_CONFIG:
            if (strcmp(name, "config") == 0) data->state = State::ROOT;
            break;
        case State::IN_SECTIONS:
            if (strcmp(name, "sections") == 0) data->state = State::IN_CONFIG;
            break;
        case State::IN_SECTION:
            if (strcmp(name, data->section.c_str()) == 0) data->state = State::IN_SECTIONS;
            break;
        case State::IN_GROUPS:
            if (strcmp(name, "groups") == 0) data->state = State::IN_SECTION;
            break;
        case State::IN_GROUP:
            if (strcmp(name, data->group.c_str()) == 0) data->state = State::IN_GROUPS;
            break;
        case State::IN_FIELDS:
            if (strcmp(name, "fields") == 0) data->state = State::IN_GROUP;
            break;
        case State::IN_FIELD:
            if (strcmp(name, data->field.c_str()) == 0) data->state = State::IN_FIELDS;
            break;
    }
}

void character_data_handler(void* udata, const XML_Char* s, int len) {
    user_data* data = (user_data*)udata;
    switch (data->state) {
        case State::ROOT:
            break;
        case State::IN_CONFIG:
            break;
        case State::IN_SECTIONS:
            break;
        case State::IN_SECTION:
            break;
        case State::IN_GROUPS:
            break;
        case State::IN_GROUP:
            break;
        case State::IN_FIELDS:
            break;
        case State::IN_FIELD:
            break;
    }
}

struct parse_module_config {
    xml_parser parser;
    user_data  data;

    void operator()(const char* filename) {
        XML_SetUserData(parser.handle(), &data);
        XML_SetElementHandler(parser.handle(), root_start_element_handler, root_end_element_handler);
        XML_SetCharacterDataHandler(parser.handle(), character_data_handler);

        data.filename = filename;

        std::ifstream in{data.filename};
        if (in) parse_xml(parser, in, &data);
        else std::cerr << "Can't open " << data.filename << "\n";

        std::sort(std::begin(data.names), std::end(data.names));

        for (auto& s : data.names) {
            std::cout << s << "\n";
        }
        
        parser.reset();
    }
};

int main(int argc, char** argv) {
    parse_module_config parse;

    argc--;
    argv++;

    while (argc) {
        parse(*argv);
        argc--;
        argv++;
    }
}

