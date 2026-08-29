import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CosmicElement { fire, earth, air, water }

extension CosmicElementInfo on CosmicElement {
  String get label {
    switch (this) {
      case CosmicElement.fire:
        return 'Fire';
      case CosmicElement.earth:
        return 'Earth';
      case CosmicElement.air:
        return 'Air';
      case CosmicElement.water:
        return 'Water';
    }
  }

  String get labelJa {
    switch (this) {
      case CosmicElement.fire:
        return '火';
      case CosmicElement.earth:
        return '地';
      case CosmicElement.air:
        return '風';
      case CosmicElement.water:
        return '水';
    }
  }

  List<Color> get gradient {
    switch (this) {
      case CosmicElement.fire:
        return ElementColors.fire;
      case CosmicElement.earth:
        return ElementColors.earth;
      case CosmicElement.air:
        return ElementColors.air;
      case CosmicElement.water:
        return ElementColors.water;
    }
  }

  IconData get icon {
    switch (this) {
      case CosmicElement.fire:
        return Icons.local_fire_department;
      case CosmicElement.earth:
        return Icons.terrain;
      case CosmicElement.air:
        return Icons.air;
      case CosmicElement.water:
        return Icons.water_drop;
    }
  }
}
