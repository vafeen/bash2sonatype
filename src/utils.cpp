#include "main.hpp"

vector <string> dependencies = {
//        "curl",
//        "wget",
//        "git",
        "unzip",
        "software-properties-common",
        "ca-certificates",
        "openjdk-17-jdk",
        "maven",
//        gpg utils
        "gnupg",
        "gnupg-agent",
        "gpg",
        "gpgconf",
        "pinentry-curses"
};

void help() {
    vector <string> info = {
            "Hello! This is make2maven",
            "Commands:",
            HELP + " , " + HELP2 + " - get help",
            SETUP + " - install dependencies",
            CLEANUP + " - remove dependencies",
    };
    for (size_t i = 0, size = info.size(); i < size; i++) {
        cout << info[i] << '\n';
    }
}

void setup() {
    cout << "Starting setup..." << '\n';

    system("sudo apt update -y");

    for (size_t i = 0, size = dependencies.size(); i < size; i++) {
        string command = "sudo apt install " + dependencies[i] + " -y";
        cout << "Installing: " << dependencies[i] << '\n';
        system(command.c_str());
    }

    cout << "Creating ~/.gnupg directory..." << '\n';
    system("mkdir -p ~/.gnupg");
    system("chmod 700 ~/.gnupg");
    system("echo 'pinentry-program /usr/bin/pinentry-curses\ndefault-cache-ttl 600\nmax-cache-ttl 7200' > ~/.gnupg/gpg-agent.conf");
    system("chmod 600 ~/.gnupg/gpg-agent.conf");

    // 7. Перезапуск gpg-agent
    cout << "Restarting gpg-agent..." << '\n';
    system("gpg-connect-agent reloadagent /bye");

    cout << "Setup completed successfully!" << '\n';
}

void cleanup() {
    cout << "Starting cleanup..." << '\n';

    for (size_t i = 0, size = dependencies.size(); i < size; i++) {
        string command = "sudo apt remove " + dependencies[i] + " -y";
        cout << "Removing: " << dependencies[i] << '\n';
        system(command.c_str());
    }
    system("sudo apt autoremove -y");
    system("sudo apt autoclean");
//    system("rm -rf ~/.gnupg");
    cout << "Cleanup completed!" << '\n';
}