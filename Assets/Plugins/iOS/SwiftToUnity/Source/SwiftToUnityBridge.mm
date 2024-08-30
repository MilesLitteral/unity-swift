#import <UnityFramework/UnityFramework-Swift.h>
#import "UnityInterface.h"
#import <Photos/Photos.h>

extern "C"
{
    char* cStringCopy(const char* string) {
        if (string == NULL) {
            return NULL;
        }

        size_t length = strlen(string) + 1;
        char* res = (char*) malloc(length);

        if (res != NULL) {
            memcpy(res, string, length);
        }

        return res;
    }

    void cSendHelloWorldMessage()
    {
        [[SwiftToUnity shared] swiftSendHelloWorldMessage];
    }

    char* cHelloWorld()
    {
        NSString *returnString = [[SwiftToUnity shared] swiftHelloWorld];
        return cStringCopy([returnString UTF8String]);
    }

    int cAdd(int x, int y)
    {
        return (int) [[SwiftToUnity shared] swiftAdd :x :y];
    }

    char* cConcatenate(const char* x, const char* y)
    {
        NSString *returnString = [[SwiftToUnity shared] swiftConcatenate :[NSString stringWithUTF8String:x] y:[NSString stringWithUTF8String:y]];
        return cStringCopy([returnString UTF8String]);
    }

   
   const char*  _GetImage()
   {
       NSLog(@"I am in Begin");
       UIImage *myUIImage = [UIImage imageNamed:@"Test.jpg"];
       NSData *imageData = UIImagePNGRepresentation(myUIImage);
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
       NSString *documentsDirectory = [paths objectAtIndex:0];
       NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Test.jpg"]; //Add the file name
       NSLog(@"filePath %@",filePath);
       [imageData writeToFile:filePath atomically:YES];
       return MakeStringCopy([filePath UTF8String]);
   }
}
