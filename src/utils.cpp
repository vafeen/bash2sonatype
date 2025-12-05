#include "main.hpp"

void help() {
    vector <string> info = {
            "Hello! This is make2maven",
            "Commands:",
            HELP + " , " + HELP2 + " - get help",
            SETUP + " - install dependencies",
            CLEANUP + " - remove dependencies",
    };
    for (size_t i = 0, infoSize = info.size(); i < infoSize; i++) {
        cout << info[i] << '\n';
    }
}

void setup() {

}

void cleanup() {

}