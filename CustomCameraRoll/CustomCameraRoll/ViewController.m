//
//  ViewController.m
//  CustomCameraRoll
//
//  Created by 김민아 on 2017. 1. 20..
//  Copyright © 2017년 김민아. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "DetailVeiwController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define STANDARD_DEVICE_WIDTH                                       414.0f
#define DEVICE_WIDTH                                                [UIScreen mainScreen].bounds.size.width
#define WRATIO_WIDTH(w)                                             (w/3.0f) / STANDARD_DEVICE_WIDTH * DEVICE_WIDTH

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *cvPhoto;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray *imageList;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getAlbum];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.imageList = [NSMutableArray new];
    
    [self.cvPhoto registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];

}

-(void)getAlbum
{
    self.library = [[ALAssetsLibrary alloc] init];
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if(result)
            {
                [self.imageList addObject:result];
                
                ALAssetRepresentation *representation = [result defaultRepresentation];
                
                NSString *urlString = [representation url].absoluteString;
                
                NSLog(@"urlString : %@, self.imageList.count : %zd", urlString, self.imageList.count );
            }

        }];
        
        [self.cvPhoto reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"error : %@", error.description);
    }];
    

}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ImageCell *cell = [self.cvPhoto dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    ALAsset *asset = (ALAsset *)self.imageList[indexPath.item];
    
    cell.ivPhoto.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionview numberOfItemsInSection:(NSInteger)section
{
    NSInteger result = 0;
    
    result = self.imageList.count;
    
    NSLog(@"item count : %zd", result);
    
    return result;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellSize = (DEVICE_WIDTH - 3.0f) / 4 ;
    
    CGSize result = CGSizeMake(cellSize, cellSize);
    
    return result;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"didSelect : %zd", indexPath.item);
    
    ALAsset *asset = (ALAsset *)self.imageList[indexPath.item];
    
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    
    UIImage *image = [UIImage imageWithCGImage:representation.fullScreenImage];
    
    DetailVeiwController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"sitd-DetailVeiwController"];
    
    detailVC.image = image;
    
    [self.navigationController pushViewController:detailVC animated:YES];
    

}

@end
