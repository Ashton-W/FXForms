//
//  FXForms.m
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
#import "FXForms_Private.h"
#import <objc/runtime.h>


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma GCC diagnostic ignored "-Wreceiver-is-weak"
#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wgnu"





UIView *FXFormsFirstResponder(UIView *view)
{
    if ([view isFirstResponder])
    {
        return view;
    }
    for (UIView *subview in view.subviews)
    {
        UIView *responder = FXFormsFirstResponder(subview);
        if (responder)
        {
            return responder;
        }
    }
    return nil;
}

#pragma mark -

BOOL FXFormOverridesSelector(id<FXForm> form, SEL selector)
{
    Class formClass = [form class];
    while (formClass && formClass != [NSObject class])
    {
        unsigned int numberOfMethods;
        Method *methods = class_copyMethodList(formClass, &numberOfMethods);
        for (unsigned int i = 0; i < numberOfMethods; i++)
        {
            if (method_getName(methods[i]) == selector)
            {
                free(methods);
                return YES;
            }
        }
        if (methods) free(methods);
        formClass = [formClass superclass];
    }
    return NO;
}

BOOL FXFormCanGetValueForKey(id<FXForm> form, NSString *key)
{
    //has key?
    if (![key length])
    {
        return NO;
    }
    
    //does a property exist for it?
    if ([[FXFormProperties(form) valueForKey:FXFormFieldKey] containsObject:key])
    {
        return YES;
    }
    
    //is there a getter method for this key?
    if ([form respondsToSelector:NSSelectorFromString(key)])
    {
        return YES;
    }
    
    //does it override valurForKey?
    if (FXFormOverridesSelector(form, @selector(valueForKey:)))
    {
        return YES;
    }
    
    //does it override valueForUndefinedKey?
    if (FXFormOverridesSelector(form, @selector(valueForUndefinedKey:)))
    {
        return YES;
    }
    
    //it will probably crash
    return NO;
}

BOOL FXFormCanSetValueForKey(id<FXForm> form, NSString *key)
{
    //has key?
    if (![key length])
    {
        return NO;
    }
    
    //does a property exist for it?
    if ([[FXFormProperties(form) valueForKey:FXFormFieldKey] containsObject:key])
    {
        return YES;
    }
    
    //is there a setter method for this key?
    if ([form respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]])])
    {
        return YES;
    }
    
    //does it override setValueForKey?
    if (FXFormOverridesSelector(form, @selector(setValue:forKey:)))
    {
        return YES;
    }
    
    //does it override setValue:forUndefinedKey?
    if (FXFormOverridesSelector(form, @selector(setValue:forUndefinedKey:)))
    {
        return YES;
    }
    
    //it will probably crash
    return NO;
}

void FXFormPreprocessFieldDictionary(NSMutableDictionary *dictionary)
{
    //convert value class from string
    if ([dictionary[FXFormFieldClass] isKindOfClass:[NSString class]])
    {
        dictionary[FXFormFieldClass] = NSClassFromString(dictionary[FXFormFieldClass]);
    }
    
    //determine value class
    NSString *key = dictionary[FXFormFieldKey];
    NSArray *options = dictionary[FXFormFieldOptions];
    Class valueClass = dictionary[FXFormFieldClass];
    if (!valueClass && key)
    {
        if ([options count])
        {
            //use same type as options
            valueClass = [[options firstObject] class];
        }
        else
        {
            //treat as string if not otherwise indicated
            valueClass = [NSString class];
        }
        dictionary[FXFormFieldClass] = valueClass;
    }
    
    //use base cell for subforms
    NSString *type = dictionary[FXFormFieldType];
    if (([options count] || dictionary[FXFormFieldViewController] || dictionary[FXFormFieldTemplate]) &&
        ![type isEqualToString:FXFormFieldTypeBitfield] && ![dictionary[FXFormFieldInline] boolValue])
    {
        //TODO: is there a good way to support custom type for non-inline options cells?
        //TODO: is there a better way to force non-inline cells to use base cell?
        dictionary[FXFormFieldType] = type = FXFormFieldTypeDefault;
    }
    
    //derive value type from key and/or value class
    if (!type)
    {
        if ([valueClass isSubclassOfClass:[NSString class]])
        {
            NSString *lowercaseKey = [key lowercaseString];
            if ([lowercaseKey hasSuffix:@"password"])
            {
                type = FXFormFieldTypePassword;
            }
            else if ([lowercaseKey hasSuffix:@"email"] || [lowercaseKey hasSuffix:@"emailaddress"])
            {
                type = FXFormFieldTypeEmail;
            }
            else if ([lowercaseKey hasSuffix:@"phone"] || [lowercaseKey hasSuffix:@"phonenumber"])
            {
                type = FXFormFieldTypePhone;
            }
            else if ([lowercaseKey hasSuffix:@"url"] || [lowercaseKey hasSuffix:@"link"])
            {
                type = FXFormFieldTypeURL;
            }
            else
            {
                type = FXFormFieldTypeText;
            }
        }
        else if ([valueClass isSubclassOfClass:[NSURL class]])
        {
            type = FXFormFieldTypeURL;
        }
        else if ([valueClass isSubclassOfClass:[NSNumber class]])
        {
            type = FXFormFieldTypeNumber;
        }
        else if ([valueClass isSubclassOfClass:[NSDate class]])
        {
            type = FXFormFieldTypeDate;
        }
        else if ([valueClass isSubclassOfClass:[UIImage class]])
        {
            type = FXFormFieldTypeImage;
        }
        else
        {
            type = FXFormFieldTypeDefault;
        }
        dictionary[FXFormFieldType] = type;
    }
    
    //convert cell from string to class
    if ([dictionary[FXFormFieldCell] isKindOfClass:[NSString class]])
    {
        dictionary[FXFormFieldCell] = NSClassFromString(dictionary[FXFormFieldCell]);
    }
    
    //convert view controller from string to class
    if ([dictionary[FXFormFieldViewController] isKindOfClass:[NSString class]])
    {
        dictionary[FXFormFieldViewController] = NSClassFromString(dictionary[FXFormFieldViewController]);
    }
    
    //preprocess template dictionary
    NSDictionary *template = dictionary[FXFormFieldTemplate];
    if (template)
    {
        template = [NSMutableDictionary dictionaryWithDictionary:template];
        FXFormPreprocessFieldDictionary((NSMutableDictionary *)template);
        dictionary[FXFormFieldTemplate] = template;
    }
    
    //derive title from key or selector name
    if (!dictionary[FXFormFieldTitle])
    {
        BOOL wasCapital = YES;
        NSString *keyOrAction = key;
        if (!keyOrAction && [dictionary[FXFormFieldAction] isKindOfClass:[NSString class]])
        {
            keyOrAction = dictionary[FXFormFieldAction];
        }
        NSMutableString *output = [NSMutableString string];
        if (keyOrAction)
        {
            [output appendString:[[keyOrAction substringToIndex:1] uppercaseString]];
            for (NSUInteger j = 1; j < [keyOrAction length]; j++)
            {
                unichar character = [keyOrAction characterAtIndex:j];
                BOOL isCapital = ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:character]);
                if (isCapital && !wasCapital) [output appendString:@" "];
                wasCapital = isCapital;
                if (character != ':') [output appendFormat:@"%C", character];
            }
        }
        if ([output length])
        {
            dictionary[FXFormFieldTitle] = NSLocalizedString(output, nil);
        }
    }
}

