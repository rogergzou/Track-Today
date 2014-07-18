//
//  HCSAddCustomShortCutViewController.m
//  Progress Report
//
//  Created by Roger on 6/29/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSAddCustomShortCutViewController.h"
#import "HCSShortcut.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface HCSAddCustomShortCutViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate> //V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate>
//UINavigationControllerDelegate prevents error for delegation of UIImagePickerController

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) NSMutableArray *imageArrayForPicker;
//@property (strong, nonatomic) UIImage *currentlySelectedImage;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerOfImages;


@end

@implementation HCSAddCustomShortCutViewController

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)sender {
    self.imageArrayForPicker = nil; //so will reload when view loads again
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)imageArrayForPicker
{
    if (!_imageArrayForPicker) {
        _imageArrayForPicker = [NSMutableArray array];
        NSArray *xcassets = @[@"No_Image_Image", @"Default_Shortcut_Image", @"Eating", @"Exercise", @"Fun", @"Internet", @"Procrastination", @"Shopping", @"Social", @"Travel", @"Work", @"analytics", @"box", @"Briefcase", @"diamond", @"imac", @"keyboards", @"man", @"wooman", @"open-box", @"settings", @"speakers", @"target", @"wine"];
        for (NSString *name in xcassets) {
            [_imageArrayForPicker addObject:[UIImage imageNamed:name]];
        }
    }
    return _imageArrayForPicker;
}

/*- (UIImage *)currentlySelectedImage
{
    if (!_currentlySelectedImage) {
        _currentlySelectedImage = [UIImage imageNamed:@"No_Image_Image"];
    }
    return _currentlySelectedImage;
}*/

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
    self.createButton.layer.cornerRadius = self.createButton.frame.size.height/6;
    self.createButton.layer.borderWidth = 1;
    self.createButton.layer.borderColor = self.createButton.titleLabel.textColor.CGColor;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        self.navigationItem.rightBarButtonItem = self.cameraButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
    //self.imageArrayForPicker = [@[[UIImage imageNamed:@"Default_Shortcut_Image"]]mutableCopy];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI_2);
    rotate = CGAffineTransformScale(rotate, 0.2, 1.65); //.02 1.65
    [self.pickerOfImages setTransform:rotate];
    //rotate rect
    
    //self.pickerOfImages.center = CGPointMake(100.0, 100.0);
    //self.pickerOfImages.transform = CGAffineTransformMakeRotation(M_PI_2); //rotation in radians
    
    
    //http://isujith.wordpress.com/2009/03/17/horizontal-uipickerview/
    
    /*
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator =YES;
    myPickerView.backgroundColor = [UIColor clearColor];
    CGAffineTransform rot = CGAffineTransformMakeRotation(-3.14/2);
    rot = CGAffineTransformScale(rotate, 0.25, 2.0);
    [myPickerView setTransform:rot];
    [self.view addSubview:myPickerView];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)imageUploadButtonTouch:(id)sender {
    [self imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (IBAction)cameraButtonTouch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:@"Take Picture"];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:@"Choose from Photo Library"];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showFromBarButtonItem:self.cameraButton animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //Take Picture or Photo Library
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [self imagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            else
                [self imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            //Choose from Photo Library or Cancel
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                [self imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            else
                //cancel button, do nothing
            break;
        default:
            //cancel, nothing
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //code to work w/ media
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
        }
        
        [self.imageButton setBackgroundImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
        [self.imageButton setBackgroundImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateHighlighted];
        [self.imageButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@""] forState:UIControlStateNormal];
        [self.imageButton setAttributedTitle:[[NSAttributedString alloc]initWithString:@""] forState:UIControlStateHighlighted];
        
        self.imageArrayForPicker[0] = image;
        [self.pickerOfImages reloadAllComponents];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        if (sourceType == UIImagePickerControllerSourceTypeCamera)
            [self imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        else
            return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    imagePicker.allowsEditing = YES;
    /*
     //I give up
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //imagePicker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:imagePicker action:nil];
     
        imagePicker.navigationBarHidden = YES;
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:imagePicker.navigationController.viewControllers[1]];
        navControl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
        navControl.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelThisImagePicker)];
     
        //imagePicker.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
        //imagePicker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
        
        //imagePicker.navigationItem.leftItemsSupplementBackButton = YES;
        //UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
        //imagePicker.navigationItem.leftBarButtonItems = [imagePicker.navigationItem.leftBarButtonItems arrayByAddingObject:cameraButton];
    }
     */
    /*
    //if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //imagePicker.showsCameraControls = YES; Default is YES. Also apparently bug for retake if this is uncommented, idk why.
        //imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear; UNNEEDED default camera controls allow switch between the two
        //UIView *customview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];//[UIScreen mainScreen].applicationFrame];
        //customview.backgroundColor = [UIColor redColor];
        //imagePicker.cameraOverlayView = customview;
        //imagePicker.toolbarHidden = YES; if not hidden looks bad, covers camera control buttons
        //imagePicker.navigationBarHidden = NO; DOES NOTHING on either state. Useless
    //}
    */
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


/*
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[UIImagePickerController class]]) {
        UINavigationItem *ipcNavBar;
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
        UINavigationBar *bar = navigationController.navigationBar;
        [bar setHidden:NO];
        ipcNavBar = bar.topItem;
        ipcNavBar.title = @"Photos";
        ipcNavBar.leftItemsSupplementBackButton = YES;
        ipcNavBar.leftBarButtonItem = cameraButton;
        //navigationController.navigationItem.leftItemsSupplementBackButton = NO;
        //NSLog(@"%@ %@ %@", navigationController.navigationBar, navigationController.navigationItem, navigationController.navigationItem.leftBarButtonItem)
    }
}
*/

#pragma mark - UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //self.currentlySelectedImage = self.imageArrayForPicker[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGRect rect = CGRectMake(0, 0, 120, 80);
    //UILabel *label = [[UILabel alloc]initWithFrame:rect];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(3.14/2);
    rotate = CGAffineTransformScale(rotate, 0.25, 2.0);
    UIImageView *imagV = [[UIImageView alloc]initWithFrame:rect];
    imagV.image = self.imageArrayForPicker[row];
    [imagV setTransform:rotate];
    //label.text = [pickerViewArray objectAtIndex:row];
    //label.font = [UIFont systemFontOfSize:22.0];
    //label.textAlignment = UITextAlignmentCenter;
    //label.numberOfLines = 2;
    //label.lineBreakMode = UILineBreakModeWordWrap;
    //label.backgroundColor = [UIColor clearColor];
    imagV.clipsToBounds = YES;
    return imagV ;
    
    UIImage *image = self.imageArrayForPicker[row];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    //http://stackoverflow.com/questions/5581241/how-to-programmatically-rotate-image-by-90-degrees-in-iphone
    //set point of rotation
    imageView.center = CGPointMake(100.0, 100.0);
    
    //rotate rect
    imageView.transform = CGAffineTransformMakeRotation(M_PI_2); //rotation in radians
    return imageView;
}

/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    UIImage *image = self.imageArrayForPicker[0]; //change later into 1
    return image.size.width * 0.0002;
}*/

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.imageArrayForPicker count];
}

/*
#pragma mark - V8HorizontalPickerViewDelegate

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
    return [self.imageArrayForPicker count];
}

#pragma mark - V8HorizontalPickerViewDataSource

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    self.currentlySelectedImage = self.imageArrayForPicker[index];
}

- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index
{
    UIImage *image = self.imageArrayForPicker[index];
    return [[UIImageView alloc]initWithImage:image];
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    UIImage *image = self.imageArrayForPicker[index];
    return image.size.width + 20.f;
}
*/

#pragma mark - UITextFieldDelegate
//NOTE: USUAL VALUES OF KEYBOARD MOVEMENT CHANGED!

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
        rect.origin.y -= 140.0;
        rect.size.height += 140.0;
    } else {
        //revert
        rect.origin.y += 140.0;
        rect.size.height -= 140.0;
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
    
    if (self.view.frame.origin.y == 20 || self.view.frame.origin.y == 0) {
        //double status bar/call changed origin
        //don't move
        return;
    }
    
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
    UIImage *image = [self.imageArrayForPicker objectAtIndex:[self.pickerOfImages selectedRowInComponent:0]];
    if ([image isEqual:[UIImage imageNamed:@"No_Image_Image"]]) {
        //no image
        if (![self.textField.text length]) {
            //no text or image
            //nothing happens, would be just blank
        } else {
            //text but no image
            HCSShortcut *shortObj = [[HCSShortcut alloc]initWithTitle:self.textField.text image:nil];
            NSData *shortcut = [NSKeyedArchiver archivedDataWithRootObject:shortObj];
            NSArray *shortArr = [defaults arrayForKey:@"textShortcuts"];
            shortArr = [shortArr arrayByAddingObject:shortcut];
            [defaults setObject:shortArr forKey:@"textShortcuts"];
            [defaults synchronize];
        }
    } else {
        //there is image
        NSString *title = @"";
        if ([self.textField.text length]) {
            //image has text so assign
            title = self.textField.text;
            
            //moved up b/c if no text, useless. Therefore, only work if text
            HCSShortcut *shortObj = [[HCSShortcut alloc]initWithTitle:title image:image];
            NSData *shortcut = [NSKeyedArchiver archivedDataWithRootObject:shortObj];
            NSArray *regularShortcuts = [defaults arrayForKey:@"shortcuts"];
            regularShortcuts = [regularShortcuts arrayByAddingObject:shortcut];
            [defaults setObject:regularShortcuts forKey:@"shortcuts"];
            [defaults synchronize];
        }
    }
    self.imageArrayForPicker = nil; //so will reload when view loads again
}

@end
