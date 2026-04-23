String getGoogleDriveDirectLink(String? url) {
  if (url == null || url.isEmpty) return '';
  
  // Format 1: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
  // Format 2: https://drive.google.com/open?id=FILE_ID
  
  final RegExp regExp = RegExp(r'(?:/d/|id=)([\w-]+)');
  final Match? match = regExp.firstMatch(url);
  
  if (match != null && match.groupCount >= 1) {
    final fileId = match.group(1);
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }
  
  return url; // Return as-is if no ID found
}
