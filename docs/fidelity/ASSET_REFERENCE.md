# Official asset and typography reference

Reviewed October 7, 2026. Official resources can improve this reconstruction, but none of the sources reviewed supplies a complete native Claude iOS app skeleton. That is a bounded search finding, not proof that no such resource exists.

| Resource | Confirmed available | What it does not establish |
|---|---|---|
| [Anthropic newsroom](https://www.anthropic.com/news) | Official press-kit download link | The kit contents could not be inspected through this retrieval. Native app assets, their redistribution terms, and correspondence to the existing bundled logo SVG remain unverified |
| [Anthropic brand styling example](https://claude.com/resources/articles/how-to-create-skills-key-steps-limitations-and-examples) | Official artifact-styling example specifies Poppins headings and Lora body text | The iOS app's typography. Document/presentation brand styling is not native-app font evidence |
| [Apple Design Resources](https://developer.apple.com/design/resources/) | Platform UI design resources | The vendor's complete app layouts or proprietary icons |
| [Apple fonts](https://developer.apple.com/fonts/) and [SF Symbols](https://developer.apple.com/sf-symbols/) | Platform fonts and configurable system icon library | That a visually similar system symbol is the exact icon used by a particular vendor screen |

The bundled Newsreader remains an explicitly documented visual substitute. No official native Claude font specification was found in the reviewed sources.

## Asset terms and distribution

Apple's downloadable font agreement restricts embedding and redistribution. Use the operating system's font rather than copying downloaded font binaries into this repository. SF Symbols also has usage restrictions, including restrictions on using symbols as app icons/logos and on particular symbols; inspect the symbol's restrictions before substituting it. [Font agreement](https://developer.apple.com/fonts/), [SF Symbols guidance](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)

The package's Newsreader OFL notice and existing logo provenance are recorded in `THIRD_PARTY_NOTICES.md`. Discovering an official press kit does not resolve the existing SVG's provenance or authorize its redistribution. The MIT license on the source code does not cover third-party marks or fonts.

For each future exact asset, record its official source, retrieval date, asset version, permitted use, and the actual app screen it matches. Keep private reference captures separate from distributable assets. No new third-party asset was downloaded or bundled during this research.

## Syntax-renderer dependency audit — October 8

The package pins [HighlighterSwift3.1.0](https://github.com/smittytone/HighlighterSwift/tree/3.1.0) at commit`fe7aae9c9b31d3b296fd3d2dd575e1a207bb29e0`, alongside the pinned Swift Markdown parser. The package uses bundled highlight.js11.11.1 through JavaScriptCore; runtime rendering does not fetch code, themes or assets. This is a third-party lexer, not proof of the vendor app's lexer or exact syntax palette.

Local audit confirmed the full HighlighterSwift MIT notice and highlight.js BSD3-Clause notice are present under `Sources/ClaudeUI/Resources/` and processed as package resources. Retain copyright/permission/disclaimer text when distributing source, and reproduce the BSD notice with binary distributions. The BSD notice also prohibits using contributor names for endorsement without permission. These dependency notices do not license the host project's code or vendor brand marks. Package resolution and bundled resource presence will be checked again in the next independent export.

Fresh light code/table captures now provide actual light references; they still do not identify the original font, lexer or all-language palette. Anthropic Sans/JetBrains Mono preference labels are not evidence those font binaries are bundled or licensed by this project.
