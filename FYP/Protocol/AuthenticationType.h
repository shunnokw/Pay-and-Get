//
//  AuthenticationType.h
//  FYP
//
//  Created by Jason Wong on 31/1/2020.
//  Copyright © 2020 Jason Wong. All rights reserved.
//

///I used Firebase for an internal company project and this is what I did:
///
///Abstract away all Firebase related code using protocols: for example, I created a DatastoreType protocol that had the necessary methods to perform CRUD operations. I created another protocol, called RealtimeDatastoreType that extended DatastoreType to add functions for event listeners, for real-time updates. I also created an AuthenticationType protocol which had sign-in/sign-out functions and another function to detect if the user is signed in. Both these protocols had concrete implementations which used Firebase Firestore and Firebase Authentication respectively, which got injected into the view’s presenter as default parameters in the initialiser.
///
///Create a testable/mock class that implements the above protocols: for the data store, I created a TestStore class that used an in-memory array for the CRUD operations and allowed me to simulate the Firebase Firestore without using a real backend. For authentication, I created a TestAuthentication class, which simply logged the users in and out without performing real authentication.
///
///Inject the testable/mock class when a UI test is running: this is simple to do - you just have to set an environment variable when you run the tests and your app can read it whenever you inject your data store/authentication classes (via the views’ presenter’s initialiser, for example). This will allow your app to detect that it’s running a test and it can inject the testable/mock classes instead. This does mean you’re modifying “production” code to inject “test” classes, but it’s alright.
///
///You don’t need to create a separate instance of the backend specifically for UI testing - you can simply use a mock for it. You can abstract things away using protocols and then swap the implementations when running tests. It also ensures that your UI tests pass even if Firebase is down.
///
///TL;DR: Your app shouldn’t know anything about Firebase. It shouldn’t matter what the backend is - it could be AWS or something custom. Your app shouldn’t depend on a concrete implementation of a specific backend :) It should only know about a protocol. My app works exactly the same - regardless of whether I use Firebase, or AWS or test/mock classes (to simulate a backend).

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AuthenticationType <NSObject>

@end

NS_ASSUME_NONNULL_END
