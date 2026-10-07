# Third-party artwork in the iOS app

## Rights record

- **CARE branding and education artwork:** Lisa Langhammer created the CARE logo
  and the education-section illustrations in 2015 specifically for Amy Banks's
  use. The CARE team confirmed that authorization on October 5, 2026.
- **Education founder portraits:** The people represented in the four bundled
  founder portraits authorized their use. The CARE team confirmed those
  permissions on October 5, 2026.
- **Calm exercise previews:** `exercise_animals` and `exercise_comedy` are
  AI-generated illustrations created for CARE. They do not copy frames from the
  linked YouTube videos.
- **Paid exercise video previews:** `FigmaMirrorGestureOne`,
  `FigmaHugCompilation`, and `FigmaReadCharacterClip` use original AI-generated
  images approved by Jayme on October 7, 2026. They replace captured video
  frames, social-media screenshots, and film-character artwork. They are
  independent preview art and do not depict the linked videos' exact frames.
- **Mirror the Emotion video:** CARE embeds YouTube video `XS7cC4rj1VU` using
  YouTube's official iframe player. The former bundled screenshot was removed on
  October 5, 2026. Before consent, the app shows original interface artwork;
  YouTube's player supplies its own video preview only after the user agrees to
  load it.
- **Other embedded videos:** CARE also uses YouTube's official iframe player for
  `A1CVa6NrPpk` and `dbj85TIYyrQ`. The app does not bundle either video's audio,
  video, or thumbnail.

The CARE rights holder should retain the original artwork files and written
permission records outside the repository in case Apple requests supporting
documentation.

## Licensed open-source artwork

The `ExerciseEmoji_*` exercise icons in `ios/CAREApp/Assets.xcassets` are 128-pixel PNGs from [Google's Noto Emoji project](https://github.com/googlefonts/noto-emoji/tree/main/2D/png/128). Copyright 2013 Google LLC. The artwork is distributed under the Apache License, Version 2.0; the full license and attribution are included in the app bundle as `NotoEmojiLicense.txt`.

These icons replace PNGs rendered from Apple's emoji font. CARE retains Unicode emoji characters in its exercise model for labels and accessibility, while the visible exercise artwork comes from Noto.

## Paid exercise additions pending review

The paid branch adds Figma-imported exercise images and external media beyond the free-release list. Before distribution, review remaining paid images, linked video sources, embed behavior, and the app privacy disclosure. The free-release permissions above do not establish rights for the added paid assets.
