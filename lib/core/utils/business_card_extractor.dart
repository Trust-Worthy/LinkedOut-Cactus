class BusinessCardExtractor {
  /// Main extraction method - returns structured data
  static ExtractedCardData extract(String rawText) {
    print('📄 Extracting from raw text:\n$rawText\n');
    
    final data = ExtractedCardData(
      rawText: rawText,
      email: _extractEmail(rawText),
      phone: _extractPhone(rawText),
      website: _extractWebsite(rawText),
      linkedin: _extractLinkedIn(rawText),
      twitter: _extractTwitter(rawText),
      instagram: _extractInstagram(rawText),
      address: _extractAddress(rawText),
      name: _extractName(rawText),
      company: _extractCompany(rawText),
      title: _extractTitle(rawText),
    );
    
    print('✅ Extraction complete:');
    print('   Email: ${data.email}');
    print('   Phone: ${data.phone}');
    print('   Name: ${data.name}');
    
    return data;
  }

  // ========================================
  // EMAIL EXTRACTION (High Confidence)
  // ========================================
  
  static String? _extractEmail(String text) {
    final emailRegex = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
      caseSensitive: false,
    );
    
    final matches = emailRegex.allMatches(text);
    
    if (matches.isEmpty) return null;
    
    final emails = matches.map((m) => m.group(0)!).toList();
    
    final realEmails = emails.where((email) {
      final lower = email.toLowerCase();
      return !lower.contains('twitter.com') && 
             !lower.contains('instagram.com') && 
             !lower.contains('linkedin.com');
    }).toList();
    
    if (realEmails.isEmpty) return null;
    
    // Prefer shorter emails (often personal)
    realEmails.sort((a, b) => a.length.compareTo(b.length));
    
    return realEmails.first;
  }

  // ========================================
  // PHONE NUMBER EXTRACTION (High Confidence)
  // ========================================
  
  static String? _extractPhone(String text) {
    final patterns = [
      RegExp(r'\+?\d{1,3}?\s*\(?\d{3}\)?\s*[-.\s]?\d{3}[-.\s]?\d{4}'), // +1 (555) 123-4567
      RegExp(r'\d{3}[-.\s]\d{3}[-.\s]\d{4}'), // 555-123-4567
      RegExp(r'\(\d{3}\)\s*\d{3}[-.\s]?\d{4}'), // (555) 123-4567
      RegExp(r'\b\d{10}\b'), // 5551234567
      RegExp(r'\+1[-.\s]\d{3}[-.\s]\d{3}[-.\s]\d{4}'), // +1-555-123-4567
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return _normalizePhone(match.group(0)!);
      }
    }
    
    return null;
  }

  static String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (normalized.startsWith('+1')) {
      return '+1-${normalized.substring(2, 5)}-${normalized.substring(5, 8)}-${normalized.substring(8)}';
    }
    
    if (normalized.length == 10) {
      return '(${normalized.substring(0, 3)}) ${normalized.substring(3, 6)}-${normalized.substring(6)}';
    }
    
    return phone;
  }

  // ========================================
  // WEBSITE EXTRACTION
  // ========================================
  
  static String? _extractWebsite(String text) {
    final urlRegex = RegExp(
      r'(?:https?://)?(?:www\.)?([a-zA-Z0-9-]+\.[a-zA-Z]{2,})(?:/[^\s]*)?',
      caseSensitive: false,
    );
    
    final matches = urlRegex.allMatches(text);
    
    for (var match in matches) {
      final url = match.group(0)!.toLowerCase();
      
      if (url.contains('linkedin.com') || 
          url.contains('twitter.com') || 
          url.contains('instagram.com') || 
          url.contains('facebook.com') || 
          url.contains('x.com') ||
          url.contains('@')) { // Avoid emails caught as urls
        continue;
      }
      
      return url.startsWith('http') ? url : 'https://$url';
    }
    
    return null;
  }

  // ========================================
  // LINKEDIN EXTRACTION
  // ========================================
  
  static String? _extractLinkedIn(String text) {
    final urlPattern = RegExp(
      r'(?:https?://)?(?:www\.)?linkedin\.com/in/([a-zA-Z0-9-]+)',
      caseSensitive: false,
    );
    
    var match = urlPattern.firstMatch(text);
    if (match != null) {
      final username = match.group(1)!;
      return 'https://linkedin.com/in/$username';
    }
    
    final shortPattern = RegExp(r'/in/([a-zA-Z0-9-]+)', caseSensitive: false);
    match = shortPattern.firstMatch(text);
    if (match != null) {
      final username = match.group(1)!;
      return 'https://linkedin.com/in/$username';
    }
    
    return null;
  }

  // ========================================
  // TWITTER/X EXTRACTION
  // ========================================
  
  static String? _extractTwitter(String text) {
    final urlPattern = RegExp(
      r'(?:https?://)?(?:www\.)?(?:twitter\.com|x\.com)/([a-zA-Z0-9_]+)',
      caseSensitive: false,
    );
    
    var match = urlPattern.firstMatch(text);
    if (match != null) {
      final username = match.group(1)!;
      return 'https://twitter.com/$username';
    }
    
    final handlePattern = RegExp(
      r'\B@([a-zA-Z0-9_]{1,15})\b(?!\.[a-zA-Z])',
      caseSensitive: false,
    );
    
    final matches = handlePattern.allMatches(text);
    for (var match in matches) {
      final username = match.group(1)!;
      final fullText = text.substring(match.start);
      // Avoid matching emails like name@company.com
      if (!fullText.contains('@$username.') && !fullText.contains('@$username@')) {
        return 'https://twitter.com/$username';
      }
    }
    
    return null;
  }

  // ========================================
  // INSTAGRAM EXTRACTION
  // ========================================
  
  static String? _extractInstagram(String text) {
    final urlPattern = RegExp(
      r'(?:https?://)?(?:www\.)?instagram\.com/([a-zA-Z0-9_.]+)',
      caseSensitive: false,
    );
    
    var match = urlPattern.firstMatch(text);
    if (match != null) {
      final username = match.group(1)!;
      return 'https://instagram.com/$username';
    }
    
    final prefixPattern = RegExp(
      r'(?:IG|Instagram):\s*@?([a-zA-Z0-9_.]+)',
      caseSensitive: false,
    );
    
    match = prefixPattern.firstMatch(text);
    if (match != null) {
      final username = match.group(1)!;
      return 'https://instagram.com/$username';
    }
    
    return null;
  }

  // ========================================
  // ADDRESS EXTRACTION
  // ========================================
  
  static String? _extractAddress(String text) {
    final zipPattern = RegExp(r'\b\d{5}(?:-\d{4})?\b');
    final zipMatch = zipPattern.firstMatch(text);
    
    if (zipMatch == null) return null;
    
    final lines = text.split('\n');
    String? cityStateLine;
    String? addressLine;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains(zipMatch.group(0)!)) {
        cityStateLine = lines[i].trim();
        if (i > 0) {
          addressLine = lines[i - 1].trim();
        }
        break;
      }
    }
    
    if (addressLine != null && cityStateLine != null) {
      return '$addressLine, $cityStateLine';
    } else if (cityStateLine != null) {
      return cityStateLine;
    }
    
    return null;
  }

  // ========================================
  // NAME EXTRACTION (Heuristic)
  // ========================================
  
  static String? _extractName(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;
    
    // Heuristic: Name is usually in the first 3 lines, 2-4 words, mostly letters
    for (int i = 0; i < lines.length && i < 3; i++) {
      final line = lines[i].trim();
      
      if (line.contains('@') || line.contains('www.') || 
          RegExp(r'\d{3}[-.\s]\d{3}').hasMatch(line) || 
          line.length > 50 || line.length < 3) {
        continue;
      }
      
      final words = line.split(RegExp(r'\s+'));
      if (words.length >= 2 && words.length <= 4) {
        final isAlphabetic = words.every((w) => RegExp(r'^[A-Za-z.\-]+$').hasMatch(w));
        if (isAlphabetic) {
          return _toTitleCase(line);
        }
      }
    }
    
    return _toTitleCase(lines.first); // Fallback
  }

  // ========================================
  // COMPANY EXTRACTION (Heuristic)
  // ========================================
  
  static String? _extractCompany(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final companyKeywords = [
      'inc', 'llc', 'ltd', 'corp', 'corporation', 'company', 'co',
      'group', 'partners', 'ventures', 'capital', 'technologies', 'tech',
      'solutions', 'consulting', 'services', 'industries', 'enterprises'
    ];
    
    // Strategy 1: Keywords
    for (var line in lines) {
      final lower = line.toLowerCase();
      for (var keyword in companyKeywords) {
        if (lower.contains(keyword)) return line.trim();
      }
    }
    
    // Strategy 2: Heuristic position (2nd or 3rd line)
    if (lines.length >= 2) {
      final secondLine = lines[1].trim();
      if (!secondLine.toLowerCase().contains(' of ') && 
          !secondLine.toLowerCase().contains(' at ') && 
          !secondLine.contains('@')) {
        return secondLine;
      }
    }
    
    if (lines.length >= 3) {
      return lines[2].trim();
    }
    
    return null;
  }

  // ========================================
  // TITLE EXTRACTION
  // ========================================
  
  static String? _extractTitle(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final titleKeywords = [
      'ceo', 'cto', 'cfo', 'coo', 'founder', 'president', 'director', 
      'manager', 'lead', 'head', 'chief', 'vp', 'senior', 'principal', 
      'engineer', 'developer', 'designer', 'analyst', 'consultant', 
      'specialist', 'associate', 'partner', 'investor', 'advisor'
    ];
    
    for (var line in lines) {
      final lower = line.toLowerCase();
      for (var keyword in titleKeywords) {
        if (lower.contains(keyword)) return line.trim();
      }
    }
    
    return null;
  }

  static String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

// ========================================
// DATA MODEL
// ========================================

class ExtractedCardData {
  final String rawText;
  final String? email;
  final String? phone;
  final String? website;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? address;
  final String? name;
  final String? company;
  final String? title;
  
  ExtractedCardData({
    required this.rawText,
    this.email,
    this.phone,
    this.website,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.address,
    this.name,
    this.company,
    this.title,
  });
  
  Map<String, String?> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'title': title,
      'linkedin': linkedin,
      'twitter': twitter,
      'instagram': instagram,
      'website': website,
      'address': address,
      'notes': rawText,
    };
  }
}