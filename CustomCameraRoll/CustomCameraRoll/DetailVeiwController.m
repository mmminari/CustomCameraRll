//
//  DetailVeiwController.m
//  CustomCameraRoll
//
//  Created by 김민아 on 2017. 1. 23..
//  Copyright © 2017년 김민아. All rights reserved.
//

#import "DetailVeiwController.h"

@interface DetailVeiwController ()

@property (weak, nonatomic) IBOutlet UIImageView *ivDetail;

@end

@implementation DetailVeiwController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ivDetail.image = self.image;
}

- (IBAction)touchedBackButton:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
