//
//  ViewController.m
//  GeofenceObjCPodsExample
//
//  Created by Yogesh Singh on 09/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)requestLocationPermission:(UIButton *)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
}

@end
