//
//  NewPostViewController.swift
//  PostsApp
//

import Foundation
import UIKit
import AWSAppSync
import AWSS3
import AWSMobileClient
class Post {
    let id: String
    let author: String
    let title: String?
    let content: String?
    let url: String?
    
    init(id:String = UUID().uuidString,
         author: String,
         title: String? = nil,
         content: String? = nil,
         url: String? = nil) {
        self.author = author
        self.title = title
        self.content = content
        self.url = url
        self.id = id
    }
}

class AddPostViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var authorInput: UITextField!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var contentInput: UITextField!
    @IBOutlet weak var urlInput: UITextField!
    var appSyncClient: AWSAppSyncClient?

    var imagePicker: UIImagePickerController!
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        //Looks for single or multiple taps.
        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imagePost.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    @IBAction func addNewPost(_ sender: Any) {
        let uniqueId = UUID().uuidString
        let S3BucketName = "ayedbucket"
        let remoteName = "test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let image = imagePost.image
        let data = UIImageJPEGRepresentation(image!, 0.9)
        do {
            try data?.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                }
            }
            
            return nil
        }
        let s3object = S3ObjectInput(bucket: uploadRequest.bucket!, key: uploadRequest.key!, region: "\(AWSRegionType.EUCentral1)", localUri: "\(AWSS3.default().configuration.endpoint.url)", mimeType: "")
        let mutationInput = CreatePostWithFileInput(id: uniqueId, author: authorInput.text!, title: titleInput.text, content: contentInput.text, url: urlInput.text, ups: 1, file: s3object ,version: 1)
        
        let mutation = AddPostWithFileMutation(input: mutationInput)
        
        appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
            do {
                // Update our normalized local store immediately for a responsive UI
                try transaction?.update(query: AllPostsQuery()) { (data: inout AllPostsQuery.Data) in
                    data.listPosts?.items?.append(AllPostsQuery.Data.ListPost.Item.init(id: uniqueId, title: mutationInput.title!, author: mutationInput.author, content: mutationInput.content!, version: 0))
                }
            } catch {
                print("Error updating the cache with optimistic response.")
            }
        }) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

