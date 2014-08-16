//
//  FXFormDefaultCell.m
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

#import "FXFormDefaultCell.h"
#import "FXFormBaseCell_Private.h"
#import "FXForms_Private.h"
#import "FXFormField_Private.h"

@implementation FXFormDefaultCell

- (void)update
{
    self.textLabel.text = self.field.title;
    self.detailTextLabel.text = [self.field fieldDescription];
    
    if ([self.field.type isEqualToString:FXFormFieldTypeLabel])
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        if (!self.field.action)
        {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else if ([self.field isSubform] || self.field.segue)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypeBoolean] || [self.field.type isEqualToString:FXFormFieldTypeOption])
    {
        self.detailTextLabel.text = nil;
        self.accessoryType = [self.field.value boolValue]? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
    }
    else if (self.field.action)
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller
{
    if ([self.field.type isEqualToString:FXFormFieldTypeBoolean] || [self.field.type isEqualToString:FXFormFieldTypeOption])
    {
        [FXFormsFirstResponder(tableView) resignFirstResponder];
        self.field.value = @(![self.field.value boolValue]);
        if (self.field.action) self.field.action(self);
        self.accessoryType = [self.field.value boolValue]? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
        if ([self.field.type isEqualToString:FXFormFieldTypeOption])
        {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            if (indexPath)
            {
                //reload section, in case fields are linked
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        else
        {
            //deselect the cell
            [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
        }
    }
    else if (self.field.action && (![self.field isSubform] || !self.field.optionCount))
    {
        //action takes precendence over segue or subform - you can implement these yourself in the action
        //the exception is for options fields, where the action will be called when the option is tapped
        //TODO: do we need to make other exceptions? Or is there a better way to handle actions for subforms?
        [FXFormsFirstResponder(tableView) resignFirstResponder];
        self.field.action(self);
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
    }
    else if (self.field.segue && [self.field.segue class] != self.field.segue)
    {
        //segue takes precendence over subform - you have to handle setup of subform yourself
        [FXFormsFirstResponder(tableView) resignFirstResponder];
        if ([self.field.segue isKindOfClass:[UIStoryboardSegue class]])
        {
            [controller prepareForSegue:self.field.segue sender:self];
            [(UIStoryboardSegue *)self.field.segue perform];
        }
        else if ([self.field.segue isKindOfClass:[NSString class]])
        {
            [controller performSegueWithIdentifier:self.field.segue sender:self];
        }
    }
    else if ([self.field isSubform])
    {
        [FXFormsFirstResponder(tableView) resignFirstResponder];
        UIViewController *subcontroller = nil;
        if ([self.field.valueClass isSubclassOfClass:[UIViewController class]])
        {
            subcontroller = self.field.value ?: [[self.field.valueClass alloc] init];
        }
        else
        {
            subcontroller = [[self.field.viewController ?: [FXFormViewController class] alloc] init];
            ((id <FXFormFieldViewController>)subcontroller).field = self.field;
        }
        if (!subcontroller.title) subcontroller.title = self.field.title;
        if (self.field.segue)
        {
            UIStoryboardSegue *segue = [[self.field.segue alloc] initWithIdentifier:self.field.key source:controller destination:subcontroller];
            [controller prepareForSegue:self.field.segue sender:self];
            [segue perform];
        }
        else
        {
            [controller.navigationController pushViewController:subcontroller animated:YES];
        }
    }
}

@end
