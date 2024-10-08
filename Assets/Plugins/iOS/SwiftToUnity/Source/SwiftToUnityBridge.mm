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


    // Helper function to convert NSArray<NSString *> to a C array of char *
    char** ConvertNSArrayToCStringArray(NSArray<NSString *> *array, int *count) {
        *count = (int)array.count;
        char **cArray = (char **)malloc(sizeof(char *) * (*count));

        for (int i = 0; i < *count; i++) {
            NSString *str = array[i];
            const char *utf8Str = [str UTF8String];
            cArray[i] = strdup(utf8Str);  // strdup creates a new string in memory
        }

        return cArray;
    }

    // Make sure to free the memory allocated for the strings and the array
    void FreeCStringArray(char **cArray, int count) {
        for (int i = 0; i < count; i++) {
            free(cArray[i]);  // Free each string
        }
        free(cArray);  // Free the array
    }

    char** _FetchGalleryImages()
    {
        NSArray<NSString*> *arr = [[SwiftToUnity shared] _FetchGalleryImages];
        int idx = [arr count];
        char** result = ConvertNSArrayToCStringArray(arr, &idx);
        return result;
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
       
       //NSPicturesDirectory
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
       NSString *documentsDirectory = [paths objectAtIndex:0];
       NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Test.png"]; //Add the file name
       NSLog(@"filePath %@",filePath);
       [imageData writeToFile:filePath atomically:YES];
       return cStringCopy([filePath UTF8String]);
    }

    char**  _GetImages()
    {
        NSArray  *path_to_images = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
        NSUInteger count = [path_to_images count];
        char **array = (char **)malloc((count + 1) * sizeof(char*));
        
        NSString * sourcePath = [[path_to_images valueForKey:@"description"] componentsJoinedByString:@""];

        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
        NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            [imageFiles addObject:[sourcePath stringByAppendingPathComponent:filename]];
        }];
        
        NSUInteger countB = [imageFiles count];
        NSLog(@"filePaths Found: %@", countB);
        for (unsigned i = 0; i < countB; i++){
            array[i] = cStringCopy([imageFiles[i] UTF8String]);
        }
        
        return array;
    }

    char**  _GetImagesSet(int numberOfImages)
    {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
        char **array = (char **)malloc((numberOfImages + 1) * sizeof(char*));
        
        NSLog(@"filePaths: %@",paths);
        for (unsigned i = 0; i < numberOfImages; i++){
            array[i] = cStringCopy([[paths objectAtIndex:i] UTF8String]);
        }
        
        return array;
    }
    
    char**  _GetImagesRandom()
    {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
        unsigned count = [paths count];
        char **array = (char **)malloc((count + 1) * sizeof(char*));
        
        int rng = arc4random_uniform(count);
        
        NSLog(@"filePaths: %@",paths);
        for (unsigned i = 0; i < rng; i++){
            array[i] = cStringCopy([[paths objectAtIndex:i] UTF8String]);
        }
        return array;
    }

    
    void freeArray(char** array)
    {
        if (array != NULL)
        {
            for (unsigned index = 0; array[index] != NULL; index++)
            {
                free(array[index]);
            }
            free(array);
        }
    }
}

