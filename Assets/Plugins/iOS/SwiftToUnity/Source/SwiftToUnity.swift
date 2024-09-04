import Foundation
import UIKit
import Photos

@objc public class SwiftToUnity: NSObject {
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
        
        override public func viewDidLoad() {
            super.viewDidLoad()
            collectionView.dataSource = self
            collectionView.delegate = self
            
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.fetchGalleryImages()
                default:
                    print("Not authorized to access photo library.")
                }
            }
        }
        
    @objc public func fetchGalleryImages() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            assets.enumerateObjects { (asset, index, stop) in
                self.assets.append(asset)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
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
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return assets.count
        }
        
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}
