import Foundation
import Photos
import UIKit

public class DownloadManager: ObservableObject {
    public static let shared = DownloadManager()
    
    @Published public var isDownloading: Bool = false
    @Published public var downloadProgress: Float = 0.0
    @Published public var toastMessage: String? = nil
    
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = urls[0].appendingPathComponent("e621_media_cache")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private init() {}
    
    public func getCachedFile(md5: String?, ext: String?) -> URL? {
        guard let md5 = md5, !md5.isEmpty, let ext = ext, !ext.isEmpty else { return nil }
        let fileUrl = cacheDirectory.appendingPathComponent("\(md5).\(ext)")
        if fileManager.fileExists(atPath: fileUrl.path) {
            return fileUrl
        }
        return nil
    }
    
    public func getCacheSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        var total: Int64 = 0
        for file in files {
            if let resources = try? file.resourceValues(forKeys: [.fileSizeKey]), let size = resources.fileSize {
                total += Int64(size)
            }
        }
        return total
    }
    
    public func getFormattedCacheSize() -> String {
        let bytes = getCacheSize()
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1.0 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(bytes) Bytes"
        }
    }
    
    public func clearCache() {
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    public func downloadPostMedia(post: Post, saveToPhotos: Bool = true) {
        guard let urlString = post.bestMediaUrl, let url = URL(string: urlString) else {
            self.toastMessage = "다운로드 URL을 찾을 수 없습니다."
            return
        }
        
        let ext = post.file?.ext ?? url.pathExtension
        let md5 = post.file?.md5 ?? "\(post.id)"
        let targetFileName = "\(post.id)_\(md5).\(ext)"
        let targetCacheUrl = cacheDirectory.appendingPathComponent(targetFileName)
        
        if fileManager.fileExists(atPath: targetCacheUrl.path) {
            if saveToPhotos {
                self.saveToPhotoLibrary(fileUrl: targetCacheUrl, isVideo: post.isVideo)
            } else {
                self.toastMessage = "이미 캐시에 저장되어 있습니다."
            }
            return
        }
        
        self.isDownloading = true
        self.toastMessage = "다운로드를 시작합니다..."
        
        let tempUrl = cacheDirectory.appendingPathComponent("temp_\(targetFileName)")
        var downloadedBytes: Int64 = 0
        if fileManager.fileExists(atPath: tempUrl.path) {
            if let attrs = try? fileManager.attributesOfItem(atPath: tempUrl.path),
               let size = attrs[.size] as? Int64 {
                downloadedBytes = size
            }
        }
        
        var request = URLRequest(url: url)
        request.setValue(NetworkService.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        let cfClearance = NetworkService.shared.cfClearance
        if !cfClearance.isEmpty && cfClearance != "bypass" {
            request.setValue(cfClearance, forHTTPHeaderField: "Cookie")
        }
        if downloadedBytes > 0 {
            request.setValue("bytes=\(downloadedBytes)-", forHTTPHeaderField: "Range")
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async { self.isDownloading = false }
            
            if let error = error {
                DispatchQueue.main.async { self.toastMessage = "다운로드 실패: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { self.toastMessage = "다운로드 응답 오류" }
                return
            }
            
            do {
                if httpResponse.statusCode == 206 {
                    let handle = try FileHandle(forWritingTo: tempUrl)
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                } else if httpResponse.statusCode == 200 {
                    try data.write(to: tempUrl)
                } else {
                    DispatchQueue.main.async { self.toastMessage = "HTTP 오류: \(httpResponse.statusCode)" }
                    return
                }
                
                if self.fileManager.fileExists(atPath: targetCacheUrl.path) {
                    try? self.fileManager.removeItem(at: targetCacheUrl)
                }
                try self.fileManager.moveItem(at: tempUrl, to: targetCacheUrl)
                
                DispatchQueue.main.async {
                    self.toastMessage = "다운로드 완료"
                    if saveToPhotos {
                        self.saveToPhotoLibrary(fileUrl: targetCacheUrl, isVideo: post.isVideo)
                    }
                }
            } catch {
                DispatchQueue.main.async { self.toastMessage = "파일 저장 실패: \(error.localizedDescription)" }
            }
        }
        task.resume()
    }
    
    private func saveToPhotoLibrary(fileUrl: URL, isVideo: Bool) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    self.toastMessage = "다운로드 완료 (사진 보관함 권한 없음: 앱 샌드박스에만 보관됨)"
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                if isVideo {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                } else {
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
                }
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.toastMessage = "사진 보관함에 저장되었습니다."
                    } else {
                        self.toastMessage = "사진 보관함 저장 실패: \(error?.localizedDescription ?? "")"
                    }
                }
            }
        }
    }
}
