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
#import <Photos/PHAsset.h>
#import <Photos/PHCollection.h>
#import <Photos/PHAssetResourceManager.h>
#import <Photos/PHImageManager.h>




#define STANDARD_DEVICE_WIDTH                                       414.0f
#define DEVICE_WIDTH                                                [UIScreen mainScreen].bounds.size.width
#define WRATIO_WIDTH(w)                                             (w/3.0f) / STANDARD_DEVICE_WIDTH * DEVICE_WIDTH

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *cvPhoto;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) PHAsset *phAsset;

@property (strong, nonatomic) NSMutableArray *imageList;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self getAlbum];
    
    self.imageList = [NSMutableArray new];
    
    [self getAlbumByUsingPHAsset];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.cvPhoto registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];

}

#pragma mark - PHPhotoLibrary
- (void)getAlbumByUsingPHAsset
{
    //PHAsset에서 원하는 타입별 asset을 가져옴
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];

    // 열거
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //마지막 이미지를 로드한 시점에 collectionView를 reload해야 하지만 비동기로 처리하기 때문에
        //asset을 저장 한 뒤 각 셀에서 이미지 로드

        PHAsset *asset = (PHAsset *)obj;
        
        [self.imageList addObject:asset];

    }];
    
    NSLog(@"self.imaegList : %@", self.imageList);
    
    [self.cvPhoto reloadData];
    
}


#pragma mark - ALAssetsLibrary

-(void)getAlbum
{
    //ALAssetLibrary 객체 생성
    self.library = [[ALAssetsLibrary alloc] init];
    
    // 원하는 type으로 asset나열
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        //필터 (all, photo, video)
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // 나열
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if(result)
            {
                //ALAsset의 thumbnail의 이미지 혹은 ALAsset의 defaultRepresentation의 fullScreenImage 이미지를 사용할 수 있다.
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
    
//    ALAsset *asset = (ALAsset *)self.imageList[indexPath.item];
//    
//    cell.ivPhoto.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    @try {
        
        PHAsset *asset = self.imageList[indexPath.item];
        
        [self setImageFromPHAsset:asset imageView:cell.ivPhoto];
        
    } @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.description);
        
    }
    
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

#pragma mark - Private Method

- (void)setImageFromPHAsset:(PHAsset *)asset imageView:(UIImageView *)imageView
{
    CGFloat cellSize = (DEVICE_WIDTH - 3.0f) / 4 ;
    
    CGSize ImageSize = CGSizeMake(cellSize, cellSize);
    
    // PHImageManger을 통해 PHAsset의 Image접근
    // 이미지 로드는 비동기로 처리되기 때문에 dispatch block 안에서 세팅 해주어야 한다.
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:ImageSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = result;
        });
        
        
    }];

}

@end
