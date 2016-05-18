//
//  ViewController.m
//  AssociateDemo
//
//  Created by 禚恒 on 16/5/17.
//  Copyright © 2016年 jinzhuanch. All rights reserved.
//

#import "ViewController.h"

#define kScreen_Height      ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width       ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame       (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))

#define RGBA(R, G, B, A)        [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define RGB(R,G,B)              [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong)UIView *textFieldBgView;

@property (nonatomic,strong)UITextField *inputTextField;

@property (nonatomic,strong)UITableView *assoTableView;

@property (nonatomic,strong)UIView *maskView;


//所有请求下来的数据放置的数组
@property (nonatomic,copy)NSArray *assoArray;
//根据关键字 查询的接口
@property (nonatomic,retain)NSMutableArray *assoTableArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getData];
    [self configUI];

}
//此地数据 主要就是把请求下来的数据 放入数组里面 然后进行处理
-(void)getData{
    //本地数据处理  这是原来代码中 对data数据的处理
    NSString *path = [[NSBundle mainBundle]pathForResource:@"tips" ofType:@"data"];
    NSData *assoData = [[NSData alloc]initWithContentsOfFile:path];
    NSString *assoStr = [[NSString alloc]initWithData:assoData encoding:NSUTF8StringEncoding];
//    self.assoArray = [assoStr componentsSeparatedByString:@"\n"];
    
    
    //json数据处理  这是后台对json文件数据的处理
    NSString *pathX = [[NSBundle mainBundle]pathForResource:@"1" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:pathX options:NSDataReadingMappedIfSafe error:nil];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

    
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dic in array) {
        
        NSString *myString = [NSString stringWithFormat:@"%@",dic[@"v"]];
        [dataArray addObject:myString];
    }
    self.assoArray = [dataArray copy];
    
    
    
}
-(void)configUI{
    
    self.textFieldBgView = [[UIView alloc]initWithFrame:CGRectMake(50, 50, 200, 50)];
    self.textFieldBgView.userInteractionEnabled = YES;
    self.textFieldBgView.layer.borderWidth = 2;
    self.textFieldBgView.layer.borderColor = RGB(255, 121, 0).CGColor;
    [self.view addSubview:self.textFieldBgView];
    
    self.inputTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 180, 30)];
    self.inputTextField.font = [UIFont systemFontOfSize:14];
    self.inputTextField.placeholder = @"输入你想查询的字段";
    self.inputTextField.textAlignment = NSTextAlignmentLeft;
    self.inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.inputTextField addTarget:self action:@selector(eventEditingChange:) forControlEvents:UIControlEventEditingChanged];
    self.inputTextField.delegate = self;
    [self.textFieldBgView addSubview:self.inputTextField];
    
    self.assoTableView = [[UITableView alloc]initWithFrame:CGRectMake(50, 110, 200, 300) style:UITableViewStylePlain];
    self.assoTableView.delegate = self;
    self.assoTableView.dataSource = self;
//    self.assoTableView.alpha = 1;
    self.assoTableView.hidden = YES;
    self.assoTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.assoTableView];
    
    //主要用来 隐藏键盘 还原
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, kScreen_Width, kScreen_Height-115)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toHideKeyboard)]];
    
    
}

#pragma mark  处理联想来的数据

-(void)hadndleAssoDataWithSearchTxet:(NSString *)searchText{
    
    self.assoTableArray = [NSMutableArray array];
//    for (NSString *str  in self.assoArray) {
//        NSRange range = [str rangeOfString:searchText];
//        
//        if (range.location == 0) {
//            [self.assoTableArray addObject:str];
//        }
//    }
    
    for (NSString *str in self.assoArray) {
        if([str rangeOfString:searchText].location !=NSNotFound)
        {
            [self.assoTableArray addObject:str];
        }
        else
        {
//            NSLog(@"no");
        }
    }
    
    
    if (self.assoTableArray.count > 0) {
        self.assoTableView.hidden = NO;
        [self.view bringSubviewToFront:self.assoTableView];
        [self.assoTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    }else{
        self.assoTableView.hidden = YES;
    }
    
}
//显示tableView
-(void)showAssoWithText:(NSString *)text{
    [self.view addSubview:self.maskView];
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0.5;
    }];
    [self hadndleAssoDataWithSearchTxet:text];
    
}

//隐藏
-(void)toHideKeyboard{
    [self.inputTextField resignFirstResponder];
    [self removeTheMaskView];
}

-(void)removeTheMaskView{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
    self.assoTableView.hidden = YES;
    
}


#pragma mark - UITextFieldDelegate
//监测 每次输入的时候 都要去判断一次数据数据里面的数据
-(void)eventEditingChange:(UITextField *)textField{
//    NSLog(@"1");
    [self showAssoWithText:textField.text];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showAssoWithText:textField.text];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self showAssoWithText:@""];
    return YES;
}


#pragma mark tableViewDele

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assoTableArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"myCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.assoTableArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.inputTextField setText:[self.assoTableArray objectAtIndex:indexPath.row]];
}

-(void)dealloc{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
