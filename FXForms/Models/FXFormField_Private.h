//
//  FXFormField_Private.h
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

#import "FXFormField.h"
@class FXFormController;

@interface FXFormField ()

@property (nonatomic, strong) Class valueClass;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, readwrite) NSString *key;
@property (nonatomic, readwrite) NSArray *options;
@property (nonatomic, readwrite) NSDictionary *fieldTemplate;
@property (nonatomic, readwrite) BOOL isSortable;
@property (nonatomic, readwrite) BOOL isInline;
@property (nonatomic, readonly) id (^valueTransformer)(id input);
@property (nonatomic, readonly) id (^reverseValueTransformer)(id input);
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *footer;

@property (nonatomic, weak) FXFormController *formController;
@property (nonatomic, strong) NSMutableDictionary *cellConfig;

+ (NSArray *)fieldsWithForm:(id<FXForm>)form controller:(FXFormController *)formController;

- (instancetype)initWithForm:(id<FXForm>)form controller:(FXFormController *)formController attributes:(NSDictionary *)attributes;
- (BOOL)isCollectionType;
- (BOOL)isSubform;
- (BOOL)isOrderedCollectionType;

@end
