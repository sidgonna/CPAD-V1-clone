import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:uuid/uuid.dart';

class RandomStyleGenerator {
  static final Random _random = Random();
  static const Uuid _uuid = Uuid();

  // Predefined list of Material Design icons
  static const List<IconData> _availableIcons = [
    Icons.lightbulb_outline,
    Icons.star_border,
    Icons.favorite_border,
    Icons.anchor,
    Icons.api,
    Icons.widgets_outlined,
    Icons.ac_unit,
    Icons.accessibility_new,
    Icons.account_balance_wallet,
    Icons.airplanemode_active,
    Icons.album,
    Icons.all_inclusive,
    Icons.assessment,
    Icons.attach_money,
    Icons.audiotrack,
    Icons.auto_awesome,
    Icons.backup,
    Icons.beach_access,
    Icons.bedtime,
    Icons.biotech,
    Icons.bolt,
    Icons.brush,
    Icons.build_circle,
    Icons.cake,
    Icons.camera_alt,
    Icons.category,
    Icons.celebration,
    Icons.cloud_queue,
    Icons.color_lens,
    Icons.construction,
    Icons.contactless,
    Icons.control_camera,
    Icons.coronavirus,
    Icons.deck,
    Icons.diamond,
    Icons.eco,
    Icons.emoji_events,
    Icons.explore,
    Icons.extension,
    Icons.face,
    Icons.family_restroom,
    Icons.filter_vintage,
    Icons.flag,
    Icons.flare,
    Icons.flight_takeoff,
    Icons.flutter_dash,
    Icons.forest,
    Icons.free_breakfast,
    Icons.functions,
    Icons.gamepad,
    Icons.gesture,
    Icons.gif,
    Icons.group_work,
    Icons.hardware,
    Icons.headset_mic,
    Icons.healing,
    Icons.highlight,
    Icons.history_edu,
    Icons.home_work,
    Icons.hourglass_empty,
    Icons.http,
    Icons.icecream,
    Icons.image_search,
    Icons.insights,
    Icons.keyboard_voice,
    Icons.landscape,
    Icons.language,
    Icons.leaderboard,
    Icons.leak_add,
    Icons.lightbulb,
    Icons.liquor,
    Icons.local_florist,
    Icons.location_city,
    Icons.lock_open,
    Icons.looks,
    Icons.loyalty,
    Icons.luggage,
    Icons.map,
    Icons.military_tech,
    Icons.mood,
    Icons.motorcycle,
    Icons.movie_filter,
    Icons.music_note,
    Icons.nature_people,
    Icons.navigation,
    Icons.network_check,
    Icons.nightlife,
    Icons.outdoor_grill,
    Icons.palette,
    Icons.pan_tool,
    Icons.park,
    Icons.pedal_bike,
    Icons.pending_actions,
    Icons.pest_control,
    Icons.pets,
    Icons.psychology,
    Icons.public,
    Icons.query_builder,
    Icons.rocket_launch,
    Icons.rowing,
    Icons.satellite_alt,
    Icons.savings,
    Icons.science,
    Icons.self_improvement,
    Icons.shield,
    Icons.shopping_bag,
    Icons.snowboarding,
    Icons.solar_power,
    Icons.sports_esports,
    Icons.sports_kabaddi,
    Icons.store,
    Icons.stream,
    Icons.surfing,
    Icons.terrain,
    Icons.thumb_up_alt,
    Icons.toys,
    Icons.translate,
    Icons.trending_up,
    Icons.two_wheeler,
    Icons.umbrella,
    Icons.volunteer_activism,
    Icons.vpn_key,
    Icons.waves,
    Icons.wb_sunny,
    Icons.weekend,
    Icons.workspaces,
    Icons.yard,
    Icons.zoom_in,
  ];

  static Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  static Alignment _getRandomAlignment() {
    final alignments = [
      Alignment.topLeft, Alignment.topCenter, Alignment.topRight,
      Alignment.centerLeft, Alignment.center, Alignment.centerRight,
      Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight,
    ];
    return alignments[_random.nextInt(alignments.length)];
  }

  static RandomStyle generate() {
    final Color color1 = _getRandomColor();
    Color color2 = _getRandomColor();
    // Ensure color2 is somewhat different from color1 for better contrast
    while (color1.value == color2.value || (color1.computeLuminance() - color2.computeLuminance()).abs() < 0.2) {
      color2 = _getRandomColor();
    }

    final Alignment beginAlignment = _getRandomAlignment();
    Alignment endAlignment = _getRandomAlignment();
    // Ensure alignments are different for a visible gradient
    while (beginAlignment == endAlignment) {
      endAlignment = _getRandomAlignment();
    }

    final IconData iconData = _availableIcons[_random.nextInt(_availableIcons.length)];

    // Determine icon color based on gradient luminance
    final double gradientLuminance = (color1.computeLuminance() + color2.computeLuminance()) / 2;
    final Color iconColor = gradientLuminance > 0.5 ? Colors.black87 : Colors.white;

    return RandomStyle(
      id: _uuid.v4(),
      gradientColors: [color1.value, color2.value],
      beginAlignment: beginAlignment.toString(),
      endAlignment: endAlignment.toString(),
      iconDataCodePoint: iconData.codePoint,
      iconDataFontFamily: iconData.fontFamily,
      iconDataFontPackage: iconData.fontPackage, // This will be null for MaterialIcons
      iconColor: iconColor.value,
    );
  }

  // Helper to convert string back to Alignment for display
  static Alignment alignmentFromString(String alignmentString) {
    switch (alignmentString) {
      case 'Alignment.topLeft': return Alignment.topLeft;
      case 'Alignment.topCenter': return Alignment.topCenter;
      case 'Alignment.topRight': return Alignment.topRight;
      case 'Alignment.centerLeft': return Alignment.centerLeft;
      case 'Alignment.center': return Alignment.center;
      case 'Alignment.centerRight': return Alignment.centerRight;
      case 'Alignment.bottomLeft': return Alignment.bottomLeft;
      case 'Alignment.bottomCenter': return Alignment.bottomCenter;
      case 'Alignment.bottomRight': return Alignment.bottomRight;
      default: return Alignment.center; // Default fallback
    }
  }
}

// This class would be a simple DTO if not using Hive directly for this part
// For now, it mirrors what might be stored or passed around.
// If RandomStyle model from models/random_style.dart is different, adjust accordingly.
class GeneratedRandomStyle {
  final List<int> gradientColors; // Storing Color.value
  final String beginAlignment;
  final String endAlignment;
  final int iconDataCodePoint;
  final String? iconDataFontFamily;
  final int iconColor; // Storing Color.value

  GeneratedRandomStyle({
    required this.gradientColors,
    required this.beginAlignment,
    required this.endAlignment,
    required this.iconDataCodePoint,
    this.iconDataFontFamily,
    required this.iconColor,
  });

  // A method to convert this to a JSON string or a Map for storage if needed
  // This is what will be stored as `_selectedValue` for a random style.
  String toJsonString() {
    // Example: "color1_val,color2_val;begin_align_str;end_align_str;icon_code;icon_family;icon_color_val"
    // This is a simple custom format. JSON would be more robust.
    // For Hive, we'd use the RandomStyleAdapter to store the RandomStyle object itself.
    // The `_selectedValue` will be the ID of the saved RandomStyle object.
    // The generation logic here creates the data, which is then saved via DatabaseService,
    // and its ID is passed to onSelectionChanged.
    // For now, this method is a placeholder for how style data might be packaged.
    // The actual RandomStyle object (from models) should be used.
    return "This would be an ID of a stored RandomStyle object";
  }
}
