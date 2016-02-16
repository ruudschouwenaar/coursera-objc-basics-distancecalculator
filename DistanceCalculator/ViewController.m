//
//  ViewController.m
//  DistanceCalculator
//
//  Created by Ruud Schouwenaar on 03/02/16.
//  Copyright © 2016 Ruud Schouwenaar. All rights reserved.
//

#import "ViewController.h"
#import "DistanceGetter/DGDistanceRequest.h"

@interface ViewController ()

@property (nonatomic) DGDistanceRequest *distanceRequest;

@property (weak, nonatomic) IBOutlet UITextField *startLocation;

@property (weak, nonatomic) IBOutlet UISegmentedControl *unit;

@property (weak, nonatomic) IBOutlet UITextField *firstDestination;
@property (weak, nonatomic) IBOutlet UILabel *firstDistance;

@property (weak, nonatomic) IBOutlet UITextField *secondDestination;
@property (weak, nonatomic) IBOutlet UILabel *secondDistance;

@property (weak, nonatomic) IBOutlet UITextField *thirdDestination;
@property (weak, nonatomic) IBOutlet UILabel *thirdDistance;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@end

@implementation ViewController
- (IBAction)calculateButtonTapped:(id)sender {
    
    NSLog(@"tapped, disabling button while processing request");
    // disable the button
    self.calculateButton.enabled = NO;
    
    // instantiate a distanceRequest
    self.distanceRequest = [DGDistanceRequest alloc];
    
    // distanceRequest needs some info:
    // an array with the destinations
    // a string with the start location
    NSString *firstDestination = self.firstDestination.text;
    NSString *secondDestination = self.secondDestination.text;
    NSString *thirdDestination = self.thirdDestination.text;
    NSArray *destinations = @[firstDestination,secondDestination,thirdDestination];
    NSString *startLocation = self.startLocation.text;
    
    // now pass this info to distanceRequest
    self.distanceRequest = [self.distanceRequest initWithLocationDescriptions:destinations sourceDescription:startLocation];
    
    // creating a weak self to prevent a retain cycle
    __weak ViewController *weakSelf = self;
    
    // get the result via a callback block
    self.distanceRequest.callback = ^(NSArray *response){
        NSLog(@"Display responces: %@",response);
        
        // make strongSelf to make sure we don't lose ourselves
        ViewController *strongSelf = weakSelf;
        // check whether strongSelf is valid, otherwise return
        if (!strongSelf) return;
        
        // block to get result, convert it to the correct unit and
        // format it so it can be displayed
        // as we have to do this 3 times, once for every destination,
        // we use a for-loop to prevent coding the same logic three times
        for (int i = 0;i < 3;i++) {
            // get the result from the response array
            NSNumber *responseValue = response[i];
            
            // variables for doing the math and formatting the result
            float distance = responseValue.floatValue;
            char *unitDescription = "";
        
            // setting the variables
            switch (strongSelf.unit.selectedSegmentIndex) {
                case 0:
                    // do not convert value
                    unitDescription = "meter";
                    break;
                case 1:
                    // convert value to kilometers
                    distance = distance * 0.001;
                    unitDescription = "km";
                    break;
                case 2:
                    // convert value to miles
                    distance = distance * 0.00062137;
                    unitDescription = "miles";
                    break;
                default:
                    break;
            }
            
            // format the result
            NSString *responseStringValue = [NSString stringWithFormat:@"%.0f %s", distance, unitDescription];
        
            // put the result in the appropriate label
            switch (i) {
                case 0:
                    strongSelf.firstDistance.text = responseStringValue;
                    break;
                case 1:
                    strongSelf.secondDistance.text = responseStringValue;
                    break;
                case 2:
                    strongSelf.thirdDistance.text = responseStringValue;
                    break;
                default:
                    break;
            }
        }
        
        // done processing
        NSLog(@"Done processing, enabling button");
        
        // enable the button
        strongSelf.calculateButton.enabled = YES;
        
    }; // end block
    
    // execute the request (which triggers the callback)
    [self.distanceRequest start];
    
}



@end
