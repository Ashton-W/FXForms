//
//  FXTemplateForm.m
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

#import "FXTemplateForm.h"
#import "FXForms_Private.h"
#import "FXFormField_Private.h"
#import "FXFormSection.h"
#import "FXFormController_Private.h"

@implementation FXTemplateForm

- (instancetype)initWithField:(FXFormField *)field
{
    if ((self = [super init]))
    {
        _field = field;
        _fields = [NSMutableArray array];
        _values = [NSMutableArray array];
        [self updateFields];
    }
    return self;
}

- (NSMutableDictionary *)newFieldDictionary
{
    //TODO: is there a better way to handle default template fallback?
    //TODO: can we infer default template from existing values instead of having string fallback?
    NSMutableDictionary *field = [NSMutableDictionary dictionaryWithDictionary:self.field.fieldTemplate];
    if (!field[FXFormFieldType]) field[FXFormFieldType] = FXFormFieldTypeText;
    if (!field[FXFormFieldClass]) field[FXFormFieldClass] = [NSString class];
    field[FXFormFieldTitle] = @"";
    return field;
}

- (void)updateFields
{
    //set fields
    [self.fields removeAllObjects];
    NSUInteger count = [(NSArray *)self.field.value count];
    for (NSUInteger i = 0; i < count; i++)
    {
        //TODO: do we need to do something special with the action to ensure the
        //correct cell is passed as the sender, as we do for options fields?
        NSMutableDictionary *field = [self newFieldDictionary];
        field[FXFormFieldKey] = [@(i) description];
        [_fields addObject:field];
    }
    
    //create add button
    NSString *addButtonTitle = self.field.fieldTemplate[FXFormFieldTitle] ?: NSLocalizedString(@"Add Item", nil);
    [_fields addObject:@{FXFormFieldTitle: addButtonTitle,
                         FXFormFieldCell: [FXFormDefaultCell class],
                         @"textLabel.textAlignment": @(NSTextAlignmentLeft),
                         FXFormFieldAction: ^(UITableViewCell<FXFormFieldCell> *cell) {
        
        FXFormField *field = cell.field;
        FXFormController *formController = field.formController;
        UITableView *tableView = formController.tableView;
        
        [tableView beginUpdates];
        
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        FXFormSection *section = formController.sections[indexPath.section];
        [section addNewField];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [formController tableView:tableView didSelectRowAtIndexPath:indexPath];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        });
        
    }}];
    
    //converts values to an ordered array
    if ([self.field.valueClass isSubclassOfClass:[NSIndexSet class]])
    {
        [self.fields removeAllObjects];
        [(NSIndexSet *)self.field.value enumerateIndexesUsingBlock:^(NSUInteger idx, __unused BOOL *stop) {
            [self.fields addObject:@(idx)];
        }];
    }
    else if ([self.field.valueClass isSubclassOfClass:[NSArray class]])
    {
        [self.values setArray:self.field.value];
    }
    else
    {
        [self.values setArray:[self.field.value allValues]];
    }
}

- (void)updateFormValue
{
    //create collection of correct type
    BOOL copyNeeded = ([NSStringFromClass(self.field.valueClass) rangeOfString:@"Mutable"].location == NSNotFound);
    id collection = [[self.field.valueClass alloc] init];
    if (copyNeeded) collection = [collection mutableCopy];
    
    //convert values back to original type
    if ([self.field.valueClass isSubclassOfClass:[NSIndexSet class]])
    {
        for (id object in self.values)
        {
            [collection addIndex:[object integerValue]];
        }
    }
    else if ([self.field.valueClass isSubclassOfClass:[NSDictionary class]])
    {
        [self.values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, __unused BOOL *stop) {
            collection[@(idx)] = obj;
        }];
    }
    else
    {
        [collection addObjectsFromArray:self.values];
    }
    
    //set field value
    if (copyNeeded) collection = [collection copy];
    self.field.value = collection;
}

- (id)valueForKey:(NSString *)key
{
    NSUInteger index = [key integerValue];
    if (index != NSNotFound)
    {
        id value = self.values[index];
        if (value != [NSNull null])
        {
            return value;
        }
    }
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    //set value
    if (!value) value = [NSNull null];
    NSUInteger index = [key integerValue];
    if (index >= [self.values count])
    {
        [self.values addObject:value];
    }
    else
    {
        self.values[index] = value;
    }
    [self updateFormValue];
}

- (void)addNewField
{
    NSUInteger index = [self.values count];
    NSMutableDictionary *field = [self newFieldDictionary];
    field[FXFormFieldKey] = [@(index) description];
    [self.fields insertObject:field atIndex:index];
    [self.values addObject:[NSNull null]];
}

- (void)removeFieldAtIndex:(NSUInteger)index
{
    [self.fields removeObjectAtIndex:index];
    [self.values removeObjectAtIndex:index];
    for (NSUInteger i = index; i < [self.values count]; i++)
    {
        self.fields[index][FXFormFieldKey] = [@(i) description];
    }
    [self updateFormValue];
}

- (void)moveFieldAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    NSMutableDictionary *field = self.fields[index1];
    [self.fields removeObjectAtIndex:index1];
    
    id value = self.values[index1];
    [self.values removeObjectAtIndex:index1];
    
    if (index2 >= [self.fields count])
    {
        [self.fields addObject:field];
        [self.values addObject:value];
    }
    else
    {
        [self.fields insertObject:field atIndex:index2];
        [self.values insertObject:value atIndex:index2];
    }
    
    for (NSUInteger i = MIN(index1, index2); i < [self.values count]; i++)
    {
        self.fields[i][FXFormFieldKey] = [@(i) description];
    }
    
    [self updateFormValue];
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
