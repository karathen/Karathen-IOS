//
//  UIViewController+Category.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/24.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "UIViewController+Category.h"

@implementation UIViewController (Category)


- (void)inputAlertWithTitle:(NSString *)title
                    message:(NSString *)message
                placeholder:(NSString *)placeholder
            secureTextEntry:(BOOL)secureTextEntry
               keyboardType:(UIKeyboardType)keyboardType
                destructive:(BOOL)destructive
                  minLength:(NSInteger)minLength
                  maxLength:(NSInteger)maxLength
                 completion:(void(^)(NSString *text))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:Localized(@"Confirm") style:destructive?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = alertController.textFields.firstObject;
        if (completion) {
            completion(textField.text);
        }
    }];
    [alertController addAction:confirmAction];
    
    @weakify(self)
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
        textField.secureTextEntry = secureTextEntry;
        textField.keyboardType = keyboardType;
        
        @strongify(self)
        [self addRacWithTextField:textField minLength:minLength maxLength:maxLength confirmAction:confirmAction];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.rt_navigationController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)addRacWithTextField:(UITextField *)textField minLength:(NSInteger)minLength maxLength:(NSInteger)maxLength confirmAction:(UIAlertAction *)confirmAction {
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        if (maxLength != 0) {
            if (x.length > maxLength) {
                textField.text = [x substringToIndex:maxLength];
            }
        }
        confirmAction.enabled = x.length >= minLength;
    }];
}

- (void)showPassWordMaxLength:(NSInteger)maxLength
                      onlyNum:(BOOL)onlyNum
                   completion:(void(^)(NSString *text))completion {
    [self inputAlertWithTitle:Localized(@"Please input password")
                      message:nil
                  placeholder:Localized(@"Wallet password")
              secureTextEntry:YES
                 keyboardType:onlyNum?UIKeyboardTypeNumberPad:UIKeyboardTypeDefault
                  destructive:YES
                    minLength:6
                    maxLength:maxLength
                   completion:completion];
}

- (void)messageAlertTitle:(NSString *)title
                  message:(NSString *)message
                   cancel:(NSString *)cancelTitle
                sureTitle:(NSString *)sureTitle
              destructive:(BOOL)destructive
              alertAction:(void(^)(NSInteger index))alertAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (alertAction) {
            alertAction(0);
        }
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:sureTitle style:destructive?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertAction) {
            alertAction(1);
        }
    }];
    [alertController addAction:confirmAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.rt_navigationController presentViewController:alertController animated:YES completion:nil];
    });
    
}

- (void)messageAlertMessage:(NSString *)message
                  sureTitle:(NSString *)sureTitle
                destructive:(BOOL)destructive
                 sureAction:(void(^)(void))sureAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:sureTitle style:destructive?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureAction) {
            sureAction();
        }
    }];
    [alertController addAction:confirmAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.rt_navigationController presentViewController:alertController animated:YES completion:nil];
    });
}




@end
