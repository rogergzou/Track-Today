//
//  HCSAddCustomShortCutViewController.m
//  Progress Report
//
//  Created by Roger on 6/29/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSAddCustomShortCutViewController.h"
#import "HCSShortcut.h"

@interface HCSAddCustomShortCutViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *imageTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation HCSAddCustomShortCutViewController

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
//yay copypasta from prototypeC

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) setViewMoveUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        //move view origin up so textfield moves up
        //increase size of view so area behind keyboard is covered up
        rect.origin.y -= 80.0;
        rect.size.height += 80.0;
    } else {
        //revert
        rect.origin.y += 80.0;
        rect.size.height -= 80.0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (void)keyboardShow:(NSNotification *)notification {
    if (self.view.frame.origin.y >= 0) {
        [self setViewMoveUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMoveUp:NO];
    }
}
- (void)keyboardHide:(NSNotification *)notification {
    if (self.view.frame.origin.y >= 0) {
        [self setViewMoveUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMoveUp:NO];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    if ([self.imageButton.imageView.image isEqual:[UIImage imageNamed:@"Insert_Image"]]) {
        //no image
        if (![self.textField.text length]) {
            //no text or image wtf
            //alertview to say plz text or cancel
        } else {
            //text but no image
            HCSShortcut *shortObj = [[HCSShortcut alloc]initWithTitle:self.textField.text image:nil];
            NSData *shortcut = [NSKeyedArchiver archivedDataWithRootObject:shortObj];
            NSArray *shortArr = [defaults arrayForKey:@"textShortcuts"];
            shortArr = [shortArr arrayByAddingObject:shortcut];
            [defaults setObject:shortArr forKey:@"textShortcuts"];
            [defaults synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        //there is image
        NSString *title = @"";
        if ([self.textField.text length]) {
            //image has text so assign
            title = self.textField.text;
        }
        HCSShortcut *shortObj = [[HCSShortcut alloc]initWithTitle:title image:self.imageButton.imageView.image];
        NSData *shortcut = [NSKeyedArchiver archivedDataWithRootObject:shortObj];
        NSArray *regularShortcuts = [defaults arrayForKey:@"shortcuts"];
        regularShortcuts = [regularShortcuts arrayByAddingObject:shortcut];
        [defaults setObject:regularShortcuts forKey:@"shortcuts"];
        [defaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}


@end
