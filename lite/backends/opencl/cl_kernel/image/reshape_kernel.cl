/* Copyright (c) 2018 PaddlePaddle Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

#include <cl_common.h>

__kernel void reshape(__read_only image2d_t input_image,
                      __write_only image2d_t output_image,
                      __private const int out_C,
                      __private const int out_H,
                      __private const int out_W,
                      __private const int in_W,
                      __private const int in_H,
                      __private const int in_Stride0,
                      __private const int in_Stride1,
                      __private const int in_Stride2,
                      __private const int out_Stride0,
                      __private const int out_Stride1,
                      __private const int out_Stride2) {
  const int out_c = get_global_id(0);
  const int out_w = get_global_id(1);
  const int out_nh = get_global_id(2);

  const int out_n = out_nh / out_H;
  const int out_h = out_nh % out_H;

  const int out_c0 = out_c * 4;
  const int out_c1 = out_c * 4 + 1;
  const int out_c2 = out_c * 4 + 2;
  const int out_c3 = out_c * 4 + 3;

  int count0 =
      out_n * out_Stride2 + out_c0 * out_Stride1 + out_h * out_Stride0 + out_w;
  int count1 =
      out_n * out_Stride2 + out_c1 * out_Stride1 + out_h * out_Stride0 + out_w;
  int count2 =
      out_n * out_Stride2 + out_c2 * out_Stride1 + out_h * out_Stride0 + out_w;
  int count3 =
      out_n * out_Stride2 + out_c3 * out_Stride1 + out_h * out_Stride0 + out_w;

  int in_n0 = count0 / in_Stride2;
  int in_n1 = count1 / in_Stride2;
  int in_n2 = count2 / in_Stride2;
  int in_n3 = count3 / in_Stride2;

  count0 = count0 % in_Stride2;
  count1 = count1 % in_Stride2;
  count2 = count2 % in_Stride2;
  count3 = count3 % in_Stride2;

  int in_c0 = count0 / in_Stride1;
  int in_c1 = count1 / in_Stride1;
  int in_c2 = count2 / in_Stride1;
  int in_c3 = count3 / in_Stride1;

  int in_h0 = (count0 % in_Stride1) / in_Stride0;
  int in_h1 = (count1 % in_Stride1) / in_Stride0;
  int in_h2 = (count2 % in_Stride1) / in_Stride0;
  int in_h3 = (count3 % in_Stride1) / in_Stride0;

  int in_w0 = (count0 % in_Stride1) % in_Stride0;
  int in_w1 = (count1 % in_Stride1) % in_Stride0;
  int in_w2 = (count2 % in_Stride1) % in_Stride0;
  int in_w3 = (count3 % in_Stride1) % in_Stride0;

  int2 input_pos0;
  int2 input_pos1;
  int2 input_pos2;
  int2 input_pos3;

  input_pos0.x = (in_c0 / 4) * in_W + in_w0;
  input_pos0.y = in_n0 * in_H + in_h0;

  input_pos1.x = (in_c1 / 4) * in_W + in_w1;
  input_pos1.y = in_n1 * in_H + in_h1;

  input_pos2.x = (in_c2 / 4) * in_W + in_w2;
  input_pos2.y = in_n2 * in_H + in_h2;

  input_pos3.x = (in_c3 / 4) * in_W + in_w3;
  input_pos3.y = in_n3 * in_H + in_h3;

  int2 output_pos;
  output_pos.x = out_c * out_W + out_w;
  output_pos.y = out_nh;

  CL_DTYPE4 input0;
  CL_DTYPE4 input1;
  CL_DTYPE4 input2;
  CL_DTYPE4 input3;
  CL_DTYPE4 output;

  input0 = READ_IMG_TYPE(CL_DTYPE_CHAR, input_image, SAMPLER, input_pos0);
  if (in_c0 % 4 == 0) {
    output.x = input0.x;
  } else if (in_c0 % 4 == 1) {
    output.x = input0.y;
  } else if (in_c0 % 4 == 2) {
    output.x = input0.z;
  } else {
    output.x = input0.w;
  }
  if (out_C - out_c * 4 >= 2) {
    input1 = READ_IMG_TYPE(CL_DTYPE_CHAR, input_image, SAMPLER, input_pos1);
    if (in_c1 % 4 == 0) {
      output.y = input1.x;
    } else if (in_c1 % 4 == 1) {
      output.y = input1.y;
    } else if (in_c1 % 4 == 2) {
      output.y = input1.z;
    } else {
      output.y = input1.w;
    }

  } else {
    output.y = 0.0f;
  }

  if (out_C - out_c * 4 >= 3) {
    input2 = READ_IMG_TYPE(CL_DTYPE_CHAR, input_image, SAMPLER, input_pos2);

    if (in_c2 % 4 == 0) {
      output.z = input2.x;
    } else if (in_c2 % 4 == 1) {
      output.z = input2.y;
    } else if (in_c2 % 4 == 2) {
      output.z = input2.z;
    } else {
      output.z = input2.w;
    }
  } else {
    output.z = 0.0f;
  }

  if (out_C - out_c * 4 >= 4) {
    input3 = READ_IMG_TYPE(CL_DTYPE_CHAR, input_image, SAMPLER, input_pos3);
    if (in_c3 % 4 == 0) {
      output.w = input3.x;
    } else if (in_c3 % 4 == 1) {
      output.w = input3.y;
    } else if (in_c3 % 4 == 2) {
      output.w = input3.z;
    } else {
      output.w = input3.w;
    }
  } else {
    output.w = 0.0f;
  }

  WRITE_IMG_TYPE(CL_DTYPE_CHAR, output_image, output_pos, output);
}
