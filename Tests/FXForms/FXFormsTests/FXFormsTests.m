//
//  FXFormsTests.m
//  FXFormsTests
//
//  Created by Ashton Williams on 28/04/2014.
//
//

#import <XCTest/XCTest.h>
#import "FXForms.h"

#pragma mark - TestForm

@interface TestForm : NSObject <FXForm>

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSDate *date;

@end

@implementation TestForm

@end

#pragma mark - Tests

@interface FXFormsTests : XCTestCase

@property (nonatomic, strong) TestForm *form;

@end

@implementation FXFormsTests

- (void)setUp
{
    [super setUp];
    self.form = [TestForm new];
}

- (void)tearDown
{
    self.form = nil;
    [super tearDown];
}

- (void)testStringFieldDescription
{
    XCTAssertNoThrow([self.form.string fieldDescription], @"NSString field description failed");
}

@end
