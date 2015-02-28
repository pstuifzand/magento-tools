#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <iomanip>
#include <sstream>
#include "fs.hpp"
#include "xml.hpp"

enum class State {
    ERROR,
    ROOT,
    IN_CONFIG,
    IN_MODULES,
    IN_MODULE,

    IN_ACTIVE,
    IN_CODEPOOL,
    IN_DEPENDS,
};

const char* state_names[] = {
    "ERROR",
    "ROOT",
    "IN_CONFIG",
    "IN_MODULES",
    "IN_MODULE",
    "IN_ACTIVE",
    "IN_CODEPOOL",
    "IN_DEPENDS",
};

struct user_data {
    const char* filename;
    std::string current_name;
    std::string current_text;
    State state;
    bool active;
    std::string codepool;

    user_data() : state(State::ROOT) {}
};

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts) {
    user_data* data = (user_data*)udata;

    //std::cout << state_names[int(data->state)] << " " << name << "\n";

    switch (data->state) {
        case State::ROOT:
            // expect <config>
            if (strcmp(name, "config") == 0) data->state = State::IN_CONFIG;
            break;
        case State::IN_CONFIG:
            // expect <modules>
            if (strcmp(name, "modules") == 0) data->state = State::IN_MODULES;
            break;
        case State::IN_MODULES:
            // name == module_name
            data->current_name = name;
            data->state = State::IN_MODULE;
            break;
        case State::IN_MODULE:
            if (strcmp(name, "active") == 0) data->state = State::IN_ACTIVE;
            if (strcmp(name, "codePool") == 0) data->state = State::IN_CODEPOOL;
            if (strcmp(name, "depends") == 0) data->state = State::IN_DEPENDS;
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
            data->state = State::ROOT;
            break;
        case State::IN_MODULES:
            if (strcmp(name, "modules") == 0) data->state = State::IN_CONFIG;
            break;
        case State::IN_MODULE:
            // output module info
            std::cout << std::setw(30) << std::left << data->current_name;
            std::cout << std::setw(6) << std::left << (data->active ? "true" : "false");
            std::cout << std::setw(10) << std::left << data->codepool;
            std::cout << data->filename << "\n";
            data->state = State::IN_MODULES;
            break;
        case State::IN_ACTIVE:
            if (strcmp(name, "active") == 0) data->state = State::IN_MODULE;
            data->active = strcmp("true", data->current_text.c_str()) == 0;
            data->current_text.clear();
            break;
        case State::IN_CODEPOOL:
            if (strcmp(name, "codePool") == 0) data->state = State::IN_MODULE;
            data->codepool = data->current_text;
            data->current_text.clear();
            break;
        case State::IN_DEPENDS:
            if (strcmp(name, "depends") == 0) data->state = State::IN_MODULE;
            break;
    }
}

void character_data_handler(void* udata, const XML_Char* s, int len) {
    user_data* data = (user_data*)udata;
    switch (data->state) {
        case State::IN_ACTIVE:
        case State::IN_CODEPOOL:
            data->current_text.append(s, len);
            break;
        case State::IN_DEPENDS:
            break;
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

struct parse_module_config {
    xml_parser parser;
    user_data  data;

    void operator()(const fs::file& f) {
        XML_SetUserData(parser.handle(), &data);
        XML_SetElementHandler(parser.handle(), root_start_element_handler, root_end_element_handler);
        XML_SetCharacterDataHandler(parser.handle(), character_data_handler);

        data.filename = f.name();

        std::stringstream name;
        name << "app/etc/modules/";
        name << f.name();

        std::ifstream in{name.str()};
        if (in) parse_xml(parser, in, &data);
        else std::cerr << "Can't open " << name.str() << "\n";
        parser.reset();
    }
};

template <typename F>
void for_all_files(fs::dir& d, F func) {
    fs::file f;
    while (next_file(d, f)) {
        if (f.name()[0] == '.') continue;
        func(f);
    }
}


int main(int argc, char** argv) {
    fs::dir module_dir{"app/etc/modules"};

    for_all_files(module_dir, parse_module_config());
}

