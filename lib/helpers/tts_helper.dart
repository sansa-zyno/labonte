class TextToSpeechHelper {
  static String preprocessForFrenchTTS(String text) {
    final replacements = {
      // English words → French phonetic equivalents
      'I': 'aï',
      'Nice': 'Naïs', // to avoid French "Niss"
      'has': 'haze',
      'Here': 'hïir',
      'Cow': 'kaou',
      'blouse': 'blaus',
      'noun': 'naoun',
      'nouns': 'naounz',
      'pronoun': 'pronaoun',
      'pronouns': 'pronaounz',
      'live': 'lïv', // for verb form
      'lives': 'lïvves', // for plural noun or 3rd person verb
      'these': 'dïïïz',
      'um': 'hum',
      'Describe': 'dèzkraïb',
      'Describing': 'dèzkraïbing',
      'pain': 'péïne',
      'vacuuming': 'vacuumiin',
      'bin': 'biin',
      'ironing': 'aioning',
      'longer': 'longa',
      'case': 'késss',
      'classes': 'classïsss',
      'until': 'entilll',
      'Nigeria': 'Naïjéria',
      'republic': 'repeublik',
      'Togolese': 'togolïsss',
      'But': 'Beut',
      'Ok': 'O K',
      'Plane': 'pléne',
      'emphasize': 'emfasaïz',
      'ride': 'raïdd',
      'indicate': 'ïne-dikeït',
      'place': 'pléss',
      'places': "plésïss",
      'infinitive': 'ïne-finitive',
      'accused': 'ak-used',
      'front': 'frontt',
      'singer': 'sïïnga',
      'incorrect': 'ïne-correct',
      'replace': 'rïpléss',
      'replaces': 'rïplésïss',
      'mine': 'maïn',
      'modifies': 'modifaïs',
      'idea': 'aï-dea',
      'Hi': 'aï',
      'fine': 'faïnn',
      'their': 'dïa',
      'theirs': 'dïazz',
      'point': 'poynts',
      'points': 'poynts',
      'Real': 'rïïle'
    };

    // Replace whole words only
    replacements.forEach((key, value) {
      final regex = RegExp(r'\b' + RegExp.escape(key) + r'\b', caseSensitive: false);
      text = text.replaceAllMapped(regex, (match) {
        // Keep original casing if needed
        if (match.group(0) == key.toUpperCase()) {
          return value.toUpperCase();
        } else if (match.group(0)![0].toUpperCase() == key[0].toUpperCase()) {
          return value[0].toUpperCase() + value.substring(1);
        }
        return value;
      });
    });
    text = text.replaceAll('Break', 'Brékkk');
    return text;
  }

  static String textToFileName(String text) {
    String safeText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'); // replace non-alphanumeric with underscore
    //safeText = safeText.substring(0, safeText.length < 50 ? safeText.length : 50); // prevent too long file names
    return safeText.hashCode.toString(); // or use hash to avoid collisions
  }
}



//reserved words: speak,prosody,rate,slow,pitch,break,time,emphasis,xml,lang