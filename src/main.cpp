#ifndef __linux__
#error "This program can only be compiled on Linux!"
#endif
#include "main.hpp"

int main(int argc, char *argv[]) {
    if (argc == 1) {
        help();
        return 0;
    }

    for (int i = 1; i < argc; i++) {
        string arg = argv[i];

        if (arg == HELP || arg == HELP2) {
            help();
        } else if (arg == SETUP) {
            setup();
        } else if (arg == CLEANUP) {
            cleanup();
        } else {
            cout << "Error: Unknown argument '" << arg << "'" << endl;
            cout << "Use " << HELP << " for help." << endl;
            return 1;
        }
    }
    return 0;
}