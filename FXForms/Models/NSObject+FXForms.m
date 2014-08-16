//
//  NSObject+FXForms.m
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

#import "NSObject+FXForms.h"

@implementation NSObject (FXForms)

- (NSString *)fieldDescription
{
    for (Class fieldClass in @[[NSString class], [NSNumber class], [NSDate class]])
    {
        if ([self isKindOfClass:fieldClass])
        {
            return [self description];
        }
    }
    for (Class fieldClass in @[[NSDictionary class], [NSArray class], [NSSet class], [NSOrderedSet class]])
    {
        if ([self isKindOfClass:fieldClass])
        {
            id collection = self;
            if (fieldClass == [NSDictionary class])
            {
                collection = [collection allValues];
            }
            NSMutableArray *array = [NSMutableArray array];
            for (id object in collection)
            {
                NSString *description = [object fieldDescription];
                if ([description length]) [array addObject:description];
            }
            return [array componentsJoinedByString:@", "];
        }
    }
    if ([self isKindOfClass:[NSDate class]])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        return [formatter stringFromDate:(NSDate *)self];
    }
    return @"";
}

- (NSArray *)fields
{
    return nil;
}

- (NSArray *)extraFields
{
    return nil;
}

- (NSArray *)excludedFields
{
    return nil;
}

@end
