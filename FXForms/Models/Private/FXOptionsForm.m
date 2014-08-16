//
//  FXOptionsForm.m
//
//  Version 1.2 beta 11
//
//  Created by Nick Lockwood on 13/02/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/FXForms
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FXOptionsForm.h"
#import "FXFormField_Private.h"
#import "FXForms_Private.h"

#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wgnu"

@implementation FXOptionsForm

- (instancetype)initWithField:(FXFormField *)field
{
    if ((self = [super init]))
    {
        _field = field;
        id action = ^(__unused id sender)
        {
            if (field.action)
            {
                //this nasty hack is necessary to pass the expected cell as the sender
                FXFormController *formController = field.formController;
                [formController enumerateFieldsWithBlock:^(FXFormField *f, NSIndexPath *indexPath) {
                    if ([f.key isEqual:field.key])
                    {
                        field.action([formController.tableView cellForRowAtIndexPath:indexPath]);
                    }
                }];
            }
        };
        NSMutableArray *fields = [NSMutableArray array];
        if (field.placeholder)
        {
            [fields addObject:@{FXFormFieldKey: @"0",
                                FXFormFieldTitle: [field.placeholder fieldDescription],
                                FXFormFieldType: FXFormFieldTypeOption,
                                FXFormFieldAction: action}];
        }
        for (NSUInteger i = 0; i < [field.options count]; i++)
        {
            NSInteger index = i + (field.placeholder? 1: 0);
            [fields addObject:@{FXFormFieldKey: [@(index) description],
                                FXFormFieldTitle: [field optionDescriptionAtIndex:index],
                                FXFormFieldType: FXFormFieldTypeOption,
                                FXFormFieldAction: action}];
        }
        _fields = fields;
    }
    return self;
}

- (id)valueForKey:(NSString *)key
{
    NSInteger index = [key integerValue];
    return @([self.field isOptionSelectedAtIndex:index]);
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSUInteger index = [key integerValue];
    [self.field setOptionSelected:[value boolValue] atIndex:index];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if ([NSStringFromSelector(selector) hasPrefix:@"set"])
    {
        return YES;
    }
    return [super respondsToSelector:selector];
}

@end
