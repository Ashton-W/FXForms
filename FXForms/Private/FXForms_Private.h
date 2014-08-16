//
//  FXForm_Private.h
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

#import "FXForms.h"
#import <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma GCC diagnostic ignored "-Wreceiver-is-weak"
#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wgnu"

static NSString *const FXFormsException = @"FXFormsException";


static const CGFloat FXFormFieldLabelSpacing = 5;
static const CGFloat FXFormFieldMinLabelWidth = 97;
static const CGFloat FXFormFieldMaxLabelWidth = 240;
static const CGFloat FXFormFieldMinFontSize = 12;
static const CGFloat FXFormFieldPaddingLeft = 10;
static const CGFloat FXFormFieldPaddingRight = 10;
static const CGFloat FXFormFieldPaddingTop = 12;
static const CGFloat FXFormFieldPaddingBottom = 12;


extern UIView *FXFormsFirstResponder(UIView *view);
extern BOOL FXFormOverridesSelector(id<FXForm> form, SEL selector);
extern BOOL FXFormCanGetValueForKey(id<FXForm> form, NSString *key);
extern BOOL FXFormCanSetValueForKey(id<FXForm> form, NSString *key);
extern void FXFormPreprocessFieldDictionary(NSMutableDictionary *dictionary);

static inline CGFloat FXFormLabelMinFontSize(UILabel *label)
{
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    
    if (![label respondsToSelector:@selector(setMinimumScaleFactor:)])
    {
        return label.minimumFontSize;
    }
    
#endif
    
    return label.font.pointSize * label.minimumScaleFactor;
}

static inline void FXFormLabelSetMinFontSize(UILabel *label, CGFloat fontSize)
{
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    
    if (![label respondsToSelector:@selector(setMinimumScaleFactor:)])
    {
        label.minimumFontSize = fontSize;
    }
    else
        
#endif
        
    {
        label.minimumScaleFactor = fontSize / label.font.pointSize;
    }
}

static inline NSArray *FXFormProperties(id<FXForm> form)
{
    if (!form) return nil;
    
    static void *FXFormPropertiesKey = &FXFormPropertiesKey;
    NSMutableArray *properties = objc_getAssociatedObject(form, FXFormPropertiesKey);
    if (!properties)
    {
        properties = [NSMutableArray array];
        Class subclass = [form class];
        while (subclass != [NSObject class])
        {
            unsigned int propertyCount;
            objc_property_t *propertyList = class_copyPropertyList(subclass, &propertyCount);
            for (unsigned int i = 0; i < propertyCount; i++)
            {
                //get property name
                objc_property_t property = propertyList[i];
                const char *propertyName = property_getName(property);
                NSString *key = @(propertyName);
                
                //get property type
                Class valueClass = nil;
                NSString *valueType = nil;
                char *typeEncoding = property_copyAttributeValue(property, "T");
                switch (typeEncoding[0])
                {
                    case '@':
                    {
                        if (strlen(typeEncoding) >= 3)
                        {
                            char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                            __autoreleasing NSString *name = @(className);
                            NSRange range = [name rangeOfString:@"<"];
                            if (range.location != NSNotFound)
                            {
                                name = [name substringToIndex:range.location];
                            }
                            valueClass = NSClassFromString(name) ?: [NSObject class];
                            free(className);
                        }
                        break;
                    }
                    case 'c':
                    case 'B':
                    {
                        valueClass = [NSNumber class];
                        valueType = FXFormFieldTypeBoolean;
                        break;
                    }
                    case 'i':
                    case 's':
                    case 'l':
                    case 'q':
                    {
                        valueClass = [NSNumber class];
                        valueType = FXFormFieldTypeInteger;
                        break;
                    }
                    case 'C':
                    case 'I':
                    case 'S':
                    case 'L':
                    case 'Q':
                    {
                        valueClass = [NSNumber class];
                        valueType = FXFormFieldTypeUnsigned;
                        break;
                    }
                    case 'f':
                    case 'd':
                    {
                        valueClass = [NSNumber class];
                        valueType = FXFormFieldTypeFloat;
                        break;
                    }
                    case '{': //struct
                    case '(': //union
                    {
                        valueClass = [NSValue class];
                        valueType = FXFormFieldTypeLabel;
                        break;
                    }
                    case ':': //selector
                    case '#': //class
                    default:
                    {
                        valueClass = nil;
                        valueType = nil;
                    }
                }
                free(typeEncoding);
                
                //add to properties
                NSMutableDictionary *inferred = [NSMutableDictionary dictionaryWithObject:key forKey:FXFormFieldKey];
                if (valueClass) inferred[FXFormFieldClass] = valueClass;
                if (valueType) inferred[FXFormFieldType] = valueType;
                [properties addObject:[inferred copy]];
            }
            free(propertyList);
            subclass = [subclass superclass];
        }
        objc_setAssociatedObject(form, FXFormPropertiesKey, properties, OBJC_ASSOCIATION_RETAIN);
    }
    return properties;
}

