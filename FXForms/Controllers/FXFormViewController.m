//
//  FXFormViewController.m
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

#import "FXFormViewController.h"
#import "FXForms_Private.h"
#import "FXFormField_Private.h"
#import "FXOptionsForm.h"
#import "FXTemplateForm.h"

#pragma GCC diagnostic ignored "-Wdirect-ivar-access"

@interface FXFormViewController ()

@property (nonatomic, strong) FXFormController *formController;

@end


@implementation FXFormViewController

@synthesize field = _field;

- (void)dealloc
{
    _formController.delegate = nil;
}

- (void)setField:(FXFormField *)field
{
    _field = field;
    
    id<FXForm> form = nil;
    if (field.options)
    {
        form = [[FXOptionsForm alloc] initWithField:field];
    }
    else if ([field isCollectionType])
    {
        form = [[FXTemplateForm alloc] initWithField:field];
    }
    else if ([field.valueClass conformsToProtocol:@protocol(FXForm)])
    {
        if (!field.value && ![field.valueClass isSubclassOfClass:NSClassFromString(@"NSManagedObject")])
        {
            //create a new instance of the form automatically
            field.value = [[field.valueClass alloc] init];
        }
        form = field.value;
    }
    else
    {
        [NSException raise:FXFormsException format:@"FXFormViewController field value must conform to FXForm protocol"];
    }
    
    self.formController.parentFormController = field.formController;
    self.formController.form = form;
}

- (FXFormController *)formController
{
    if (!_formController)
    {
        _formController = [[FXFormController alloc] init];
        _formController.delegate = self;
    }
    return _formController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
                                                      style:UITableViewStyleGrouped];
    }
    if (!self.tableView.superview)
    {
        self.view = self.tableView;
    }
}

- (void)setTableView:(UITableView *)tableView
{
    self.formController.tableView = tableView;
    if (![self isViewLoaded])
    {
        self.view = self.tableView;
    }
}

- (UITableView *)tableView
{
    return self.formController.tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected)
    {
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
}

@end
