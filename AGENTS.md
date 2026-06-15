# Project Agent Notes

## Command Environment

- Use `pwsh` for local shell commands in this workspace.
- This Flutter project uses FVM. Prefer `fvm flutter ...` and `fvm dart ...` over global `flutter` or `dart`.
- The project FVM version is defined in `.fvmrc` as Flutter `3.44.0`.

## Common Checks

- Analyze the project with `fvm flutter analyze`.
- For targeted Dart analysis, use `fvm dart analyze <path>`.

## Code Comments

- Add Chinese comments for major modules, key logic, classes, and methods to make the code easier to understand.
- Prefer concise explanatory comments that describe intent and responsibilities; avoid noisy line-by-line comments for obvious code.

## Default Text

- Default text values must be empty. Do not write specific sample or placeholder text unless the user explicitly provides it.

## Dart Style

- Do not use Dart `enum` in project development. Use `class` definitions instead when modeling fixed values or categories.

## Page Structure

- Keep page files concise. Pure UI files should preferably stay under 400 lines.
- Encapsulate page logic in separate classes and let the UI reference those classes, keeping business logic decoupled from UI layout code.

## Dart Imports

- Import paths must be absolute package imports, for example `package:easy_moni/...`; do not use relative import paths.

## Flutter Assets

- Design image slices and local image resources must be accessed through `lib/gen/assets.gen.dart`.
- Import generated assets with `import 'package:easy_moni/gen/assets.gen.dart';` or the appropriate relative import that matches the file's existing style.
- Use `Assets.images.*` for image widgets and providers, for example:
  - `Assets.images.customer.image(width: 32, height: 32)`
  - `DecorationImage(image: Assets.images.loginBg.provider(), fit: BoxFit.cover)`
  - `Assets.images.loanYellowCard.path`
- Do not reference Figma MCP temporary image URLs, raw asset string paths, or newly hardcoded asset paths in feature code when an `Assets.images.*` entry exists.
- Do not edit `lib/gen/assets.gen.dart` manually. Add files under `assets/images/` and regenerate FlutterGen output when new assets are needed.
