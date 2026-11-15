#!/usr/bin/env python3
"""Force the Flex Flutter app onto a black-and-white Material theme."""

import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    if old not in text:
        raise SystemExit(f"Pattern not found in {path}")
    path.write_text(text.replace(old, new, 1))


replace_once(
    root / "lib/main.dart",
    """        final lightScheme = ColorScheme.fromSeed(seedColor: Color(seedColor));
        final darkScheme = ColorScheme.fromSeed(
          seedColor: Color(seedColor),
          brightness: Brightness.dark,
        );""",
    """        final lightScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF000000),
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        ).copyWith(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFFFFF),
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        ).copyWith(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
        );""",
)

replace_once(
    root / "lib/main.dart",
    "colorScheme: colors ? (lightDynamic ?? lightScheme) : lightScheme,",
    "colorScheme: lightScheme,",
)

replace_once(
    root / "lib/main.dart",
    """colorScheme: (colors ? (darkDynamic ?? darkScheme) : darkScheme)
                .copyWith(surface: amoledDark ? Colors.black : null),""",
    "colorScheme: darkScheme,",
)

replace_once(
    root / "lib/constants.dart",
    "themeMode: ThemeMode.system.toString(),",
    "themeMode: ThemeMode.light.toString(),",
)

replace_once(
    root / "lib/database/settings.dart",
    "integer().withDefault(const Constant(0xFF673AB7))();",
    "integer().withDefault(const Constant(0xFF000000))();",
)

print("Applied black-and-white theme")
