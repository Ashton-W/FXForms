//
//  FXFormImagePickerCell.m
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

#import "FXFormImagePickerCell.h"

#pragma GCC diagnostic ignored "-Wgnu"

@interface FXFormImagePickerCell () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end


@implementation FXFormImagePickerCell

- (void)setUp
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    self.accessoryView = imageView;
    [self setNeedsLayout];
}

- (void)dealloc
{
    _imagePickerController.delegate = nil;
}

- (void)layoutSubviews
{
    CGRect frame = self.imagePickerView.bounds;
    frame.size.height = self.bounds.size.height - 10;
    UIImage *image = self.imagePickerView.image;
    frame.size.width = image.size.height? image.size.width * (frame.size.height / image.size.height): 0;
    self.imagePickerView.bounds = frame;
    
    [super layoutSubviews];
}

- (void)update
{
    self.textLabel.text = self.field.title;
    self.imagePickerView.image = [self imageValue];
}

- (UIImage *)imageValue
{
    if (self.field.value)
    {
        return self.field.value;
    }
    else if (self.field.placeholder)
    {
        UIImage *placeholderImage = self.field.placeholder;
        if ([placeholderImage isKindOfClass:[NSString class]])
        {
            placeholderImage = [UIImage imageNamed:self.field.placeholder];
        }
        return placeholderImage;
    }
    return nil;
}

- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController)
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        [self setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    return _imagePickerController;
}

- (UIImageView *)imagePickerView
{
    return (UIImageView *)self.accessoryView;
}

- (BOOL)setSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        self.imagePickerController.sourceType = sourceType;
        return YES;
    }
    return NO;
}

- (void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller
{
    [self becomeFirstResponder];
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
    [controller presentViewController:self.imagePickerController animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.field.value = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.imagePickerView.image = [self imageValue];
    [self setNeedsLayout];
    
    if (self.field.action) self.field.action(self);
}

@end
