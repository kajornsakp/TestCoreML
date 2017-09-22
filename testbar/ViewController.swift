//
//  ViewController.swift
//  testbar
//
//  Created by Kajornsak Peerapathananont on 9/12/2560 BE.
//  Copyright © 2560 Kajornsak Peerapathananont. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var outputPossibility: UILabel!
    
    let imagePicker = UIImagePickerController()
//    let model = MobileNet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressPickImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func pixelBuffer(image : UIImage) -> CVPixelBuffer?{

            let modelSize = 224
            UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
            image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let attrs = [kCVPixelBufferCGImageCompatibilityKey : kCFBooleanTrue,kCVPixelBufferCGBitmapContextCompatibilityKey : kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int((newImage.size.width)), Int((newImage.size.height)), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess)else{ return nil}
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue : 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context : CGContext = CGContext(data : pixelData,width: Int(newImage.size.width),height:Int(newImage.size.height),bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
            context.translateBy(x:0,y:newImage.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            UIGraphicsPushContext(context)
       
        return pixelBuffer
    }
    
    func classify(_ image : UIImage){
        
        outputLabel.text = ""
        guard let pixelBuffer = image.pixelBuffer(width: 224, height: 224) else {
            return
        }
        let model = MobileNet()
        do {
            let output = try model.prediction(image: pixelBuffer)
            let probs = output.classLabelProbs.sorted { $0.value > $1.value }
            if let prob = probs.first {
                outputLabel.text = "\(prob.key)"
                outputPossibility.text = "\(prob.value)"
            }
            print(probs)
        }
        catch {
            outputLabel.text = error.localizedDescription
            outputPossibility.text = "0.00"
        }
       
    }
}

extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            classify(imageView.image!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
