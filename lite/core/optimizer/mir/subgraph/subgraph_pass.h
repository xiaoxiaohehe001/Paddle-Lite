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

#pragma once

#include <memory>
#include <vector>
#include "lite/core/optimizer/mir/pass.h"

namespace paddle {
namespace lite {
namespace mir {

class NPUSubgraphPass : public ProgramPass {
 public:
  void Apply(const std::unique_ptr<SSAGraph>& graph) override;
};

class BMSubgraphPass : public ProgramPass {
 public:
  void Apply(const std::unique_ptr<SSAGraph>& graph) override;
};

class MLUSubgraphPass : public ProgramPass {
 public:
  void Apply(const std::unique_ptr<SSAGraph>& graph) override;
};

class NNAdapterSubgraphPass : public ProgramPass {
 public:
  void Apply(const std::unique_ptr<SSAGraph>& graph) override;
};

}  // namespace mir
}  // namespace lite
}  // namespace paddle
