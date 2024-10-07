import 'dart:io';

import 'package:flutter_flavorizr/src/exception/file_not_found_exception.dart';
import 'package:flutter_flavorizr/src/exception/malformed_resource_exception.dart';
import 'package:flutter_flavorizr/src/processors/commons/copy_file_processor.dart';
import 'package:image/image.dart';

class ImageResizerProcessor extends CopyFileProcessor {
  final Size size;

  ImageResizerProcessor(
    super.source,
    super.destination,
    this.size, {
    required super.config,
  });

  @override
  File execute() {
    // Read the source image
    final imageBytes = File(source).readAsBytesSync();
    var image = decodeImage(imageBytes);
    if (image == null) {
      throw FileNotFoundException(source);
    }

    // Check if the image has an alpha channel
    if (image.numChannels > 3) {
      // Remove alpha channel by converting the image to RGB
      image = image.convert(numChannels: 3);
    }

    // Resize the image to the target size
    final thumbnail = copyResize(
      image,
      width: size.width,
      height: size.height,
      interpolation: Interpolation.average,
    );

    // Encode the image based on the file extension
    final encodedImage = encodeNamedImage(destination, thumbnail);

    if (encodedImage == null) {
      throw MalformedResourceException(source);
    }

    // Write the encoded image to the destination file
    return File(destination)
      ..createSync(recursive: true)
      ..writeAsBytesSync(encodedImage);
  }

  @override
  String toString() =>
      'ImageResizerProcessor: Resizing image to $size from $source to $destination';
}

class Size {
  final int width;
  final int height;

  const Size({
    required this.width,
    required this.height,
  });

  @override
  String toString() => 'Size{width: $width, height: $height}';
}
