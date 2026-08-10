import Flutter
import PhotosUI
import UIKit

final class GalleryPickerHelper: NSObject, PHPickerViewControllerDelegate {
  static let shared = GalleryPickerHelper()

  private var pendingResult: FlutterResult?

  func pickImage(from viewController: UIViewController, result: @escaping FlutterResult) {
    if pendingResult != nil {
      result(
        FlutterError(
          code: "in_progress",
          message: "Gallery picker is already in progress",
          details: nil
        )
      )
      return
    }

    pendingResult = result

    DispatchQueue.main.async {
      var config = PHPickerConfiguration()
      config.selectionLimit = 1
      config.filter = .images

      let picker = PHPickerViewController(configuration: config)
      picker.delegate = self
      picker.modalPresentationStyle = .fullScreen
      viewController.present(picker, animated: true)
    }
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    guard let provider = results.first?.itemProvider,
      provider.canLoadObject(ofClass: UIImage.self)
    else {
      finish(with: nil)
      return
    }

    provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
      DispatchQueue.main.async {
        guard let self else { return }
        guard let image = object as? UIImage else {
          self.finish(with: nil)
          return
        }
        self.finish(with: Self.jpegData(from: image, maxDimension: 1600, quality: 0.85))
      }
    }
  }

  private func finish(with data: Data?) {
    guard let pending = pendingResult else { return }
    pendingResult = nil

    if let data, !data.isEmpty {
      pending(FlutterStandardTypedData(bytes: data))
    } else {
      pending(nil)
    }
  }

  private static func jpegData(
    from image: UIImage,
    maxDimension: CGFloat,
    quality: CGFloat
  ) -> Data? {
    let resized = resize(image: image, maxDimension: maxDimension)
    return resized.jpegData(compressionQuality: quality)
  }

  private static func resize(image: UIImage, maxDimension: CGFloat) -> UIImage {
    let size = image.size
    let longest = max(size.width, size.height)
    guard longest > maxDimension, longest > 0 else { return image }

    let scale = maxDimension / longest
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
}
