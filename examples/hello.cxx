#include <hello_hip.hxx>
#include <iostream>

int main(int argc, char** argv) {

  std::cout << "Hellow World!" << std::endl;

  set_device(0);
  launch_hello_hip();
}