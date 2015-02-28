#ifndef FS_HPP
#define FS_HPP

#include <sys/types.h>
#include <dirent.h>

namespace fs {

class file {
    private:
        dirent* ent;
    public:
        file() : ent(0) {}
        file(dirent* ent) : ent(ent) {}

        const char* name() const { return ent->d_name; }
        bool at_end() const { return ent == 0; }
};

class dir {
    private:
        DIR* dir_ent;
        const char* name_;
    public:
        dir() : dir_ent(0), name_(0) {}
        dir(const char* name) : dir_ent(opendir(name)), name_(name) {}
        ~dir() { if (dir_ent) closedir(dir_ent); }

        const char* name() const { return name_; }

        file next_file() {
            return file(readdir(dir_ent));
        }
};

bool next_file(dir& d, file& f) {
    f = d.next_file();
    return !f.at_end();
}

}

#endif
