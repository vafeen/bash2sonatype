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
            cout << "Ошибка: Неизвестный аргумент '" << arg << "'" << endl;
            cout << "Используйте " << HELP << " для получения справки." << endl;
            return 1;
        }
    }
    return 0;
}