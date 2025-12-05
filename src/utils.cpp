#ifndef __linux__
#error "This program can only be compiled on Linux!"
#endif

#include "main.hpp"

vector<string> dependencies = {
    //        "curl",
    //        "wget",
    //        "git",
    "unzip", "software-properties-common", "ca-certificates", "openjdk-17-jdk",
    "maven",
    //        gpg 1_utils
    "gnupg", "gnupg-agent", "gpg", "gpgconf", "pinentry-curses"};

void help() {
  vector<string> info = {
      "Hello! This is make2maven",          "Commands:",
      HELP + " , " + HELP2 + " - get help", SETUP + " - install dependencies",
      CLEANUP + " - remove dependencies",   BUILD + " - build project"};
  for (size_t i = 0, size = info.size(); i < size; i++) {
    cout << info[i] << '\n';
  }
}

void setup() {
  cout << "Starting setup..." << '\n';

  systemWithPrint("sudo apt update -y");

  for (size_t i = 0, size = dependencies.size(); i < size; i++) {
    string command = "sudo apt install " + dependencies[i] + " -y";
    cout << "Installing: " << dependencies[i] << '\n';
    systemWithPrint(command);
  }

  cout << "Creating ~/.gnupg directory..." << '\n';
  systemWithPrint("mkdir -p ~/.gnupg");
  systemWithPrint("chmod 700 ~/.gnupg");
  systemWithPrint(
      "echo 'pinentry-program /usr/bin/pinentry-curses\ndefault-cache-ttl "
      "600\nmax-cache-ttl 7200' > ~/.gnupg/gpg-agent.conf");
  systemWithPrint("chmod 600 ~/.gnupg/gpg-agent.conf");

  cout << "Restarting gpg-agent..." << '\n';
  systemWithPrint("gpg-connect-agent reloadagent /bye");

  cout << "Setup completed successfully!" << '\n';
}

void cleanup() {
  cout << "Starting cleanup..." << '\n';

  for (size_t i = 0, size = dependencies.size(); i < size; i++) {
    string command = "sudo apt remove " + dependencies[i] + " -y";
    cout << "Removing: " << dependencies[i] << '\n';
    systemWithPrint(command);
  }
  systemWithPrint("sudo apt autoremove -y");
  systemWithPrint("sudo apt autoclean");
  //    systemWithPrint("rm -rf ~/.gnupg");
  cout << "Cleanup completed!" << '\n';
}

void build() {
  cout << "start building...";
  systemWithPrint("bash ./gradlew build");
}

void systemWithPrint(const string &command) {
  cout << '\n' << command << '\n';
  system(command.c_str());
}
