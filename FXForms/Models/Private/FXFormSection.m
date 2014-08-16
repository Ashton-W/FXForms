//
//  FXFormSection.m
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

#import "FXFormSection.h"
#import "FXFormField_Private.h"
#import "FXTemplateForm.h"
#import "FXOptionsForm.h"
#import "NSObject+FXForms.h"

#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wgnu"

@implementation FXFormSection

+ (NSArray *)sectionsWithForm:(id<FXForm>)form controller:(FXFormController *)formController
{
    NSMutableArray *sections = [NSMutableArray array];
    FXFormSection *section = nil;
    for (FXFormField *field in [FXFormField fieldsWithForm:form controller:formController])
    {
        id<FXForm> subform = nil;
        if (field.options && field.isInline)
        {
            subform = [[FXOptionsForm alloc] initWithField:field];
        }
        else if ([field isCollectionType] && field.isInline)
        {
            subform = [[FXTemplateForm alloc] initWithField:field];
        }
        else if ([field.valueClass conformsToProtocol:@protocol(FXForm)] && field.isInline)
        {
            if (![field.valueClass isSubclassOfClass:NSClassFromString(@"NSManagedObject")])
            {
                //create a new instance of the form automatically
                field.value = [[field.valueClass alloc] init];
            }
            subform = field.value;
        }
        
        if (subform)
        {
            NSArray *subsections = [FXFormSection sectionsWithForm:subform controller:formController];
            [sections addObjectsFromArray:subsections];
            
            section = [subsections firstObject];
            if (!section.header) section.header = field.header ?: field.title;
            section.isSortable = field.isSortable;
            section = nil;
        }
        else
        {
            if (!section || field.header)
            {
                section = [[FXFormSection alloc] init];
                section.form = form;
                section.header = field.header;
                section.isSortable = ([form isKindOfClass:[FXTemplateForm class]] && ((FXTemplateForm *)form).field.isSortable);
                [sections addObject:section];
            }
            [section.fields addObject:field];
            if (field.footer)
            {
                section.footer = field.footer;
                section = nil;
            }
        }
    }
    return sections;
}

- (NSMutableArray *)fields
{
    if (!_fields)
    {
        _fields = [NSMutableArray array];
    }
    return _fields;
}

- (void)addNewField
{
    FXFormController *controller = [[_fields lastObject] formController];
    [(FXTemplateForm *)self.form addNewField];
    [_fields setArray:[FXFormField fieldsWithForm:self.form controller:controller]];
}

- (void)removeFieldAtIndex:(NSUInteger)index
{
    FXFormController *controller = [[_fields lastObject] formController];
    [(FXTemplateForm *)self.form removeFieldAtIndex:index];
    [_fields setArray:[FXFormField fieldsWithForm:self.form controller:controller]];
}

- (void)moveFieldAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    FXFormController *controller = [[_fields lastObject] formController];
    [(FXTemplateForm *)self.form moveFieldAtIndex:index1 toIndex:index2];
    [_fields setArray:[FXFormField fieldsWithForm:self.form controller:controller]];
}

@end
