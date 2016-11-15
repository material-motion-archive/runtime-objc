/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

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

#import "MDMConsoleLoggingTracer.h"

#import <objc/runtime.h>

static NSString *debugDescriptionOfPlanProperties(NSObject<MDMPlan> *plan) {
  NSMutableArray *propertyDescriptions = [NSMutableArray array];
  unsigned int numberOfProperties = 0;
  objc_property_t *properties = class_copyPropertyList([plan class], &numberOfProperties);
  for (unsigned int ix = 0; ix < numberOfProperties; ix++) {
    objc_property_t property = properties[ix];
    const char *propName = property_getName(property);
    if (propName) {
      NSString *propertyName = [NSString stringWithCString:propName
                                                  encoding:[NSString defaultCStringEncoding]];
      const char *attributes = property_getAttributes(property);
      NSString *propertyType = [NSString stringWithCString:attributes
                                                  encoding:[NSString defaultCStringEncoding]];
      NSArray *propertyTypeComponents = [propertyType componentsSeparatedByString:@"\""];
      if ([propertyTypeComponents count] > 1) {
        propertyType = propertyTypeComponents[1];
      } else {
        propertyType = @"@";
      }

      [propertyDescriptions addObject:[NSString stringWithFormat:
                                                    @"  let %@: %@ = %@",
                                                    propertyName,
                                                    propertyType,
                                                    [plan valueForKey:propertyName]]];
    }
  }
  free(properties);

  return [propertyDescriptions componentsJoinedByString:@"\n"];
}

@implementation MDMConsoleLoggingTracer

- (void)didAddPlan:(NSObject<MDMPlan> *)plan to:(id)target {
  NSLog(@"didAddPlan to target: %@\nPlan: %@\n%@\n\n",
        target,
        NSStringFromClass([plan class]),
        debugDescriptionOfPlanProperties(plan));
}

- (void)didAddPlan:(id)plan named:(NSString *)name to:(id)target {
  NSLog(@"didAddPlan named %@ to target: %@\nPlan: %@\n%@\n\n",
        name,
        target,
        NSStringFromClass([plan class]),
        debugDescriptionOfPlanProperties(plan));
}

- (void)didRemovePlanNamed:(NSString *)name from:(id)target {
  NSLog(@"didRemovePlan named %@ from target: %@\n\n", name, target);
}

- (void)didCreatePerformer:(NSObject<MDMPerforming> *)performer for:(id)target {
  NSLog(@"didCreatePerformer: %@ for: %@\n\n", NSStringFromClass([performer class]), target);
}

@end
