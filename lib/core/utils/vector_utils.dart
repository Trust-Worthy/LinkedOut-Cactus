import 'dart:math';

class VectorUtils {
  /// Calculates Cosine Similarity between two vectors.
  /// Returns a value between -1.0 (opposite) and 1.0 (identical).
  static double cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw Exception("Vectors must have the same length");
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0; // Handle zero vectors
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}