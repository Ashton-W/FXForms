//
//  FXForms.h
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

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#import <UIKit/UIKit.h>


#ifndef FXForms

static NSString *const FXFormFieldKey = @"key";
static NSString *const FXFormFieldType = @"type";
static NSString *const FXFormFieldClass = @"class";
static NSString *const FXFormFieldCell = @"cell";
static NSString *const FXFormFieldTitle = @"title";
static NSString *const FXFormFieldPlaceholder = @"placeholder";
static NSString *const FXFormFieldDefaultValue = @"default";
static NSString *const FXFormFieldOptions = @"options";
static NSString *const FXFormFieldTemplate = @"template";
static NSString *const FXFormFieldValueTransformer = @"valueTransformer";
static NSString *const FXFormFieldAction = @"action";
static NSString *const FXFormFieldSegue = @"segue";
static NSString *const FXFormFieldHeader = @"header";
static NSString *const FXFormFieldFooter = @"footer";
static NSString *const FXFormFieldInline = @"inline";
static NSString *const FXFormFieldSortable = @"sortable";
static NSString *const FXFormFieldViewController = @"viewController";

static NSString *const FXFormFieldTypeDefault = @"default";
static NSString *const FXFormFieldTypeLabel = @"label";
static NSString *const FXFormFieldTypeText = @"text";
static NSString *const FXFormFieldTypeLongText = @"longtext";
static NSString *const FXFormFieldTypeURL = @"url";
static NSString *const FXFormFieldTypeEmail = @"email";
static NSString *const FXFormFieldTypePhone = @"phone";
static NSString *const FXFormFieldTypePassword = @"password";
static NSString *const FXFormFieldTypeNumber = @"number";
static NSString *const FXFormFieldTypeInteger = @"integer";
static NSString *const FXFormFieldTypeUnsigned = @"unsigned";
static NSString *const FXFormFieldTypeFloat = @"float";
static NSString *const FXFormFieldTypeBitfield = @"bitfield";
static NSString *const FXFormFieldTypeBoolean = @"boolean";
static NSString *const FXFormFieldTypeOption = @"option";
static NSString *const FXFormFieldTypeDate = @"date";
static NSString *const FXFormFieldTypeTime = @"time";
static NSString *const FXFormFieldTypeDateTime = @"datetime";
static NSString *const FXFormFieldTypeImage = @"image";

#endif

#import "Models/NSObject+FXForms.h"
#import "Models/FXForm.h"
#import "Models/FXFormField.h"

#import "Controllers/FXFormControllerDelegate.h"
#import "Controllers/FXFormController.h"
#import "Controllers/FXFormFieldViewController.h"
#import "Controllers/FXFormViewController.h"

#import "Views/FXFormFieldCell.h"
#import "Views/FXFormBaseCell.h"
#import "Views/FXFormDefaultCell.h"
#import "Views/FXFormTextFieldCell.h"
#import "Views/FXFormTextViewCell.h"
#import "Views/FXFormSwitchCell.h"
#import "Views/FXFormStepperCell.h"
#import "Views/FXFormSliderCell.h"
#import "Views/FXFormDatePickerCell.h"
#import "Views/FXFormImagePickerCell.h"
#import "Views/FXFormOptionPickerCell.h"
#import "Views/FXFormOptionSegmentsCell.h"

#pragma GCC diagnostic pop

