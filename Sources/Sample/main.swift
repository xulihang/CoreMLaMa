import CoreGraphics
import CoreML
import Foundation
import VideoToolbox

// 命令行参数处理
guard CommandLine.arguments.count == 4 else {
    print("Usage: \(CommandLine.arguments[0]) <input_image_path> <mask_image_path> <output_image_path>")
    print("Example: \(CommandLine.arguments[0]) input.jpg mask.png output.jpg")
    exit(EXIT_FAILURE)
}

let inputImagePath = CommandLine.arguments[1]
let maskImagePath = CommandLine.arguments[2]
let outputImagePath = CommandLine.arguments[3]

print("Sample LaMa inpainting app")
print("Input: \(inputImagePath)")
print("Mask: \(maskImagePath)")
print("Output: \(outputImagePath)")

// 加载模型
print("Loading LaMa.mlmodelc")
guard let modelUrl = Bundle.main.url(forResource: "LaMa", withExtension: "mlmodelc") else {
    // 如果主Bundle中没有，尝试在当前目录查找
    let currentDirectory = FileManager.default.currentDirectoryPath
    let modelPath = currentDirectory + "/LaMa.mlmodelc"
    if FileManager.default.fileExists(atPath: modelPath) {
        print("Could not find LaMa.mlmodelc in main bundle, but found in current directory")
        exit(EXIT_FAILURE)
    } else {
        print("Could not find LaMa.mlmodelc. Please ensure the model is available.")
        print("Expected path: \(modelPath)")
        exit(EXIT_FAILURE)
    }
}

// 加载输入图像
print("Loading input image: \(inputImagePath)")
guard let inputImage = loadImage(from: inputImagePath) else {
    print("Failed to load input image from: \(inputImagePath)")
    exit(EXIT_FAILURE)
}

// 加载掩码图像
print("Loading mask image: \(maskImagePath)")
guard let maskImage = loadImage(from: maskImagePath) else {
    print("Failed to load mask image from: \(maskImagePath)")
    exit(EXIT_FAILURE)
}

// 检查图像尺寸是否匹配
guard inputImage.width == maskImage.width && inputImage.height == maskImage.height else {
    print("Error: Input image and mask image dimensions do not match")
    print("Input image: \(inputImage.width)x\(inputImage.height)")
    print("Mask image: \(maskImage.width)x\(maskImage.height)")
    exit(EXIT_FAILURE)
}

print("Creating LaMa model")
let lama: LaMa
do {
    lama = try LaMa(contentsOf: modelUrl)
} catch {
    print("Failed to create LaMa model: \(error)")
    exit(EXIT_FAILURE)
}

print("Preparing input for inpainting")
let input: LaMaInput
do {
    input = try LaMaInput(imageWith: inputImage, maskWith: maskImage)
} catch {
    print("Failed to prepare input: \(error)")
    exit(EXIT_FAILURE)
}

print("Inpainting...")
let output: LaMaOutput
do {
    output = try lama.prediction(input: input)
} catch {
    print("Inpainting failed: \(error)")
    exit(EXIT_FAILURE)
}

// 转换输出为CGImage
var inpaintedImage: CGImage?
let status = VTCreateCGImageFromCVPixelBuffer(output.output, options: nil, imageOut: &inpaintedImage)

guard status == noErr, let resultImage = inpaintedImage else {
    print("Failed to convert output to image")
    exit(EXIT_FAILURE)
}

// 保存输出图像
print("Saving output to: \(outputImagePath)")
do {
    try saveImage(resultImage, to: outputImagePath)
    print("Successfully saved output image")
} catch {
    print("Failed to save output image: \(error)")
    exit(EXIT_FAILURE)
}

print("Done!")

// 辅助函数：从文件路径加载图像
func loadImage(from path: String) -> CGImage? {
    let url = URL(fileURLWithPath: path)
    
    guard FileManager.default.fileExists(atPath: path) else {
        print("File does not exist: \(path)")
        return nil
    }
    
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        print("Failed to create image source from: \(path)")
        return nil
    }
    
    return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
}

// 辅助函数：保存图像到文件路径
func saveImage(_ image: CGImage, to path: String) throws {
    let url = URL(fileURLWithPath: path)
    let directory = url.deletingLastPathComponent()
    
    // 确保输出目录存在
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    
    let typeIdentifier = getTypeIdentifier(for: path)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, typeIdentifier as CFString, 1, nil) else {
        throw NSError(domain: "ImageSaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image destination"])
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "ImageSaveError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize image destination"])
    }
}

// 辅助函数：根据文件扩展名获取类型标识符
func getTypeIdentifier(for path: String) -> String {
    let fileExtension = (path as NSString).pathExtension.lowercased()
    
    switch fileExtension {
    case "jpg", "jpeg":
        return "public.jpeg"
    case "png":
        return "public.png"
    case "tiff", "tif":
        return "public.tiff"
    case "bmp":
        return "com.microsoft.bmp"
    case "gif":
        return "com.compuserve.gif"
    default:
        return "public.png" // 默认使用PNG
    }
}
