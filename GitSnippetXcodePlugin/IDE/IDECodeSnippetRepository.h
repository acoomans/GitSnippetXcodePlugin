//
//  IDECodeSnippetRepository.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

@interface IDECodeSnippetRepository : NSObject
{
    NSMutableDictionary *_systemSnippetsByIdentifier;
    NSMutableDictionary *_snippetsByIdentifier;
    NSMutableSet *_codeSnippetsNeedingSaving;
    //DVTDelayedInvocation *_savingInvocation;
    NSMutableSet *_codeSnippets;
}

+ (id)sharedRepository;
@property(readonly) NSSet *codeSnippets; // @synthesize codeSnippets=_codeSnippets;
//- (void).cxx_destruct;
- (void)removeCodeSnippet:(id)arg1;
- (void)addCodeSnippet:(id)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)stopObservingSnippet:(id)arg1;
- (void)startObservingSnippet:(id)arg1;
- (void)_removeUserCodeSnippetFromDisk:(id)arg1;
- (void)_saveUserCodeSnippetsToDisk;
- (void)saveUserCodeSnippetToDisk:(id)arg1;
- (void)setUserSnippetNeedsSaving:(id)arg1;
- (id)_updatedUserSnippet:(id)arg1;
- (void)_loadUserCodeSnippets;
- (id)codeSnippetFromCustomDataSpecifier:(id)arg1 dataStore:(id)arg2;
- (void)_loadSystemCodeSnippets;
- (id)userDataStore;
- (id)init;

- (void)old_saveUserCodeSnippetToDisk:(id)arg1;
- (id)old__updatedCodeSnippet:(id)arg1;
- (void)old_removeCodeSnippet:(id)arg1;
@end
