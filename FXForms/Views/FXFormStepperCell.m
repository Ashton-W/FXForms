//
//  FXFormStepperCell.m
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

#import "FXFormStepperCell.h"
#import "FXForms_Private.h"

@implementation FXFormStepperCell

- (void)setUp
{
    UIStepper *stepper = [[UIStepper alloc] init];
    stepper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    UIView *wrapper = [[UIView alloc] initWithFrame:stepper.frame];
    [wrapper addSubview:stepper];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        wrapper.frame = CGRectMake(0, 0, wrapper.frame.size.width + FXFormFieldPaddingRight, wrapper.frame.size.height);
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryView = wrapper;
    [self.stepper addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)update
{
    self.textLabel.text = self.field.title;
    self.detailTextLabel.text = [self.field fieldDescription];
    self.stepper.value = [self.field.value doubleValue];
}

- (UIStepper *)stepper
{
    return (UIStepper *)[self.accessoryView.subviews firstObject];
}

- (void)valueChanged
{
    self.field.value = @(self.stepper.value);
    self.detailTextLabel.text = [self.field fieldDescription];
    [self setNeedsLayout];
    
    if (self.field.action) self.field.action(self);
}

@end
