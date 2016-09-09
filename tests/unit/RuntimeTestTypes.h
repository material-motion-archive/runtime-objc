/*
 Copyright 2016 The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy
 of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations
 under the License.
 */

@import MaterialMotionRuntime;

@interface TestPerformerA : NSObject <MDMPlanPerforming>
@property(nonatomic) bool boolean;
@end

@interface TestPerformerB : NSObject <MDMPlanPerforming>
@property(nonatomic) bool boolean;
@end

@interface TestPerformerSubclass : TestPerformerA
@end

@interface TestPlanA : NSObject <MDMPlan>
@property(nonatomic) bool desiredBoolean;
@end

@interface TestPlanB : NSObject <MDMPlan>
@property(nonatomic) bool desiredBoolean;
@end

@interface TestPlanSubclassA : TestPlanA
@end

// - (Class)performerClass is overridden
@interface TestPlanSubclassB : TestPlanA
@end

@interface TestState : NSObject
@property(nonatomic) bool boolean;
@end
