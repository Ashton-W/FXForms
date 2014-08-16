//
//  FXFormOptionSegmentsCell.m
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

#import "FXFormOptionSegmentsCell.h"
#import "FXForms_Private.h"

@interface FXFormOptionSegmentsCell ()

@property (nonatomic, strong, readwrite) UISegmentedControl *segmentedControl;

@end


@implementation FXFormOptionSegmentsCell

- (void)setUp
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[]];
    [self.segmentedControl addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.segmentedControl];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect segmentedControlFrame = self.segmentedControl.frame;
    segmentedControlFrame.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + FXFormFieldPaddingLeft;
    segmentedControlFrame.origin.y = (self.contentView.frame.size.height - segmentedControlFrame.size.height) / 2;
    segmentedControlFrame.size.width = self.contentView.bounds.size.width - segmentedControlFrame.origin.x - FXFormFieldPaddingRight;
    self.segmentedControl.frame = segmentedControlFrame;
}

- (void)update
{
    self.textLabel.text = self.field.title;
    
    [self.segmentedControl removeAllSegments];
    for (NSUInteger i = 0; i < [self.field optionCount]; i++)
    {
        [self.segmentedControl insertSegmentWithTitle:[self.field optionDescriptionAtIndex:i] atIndex:i animated:NO];
        if ([self.field isOptionSelectedAtIndex:i])
        {
            [self.segmentedControl setSelectedSegmentIndex:i];
        }
    }
}

- (void)valueChanged
{
    //note: this loop is to prevent bugs when field type is multiselect
    //which currently isn't supported by FXFormOptionSegmentsCell
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    for (NSInteger i = 0; i < (NSInteger)[self.field optionCount]; i++)
    {
        [self.field setOptionSelected:(selectedIndex == i) atIndex:i];
    }
    
    if (self.field.action) self.field.action(self);
}

@end
