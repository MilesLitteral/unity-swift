import Foundation
import UIKit
import Photos

@objc public class SwiftToUnity: NSObject {//UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @objc public static let shared = SwiftToUnity()

    /// Sends a "Hello World" message to the "Canvas" GameObject by calling the "OnMessageReceived" script method on that object with the "Hello World!" message.
    @objc public func swiftSendHelloWorldMessage() {
        // The UnitySendMessage function has three parameters: the name of the target GameObject, the script method to call on that object and the message string to pass to the called method.
        UnitySendMessage("Canvas", "OnMessageReceived", "Hello World!");
    }

    /// Returns the "Hello, Swift!" string.
    ///
    /// - Returns: The "Hello, Swift!" string.
    @objc public func swiftHelloWorld() -> String {
        return "Hello, Swift!"
    }

    /// Adds two integers and returns the result.
    ///
    /// - Parameters:
    ///   - x: The first integer.
    ///   - y: The second integer.
    /// - Returns: The sum of the two integers.
    @objc public func swiftAdd(_ x: Int, _ y: Int) -> Int {
        return x + y
    }

    /// Concatenates two strings and returns the result.
    ///
    /// - Parameters:
    ///   - x: The first string.
    ///   - y: The second string.
    /// - Returns: The concatenated string.
    @objc public func swiftConcatenate(_ x: String, y: String) -> String {
        return x + y
    }

        @IBOutlet weak var collectionView: UICollectionView!
        var assets = [PHAsset]()
        var bytes  = [String]()
    
    /*override public func viewDidLoad() {
           super.viewDidLoad()
           collectionView.dataSource = self
           collectionView.delegate = self
           
           PHPhotoLibrary.requestAuthorization { status in
               switch status {
               case .authorized:
                   self._FetchGalleryImages()
               default:
                   print("Not authorized to access photo library.")
               }
           }
       }*/
    
    func getImageData(from asset: PHAsset, targetSize: CGSize, completion: @escaping (Data?) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.version = .original

        if #available(iOS 13, *) {
            imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                completion(data) // `data` is the image data in byte format
            }
        } else {
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, _) in
                completion(image?.pngData())
            }        }
    }
    
    @available(iOS 13, *)
    func getImageData(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let imageManager = PHImageManager.default()

        // Define the size for the requested image (e.g., full resolution or thumbnail)
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false  // Ensure it's async
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        requestOptions.isNetworkAccessAllowed = true // Allow network access for iCloud images
        
        // Fetch the image as NSData
        imageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, _, _, _) in
            if let data = data {
                print("Image data successfully retrieved.")
                completion(data)
            } else {
                print("Failed to retrieve image data.")
                completion(nil)
            }
        }
    }

   
    @available(iOS 13, *)
    @objc public func _FetchGalleryImages() -> [String] {
        self.bytes = [] // Ensure bytes is properly initialized
        
        let status = PHPhotoLibrary.authorizationStatus()

        if status == .authorized {
            if #available(iOS 13, *) {
                return fetchImages()
            } else {
                // Fallback on earlier versions
                return []
            }
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized {
                    _ = self?.fetchImages()
                } else {
                    print("Photos access denied.")
                }
            }
        } else {
            print("Photos access denied or restricted.")
        }
        return []
    }

    @available(iOS 13, *)
    private func fetchImages() -> [String] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 3

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        print("Found \(assets.count) assets.")

        assets.enumerateObjects { [weak self] (asset, _, _) in
            guard let strongSelf = self else { return }

            if !asset.isHidden {
                strongSelf.getImageData(from: asset) { data in
                    if let data = data {
                        print("Image data size: \(data.count) bytes") // Log image size
                        
                        let byteString = data.base64EncodedString()

                        // Thread-safe access to self.bytes
                        DispatchQueue.main.async {
                            strongSelf.bytes.append(byteString)
                            print("Image converted to base64 successfully.")
                        }
                    } else {
                        print("Failed to retrieve image data for asset: \(asset)")
                    }
                }
            } else {
                print("Asset is not available locally, might need to download from iCloud.")
            }
        }

        return self.bytes
    }
    
    @objc public func loadImageFromAsset(asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, _) in
                completion(image)
            }
        }
        
        // MARK: UICollectionViewDataSource
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return assets.count
        }
        
    @objc public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            let asset = assets[indexPath.item]
            let targetSize = CGSize(width: 100, height: 100)
            
            loadImageFromAsset(asset: asset, targetSize: targetSize) { image in
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
            
            return cell
        }
    }

    // Custom UICollectionViewCell class
public class ImageCell: UICollectionViewCell {
        @IBOutlet weak var imageView: UIImageView!
    }
