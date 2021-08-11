//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<speech_to_text/SpeechToTextPlugin.h>)
#import <speech_to_text/SpeechToTextPlugin.h>
#else
@import speech_to_text;
#endif

#if __has_include(<text_to_speech/TextToSpeechPlugin.h>)
#import <text_to_speech/TextToSpeechPlugin.h>
#else
@import text_to_speech;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [SpeechToTextPlugin registerWithRegistrar:[registry registrarForPlugin:@"SpeechToTextPlugin"]];
  [TextToSpeechPlugin registerWithRegistrar:[registry registrarForPlugin:@"TextToSpeechPlugin"]];
}

@end
