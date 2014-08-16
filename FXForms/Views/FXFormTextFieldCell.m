//
//  FXFormTextFieldCell.m
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

#import "FXFormTextFieldCell.h"
#import "FXForms_Private.h"
#import "FXFormBaseCell_Private.h"

@interface FXFormTextFieldCell () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign, getter = isReturnKeyOverriden) BOOL returnKeyOverridden;

@end


@implementation FXFormTextFieldCell

- (void)setUp
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleLeftMargin;
    self.textField.font = [UIFont systemFontOfSize:self.textLabel.font.pointSize];
    self.textField.minimumFontSize = FXFormLabelMinFontSize(self.textLabel);
    self.textField.textColor = [UIColor colorWithRed:0.275f green:0.376f blue:0.522f alpha:1.000f];
    self.textField.delegate = self;
    [self.contentView addSubview:self.textField];
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.textField action:NSSelectorFromString(@"becomeFirstResponder")]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.textField];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _textField.delegate = nil;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    //TODO: is there a less hacky fix for this?
    static NSDictionary *specialCases = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        specialCases = @{@"textField.autocapitalizationType": ^(UITextField *f, NSInteger v){ f.autocapitalizationType = v; },
                         @"textField.autocorrectionType": ^(UITextField *f, NSInteger v){ f.autocorrectionType = v; },
                         @"textField.spellCheckingType": ^(UITextField *f, NSInteger v){ f.spellCheckingType = v; },
                         @"textField.keyboardType": ^(UITextField *f, NSInteger v){ f.keyboardType = v; },
                         @"textField.keyboardAppearance": ^(UITextField *f, NSInteger v){ f.keyboardAppearance = v; },
                         @"textField.returnKeyType": ^(UITextField *f, NSInteger v){ f.returnKeyType = v; },
                         @"textField.enablesReturnKeyAutomatically": ^(UITextField *f, NSInteger v){ f.enablesReturnKeyAutomatically = !!v; },
                         @"textField.secureTextEntry": ^(UITextField *f, NSInteger v){ f.secureTextEntry = !!v; }};
    });
    
    void (^block)(UITextField *f, NSInteger v) = specialCases[keyPath];
    if (block)
    {
        if ([keyPath isEqualToString:@"textField.returnKeyType"])
        {
            //oh god, the hack, it burns
            self.returnKeyOverridden = YES;
        }
        
        block(self.textField, [value integerValue]);
    }
    else
    {
        [super setValue:value forKeyPath:keyPath];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelFrame = self.textLabel.frame;
    labelFrame.size.width = MIN(MAX([self.textLabel sizeThatFits:CGSizeZero].width, FXFormFieldMinLabelWidth), FXFormFieldMaxLabelWidth);
    self.textLabel.frame = labelFrame;
    
    CGRect textFieldFrame = self.textField.frame;
    textFieldFrame.origin.x = self.textLabel.frame.origin.x + MAX(FXFormFieldMinLabelWidth, self.textLabel.frame.size.width) + FXFormFieldLabelSpacing;
    textFieldFrame.origin.y = (self.contentView.bounds.size.height - textFieldFrame.size.height) / 2;
    textFieldFrame.size.width = self.textField.superview.frame.size.width - textFieldFrame.origin.x - FXFormFieldPaddingRight;
    if (![self.textLabel.text length])
    {
        textFieldFrame.origin.x = FXFormFieldPaddingLeft;
        textFieldFrame.size.width = self.contentView.bounds.size.width - FXFormFieldPaddingLeft - FXFormFieldPaddingRight;
    }
    else if (self.textField.textAlignment == NSTextAlignmentRight)
    {
        textFieldFrame.origin.x = self.textLabel.frame.origin.x + labelFrame.size.width + FXFormFieldLabelSpacing;
        textFieldFrame.size.width = self.textField.superview.frame.size.width - textFieldFrame.origin.x - FXFormFieldPaddingRight;
    }
    self.textField.frame = textFieldFrame;
}

- (void)update
{
    self.textLabel.text = self.field.title;
    self.textField.placeholder = [self.field.placeholder fieldDescription];
    self.textField.text = [self.field fieldDescription];
    
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.textAlignment = [self.field.title length]? NSTextAlignmentRight: NSTextAlignmentLeft;
    self.textField.secureTextEntry = NO;
    
    if ([self.field.type isEqualToString:FXFormFieldTypeText])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypeUnsigned])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.textAlignment = NSTextAlignmentRight;
    }
    else if ([@[FXFormFieldTypeNumber, FXFormFieldTypeInteger, FXFormFieldTypeFloat] containsObject:self.field.type])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.textField.textAlignment = NSTextAlignmentRight;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypePassword])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.secureTextEntry = YES;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypeEmail])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypePhone])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypePhonePad;
    }
    else if ([self.field.type isEqualToString:FXFormFieldTypeURL])
    {
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.keyboardType = UIKeyboardTypeURL;
    }
}

- (BOOL)textFieldShouldBeginEditing:(__unused UITextField *)textField
{
    //welcome to hacksville, population: you
    if (!self.returnKeyOverridden)
    {
        //get return key type
        UIReturnKeyType returnKeyType = UIReturnKeyDone;
        UITableViewCell <FXFormFieldCell> *nextCell = [self nextCell];
        if ([nextCell canBecomeFirstResponder])
        {
            returnKeyType = UIReturnKeyNext;
        }
        
        self.textField.returnKeyType = returnKeyType;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField
{
    [self.textField selectAll:nil];
}

- (void)textDidChange
{
    [self updateFieldValue];
}

- (BOOL)textFieldShouldReturn:(__unused UITextField *)textField
{
    if (self.textField.returnKeyType == UIReturnKeyNext)
    {
        [[self nextCell] becomeFirstResponder];
    }
    else
    {
        [self.textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField
{
    [self updateFieldValue];
    
    if (self.field.action) self.field.action(self);
}

- (void)updateFieldValue
{
    self.field.value = self.textField.text;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

@end
