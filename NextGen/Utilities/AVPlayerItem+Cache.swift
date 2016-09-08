//
//  AVPlayerItem+Cache.swift
//

extension AVPlayerItem {
    
    convenience init(cacheableURL: NSURL) {
        if let tempFileURL = NextGenCacheManager.tempFileURL(cacheableURL) {
            if NextGenCacheManager.fileExists(tempFileURL) {
                self.init(URL: tempFileURL)
            } else {
                NextGenCacheManager.storeTempFile(cacheableURL)
                self.init(URL: cacheableURL)
            }
        } else {
            self.init(URL: cacheableURL)
        }
    }
    
}