//
//  AppDelegate.m
//  mogenerator Example http://github.com/apontious/mogenerator-Example
//
//  Created by Andrew Pontious on 11/19/11.
//  Copyright (c) 2011 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"

#import "Measurements.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Updated via Cocoa bindings
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *age;
@property (nonatomic, retain) NSNumber *height;
@property (nonatomic) BOOL likesDogs;

@property (nonatomic, retain) NSString *text;

@property (nonatomic, assign) IBOutlet NSButton *addButton;

@property (nonatomic, retain) NSMutableArray *measurements;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize name;
@synthesize age;
@synthesize height;
@synthesize likesDogs;

@synthesize text;

@synthesize addButton;

@synthesize measurements;

#pragma mark - Private Methods

- (void)refreshText {
    NSMutableString *string = [NSMutableString string];
    
    NSUInteger ageTotal = 0;
    float heightTotal = 0.0;
    NSUInteger likesDogsTotal = 0;
    
    for (Measurements *measurementsObject in self.measurements) {
        ageTotal += measurementsObject.age;
        heightTotal += measurementsObject.height;
        likesDogsTotal += (measurementsObject.likesDogs == YES ? 1 : 0);
        
        [string appendFormat:@"%@, age %ld, height %.2f, %@ dogs\n", 
         measurementsObject.name,
         measurementsObject.age,
         measurementsObject.height,
         (measurementsObject.likesDogs == YES ? @"likes" : @"doesn't like")];
    }
    
    if ([self.measurements count] > 1) {
        [string appendFormat:@"----------------------------------------\nAverage age %.2f, average height %.2f, likes dogs %ld%%",
         ((float)ageTotal / (float)[self.measurements count]),
         heightTotal / (float)[self.measurements count],
         (NSUInteger)((float)likesDogsTotal / (float)[self.measurements count] * 100)];
    }
    
    self.text = string;
}

- (void)refreshButton {
    if ([self.name length] > 0 &&
        self.age != nil &&
        self.height != nil) {
        [self.addButton setEnabled:YES];
    } else {
        [self.addButton setEnabled:NO];
    }
}

#pragma mark - Actions

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)addMeasurements:(id)sender {
    // Text fields with formatters only seem to commit their text (and validate it) upon tabbing out of the field. So we emulate that when you press the button.
    if ([self.window makeFirstResponder:self.window] == YES) {
        Measurements *newMeasurements = [Measurements insertInManagedObjectContext:[self managedObjectContext]];

        [self.measurements addObject:newMeasurements];
        
        newMeasurements.name = self.name;
        newMeasurements.age = [self.age shortValue];
        newMeasurements.height = [self.height floatValue];
        newMeasurements.likesDogs = self.likesDogs;
    
        [self refreshText];
    }
}

#pragma mark - Core Data Methods

/**
 Returns the directory the application uses to store the Core Data store file. This code uses a directory named "mogenerator Example" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"mogenerator Example"];
}

/**
 Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mogenerator Example" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"mogenerator Example.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = [coordinator retain];
    
    return __persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return __managedObjectContext;
}

#pragma mark - NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.measurements = [NSMutableArray array];
    
    [self addObserver:self forKeyPath:@"name" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"age" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"height" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"likesDogs" options:0 context:NULL];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

#pragma mark - NSWindowDelegate Methods

/**
 Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

#pragma mark - Standard Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self refreshButton];
}

- (void)dealloc
{
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    
    self.measurements = nil;
    
    [super dealloc];
}

@end
