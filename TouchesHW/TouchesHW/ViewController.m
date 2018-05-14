//
//  ViewController.m
//  TouchesHW
//
//  Created by Ivan Kozaderov on 13.05.2018.
//  Copyright © 2018 n1ke71. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong,nonatomic) UIView* cageView;
@property(strong,nonatomic) UIView* checkerView;
@property(strong,nonatomic) UIView* boardView;
@property(strong,nonatomic) UIView* draggingView;
@property(strong,nonatomic) NSMutableArray* checkersArray;
@property(strong,nonatomic) NSMutableArray* cagesArray;
@property(strong,nonatomic) NSMutableSet* freeCagesSet;
@property(assign,nonatomic) CGPoint touchOffset;
@property(assign,nonatomic) CGPoint positionBefore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.checkersArray   = [NSMutableArray array];
    self.cagesArray      = [NSMutableArray array];
    self.freeCagesSet    = [NSMutableSet set];
    
    
    CGRect  boardRect = CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 2, CGRectGetMidY(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 2, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
    UIView* board     = [[UIView alloc]initWithFrame:boardRect];
    board.backgroundColor = [UIColor grayColor];
    [self.view addSubview:board];
    board.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
    
    self.boardView = board;
    
    CGFloat sideOfCage = CGRectGetWidth(self.view.bounds) / 8 ;
    CGRect  cageRect   = CGRectMake(CGRectGetMinX(self.boardView.bounds) + sideOfCage , CGRectGetMinY(self.boardView.bounds),sideOfCage, sideOfCage);
    
    CGRect  checkerRect = CGRectMake(20.f, 20.f, 40.f, 40.f);
    
    
    for (int j = 0; j < 8; j++) {
        
        for (int i = 0; i < 4; i++) {
            
            UIView* cageView = [[UIView alloc]initWithFrame:cageRect];
            cageView.backgroundColor = [UIColor blackColor];
            [self.boardView addSubview:cageView];
            [self.cagesArray addObject:cageView];
            
            if (j<3) {
                
                [self addCheckerRect:checkerRect toPoint:cageView.center withColor:[UIColor redColor]];
                
            }
            else if (j>4){
                
                [self addCheckerRect:checkerRect toPoint:cageView.center withColor:[UIColor greenColor]];
                
            }
            else {
                
                NSValue* value = [NSValue valueWithCGPoint:cageView.center];
                [self.freeCagesSet addObject:value];
                
            }
            
            cageRect.origin.x = cageRect.origin.x + sideOfCage * 2;
            
            
        }
        
        cageRect.origin.y = cageRect.origin.y + sideOfCage;
        
        if ((j%2)) {
            
            cageRect.origin.x = CGRectGetMinX(self.boardView.bounds) + sideOfCage;
            
        }
        else {
            
            cageRect.origin.x = CGRectGetMinX(self.boardView.bounds);
            
        }
        
        
    }
}


#pragma mark - Methods

-(void)addCheckerRect:(CGRect)checkerRect toPoint:(CGPoint) point withColor:(UIColor*) color{
    
    
    UIView* checkerView = [[UIView alloc]initWithFrame:checkerRect];
    checkerView .center = point;
    checkerView .backgroundColor = color;
    checkerView .layer.cornerRadius = 20.f;
    [self.boardView     addSubview:checkerView];
    [self.checkersArray addObject:checkerView];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSSet* checkersSet = [NSSet setWithArray:self.checkersArray];
    UITouch* touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.boardView];
    UIView* view   = [self.boardView hitTest:point withEvent:event];
    
    
    if ([checkersSet containsObject:view]) {
        
        self.draggingView = view;
        self.positionBefore = view.center;
        
        [self.view bringSubviewToFront:self.draggingView];
        
        CGPoint touchPoint  = [touch locationInView:self.draggingView];
        
        self.touchOffset    = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                          
                                          CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        
        
    }
    else {
        
        self.draggingView = nil;
        self.positionBefore = CGPointZero;
    }
    
    
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.draggingView) {
        
        UITouch* touch = [touches anyObject];
        CGPoint  point  = [touch locationInView:self.boardView];
        
        if ([self.boardView pointInside:point withEvent:event]) {
            
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.boardView bringSubviewToFront:self.draggingView];
                
                self.draggingView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                
                self.draggingView.center = CGPointMake(point.x + self.touchOffset.x, point.y + self.touchOffset.y);
                
            }];
            
            
        }
        else {
            [UIView animateWithDuration:0.3f animations:^{
                
                self.draggingView.transform = CGAffineTransformIdentity;
                self.draggingView.center    = self.positionBefore;
            }];
            
            self.draggingView = nil;
            self.positionBefore = CGPointZero;
        }
        
        
    }
    
    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.draggingView.transform = CGAffineTransformIdentity;
        
    }];
    
    
    if (self.draggingView) {
        
        
        [self.freeCagesSet addObject:[NSValue valueWithCGPoint:self.positionBefore]];
        
        CGPoint newCenter = [self findFreeCellFor:CGPointMake(self.draggingView.center.x + self.touchOffset.x,
                                                              self.draggingView.center.y + self.touchOffset.y)];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.boardView bringSubviewToFront:self.draggingView];
            
            self.draggingView.center = newCenter;
            
            self.draggingView = nil;
            self.positionBefore = CGPointZero;
        }];
        
    }
        
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.draggingView.transform = CGAffineTransformIdentity;
        self.draggingView = nil;
        
    }];
    
}

-(CGPoint) findFreeCellFor:(CGPoint) pointChecker{
    
    CGFloat minLenght    = CGRectGetWidth(self.boardView.bounds) * 2;
    CGPoint nearestPoint = CGPointZero;
    // NSLog(@"minLenght=%f ",minLenght);
    NSArray* arrayPoint = [self.freeCagesSet allObjects];
    
    for (int i = 0; i < [arrayPoint count] ; i++) {
        
        CGPoint point = [[arrayPoint objectAtIndex:i] CGPointValue];
        CGFloat dx    = fabs(point.x -  pointChecker.x);
        CGFloat dy    = fabs(point.y -  pointChecker.y);
        
        //   NSLog(@"dx%f dy=%f point=%@",dx,dy, NSStringFromCGPoint(point));
        CGFloat length = sqrtf(powf(dx, 2) + powf(dy, 2));
        //   NSLog(@"length=%f ",length);
        if (length < minLenght) {
            
            minLenght    = length;
            nearestPoint = point;
        }
    }
    
    return nearestPoint;
}

@end
