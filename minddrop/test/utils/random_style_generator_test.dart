import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/utils/random_style_generator.dart';

void main() {
  group('RandomStyleGenerator', () {
    test('generate() creates a RandomStyle with valid properties', () {
      final RandomStyle style = RandomStyleGenerator.generate();

      expect(style, isA<RandomStyle>());
      expect(style.id, isNotEmpty);

      expect(style.gradientColors, isList);
      expect(style.gradientColors.length, 2);
      style.gradientColors.forEach((colorValue) {
        expect(Color(colorValue), isA<Color>());
      });

      expect(style.beginAlignment, isA<String>());
      expect(RandomStyleGenerator.alignmentFromString(style.beginAlignment), isA<Alignment>());

      expect(style.endAlignment, isA<String>());
      expect(RandomStyleGenerator.alignmentFromString(style.endAlignment), isA<Alignment>());

      // It's possible begin and end alignments could be the same by chance if not explicitly prevented
      // The generator has a while loop to prevent this, so they should be different.
      // However, for robustness of the test itself, this specific check might be flaky if that logic changes.
      // For now, we assume the generator's internal logic ensures they are different if that's intended.

      expect(style.iconDataCodePoint, isA<int>());
      expect(style.iconDataCodePoint, greaterThan(0));

      // fontFamily can be null for some system icons, but MaterialIcons should have it.
      // Let's check it's either null or a non-empty string if present.
      if (style.iconDataFontFamily != null) {
        expect(style.iconDataFontFamily, isA<String>());
        expect(style.iconDataFontFamily, isNotEmpty);
      }
      // iconDataFontPackage is likely null for MaterialIcons
      // No strong assertion here other than type if needed

      expect(style.iconColor, isA<int>());
      expect(Color(style.iconColor), isA<Color>());
    });

    test('alignmentFromString converts known strings to Alignments', () {
      expect(RandomStyleGenerator.alignmentFromString('Alignment.topLeft'), Alignment.topLeft);
      expect(RandomStyleGenerator.alignmentFromString('Alignment.center'), Alignment.center);
      expect(RandomStyleGenerator.alignmentFromString('Alignment.bottomRight'), Alignment.bottomRight);
    });

    test('alignmentFromString returns a default for unknown strings', () {
      expect(RandomStyleGenerator.alignmentFromString('unknown.string.value'), Alignment.center);
    });

    // Test to ensure generated colors are somewhat different (luminance check in generator)
    test('generate() produces two different gradient colors with sufficient luminance difference', () {
      for (int i = 0; i < 10; i++) { // Run a few times due to randomness
        final style = RandomStyleGenerator.generate();
        final color1 = Color(style.gradientColors[0]);
        final color2 = Color(style.gradientColors[1]);
        expect(color1.value, isNot(equals(color2.value)));
        expect((color1.computeLuminance() - color2.computeLuminance()).abs(), greaterThanOrEqualTo(0.2),
          reason: "Luminance difference between $color1 and $color2 was too small.");
      }
    });

    test('generate() produces different begin and end alignments', () {
       for (int i = 0; i < 10; i++) { // Run a few times
        final style = RandomStyleGenerator.generate();
        expect(style.beginAlignment, isNot(equals(style.endAlignment)),
          reason: "Begin and End alignments were the same: ${style.beginAlignment}");
      }
    });
  });
}
