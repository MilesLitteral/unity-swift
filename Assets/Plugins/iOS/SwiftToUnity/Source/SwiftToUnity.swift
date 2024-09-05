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
    
    func getImageData(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
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
            // Fallback on earlier versions
        }
    }
    
    @objc public func _FetchGalleryImages() -> [String] {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                print("You have Photos access.")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                assets.enumerateObjects { (asset, index, stop) in
                    if !asset.isHidden {
                        self.getImageData(from: asset) { data in
                            if let data = data {
                                let byteString = data.base64EncodedString() // This converts the data to a base64-encoded string
                                self.bytes.append(asset.localIdentifier)
                                //self.assets.append(asset)
                                //print("Byte string: \(byteString)")
                            } else {
                                print("Failed to retrieve image data.")
                            }
                        }
                    } else {
                        print("Asset is not available locally, might need to download from iCloud.")
                    }
                    
                }
                
                break
            case .denied, .restricted:
                // Access denied or restricted
                print("Photos access denied or restricted.")
            case .notDetermined:
                // Request permission
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        // Permission granted
                        print("Photos access granted.")
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        
                        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                        assets.enumerateObjects { (asset, index, stop) in
                            self.getImageData(from: asset) { data in
                                if let data = data {
                                    let byteString = data.base64EncodedString() // This converts the data to a base64-encoded string
                                    self.bytes.append(asset.localIdentifier)
                                    //self.assets.append(asset)
                                    //print("Byte string: \(byteString)")
                                } else {
                                    print("Failed to retrieve image data.")
                                }
                            }
                        }
                    } else {
                        print("Photos access denied.")
                    }
                }
            @unknown default:
                fatalError("Unexpected authorization status.")
            }

            return self.bytes;
        
            //DispatchQueue.main.async {
            //    self.collectionView.reloadData()
            //}
            //return self.paths;
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
