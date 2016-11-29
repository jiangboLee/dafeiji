//
//  ViewController.m
//  FeiJiFair
//
//  Created by ** on 2016/11/24.
//  Copyright © 2016年 Test. All rights reserved.
//

#import "ViewController.h"
#define kWindowWidth                        [[UIScreen mainScreen] bounds].size.width
#define kWindowHeight                       [[UIScreen mainScreen] bounds].size.height


@interface ViewController ()
{
    NSInteger floatWeight;
    NSTimer *timer;
    NSTimer *findZidanTimer;
    NSTimer *fireZidanTimer;
    NSInteger fen;
}
@property (nonatomic ,strong) UIImageView *bgImg1;
@property (nonatomic ,strong) UIImageView *bgImg2;
@property (nonatomic ,strong) UIImageView *myPlane;
@property (nonatomic ,strong) NSMutableArray *diJiArray;
@property (nonatomic ,strong) NSMutableArray *ziDanArray;
@property (nonatomic ,strong) UIImageView *baozha;
@property (nonatomic ,strong) NSMutableArray *baozhaArray;
@property (nonatomic ,strong) UILabel *fenLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fen = 0;
    [self.view addSubview:self.bgImg1];
    [self.view addSubview:self.bgImg2];
    [self.view addSubview:self.myPlane];
    [self.view addSubview:self.baozha];
    [self.view addSubview:self.fenLab];
    //创建控制地图移动的定时器
    [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(mapMove) userInfo:nil repeats:YES];
    //创建找敌机的定时器
    [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(findDiJi) userInfo:nil repeats:YES];
    //创建控制敌机下落的定时器
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(downDiJi) userInfo:nil repeats:YES];
    //创建找子弹的定时器
    findZidanTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(findZiDan) userInfo:nil repeats:YES];
    //发射子弹
    fireZidanTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fireZiDan) userInfo:nil repeats:YES];
    //创建爆炸的定时器
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(baoZha) userInfo:nil repeats:YES];
}
#pragma mark  -------timer
-(void)mapMove
{
    
    CGRect rect1 = self.bgImg1.frame;
    
    rect1.origin.y = rect1.origin.y + 10;
    
    CGRect rect2 = self.bgImg2.frame;
    
    rect2.origin.y = rect2.origin.y + 10;
    
    [UIView animateWithDuration:0.05 animations:^{
        
        self.bgImg1.frame = rect1;
        self.bgImg2.frame = rect2;
    }];
    
    if (rect1.origin.y >= kWindowHeight)
    {
        self.bgImg1.frame = CGRectMake(0, -kWindowHeight, kWindowWidth, kWindowHeight+10);
    }
    
    if (rect2.origin.y >=kWindowHeight)
    {
        self.bgImg2.frame = CGRectMake(0, -kWindowHeight, kWindowWidth, kWindowHeight+10);
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //获取屏幕中点的位置
    CGPoint point = [touch locationInView:self.view];
    //CGRectContains包含Point
    if (CGRectContainsPoint(self.myPlane.frame, point))
    {
        self.myPlane.center = point;
    }
}
-(void)findDiJi
{
    for (UIImageView *diji in self.diJiArray)
    {
        if (diji.tag == 0)
        {
            
            diji.tag = 1;
            
            floatWeight = kWindowWidth-35;
            
            int x = arc4random()%floatWeight;
            
            diji.frame = CGRectMake(x, -x, 35, 25);
            
            break;
        }
    }
}

-(void)downDiJi
{
    for (UIImageView *diji in self.diJiArray)
    {
        if (diji.tag == 1)
        {
            CGRect rect = diji.frame;
            
            rect.origin.y = rect.origin.y + 10;
            
            [UIView animateWithDuration:0.1 animations:^{
                
                diji.frame = rect;
            }];
            
            if (rect.origin.y >=kWindowHeight)
            {
                diji.frame = CGRectMake(0, -25, 35, 25);
                
                diji.tag = 0;
            }
            
        }
    }
}

-(void)findZiDan
{
    for (UIImageView *ziDan in self.ziDanArray)
    {
        if (ziDan.tag == 0)
        {
            ziDan.hidden = NO;
            ziDan.tag = 1;
            
            CGPoint point = self.myPlane.center;
            
            point.y = point.y - 30 - 7;
            
            ziDan.center = point;
            
            break;
        }
    }
}

-(void)fireZiDan
{
    for (UIImageView *ziDan in self.ziDanArray)
    {
        if (ziDan.tag == 1)
        {
            CGRect rect = ziDan.frame;
            
            rect.origin.y = rect.origin.y - 10;
            
            [UIView animateWithDuration:0.05 animations:^{
                
                ziDan.frame = rect;
            }];
            
            
            if (rect.origin.y < -14) {
                ziDan.tag = 0;
                
                ziDan.hidden = YES;
                ziDan.frame = CGRectMake(0, -14, 7, 14);
            }
        }
    }
}

-(void)baoZha
{
    for (UIImageView *diJi in self.diJiArray)
    {
        if (diJi.tag == 1)
        {
            if (CGRectIntersectsRect(diJi.frame, self.myPlane.frame)) {
                
                self.baozha.frame = self.myPlane.frame;
                [self.baozha startAnimating];
                
                
                //取消定时器
                [timer setFireDate:[NSDate distantFuture]];
                [findZidanTimer setFireDate:[NSDate distantFuture]];
                [fireZidanTimer setFireDate:[NSDate distantFuture]];
                
                self.myPlane.hidden = YES;
                for (UIImageView *ziDan in self.ziDanArray) {
                    
                    ziDan.hidden = YES;
                }
                
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"GAVE OVER" message:[NSString stringWithFormat:@"分数:%zd分",fen]preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [timer invalidate];
                    
                    
                    
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    fen = 0 ;
                    self.fenLab.text = [NSString stringWithFormat:@"%ld分",fen];
                    for (UIImageView *diJia in self.diJiArray) {
                        
                        diJia.tag = 0;
                        diJia.frame = CGRectMake(0, -25, 35, 25);
                    }
                    
                    self.myPlane.hidden = NO;
                    [timer setFireDate:[NSDate distantPast]];
                    [findZidanTimer setFireDate:[NSDate distantPast]];
                    [fireZidanTimer setFireDate:[NSDate distantPast]];
                    
                    
                }];
                
                [alertController addAction:action1];
                [alertController addAction:action2];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
                return;
            }
            
            for (UIImageView *ziDan in self.ziDanArray)
            {
                if (ziDan.tag ==1)
                {
                    if (CGRectIntersectsRect(ziDan.frame, diJi.frame))
                    {
                        fen+=1;
                        self.baozha.frame = diJi.frame;

                        [self.baozha startAnimating];

                        ziDan.tag = 0;
                        ziDan.hidden = YES;
                        
                        ziDan.frame = CGRectMake(0, -14, 7, 14);
                        
                        diJi.tag = 0;
                       
                        diJi.frame = CGRectMake(0, -25, 35, 25);
                        
                        self.fenLab.text = [NSString stringWithFormat:@"%ld分",fen];
                    }
                }
            }
        }
    }
}
#define mark ----Controller--

-(UIImageView *)bgImg1
{
    if (!_bgImg1) {
        _bgImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight+10)];
        _bgImg1.image = [UIImage imageNamed:@"bg"];
    }
    return _bgImg1;
    
}
-(UIImageView *)bgImg2
{
    if (!_bgImg2) {
        _bgImg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, -kWindowHeight, kWindowWidth, kWindowHeight+10)];
        _bgImg2.image = [UIImage imageNamed:@"bg"];
    }
    return _bgImg2;

}
-(UIImageView *)myPlane
{
    if (!_myPlane) {
        _myPlane = [[UIImageView alloc] initWithFrame:CGRectMake(120, 230, 80, 60)];
        //animationImages是UIImageView的属性动画
        _myPlane.center = CGPointMake(kWindowWidth/2, 400);
        _myPlane.animationImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"plane1"],[UIImage imageNamed:@"plane2"],  nil];
        //动画时间
        _myPlane.animationDuration = .3;
        //开始动画
        [_myPlane startAnimating];
    }
    return _myPlane;
}
-(NSMutableArray *)diJiArray
{
    if (!_diJiArray) {
        _diJiArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < 15; i++) {
            UIImageView *dijiImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, -25, 35, 25)];
            dijiImg.image = [UIImage imageNamed:@"diji"];
            [self.view addSubview:dijiImg];
            [_diJiArray addObject:dijiImg];
        }
    }
    return _diJiArray;
}
-(NSMutableArray *)ziDanArray
{
    if (!_ziDanArray) {
        _ziDanArray = [NSMutableArray arrayWithCapacity:0];
        for ( int i = 0 ; i< 60; i++)
        {
            UIImageView *ziDanImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, -14, 7, 14)];
            ziDanImg.image = [UIImage imageNamed:@"zidan1"];
            [self.view addSubview:ziDanImg];
            [_ziDanArray addObject:ziDanImg];
        }
    }
    return _ziDanArray;
}
-(UIImageView *)baozha
{
    if (!_baozha) {
        _baozha = [[UIImageView alloc] initWithFrame:CGRectMake(0, -kWindowHeight, kWindowWidth, kWindowHeight)];
        _baozha.animationImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"bz1"],[UIImage imageNamed:@"bz2"],[UIImage imageNamed:@"bz3"],[UIImage imageNamed:@"bz4"],[UIImage imageNamed:@"bz5"],[UIImage imageNamed:@"bz6"], nil];
        _baozha.animationDuration = 0.3;
        //animationRepeatCount动画的次数
        _baozha.animationRepeatCount = 1;
    }
    return _baozha;
}
-(UILabel *)fenLab
{
    if (!_fenLab) {
        _fenLab = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-100, 30, 80, 40)];
        _fenLab.font = [UIFont systemFontOfSize:15];
        _fenLab.textColor = [UIColor redColor];
        _fenLab.text = @"0分";
        _fenLab.textAlignment = NSTextAlignmentCenter;
    }
    return _fenLab;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
