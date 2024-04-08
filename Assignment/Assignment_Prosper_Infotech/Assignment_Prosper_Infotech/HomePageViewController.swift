//
//  HomePageViewController.swift
//  Assignment_Prosper_Infotech
//
//  Created by Vidya Vikas Jagtap on 27/03/24.
//

import UIKit
import CoreImage

class HomePageViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
   
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var pickedImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editPhotoButton.isHidden = true
        pickedImageView.isHidden = true
        // Set navigation bar title
        self.title = "Photo Editor"
        
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
            
        }else {
            // Handle case where camera is not available
            print("Camera is not available")
        }
    }
    
    @IBAction func editPhotoButtonTapped(_ sender: UIButton) {
        guard let capturedImage = capturedImage else { return }
        
        guard let editedImage = applyFilter(to: capturedImage, withFilterName: "CIPhotoEffectMono") else { return }
        
        if let imageWithText = addText("Vidya", to: editedImage) {
            // Save the edited image
            UIImageWriteToSavedPhotosAlbum(imageWithText, nil, nil, nil)

           // Dismiss image picker controller
            dismiss(animated: true, completion: nil)
           
            // Share the edited image
            let activityViewController = UIActivityViewController(activityItems: [imageWithText], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Handle Picked Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            capturedImage = pickedImage
            editPhotoButton.isHidden = false
            pickedImageView.image = pickedImage // Set the image to UIImageView
            pickedImageView.isHidden = false // Show the UIImageView
            print("picked image: \(pickedImage)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Handle canceled picked image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Apply Filter on the photo
    func applyFilter(to image: UIImage, withFilterName filterName: String) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let filter = CIFilter(name: filterName)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let outputCIImage = filter?.outputImage,
           let cgImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    // Add text on photo
    func addText(_ text: String, to image: UIImage) -> UIImage? {
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 40)!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let textRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
