# Asset provenance

- **Newsreader.ttf**: The Newsreader Project Authors (2020), SIL Open Font License 1.1. Full license accompanies the font in `Sources/ClaudeUI/Resources/Newsreader-OFL.txt`. Copied from the existing companion project's licensed font resource. This is a visual substitute; no claim it is Claude's actual iOS font.
- **Claude_AI_symbol.svg**: Existing companion asset, copied unmodified from its `ClaudeLogo.imageset`. Claude/Anthropic brand artwork belongs to its owner. Original source and redistribution permission have not been independently established in this pass. The code license (if assigned later) must not imply a license to this mark. Replace/remove the resource before publishing if permission is not established.
- **SF Symbols**: Rendered by iOS through system symbol names; no extracted SF Symbols files are redistributed.
- **Temporary-session ghost and unequal menu lines**: Small geometric SwiftUI paths recreated for this interface study; exact outline fidelity is unverified.
- **Camera scene**: Original synthetic SwiftUI scene. The private camera-reference image is not redistributed.
- **Photo tiles**: Synthetic SwiftUI landscape drawings, not photos from the user's library.
- **Screenshots**: Private source screenshots are not included. Public documentation should use synthetic demo screenshots only.

No third-party app binaries, proprietary fonts, account credentials, or real user conversations are included.

- **GitHub logo**: Simple Icons `icons/github.svg`, retrieved October8,2026 from https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg (SHA256 `3bf8cceead820aec50d4ee825a3fd02c5a1cd6665cc9cf4cbf3d9c8861a204bb`). Upstream CC0 text is included as `Resources/Simple-Icons-CC0.md`. GitHub trademarks remain owned by GitHub; CC0 does not grant trademark rights. The icon identifies the repository integration control, not this project's identity. GitHub's [brand guidance](https://brand.github.com/foundations/logo) describes integration use and non-affiliation constraints.
- **Code status/configuration glyphs and sleeping mascot**: Original geometric/vector and pixel approximations of the provided UI reference. No original animated sprite asset was extracted; motion and exact outlines remain unverified.

The `ClaudeWidgets` target reuses a copy of the same `ClaudeLogo` SVG to remain independent of the app UI target. Its provenance and unresolved redistribution/trademark considerations are identical to those stated above. Widget voice and Dispatch glyphs are original approximate vector geometry; camera, Code, plus and search use SF Symbols.

## Swift Markdown and cmark

Markdown parsing uses swiftlang/swift-markdown 0.9.0 (Apache License 2.0 with Runtime Library Exception) and its swift-cmark 0.9.0 dependency (BSD-style and included component notices). Full notices are retained with the package resources as `Swift-Markdown-LICENSE.txt` and `Swift-CMark-COPYING.txt`. The upstream sources are resolved through SwiftPM, not copied into this repository. See [Markdown integration and limitations](docs/features/MARKDOWN.md).

The added `Newsreader-Italic.ttf` is the unmodified variable italic face from [Google Fonts Newsreader](https://github.com/google/fonts/tree/main/ofl/newsreader), distributed under the accompanying Newsreader OFL notice. It complements the existing upright substitute so emphasis has a real italic face. It is not Claude's proprietary typeface.

Newsreader italic SHA-256: `796668611f80b64d5adf182fde3b6f29ed83b4e7cbec7b96937e84ac01364792` (retrieved 2026-10-08).


## Offline syntax coloring

[HighlighterSwift](https://github.com/smittytone/HighlighterSwift) is pinned to 3.1.0 (commit `fe7aae9c9b31d3b296fd3d2dd575e1a207bb29e0`). It wraps bundled highlight.js 11.11.1 through JavaScriptCore and returns native attributed text. HighlighterSwift is MIT licensed; highlight.js is BSD 3-Clause. Full upstream notices are bundled in `Resources/HighlighterSwift-LICENSE.txt` and `Resources/HighlightJS-LICENSE.txt`. The Atom One Dark/Light styles are supplied by this dependency. SwiftPM resolves the dependency source; no private source-app assets or code content are copied into it.
