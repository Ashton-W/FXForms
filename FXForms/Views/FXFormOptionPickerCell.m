//
//  FXFormOptionPickerCell.m
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

#import "FXFormOptionPickerCell.h"
#import "FXForms_Private.h"
#import "FXFormField_Private.h"

@interface FXFormOptionPickerCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;

@end


@implementation FXFormOptionPickerCell

- (void)setUp
{
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)dealloc
{
    _pickerView.dataSource = nil;
    _pickerView.delegate = nil;
}

- (void)update
{
    self.textLabel.text = self.field.title;
    self.detailTextLabel.text = [self.field fieldDescription];
    
    NSUInteger index = self.field.value? [self.field.options indexOfObject:self.field.value]: NSNotFound;
    if (self.field.placeholder)
    {
        index = (index == NSNotFound)? 0: index + 1;
    }
    if (index != NSNotFound)
    {
        [self.pickerView selectRow:index inComponent:0 animated:NO];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputView
{
    return self.pickerView;
}

- (void)didSelectWithTableView:(UITableView *)tableView controller:(__unused UIViewController *)controller
{
    [self becomeFirstResponder];
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    return [self.field optionCount];
}

- (NSString *)pickerView:(__unused UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(__unused NSInteger)component
{
    return [self.field optionDescriptionAtIndex:row];
}

- (void)pickerView:(__unused UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(__unused NSInteger)component
{
    [self.field setOptionSelected:YES atIndex:row];
    self.detailTextLabel.text = [self.field fieldDescription] ?: [self.field.placeholder fieldDescription];
    
    [self setNeedsLayout];
    
    if (self.field.action) self.field.action(self);
}

@end
