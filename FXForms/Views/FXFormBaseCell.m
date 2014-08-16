//
//  FXFormBaseCell.m
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

#import "FXFormBaseCell.h"
#import "FXForms_Private.h"

@implementation FXFormBaseCell

@synthesize field = _field;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.textLabel.font = [UIFont boldSystemFontOfSize:17];
        FXFormLabelSetMinFontSize(self.textLabel, FXFormFieldMinFontSize);
        self.detailTextLabel.font = [UIFont systemFontOfSize:17];
        FXFormLabelSetMinFontSize(self.detailTextLabel, FXFormFieldMinFontSize);
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        {
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else
        {
            self.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    if (![keyPath isEqualToString:@"style"])
    {
        [super setValue:value forKeyPath:keyPath];
    }
}

- (void)setField:(FXFormField *)field
{
    _field = field;
    [self update];
    [self setNeedsLayout];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    //don't distinguish between these, because we're always in edit mode
    super.accessoryType = accessoryType;
    super.editingAccessoryType = accessoryType;
}

- (void)setEditingAccessoryType:(UITableViewCellAccessoryType)editingAccessoryType
{
    //don't distinguish between these, because we're always in edit mode
    [self setAccessoryType:editingAccessoryType];
}

- (void)setAccessoryView:(UIView *)accessoryView
{
    //don't distinguish between these, because we're always in edit mode
    super.accessoryView = accessoryView;
    super.editingAccessoryView = accessoryView;
}

- (void)setEditingAccessoryView:(UIView *)editingAccessoryView
{
    //don't distinguish between these, because we're always in edit mode
    [self setAccessoryView:editingAccessoryView];
}

- (UITableView *)tableView
{
    UITableView *view = (UITableView *)[self superview];
    while (![view isKindOfClass:[UITableView class]])
    {
        view = (UITableView *)[view superview];
    }
    return view;
}

- (NSIndexPath *)indexPathForNextCell
{
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    if (indexPath)
    {
        //get next indexpath
        if ([tableView numberOfRowsInSection:indexPath.section] > indexPath.row + 1)
        {
            return [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        }
        else if ([tableView numberOfSections] > indexPath.section + 1)
        {
            return [NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1];
        }
    }
    return nil;
}

- (UITableViewCell <FXFormFieldCell> *)nextCell
{
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [self indexPathForNextCell];
    if (indexPath)
    {
        //get next cell
        return (UITableViewCell <FXFormFieldCell> *)[tableView cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)setUp
{
    //override
}

- (void)update
{
    //override
}

- (void)didSelectWithTableView:(__unused UITableView *)tableView controller:(__unused UIViewController *)controller
{
    //override
}

@end
