#include "astaticlib.h"

#include "vectadd.cuh"

namespace astaticlib {

void vectAdd(int count, const float *vec0, const float *vec1, float *added) {
  vectadd::vectAdd(count, vec0, vec1, added);
}

}  // namespace astaticlib
