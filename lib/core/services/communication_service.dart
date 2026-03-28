import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch dialer for $phoneNumber';
    }
  }

  static Future<void> launchWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '233${cleanPhone.substring(1)}';
    }

    // 2. Build the URI
    final url =
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    final Uri whatsappUri = Uri.parse(url);

    try {
      final success = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        await launchUrl(whatsappUri);
      }
    } catch (e) {
      debugger(message: "Error launching WhatsApp: $e");
      throw 'Could not launch WhatsApp';
    }
  }

  static Future<void> launchInstagram(String username) async {
    final Uri uri = Uri.parse('https://instagram.com/$username');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch Instagram';
      }
    } catch (e) {
      debugger(message: "Error launching Instagram: $e");
      throw 'Could not launch Instagram';
    }
  }

  static Future<void> launchX(String username) async {
    final Uri uri = Uri.parse('https://x.com/$username');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch X';
      }
    } catch (e) {
      debugger(message: "Error launching X: $e");
      throw 'Could not launch X';
    }
  }

  static Future<void> launchTikTok(String username) async {
    final Uri uri = Uri.parse('https://tiktok.com/@$username');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch TikTok';
      }
    } catch (e) {
      debugger(message: "Error launching TikTok: $e");
      throw 'Could not launch TikTok';
    }
  }
}
