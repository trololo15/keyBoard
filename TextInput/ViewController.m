//
//  ViewController.m
//  TextInput
//
//  Created by BO on 15/11/26.
//  Copyright © 2015年 BO. All rights reserved.
//

#import "ViewController.h"
#import "MMGrowingTextView.h"
#import "UIViewExt.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,
MMGrowingTextViewDelegate>
{
    UITableView       *_tableView;
    NSMutableArray    *_dataSource;
    MMGrowingTextView *growTextView;
    UIView            *senderView;
}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"wechat";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _dataSource = [NSMutableArray arrayWithObjects:@"Hi",@"在吗",@"晚上一起吃饭？", nil];
    [self configSubviews];
}

- (void)configSubviews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-50) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    growTextView = [[MMGrowingTextView alloc] initWithFrame:CGRectMake(13, 10, kScreenWidth-26, 33)];
    growTextView.layer.borderColor = RGBA(210, 210, 210, 1).CGColor;
    growTextView.layer.borderWidth = 0.5f;
    growTextView.layer.cornerRadius = 5.0f;
    growTextView.growingDelegate = self;
    growTextView.delegate = self;
    growTextView.minHeight = 33;
    growTextView.maxHeight = 90;
    growTextView.font = [UIFont systemFontOfSize:15];
    growTextView.returnKeyType = UIReturnKeySend;
    growTextView.layer.masksToBounds = YES;
    
    senderView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.bottom, kScreenWidth, 50)];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    line.backgroundColor = RGBA(210, 210, 210, 1);
    [senderView addSubview:line];
    [senderView addSubview:growTextView];
    [self.view addSubview:senderView];
}

- (void)inputTextFieldBackToNormal {
    
    NSIndexPath *index1 = [NSIndexPath indexPathForRow:_dataSource.count-1 inSection:0];
    if (_dataSource.count>0) {
        [_tableView scrollToRowAtIndexPath:index1 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - 键盘处理
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note
{
    
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    //先拿到键盘以及tableview需要缩小的高度
    
    CGFloat tableViewHeight = kScreenHeight - 64 - senderView.height;
    
    //做动画
    //拿到键盘动画的时间
    NSValue *animationDurationValue = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationD;
    [animationDurationValue getValue:&animationD];
    
    //拿到动画曲线
    NSValue *animationCurve = note.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationC;
    [animationCurve getValue:&animationC];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationD];
    [UIView setAnimationCurve:animationC];
    
    _tableView.height = tableViewHeight;
    senderView.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
}

- (void)growingTextView:(MMGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float heightDifference = (height - growTextView.height);
    CGRect frame = senderView.frame;
    frame.size.height += heightDifference;
    frame.origin.y -= heightDifference;
    senderView.frame = frame;
    [growTextView reloadInputViews];
    _tableView.height -= heightDifference;
    if (heightDifference>0) {
        [self inputTextFieldBackToNormal];
    }
}

#pragma mark - TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    
    return YES;
}

- (void)sendMessage
{
    [_dataSource addObject:growTextView.text];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    growTextView.text = @"";
}

#pragma mark - Tableview..
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellll";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
