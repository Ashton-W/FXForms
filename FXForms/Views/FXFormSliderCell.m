//
//  FXFormSliderCell.m
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

#import "FXFormSliderCell.h"
#import "FXForms_Private.h"

#pragma GCC diagnostic ignored "-Wconversion"

@interface FXFormSliderCell ()

@property (nonatomic, strong) UISlider *slider;

@end

@implementation FXFormSliderCell

- (void)setUp
{
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect sliderFrame = self.slider.frame;
    sliderFrame.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + FXFormFieldPaddingLeft;
    sliderFrame.origin.y = (self.contentView.frame.size.height - sliderFrame.size.height) / 2;
    sliderFrame.size.width = self.contentView.bounds.size.width - sliderFrame.origin.x - FXFormFieldPaddingRight;
    self.slider.frame = sliderFrame;
}

- (void)update
{
    self.textLabel.text = self.field.title;
    self.slider.value = [self.field.value doubleValue];
}

- (void)valueChanged
{
    self.field.value = @(self.slider.value);
    
    if (self.field.action) self.field.action(self);
}

@end
