//
//  AVPlayerItem+Cache.swift
//

extension AVPlayerItem {
    
    convenience init(cacheableURL: URL) {
        if let tempFileURL = NextGenCacheManager.tempFileURL(cacheableURL) {
            if NextGenCacheManager.fileExists(tempFileURL) {
                self.init(url: tempFileURL)
            } else {
                NextGenCacheManager.storeTempFile(cacheableURL)
                self.init(url: cacheableURL)
            }
        } else {
            self.init(url: cacheableURL)
        }
    }
    
}
