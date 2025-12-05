#ifndef __linux__
    #error "This program can only be compiled on Linux!"
#endif
#ifndef MAIN_HPP
#define MAIN_HPP

#include <iostream>
#include <string>
#include <vector>

using namespace std;

const string HELP = "--help";
const string HELP2 = "-h";
const string SETUP = "setup";
const string CLEANUP = "cleanup";

void help();
void setup();
void cleanup();

#endif