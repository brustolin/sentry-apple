//This is necessary for CocoaPod.
//Instead of splitting into many podspecs which means we would have to
//publish many pods, we can merge all the modules into one cocoapod project.
#if canImport(SentryCore)
@_exported import SentryCore
#endif
