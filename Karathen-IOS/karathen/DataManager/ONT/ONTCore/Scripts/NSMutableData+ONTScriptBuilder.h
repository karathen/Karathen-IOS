//
//  NSMutableData+ONTScriptBuilder.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/24.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBigNumber.h"

typedef NS_OPTIONS(unsigned char, ONT_OPCODE){
    // Constants
    ONT_OPCODE_PUSH0 = 0x00, // An empty array of bytes is pushed onto the stack.
    ONT_OPCODE_PUSHF = ONT_OPCODE_PUSH0,
    ONT_OPCODE_PUSHBYTES1 = 0x01, // 0x01-0x4B The next bytes is data to be pushed onto the stack
    ONT_OPCODE_PUSHBYTES75 = 0x4B,
    ONT_OPCODE_PUSHDATA1 = 0x4C, // The next byte contains the number of bytes to be pushed onto the stack.
    ONT_OPCODE_PUSHDATA2 = 0x4D, // The next two bytes contain the number of bytes to be pushed onto the stack.
    ONT_OPCODE_PUSHDATA4 = 0x4E, // The next four bytes contain the number of bytes to be pushed onto the stack.
    ONT_OPCODE_PUSHM1 = 0x4F, // The number -1 is pushed onto the stack.
    ONT_OPCODE_PUSH1 = 0x51, // The number 1 is pushed onto the stack.
    ONT_OPCODE_PUSHT = ONT_OPCODE_PUSH1,
    ONT_OPCODE_PUSH2 = 0x52, // The number 2 is pushed onto the stack.
    ONT_OPCODE_PUSH3 = 0x53, // The number 3 is pushed onto the stack.
    ONT_OPCODE_PUSH4 = 0x54, // The number 4 is pushed onto the stack.
    ONT_OPCODE_PUSH5 = 0x55, // The number 5 is pushed onto the stack.
    ONT_OPCODE_PUSH6 = 0x56, // The number 6 is pushed onto the stack.
    ONT_OPCODE_PUSH7 = 0x57, // The number 7 is pushed onto the stack.
    ONT_OPCODE_PUSH8 = 0x58, // The number 8 is pushed onto the stack.
    ONT_OPCODE_PUSH9 = 0x59, // The number 9 is pushed onto the stack.
    ONT_OPCODE_PUSH10 = 0x5A, // The number 10 is pushed onto the stack.
    ONT_OPCODE_PUSH11 = 0x5B, // The number 11 is pushed onto the stack.
    ONT_OPCODE_PUSH12 = 0x5C, // The number 12 is pushed onto the stack.
    ONT_OPCODE_PUSH13 = 0x5D, // The number 13 is pushed onto the stack.
    ONT_OPCODE_PUSH14 = 0x5E, // The number 14 is pushed onto the stack.
    ONT_OPCODE_PUSH15 = 0x5F, // The number 15 is pushed onto the stack.
    ONT_OPCODE_PUSH16 = 0x60, // The number 16 is pushed onto the stack.
    
    // Flow control
    ONT_OPCODE_NOP = 0x61, // Does nothing.
    ONT_OPCODE_JMP = 0x62,
    ONT_OPCODE_JMPIF = 0x63,
    ONT_OPCODE_JMPIFNOT = 0x64,
    ONT_OPCODE_CALL = 0x65,
    ONT_OPCODE_RET = 0x66,
    ONT_OPCODE_APPCALL = 0x67,
    ONT_OPCODE_SYSCALL = 0x68,
    ONT_OPCODE_TAILCALL = 0x69,
    ONT_OPCODE_DUPFROMALTSTACK = 0x6A,
    
    // Stack
    ONT_OPCODE_TOALTSTACK = 0x6B, // Puts the input onto the top of the alt stack. Removes it from the main stack.
    ONT_OPCODE_FROMALTSTACK = 0x6C, // Puts the input onto the top of the main stack. Removes it from the alt stack.
    ONT_OPCODE_XDROP = 0x6D,
    ONT_OPCODE_XSWAP = 0x72,
    ONT_OPCODE_XTUCK = 0x73,
    ONT_OPCODE_DEPTH = 0x74, // Puts the number of stack items onto the stack.
    ONT_OPCODE_DROP = 0x75, // Removes the top stack item.
    ONT_OPCODE_DUP = 0x76, // Duplicates the top stack item.
    ONT_OPCODE_NIP = 0x77, // Removes the second-to-top stack item.
    ONT_OPCODE_OVER = 0x78, // Copies the second-to-top stack item to the top.
    ONT_OPCODE_PICK = 0x79, // The item n back in the stack is copied to the top.
    ONT_OPCODE_ROLL = 0x7A, // The item n back in the stack is moved to the top.
    ONT_OPCODE_ROT = 0x7B, // The top three items on the stack are rotated to the left.
    ONT_OPCODE_SWAP = 0x7C, // The top two items on the stack are swapped.
    ONT_OPCODE_TUCK = 0x7D, // The item at the top of the stack is copied and inserted before the second-to-top item.
    
    // Splice
    ONT_OPCODE_CAT = 0x7E, // Concatenates two strings.
    ONT_OPCODE_SUBSTR = 0x7F, // Returns a section of a string.
    ONT_OPCODE_LEFT = 0x80, // Keeps only characters left of the specified point in a string.
    ONT_OPCODE_RIGHT = 0x81, // Keeps only characters right of the specified point in a string.
    ONT_OPCODE_SIZE = 0x82, // Returns the length of the input string.
    
    // Bitwise logic
    ONT_OPCODE_INVERT = 0x83, // Flips all of the bits in the input.
    ONT_OPCODE_AND = 0x84, // Boolean and between each bit in the inputs.
    ONT_OPCODE_OR = 0x85, // Boolean or between each bit in the inputs.
    ONT_OPCODE_XOR = 0x86, // Boolean exclusive or between each bit in the inputs.
    ONT_OPCODE_EQUAL = 0x87, // Returns 1 if the inputs are exactly equal, 0 otherwise.
    // EQUALVERIFY = 0x88, // Same as EQUAL, but runs VERIFY afterward.
    // RESERVED1 = 0x89, // Transaction is invalid unless occuring in an unexecuted IF branch
    // RESERVED2 = 0x8A, // Transaction is invalid unless occuring in an unexecuted IF branch
    
    // Arithmetic
    // Note: Arithmetic inputs are limited to signed 32-bit integers, but may overflow their output.
    ONT_OPCODE_INC = 0x8B, // 1 is added to the input.
    ONT_OPCODE_DEC = 0x8C, // 1 is subtracted from the input.
    // SAL           = 0x8D, // The input is multiplied by 2.
    // SAR           = 0x8E, // The input is divided by 2.
    ONT_OPCODE_NEGATE = 0x8F, // The sign of the input is flipped.
    ONT_OPCODE_ABS = 0x90, // The input is made positive.
    ONT_OPCODE_NOT = 0x91, // If the input is 0 or 1, it is flipped. Otherwise the output will be 0.
    ONT_OPCODE_NZ = 0x92, // Returns 0 if the input is 0. 1 otherwise.
    ONT_OPCODE_ADD = 0x93, // a is added to b.
    ONT_OPCODE_SUB = 0x94, // b is subtracted from a.
    ONT_OPCODE_MUL = 0x95, // a is multiplied by b.
    ONT_OPCODE_DIV = 0x96, // a is divided by b.
    ONT_OPCODE_MOD = 0x97, // Returns the remainder after dividing a by b.
    ONT_OPCODE_SHL = 0x98, // Shifts a left b bits, preserving sign.
    ONT_OPCODE_SHR = 0x99, // Shifts a right b bits, preserving sign.
    ONT_OPCODE_BOOLAND = 0x9A, // If both a and b are not 0, the output is 1. Otherwise 0.
    ONT_OPCODE_BOOLOR = 0x9B, // If a or b is not 0, the output is 1. Otherwise 0.
    ONT_OPCODE_NUMEQUAL = 0x9C, // Returns 1 if the numbers are equal, 0 otherwise.
    ONT_OPCODE_NUMNOTEQUAL = 0x9E, // Returns 1 if the numbers are not equal, 0 otherwise.
    ONT_OPCODE_LT = 0x9F, // Returns 1 if a is less than b, 0 otherwise.
    ONT_OPCODE_GT = 0xA0, // Returns 1 if a is greater than b, 0 otherwise.
    ONT_OPCODE_LTE = 0xA1, // Returns 1 if a is less than or equal to b, 0 otherwise.
    ONT_OPCODE_GTE = 0xA2, // Returns 1 if a is greater than or equal to b, 0 otherwise.
    ONT_OPCODE_MIN = 0xA3, // Returns the smaller of a and b.
    ONT_OPCODE_MAX = 0xA4, // Returns the larger of a and b.
    ONT_OPCODE_WITHIN = 0xA5, // Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.
    
    // Crypto
    // RIPEMD160 = 0xA6, // The input is hashed using RIPEMD-160.
    ONT_OPCODE_SHA1 = 0xA7, // The input is hashed using SHA-1.
    ONT_OPCODE_SHA256 = 0xA8, // The input is hashed using SHA-256.
    ONT_OPCODE_HASH160 = 0xA9,
    ONT_OPCODE_HASH256 = 0xAA,
    // tslint:disable-next-line:max-line-length
    ONT_OPCODE_CHECKSIG = 0xAC, // The entire transaction's outputs inputs and script (from the most recently-executed CODESEPARATOR to the end) are hashed. The signature used by CHECKSIG must be a valid signature for this hash and public key. If it is 1 is returned 0 otherwise.
    // tslint:disable-next-line:max-line-length
    ONT_OPCODE_CHECKMULTISIG = 0xAE, // For each signature and public key pair CHECKSIG is executed. If more public keys than signatures are listed some key/sig pairs can fail. All signatures need to match a public key. If all signatures are valid 1 is returned 0 otherwise. Due to a bug one extra unused value is removed from the stack.
    
    // Array
    // tslint:disable:indent
    ONT_OPCODE_ARRAYSIZE  = 0xC0,
    ONT_OPCODE_PACK       = 0xC1,
    ONT_OPCODE_UNPACK     = 0xC2,
    ONT_OPCODE_PICKITEM   = 0xC3,
    ONT_OPCODE_SETITEM    = 0xC4,
    ONT_OPCODE_NEWARRAY   = 0xC5,
    ONT_OPCODE_NEWSTRUCT  = 0xC6,
    ONT_OPCODE_NEWMAP     = 0xC7,
    ONT_OPCODE_APPEND     = 0xC8,
    ONT_OPCODE_REVERSE    = 0xC9,
    ONT_OPCODE_REMOVE     = 0xCA,
    ONT_OPCODE_HASKEY     = 0xCB,
    ONT_OPCODE_KEYS       = 0xCC,
    ONT_OPCODE_VALUES     = 0xCD,
    
    // Exception
    ONT_OPCODE_THROW = 0xF0,
    ONT_OPCODE_THROWIFNOT = 0xF1
};


@interface NSMutableData (ONTScriptBuilder)
-(void)addOpcode:(ONT_OPCODE)op;
-(void)addByte:(Byte)byte;
-(void)addData:(NSData *)data;

-(void)pushBool:(BOOL)b;
-(void)pushNumber:(NSNumber *)number;
-(void)pushData:(NSData *)data;
-(void)pushPack;
@end
