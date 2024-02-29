//
//  UIImage+Extension.swift
//  
//
//  Created by Tristate on 1/20/20.
//  Copyright © 2020 Tristate. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageAndCircle(logoImage : UIImage) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: logoImage.size.height + 15, height: logoImage.size.height + 15)
        
        UIGraphicsBeginImageContext(rect.size)
        logoImage.draw(in: CGRect(x: 0, y: 10, width: logoImage.size.width, height: logoImage.size.height))
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        //Circle
        let rect1 = CGRect(x: rect.width - 40, y: 00, width: 30, height: 30)
        context.setFillColor(UIColor.clear.cgColor)
        context.fillEllipse(in: rect)
        
        context.saveGState()
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setFillColor(UIColor(63,207,118).cgColor)
        context.setAlpha(1.0)
        context.setLineWidth(3.0)
        context.addEllipse(in: rect1)
        
        context.drawPath(using: .fillStroke) // or .fillStroke if need filling
        
        context.restoreGState()
        
        guard let savedImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage()}
        
        UIGraphicsEndImageContext()
        
        return savedImage
    }
    
    //Create Circle
    class func circle(diameter: CGFloat,color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx!.fillEllipse(in: rect)
        ctx!.setFillColor(color.cgColor)
        ctx!.restoreGState()
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return img
    }
    
    //Draw Context On Image
    class func DrawOnImage(startingImage: UIImage) -> UIImage {

         // Create a context of the starting image size and set it as the current one
         UIGraphicsBeginImageContext(startingImage.size)

         // Draw the starting image in the current context as background
         startingImage.draw(at: CGPoint.zero)

         // Get the current context
         let context = UIGraphicsGetCurrentContext()!

         // Draw a red line
         context.setLineWidth(2.0)
         context.setStrokeColor(UIColor.red.cgColor)
         context.move(to: CGPoint(x: 100, y: 100))
         context.addLine(to: CGPoint(x: 200, y: 200))
         context.strokePath()

         // Draw a transparent green Circle
         context.setStrokeColor(UIColor.green.cgColor)
         context.setAlpha(0.5)
         context.setLineWidth(10.0)
         context.addEllipse(in: CGRect(x: 100, y: 100, width: 100, height: 100))
         context.drawPath(using: .stroke) // or .fillStroke if need filling
         // Save the context as a new UIImage
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
         UIGraphicsEndImageContext()

         // Return modified image
         return img
    }
    
    //Draw Text In Center
    func draw(_ s: String?, with font: UIFont?, in contextRect: CGRect) {
        
        let fontHeight = font?.pointSize ?? 0.0
        let yOffset = (contextRect.size.height - fontHeight) / 2.0
        
        let textRect = CGRect(x: 0, y: yOffset, width: contextRect.size.width, height: fontHeight)
        
        if let font = font {
            s?.draw(in: textRect, withAttributes: [.font : font])
        }
    }
    
    //Draw Text on Image
    class func textToImage1(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{

        // Setup the font specific variables
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!

        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]

        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //Pass the image back up to the caller
        return newImage!

    }
    
    //Draw Text on Image
    class func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{

        // Setup the font specific variables
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.center
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 15)!

        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let attributes=[
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.paragraphStyle: textStyle,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.backgroundColor: UIColor.clear]

        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: attributes)

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //Pass the image back up to the caller
        return newImage!

    }
    
    //Rotate Image
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    //Add Rainbow to Image
    class func addRainbow(to img: UIImage) -> UIImage {
        // create a CGRect representing the full size of our input iamge
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)

        // figure out the height of one section (there are six)
        let sectionHeight = img.size.height / 6

        // set up the colors – these are based on my trial and error
        let red = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.8)
        let orange = UIColor(red: 1, green: 0.7, blue: 0.35, alpha: 0.8)
        let yellow = UIColor(red: 1, green: 0.85, blue: 0.1, alpha: 0.65)
        let green = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 0.5)
        let blue = UIColor(red: 0, green: 0.35, blue: 0.7, alpha: 0.5)
        let purple = UIColor(red: 0.3, green: 0, blue: 0.5, alpha: 0.6)
        let colors = [red, orange, yellow, green, blue, purple]

        let renderer = UIGraphicsImageRenderer(size: img.size)
        let result = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(rect)

            // loop through all six colors
            for i in 0 ..< 6 {
                let color = colors[i]

                // figure out the rect for this section
                let rect = CGRect(x: 0, y: CGFloat(i) * sectionHeight, width: rect.width, height: sectionHeight)

                // draw it onto the context at the right place
                color.set()
                ctx.fill(rect)
            }

            // now draw our input image over using Luminosity mode, with a little bit of alpha to make it fainter
            img.draw(in: rect, blendMode: .luminosity, alpha: 0.6)
        }

        return result
    }
    
    //Return Circular Image
    func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    var circleMasked: UIImage? {
        let newImage = self.copy() as! UIImage
        let cornerRadius = self.size.height/2
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        let bounds = CGRect(origin: CGPoint.zero, size: self.size)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        newImage.draw(in: bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    var squareImage : UIImage? {
        var imageHeight = self.size.height
        var imageWidth = self.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        let refWidth : CGFloat = CGFloat(self.cgImage!.width)
        let refHeight : CGFloat = CGFloat(self.cgImage!.height)
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = self.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: self.imageOrientation)
        }
        
        return nil
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

import ImageIO

extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
            var width: CGFloat
            var height: CGFloat
            var newImage: UIImage

            let size = self.size
            let aspectRatio =  size.width/size.height

            switch contentMode {
                case .scaleAspectFit:
                    if aspectRatio > 1 {                            // Landscape image
                        width = dimension
                        height = dimension / aspectRatio
                    } else {                                        // Portrait image
                        height = dimension
                        width = dimension * aspectRatio
                    }

            default:
                fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
            }

            if #available(iOS 10.0, *) {
                let renderFormat = UIGraphicsImageRendererFormat.default()
                renderFormat.opaque = opaque
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
                newImage = renderer.image {
                    (context) in
                    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            } else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
                    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                    newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }

            return newImage
        }
    }
