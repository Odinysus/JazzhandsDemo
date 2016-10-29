//
//  IntrotductionController.m
//  isigoyi
//
//  Created by qiang on 16/7/13.
//  Copyright © 2016年 akite. All rights reserved.
//

#import "IntrotductionController.h"
#import "SMPageControl.h"
#import "FUIButton+Helper.h"
#import "UIColor+expand.h"
#import "Masonry.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface IntrotductionController () <UIScrollViewDelegate>

@property (nonatomic, strong) SMPageControl *pageControl;
@property (nonatomic, strong) FUIButton *loginBtn;
@property (nonatomic, strong) FUIButton *registerBtn;
@property (nonatomic, strong) FUIButton *watchAroundBtn;

@property (nonatomic, strong) NSMutableDictionary *imagesAttibitueDic;
@property (nonatomic, strong) NSMutableDictionary *tipDic;

@end

@implementation IntrotductionController

#pragma mark life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _imagesAttibitueDic = [NSMutableDictionary new];
        _imagesAttibitueDic[@"image_1"] = @[@"ramo_left",
                                            @"remo_left",
                                            @"remo_right",
                                            @"remo_bottom",
                                            @"remo_title"];
        _imagesAttibitueDic[@"image_2"] = @[@"nico",
                                            @"nico_tip",
                                            @"nico_star_left",
                                            @"nico_star_right"];
        _imagesAttibitueDic[@"image_3"] = @[@"asong_back",
                                            @"asong1"];
        
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor  blueColor];
    self.scrollView.delegate = self;
    [self configButtonAndPageControl];
    [self configTipAndAnimation];
}

- (NSUInteger)numberOfPages
{
    return 4;
}
- (void)configButtonAndPageControl
{
    CGFloat padding = 20;
    _loginBtn = [FUIButton defaultBtn];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(clickLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_loginBtn.superview).with.offset(padding);
        make.bottom.equalTo(_loginBtn.superview).with.offset(-padding);
        make.width.mas_equalTo(SCREEN_WIDTH/ 3);
        make.height.mas_equalTo(SCREEN_WIDTH/ 9);
    }];
    
    _registerBtn = [FUIButton defaultBtn];
    [_registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_registerBtn addTarget:self action:@selector(clickRegisterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_loginBtn);
        make.height.equalTo(_loginBtn);
        make.right.equalTo(_registerBtn.superview).with.offset(-padding);
        make.bottom.equalTo(_registerBtn.superview).with.offset(-padding);
    }];
    
    _pageControl = [[SMPageControl alloc] init];
    [_pageControl setNumberOfPages:4];
    [_pageControl setCurrentPage:0];
    [self.view addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH/2);
        make.centerX.equalTo(self.scrollView);
        make.bottom.equalTo(_loginBtn.mas_top).with.offset(-10);
    }];
}

- (void)configTipAndAnimation
{
    [self configLeimu:1];
    [self configNico:2];
    [self configASongWithIndex:3];
    [self changeBackGroundColor];
}

- (void)configLeimu:(NSInteger)index
{
    NSString *indexStr = [NSString stringWithFormat:@"image_%ld", index];
    NSArray *imageStrs = self.imagesAttibitueDic[indexStr];
    // 左边上的罗姆
    UIImageView *ramoLeftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[0]]];
    ramoLeftImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:ramoLeftImgView];
    [ramoLeftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollView).multipliedBy(0.45);
        make.height.equalTo(ramoLeftImgView.mas_width).multipliedBy(0.9);
    }];
    // index=1
    // x的起始位置为0, 进入视野时位置为1.与offset相同,即相对静止
    // 退出视野时罗姆的x的位置为3,offset的位置是2.
    // 即罗姆向右移动的速度比拖动的速度快,屏幕上显示罗姆向右边飘去
    [self keepView:ramoLeftImgView
           onPages:@[@(index-1),@(index),@(index+2)]
           atTimes:@[@(index-1), @(index), @(index+1)]
       withOffsets:@[@14,@14, @0]
     withAttribute:IFTTTHorizontalPositionAttributeLeft];
    NSLayoutConstraint *leftRamoTopConstraint = [NSLayoutConstraint constraintWithItem:ramoLeftImgView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0];
    [self.contentView addConstraint:leftRamoTopConstraint];
    // 添加一个罗姆的top约束帧动画.y的起始位置为-0.2,位于屏幕之外.
    // 进入视野,y的位置为0.2,即从屏幕上方移动下来
    // 退出视野,y的位置又变为-0.2,即移出屏幕
    IFTTTConstraintMultiplierAnimation *leftRamoTopAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                               constraint:leftRamoTopConstraint
                                                                                                                attribute:IFTTTLayoutAttributeHeight
                                                                                                            referenceView:self.contentView];
    [leftRamoTopAnimation addKeyframeForTime:index-1 multiplier:-0.2];
    [leftRamoTopAnimation addKeyframeForTime:index multiplier:0.2f withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [leftRamoTopAnimation addKeyframeForTime:index+1 multiplier:-0.2];
    [self.animator addAnimation:leftRamoTopAnimation];
    
    //  左边的蕾姆
    UIImageView *remoLeftImgView = [UIImageView new];
    remoLeftImgView.image = [UIImage imageNamed:imageStrs[1]];
    remoLeftImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:remoLeftImgView];
    [remoLeftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(ramoLeftImgView.mas_width);
        make.height.equalTo(remoLeftImgView.mas_width).multipliedBy(1.25);
    }];
    // 左边的蕾姆
    // x的起始位置为0, offset为0. 进入视野时位置为1.与offset相同,即相对静止
    // 退出视野时罗姆的x的位置为1,offset的位置是2.
    // 即罗姆的速度(0)比拖动的速度(1)慢,所以屏幕上显示罗姆向左边飘去
    [self keepView:remoLeftImgView
           onPages:@[@(index-1), @(index), @(index)]
           atTimes:@[@(index-1),@(index), @(index+1)]
     withAttribute:IFTTTHorizontalPositionAttributeLeft
            offset:20];
    
    NSLayoutConstraint *leftRemoBottomConstraint = [NSLayoutConstraint constraintWithItem:remoLeftImgView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:0];
    [self.contentView addConstraint:leftRemoBottomConstraint];
    // 为左边的蕾姆添加约束帧动画.
    IFTTTConstraintMultiplierAnimation *leftRemoBottomAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                               constraint:leftRemoBottomConstraint
                                                                                                                attribute:IFTTTLayoutAttributeHeight
                                                                                                            referenceView:self.contentView];
    [leftRemoBottomAnimation addKeyframeForTime:index-1 multiplier:0.5];
    [leftRemoBottomAnimation addKeyframeForTime:index multiplier:-0.5 withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [self.animator addAnimation:leftRemoBottomAnimation];
    
    // 右上的蕾姆
    UIImageView *remoRightImgView = [UIImageView new];
    remoRightImgView.image = [UIImage imageNamed:imageStrs[2]];
    remoRightImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:remoRightImgView];
    [remoRightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(ramoLeftImgView.mas_width);
        make.height.equalTo(remoRightImgView.mas_width);
    }];
    // 与左边的罗姆类似
    [self keepView:remoRightImgView
           onPages:@[@(index-1), @(index), @(index)]
           atTimes:@[@(index-1),@(index), @(index+1)]
     withAttribute:IFTTTHorizontalPositionAttributeRight
            offset:-14];
    NSLayoutConstraint *rightRemoTopConstraint = [NSLayoutConstraint constraintWithItem:remoRightImgView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0];
    [self.contentView addConstraint:rightRemoTopConstraint];
    IFTTTConstraintMultiplierAnimation *rightRemoTopAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                               constraint:rightRemoTopConstraint
                                                                                                                attribute:IFTTTLayoutAttributeHeight
                                                                                                            referenceView:self.contentView];
    [rightRemoTopAnimation addKeyframeForTime:index-1 multiplier:-0.2];
    [rightRemoTopAnimation addKeyframeForTime:index multiplier:0.2f withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [rightRemoTopAnimation addKeyframeForTime:index+1 multiplier:-0.2];
    [self.animator addAnimation:rightRemoTopAnimation];

    // 右下的蕾姆
    UIImageView *remoBottomImgView = [UIImageView new];
    remoBottomImgView.image = [UIImage imageNamed:imageStrs[3]];
    remoBottomImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:remoBottomImgView];
    [remoBottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(ramoLeftImgView.mas_width);
        make.height.equalTo(remoBottomImgView.mas_width).multipliedBy(1.25);
    }];
    [self keepView:remoBottomImgView onPages:@[@(index), @(index), @(index+1)] atTimes:@[@(index-1),@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeRight offset:-14];
    NSLayoutConstraint *remoBottomConstraint = [NSLayoutConstraint constraintWithItem:remoBottomImgView
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:0];
    [self.contentView addConstraint:remoBottomConstraint];
    IFTTTConstraintMultiplierAnimation *remoBottomAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                                constraint:remoBottomConstraint
                                                                                                                 attribute:IFTTTLayoutAttributeHeight
                                                                                                             referenceView:self.contentView];
    [remoBottomAnimation addKeyframeForTime:index multiplier:-0.5f withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [remoBottomAnimation addKeyframeForTime:index+1 multiplier:0.2f];
    [self.animator addAnimation:remoBottomAnimation];
    
    // 中间的标题
    UIImageView *titleImgView = [UIImageView new];
    titleImgView.image = [UIImage imageNamed:imageStrs[4]];
    titleImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:titleImgView];
    [titleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(ramoLeftImgView.mas_width).multipliedBy(0.75);
        make.height.equalTo(titleImgView.mas_width);
        make.centerY.equalTo(titleImgView.superview).multipliedBy(0.65);
    }];
    [self keepView:titleImgView onPages:@[@(index), @(index), @(index+1)] atTimes:@[@(index-1),@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeCenterX offset:0];
    
    IFTTTRotationAnimation *rotationAnimation = [IFTTTRotationAnimation animationWithView:titleImgView];
    [rotationAnimation addKeyframeForTime:index rotation:0];
    [rotationAnimation addKeyframeForTime:index+1 rotation:-360];
    [self.animator addAnimation:rotationAnimation];
    
    IFTTTHideAnimation *hideAnimation = [IFTTTHideAnimation animationWithView:titleImgView hideAt:index+0.95];
    [self.animator addAnimation:hideAnimation];
}


- (void)configNico:(NSInteger)index
{
    NSString *indexStr = [NSString stringWithFormat:@"image_%ld", index];
    NSArray *imageStrs = self.imagesAttibitueDic[indexStr];
    UIImageView *nicoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[0]]];
    nicoImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:nicoImgView];
    [nicoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nicoImgView.superview).with.offset(40);
        make.width.equalTo(self.scrollView).multipliedBy(0.8);
        make.centerY.equalTo(self.contentView).multipliedBy(0.8);
    }];
    [self keepView:nicoImgView onPages:@[@(index), @(index+1)] atTimes:@[@(index), @(index+1)]];
    [self addAlphaAnimation:nicoImgView index:index];
    
    // noco标题
    UIImageView *nicoTipImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[1]]];
    nicoTipImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:nicoTipImgView];
    [nicoTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(nicoImgView).multipliedBy(0.2);
    }];
    [self keepView:nicoTipImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)]
     withAttribute:IFTTTHorizontalPositionAttributeLeft offset:SCREEN_WIDTH/10];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:nicoTipImgView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nicoImgView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.f
                                                                      constant:20.f];
    [self.contentView addConstraint:topConstraint];

    IFTTTConstraintConstantAnimation *topConstantAnimation = [IFTTTConstraintConstantAnimation animationWithSuperview:self.contentView
                                                                                                           constraint:topConstraint];
    [topConstantAnimation addKeyframeForTime:index constant:20 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [topConstantAnimation addKeyframeForTime:index+0.15 constant:-200 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [self.animator addAnimation:topConstantAnimation];
    
    //   左边的星星
    UIImageView *starLeftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[2]]];
    starLeftImgView.layer.zPosition = 100;
    starLeftImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starLeftImgView];
    [starLeftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starLeftImgView.superview).multipliedBy(0.5);
        make.width.equalTo(nicoImgView).multipliedBy(0.07);
        make.height.equalTo(starLeftImgView);
    }];
    [self keepView:starLeftImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeLeft offset:50];
    [self addStarToNicoWithImg:starLeftImgView withIndex:index];
    
    // 左中的星星
    UIImageView *starLeftMidImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[2]]];
    starLeftMidImgView.layer.zPosition = 100;
    starLeftMidImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starLeftMidImgView];
    [starLeftMidImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starLeftMidImgView.superview).multipliedBy(0.85);
        make.size.equalTo(starLeftImgView);
    }];
    [self keepView:starLeftMidImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeLeft offset:30];
    [self addStarToNicoWithImg:starLeftMidImgView withIndex:index];
    
    // 中间左边的星星
    UIImageView *starMidLeftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[2]]];
    starMidLeftImgView.layer.zPosition = 100;
    starMidLeftImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starMidLeftImgView];
    [starMidLeftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starMidLeftImgView.superview).multipliedBy(0.9);
        make.size.equalTo(starLeftImgView);
    }];
    [self keepView:starMidLeftImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeCenterX offset:-45];
    [self addStarToNicoWithImg:starMidLeftImgView withIndex:index];
    
    // 中间右边的星星
    UIImageView *starMidRightImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[3]]];
    starMidRightImgView.layer.zPosition = 100;
    starMidRightImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starMidRightImgView];
    [starMidRightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starMidRightImgView.superview).multipliedBy(0.76);
        make.size.equalTo(starLeftImgView);
    }];
    [self keepView:starMidRightImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeCenterX offset:45];
    [self addStarToNicoWithImg:starMidRightImgView withIndex:index];
    
    // 右上边的星星
    UIImageView *starRightTopImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[3]]];
    starRightTopImgView.layer.zPosition = 100;
    starRightTopImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starRightTopImgView];
    [starRightTopImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starRightTopImgView.superview).multipliedBy(0.45);
        make.size.equalTo(starLeftImgView);
    }];
    [self keepView:starRightTopImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeRight offset:-50];
    [self addStarToNicoWithImg:starRightTopImgView withIndex:index];
    
    // 右下的星星
    UIImageView *starRightBottomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[3]]];
    starRightBottomImgView.layer.zPosition = 100;
    starRightBottomImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:starRightBottomImgView];
    [starRightBottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(starRightBottomImgView.superview).multipliedBy(0.7);
        make.size.equalTo(starLeftImgView);
    }];
    [self keepView:starRightBottomImgView
           onPages:@[@(index), @(index+1)]
           atTimes:@[@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeRight offset:-30];
    [self addStarToNicoWithImg:starRightBottomImgView withIndex:index];
}

- (void)addStarToNicoWithImg:(UIImageView *)imgView withIndex:(int)index
{
    IFTTTTransform3DAnimation *transformAnimation = [IFTTTTransform3DAnimation animationWithView:imgView];
    IFTTTTransform3D *transform = [IFTTTTransform3D transformWithM34:0.005];
    IFTTTTransform3DRotate rotate = {M_PI + M_PI_2, 0, 1, 0};
    transform.rotate = rotate;
    IFTTTTransform3D *transformPure = [[IFTTTTransform3D alloc] init];
    [transformAnimation addKeyframeForTime:index transform:transformPure];
    [transformAnimation addKeyframeForTime:index+0.5 transform:transform];
    [self.animator addAnimation:transformAnimation];
}

- (CAShapeLayer *)starPathLayerWithPoint:(CGPoint)point;
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self starPathWithPoint:point];
    
    return shapeLayer;
}

- (CGPathRef)starPathWithPoint:(CGPoint)point
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(point.x-SCREEN_WIDTH , point.y)];
    return path.CGPath;
}

- (void)configASongWithIndex:(int)index
{
    NSString *indexStr = [NSString stringWithFormat:@"image_%d", index];
    NSArray *imageStrs = self.imagesAttibitueDic[indexStr];
    UIImageView *leimuImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStrs[0]]];
    leimuImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:leimuImgView];
    [leimuImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leimuImgView.superview).with.offset(40);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.centerY.equalTo(self.contentView).multipliedBy(0.8);
    }];
    [self keepView:leimuImgView onPages:@[@(index+1), @(index), @(index-1)] atTimes:@[@(index-1), @(index), @(index+1)]];
    
    UIImageView *leimuImgHeart = [UIImageView new];
    leimuImgHeart.image = [UIImage imageNamed:imageStrs[1]];
    leimuImgHeart.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:leimuImgHeart];
    
    [leimuImgHeart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(leimuImgView.mas_width).multipliedBy(0.4);
        make.height.equalTo(leimuImgHeart.mas_width).multipliedBy(2);
    }];
    [self keepView:leimuImgHeart onPages:@[@(index-1.15),@(index-0.15), @(index-1.15)] atTimes:@[@(index-1),@(index), @(index+1)] withAttribute:IFTTTHorizontalPositionAttributeCenterX offset:0];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:leimuImgHeart
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0 constant:0.f];
    [self.contentView addConstraint:topConstraint];
    IFTTTConstraintMultiplierAnimation *constantAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                            constraint:topConstraint
                                                                                                             attribute:IFTTTLayoutAttributeHeight
                                                                                                         referenceView:self.contentView];
    [constantAnimation addKeyframeForTime:index-1 multiplier:-0.3f];
    [constantAnimation addKeyframeForTime:index multiplier:0.2f];
    [self.animator addAnimation:constantAnimation];
    
}
- (void)changeBackGroundColor
{
    IFTTTBackgroundColorAnimation *colorAnimation = [IFTTTBackgroundColorAnimation animationWithView:self.contentView];
    [colorAnimation addKeyframeForTime:1 color:[UIColor colorWithHexString:@"d9e1e7"] withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [colorAnimation addKeyframeForTime:2 color:[UIColor colorWithHexString:@"d1f6f9"] withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [colorAnimation addKeyframeForTime:3 color:[UIColor colorWithHexString:@"fbede4"] withEasingFunction:IFTTTEasingFunctionEaseInOutQuad];
    [self.animator addAnimation:colorAnimation];
}

- (void)addAlphaAnimation:(UIView *)view index:(int)index
{
    IFTTTAlphaAnimation *alphaAnimation = [[IFTTTAlphaAnimation alloc] initWithView:view];
    [alphaAnimation addKeyframeForTime:index-0.5 alpha:0];
    [alphaAnimation addKeyframeForTime:index alpha:1];
    [alphaAnimation addKeyframeForTime:index+0.5 alpha:0];
    [self.animator addAnimation:alphaAnimation];
}

#pragma mark scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatePageOffset];
    [self animateCurrentFrame];
    NSInteger nearestPage = floorf(self.pageOffset + 0.5);
    self.pageControl.currentPage = nearestPage;
}

- (void)updatePageOffset
{
    if (self.pageWidth > 0.f) {
        CGFloat currentOffset = self.scrollView.contentOffset.x;
        currentOffset = currentOffset / self.pageWidth;
        self.pageOffset = currentOffset;
    } else {
        self.pageOffset = 0.f;
    }
}

#pragma mark Action
- (void)clickLoginBtn:(FUIButton *)btn
{
}

- (void)clickRegisterBtn:(FUIButton *)btn
{
}
@end
