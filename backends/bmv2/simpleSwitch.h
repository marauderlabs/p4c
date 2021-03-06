/*
Copyright 2013-present Barefoot Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#ifndef _BACKENDS_BMV2_SIMPLESWITCH_H_
#define _BACKENDS_BMV2_SIMPLESWITCH_H_

#include <algorithm>
#include <cstring>
#include "frontends/p4/fromv1.0/v1model.h"
#include "sharedActionSelectorCheck.h"

namespace BMV2 {

class Backend;

}  // namespace BMV2

namespace P4V1 {

class SimpleSwitch {
    BMV2::Backend* backend;
    V1Model&       v1model;

 protected:
    void addToFieldList(const IR::Expression* expr, Util::JsonArray* fl);
    int createFieldList(const IR::Expression* expr, cstring group,
                        cstring listName, Util::JsonArray* field_lists);
    cstring convertHashAlgorithm(cstring algorithm);
    cstring createCalculation(cstring algo, const IR::Expression* fields,
                              Util::JsonArray* calculations, const IR::Node* node);
    void generateUpdate(const IR::BlockStatement *block,
                        Util::JsonArray* checksums, Util::JsonArray* calculations);

 public:
    void convertExternObjects(Util::JsonArray *result, const P4::ExternMethod *em,
                              const IR::MethodCallExpression *mc, const IR::StatOrDecl *s);
    void convertExternFunctions(Util::JsonArray *result, const P4::ExternFunction *ef,
                                const IR::MethodCallExpression *mc, const IR::StatOrDecl* s);
    void convertExternInstances(const IR::Declaration *c,
                                const IR::ExternBlock* eb, Util::JsonArray* action_profiles,
                                BMV2::SharedActionSelectorCheck& selector_check);
    void convertChecksumUpdate(const IR::P4Control* updateControl,
                               Util::JsonArray* checksums, Util::JsonArray* calculations);

    void setPipelineControls(const IR::ToplevelBlock* blk, std::set<cstring>* controls,
                             std::map<cstring, cstring>* map);
    void setNonPipelineControls(const IR::ToplevelBlock* blk, std::set<cstring>* controls);
    void setUpdateChecksumControls(const IR::ToplevelBlock* blk, std::set<cstring>* controls);
    void setDeparserControls(const IR::ToplevelBlock* blk, std::set<cstring>* controls);

    explicit SimpleSwitch(BMV2::Backend* backend) :
        backend(backend), v1model(V1Model::instance)
    { CHECK_NULL(backend); }
};

}  // namespace P4V1

#endif /* _BACKENDS_BMV2_SIMPLESWITCH_H_ */
