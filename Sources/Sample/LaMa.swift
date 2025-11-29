//
// LaMa.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class LaMaInput : MLFeatureProvider {

    /// image as color (kCVPixelFormatType_32BGRA) image buffer, 800 pixels wide by 800 pixels high
    var image: CVPixelBuffer

    /// mask as grayscale (kCVPixelFormatType_OneComponent8) image buffer, 800 pixels wide by 800 pixels high
    var mask: CVPixelBuffer

    var featureNames: Set<String> { ["image", "mask"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        if featureName == "mask" {
            return MLFeatureValue(pixelBuffer: mask)
        }
        return nil
    }

    init(image: CVPixelBuffer, mask: CVPixelBuffer) {
        self.image = image
        self.mask = mask
    }

    convenience init(imageWith image: CGImage, maskWith mask: CGImage) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, mask: try MLFeatureValue(cgImage: mask, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_OneComponent8, options: nil).imageBufferValue!)
    }

    convenience init(imageAt image: URL, maskAt mask: URL) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, mask: try MLFeatureValue(imageAt: mask, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_OneComponent8, options: nil).imageBufferValue!)
    }

    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setMask(with mask: CGImage) throws  {
        self.mask = try MLFeatureValue(cgImage: mask, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_OneComponent8, options: nil).imageBufferValue!
    }

    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setMask(with mask: URL) throws  {
        self.mask = try MLFeatureValue(imageAt: mask, pixelsWide: 800, pixelsHigh: 800, pixelFormatType: kCVPixelFormatType_OneComponent8, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class LaMaOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// output as color (kCVPixelFormatType_32BGRA) image buffer, 800 pixels wide by 800 pixels high
    var output: CVPixelBuffer {
        provider.featureValue(for: "output")!.imageBufferValue!
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(output: CVPixelBuffer) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["output" : MLFeatureValue(pixelBuffer: output)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class LaMa {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "LaMa", withExtension:"mlmodelc")!
    }

    /**
        Construct LaMa instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of LaMa.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `LaMa.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct LaMa instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct LaMa instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<LaMa, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct LaMa instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> LaMa {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct LaMa instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<LaMa, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(LaMa(model: model)))
            }
        }
    }

    /**
        Construct LaMa instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> LaMa {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return LaMa(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as LaMaInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as LaMaOutput
    */
    func prediction(input: LaMaInput) throws -> LaMaOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as LaMaInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as LaMaOutput
    */
    func prediction(input: LaMaInput, options: MLPredictionOptions) throws -> LaMaOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return LaMaOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as LaMaInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as LaMaOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: LaMaInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> LaMaOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return LaMaOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - image: color (kCVPixelFormatType_32BGRA) image buffer, 800 pixels wide by 800 pixels high
            - mask: grayscale (kCVPixelFormatType_OneComponent8) image buffer, 800 pixels wide by 800 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as LaMaOutput
    */
    func prediction(image: CVPixelBuffer, mask: CVPixelBuffer) throws -> LaMaOutput {
        let input_ = LaMaInput(image: image, mask: mask)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [LaMaInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [LaMaOutput]
    */
    func predictions(inputs: [LaMaInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [LaMaOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [LaMaOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  LaMaOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
