import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';

enum CloudinaryResourceType { image, video }

class CloudinaryResource {
  final String url;
  final CloudinaryResourceType type;
  final String publicId;
  final String? assetFolder;

  CloudinaryResource({
    required this.url,
    required this.type,
    required this.publicId,
    this.assetFolder,
  });
}

class CloudinaryService {
  /// Fetches both images and videos for a given tag
  static Future<List<CloudinaryResource>> fetchMixedAssetsByTag(
    String tag,
  ) async {
    final List<CloudinaryResource> resources = [];

    // Fetch Images
    final images = await _fetchResources(tag, CloudinaryResourceType.image);
    resources.addAll(images);

    // Fetch Videos
    final videos = await _fetchResources(tag, CloudinaryResourceType.video);
    resources.addAll(videos);

    // Sort by type or keep original order? For now, just combined.
    return resources;
  }

  static Future<List<CloudinaryResource>> _fetchResources(
    String tag,
    CloudinaryResourceType type,
  ) async {
    final typeStr = type == CloudinaryResourceType.image ? 'image' : 'video';
    final url =
        'https://res.cloudinary.com/${AppConstants.cloudName}/$typeStr/list/$tag.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resData = data['resources'] ?? [];

        return resData.map((res) {
          final publicId = res['public_id'];
          final version = res['version'];
          final format = res['format'];
          final folder = res['asset_folder'];
          final resourceUrl =
              'https://res.cloudinary.com/${AppConstants.cloudName}/$typeStr/upload/v$version/$publicId.$format';

          return CloudinaryResource(
            url: resourceUrl,
            type: type,
            publicId: publicId,
            assetFolder: folder,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        // 404 means no assets have this tag yet; treat as empty list
        return [];
      } else if (response.statusCode == 403) {
        debugger(
          message:
              'Cloudinary Access Denied (403): Please ensure your Cloudinary'
              ' "Resource list" setting is ENABLED (Unchecked) in Settings > Security.',
        );
      } else {
        debugger(
          message:
              'Cloudinary API Error (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugger(message: 'Cloudinary Fetch Error ($typeStr): $e');
    }
    return [];
  }

  static Future<List<String>> fetchImagesByTag(String tag) async {
    final resources = await _fetchResources(tag, CloudinaryResourceType.image);
    return resources.map((r) => r.url).toList();
  }

  /// Groups a list of resources by their asset folder path
  static Map<String, List<String>> groupByFolder(
    List<CloudinaryResource> resources,
  ) {
    final Map<String, List<String>> grouped = {};

    for (var res in resources) {
      final folder = res.assetFolder ?? 'uncategorized';
      if (!grouped.containsKey(folder)) {
        grouped[folder] = [];
      }
      grouped[folder]!.add(res.url);
    }

    return grouped;
  }
}
