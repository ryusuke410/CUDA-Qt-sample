#include <iostream>

#include <astaticlib.h>

int main() {
  const int count = 10;
  auto *const vec0 = new float[count];
  auto *const vec1 = new float[count];
  auto *const result = new float[count];

  for (int i = 0; i < count; ++i) {
    vec0[i] = float(i);
    vec1[i] = float(i);
  }

  astaticlib::vectAdd(count, vec0, vec1, result);

  for (int i = 0; i < count; ++i) {
    std::cout << i << ", " << result[i] << std::endl;
  }

  return 0;
}
