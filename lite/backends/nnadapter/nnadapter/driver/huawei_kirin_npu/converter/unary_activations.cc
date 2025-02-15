// Copyright (c) 2019 PaddlePaddle Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "core/operation/unary_activations.h"
#include "driver/huawei_kirin_npu/converter/converter.h"
#include "utility/debug.h"
#include "utility/logging.h"

namespace nnadapter {
namespace huawei_kirin_npu {

int ConvertUnaryActivations(Converter* converter, hal::Operation* operation) {
  UNARY_ACTIVATIONS_OPERATION_EXTRACT_INPUTS_OUTPUTS

  // Convert to GE operators
  auto input_operator = converter->GetMappedOperator(input_operand);
  if (!input_operator) {
    input_operator = converter->ConvertOperand(input_operand);
  }
  switch (operation->type) {
#define CONVERT_UNARY_ACTIVATION(type, act_mode)                      \
  case NNADAPTER_##type: {                                            \
    auto act_op =                                                     \
        converter->AddOperator<hiai::op::Activation>(output_operand); \
    act_op->set_attr_mode(act_mode);                                  \
    SET_INPUT(act_op, x, input_operator);                             \
    MAP_OUTPUT(act_op, y, output_operand);                            \
  } break;
    CONVERT_UNARY_ACTIVATION(SIGMOID, 0);
    CONVERT_UNARY_ACTIVATION(RELU, 1);
    CONVERT_UNARY_ACTIVATION(RELU6, 14);
    CONVERT_UNARY_ACTIVATION(TANH, 2);
    CONVERT_UNARY_ACTIVATION(ABS, 6);
#undef CONVERT_UNARY_ACTIVATION
#define CONVERT_UNARY_ACTIVATION(type, class_name)                    \
  case NNADAPTER_##type: {                                            \
    auto act_op =                                                     \
        converter->AddOperator<hiai::op::class_name>(output_operand); \
    SET_INPUT(act_op, x, input_operator);                             \
    MAP_OUTPUT(act_op, y, output_operand);                            \
  } break;
    CONVERT_UNARY_ACTIVATION(LOG, Log);
    CONVERT_UNARY_ACTIVATION(EXP, Exp);
    CONVERT_UNARY_ACTIVATION(FLOOR, Floor);
    CONVERT_UNARY_ACTIVATION(SQUARE, Square);
#undef CONVERT_UNARY_ACTIVATION
    default:
      NNADAPTER_LOG(FATAL) << "Unsupported activation operation type "
                           << OperationTypeToString(operation->type)
                           << " is found.";
      break;
  }
  return NNADAPTER_NO_ERROR;
}

}  // namespace huawei_kirin_npu
}  // namespace nnadapter
