#include <expat.h>
#include <cstring>
#include <iostream>
#include <fstream>

enum class State {
    ERROR,
    WAIT_FOR_SECTION,

    IN_HELPERS,
    IN_HELPER,
    IN_HELPER_CLASS,

    IN_MODELS,
    IN_MODEL,
    IN_MODEL_CLASS,

    IN_BLOCKS,
    IN_BLOCK,
    IN_BLOCK_CLASS,
};

enum class CodePool {
    CORE,
    COMMUNITY,
    LOCAL,
    ERROR,
};

static
const char* pool_name[] = {
    "core",
    "community",
    "local",
    "error",
};

static
const char* state_name[] = {
    "ERROR",
    "WAIT_FOR_SECTION",

    "IN_HELPERS",
    "IN_HELPER",
    "IN_HELPER_CLASS",

    "IN_MODELS",
    "IN_MODEL",
    "IN_MODEL_CLASS",

    "IN_BLOCKS",
    "IN_BLOCK",
    "IN_BLOCK_CLASS",
};

struct user_data {
    State state;

    std::string name;
    std::string current_text;

    const char* filename;

    CodePool pool;
};

static 
const char* section_name[] = {
    "",
    "",
    "",
    "",
    "Helper: ",
    "",
    "",
    "Model: ",
    "",
    "",
    "Block: ",
};

static
const State start_element_next_state[] = {
    State::ERROR,
    State::ERROR,

    State::IN_HELPER,
    State::IN_HELPER_CLASS,
    State::ERROR,

    State::IN_MODEL,
    State::IN_MODEL_CLASS,
    State::ERROR,

    State::IN_BLOCK,
    State::IN_BLOCK_CLASS,
    State::ERROR,
};

static
const State end_element_next_state[] = {
    State::ERROR,
    State::ERROR,

    State::WAIT_FOR_SECTION,
    State::IN_HELPERS,
    State::IN_HELPER,

    State::WAIT_FOR_SECTION,
    State::IN_MODELS,
    State::IN_MODEL,

    State::WAIT_FOR_SECTION,
    State::IN_BLOCKS,
    State::IN_BLOCK,
};

CodePool find_code_pool(const char* filename) {
    int n         = strlen(filename);
    const char* p = filename;

    while (1) {
        if (strncmp("app/code/", p, 9) == 0) {
            p += 9;
            n -= 9;
            break;
        }
        while (n && *p != '/') { ++p; --n; }
        if (!n) break;
        ++p; --n;
    }
    if (strncmp("cor", p, 3) == 0) return CodePool::CORE;
    if (strncmp("com", p, 3) == 0) return CodePool::COMMUNITY;
    if (strncmp("loc", p, 3) == 0) return CodePool::LOCAL;
    return CodePool::ERROR;
}

void root_start_element_handler(void* udata, const XML_Char* name, const XML_Char** atts) {
    user_data* data = (user_data*)udata;

    switch (data->state) {
        case State::WAIT_FOR_SECTION: {
            if (strcmp("helpers", name) == 0) data->state = State::IN_HELPERS;
            if (strcmp("models", name) == 0) data->state = State::IN_MODELS;
            if (strcmp("blocks", name) == 0) data->state = State::IN_BLOCKS;
        } break;

        case State::IN_HELPERS:
        case State::IN_MODELS:
        case State::IN_BLOCKS: {
            // here is a tag with a variable name
            data->name.assign(name);
            data->state = start_element_next_state[int(data->state)];
        } break;

        case State::IN_HELPER:
        case State::IN_BLOCK:
        case State::IN_MODEL: {
            if (strcmp("class", name) == 0) data->state = start_element_next_state[int(data->state)];
        } break;
    }
}

void root_end_element_handler(void* udata, const XML_Char* name) {
    user_data* data = (user_data*)udata;

    switch (data->state) {
        case State::IN_HELPERS:
        case State::IN_MODELS:
        case State::IN_BLOCKS:
            if (strcmp("helpers", name) == 0) data->state = end_element_next_state[int(data->state)];
            if (strcmp("models", name) == 0) data->state = end_element_next_state[int(data->state)];
            if (strcmp("blocks", name) == 0) data->state = end_element_next_state[int(data->state)];
            break;
        case State::IN_HELPER:
        case State::IN_MODEL:
        case State::IN_BLOCK:
            // here is a tag with a variable name
            // expat checks mismatched tags
            data->state = end_element_next_state[int(data->state)];
            break;
        case State::IN_HELPER_CLASS:
        case State::IN_MODEL_CLASS:
        case State::IN_BLOCK_CLASS:
            // where about to leave the <class> block, so print the info we gathered
            if (strcmp("class", name) == 0) {
                std::cout << section_name[int(data->state)] << data->name << " => " << data->current_text << " (" << pool_name[int(data->pool)] << ")\n";
                data->current_text = "";
                data->state = end_element_next_state[int(data->state)];
            }
            break;
    }
}

void character_data_handler(void* udata, const XML_Char* s, int len) {
    user_data* data = (user_data*)udata;
    switch (data->state) {
        case State::IN_HELPER_CLASS:
        case State::IN_MODEL_CLASS:
        case State::IN_BLOCK_CLASS:
            data->current_text.append(s, len);
            break;
    }
}

void parse_xml(XML_Parser parser, std::ifstream& in, user_data* data) {
    const int size = 1024;
    char buf[size];
    while (in) {
        in.read(buf, size);
        XML_Status ret = XML_Parse(parser, buf, in.gcount(), in ? 0 : 1);
        if (!ret) {
            XML_Error error = XML_GetErrorCode(parser);
            int line = XML_GetCurrentLineNumber(parser);
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
    XML_Parser parser = XML_ParserCreate(0);

    while (argc) {
        user_data data = { State::WAIT_FOR_SECTION };
        data.filename = *argv;

        XML_SetUserData(parser, &data);
        XML_SetElementHandler(parser, root_start_element_handler, root_end_element_handler);
        XML_SetCharacterDataHandler(parser, character_data_handler);

        data.pool = find_code_pool(data.filename);
        if (data.pool != CodePool::ERROR) {
            std::ifstream in{data.filename};
            if (in) parse_xml(parser, in, &data);
            XML_ParserReset(parser, 0);
        } else {
            std::cout << "File skipped: " << data.filename << "\n";
        }

        argc--;
        argv++;
    }

    XML_ParserFree(parser);
}

