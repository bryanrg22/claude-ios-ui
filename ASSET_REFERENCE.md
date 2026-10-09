# Official asset and typography reference

Reviewed October 7, 2026. Official resources can improve this reconstruction, but none of the sources reviewed supplies a complete native ChatGPT or Claude iOS app skeleton. That is a bounded search finding, not proof that no such resource exists.

| Resource | Confirmed available | What it does not establish |
|---|---|---|
| [OpenAI plugin UI guidelines](https://developers.openai.com/plugins/concepts/ui-guidelines) | General typography guidance explicitly identifies SF Pro on iOS; links the official Apps SDK UI component library and Figma components | Native per-screen font sizes, weights, tracking, custom icon mappings, or a SwiftUI copy of the app. The published component system uses Tailwind/CSS and serves plugin interfaces |
| [OpenAI brand guidelines](https://openai.com/brand/) | Official logo downloads, mark usage rules, and access to OpenAI Sans through the full brand guidelines | OpenAI Sans being the native iOS UI font, or permission to redistribute every brand asset under a project's code license |
| [Anthropic newsroom](https://www.anthropic.com/news) | Official press-kit download link | The kit contents could not be inspected through this retrieval. Native app assets, their redistribution terms, and correspondence to the existing bundled Claude SVG remain unverified |
| [Anthropic brand styling example](https://claude.com/resources/articles/how-to-create-skills-key-steps-limitations-and-examples) | Official artifact-styling example specifies Poppins headings and Lora body text | Claude iOS typography. Document/presentation brand styling is not native-app font evidence |
| [Apple Design Resources](https://developer.apple.com/design/resources/) | Platform UI design resources | Either vendor's complete app layouts or proprietary icons |
| [Apple fonts](https://developer.apple.com/fonts/) and [SF Symbols](https://developer.apple.com/sf-symbols/) | Platform fonts and configurable system icon library | That a visually similar system symbol is the exact icon used by a particular vendor screen |

Use system font APIs for the current ChatGPT implementation. The OpenAI statement supports that baseline in general design guidance; screenshot comparison must still establish each screen's metrics. Claude's bundled Newsreader remains an explicitly documented visual substitute. No official native Claude font specification was found in the reviewed sources.

## Asset terms and distribution

OpenAI's published mark terms require appropriate context, unchanged supplied marks, ownership attribution, and no misleading endorsement; they do not grant an unrestricted sublicense to brand assets. The current ChatGPT package bundles an existing knot vector in widget and About resource catalogs; its upstream attribution/redistribution provenance remains unresolved in `chatgpt-ios-ui/ASSETS.md`. No OpenAI font file is bundled. [OpenAI terms](https://openai.com/brand/)

Apple's downloadable font agreement restricts embedding and redistribution. Use the operating system's font rather than copying downloaded font binaries into these repositories. SF Symbols also has usage restrictions, including restrictions on using symbols as app icons/logos and on particular symbols; inspect the symbol's restrictions before substituting it. [Font agreement](https://developer.apple.com/fonts/), [SF Symbols guidance](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)

The Claude package's Newsreader OFL notice and existing logo provenance are recorded in `claude-ios-ui/THIRD_PARTY.md`. Discovering an official press kit does not resolve the existing SVG's provenance or authorize its redistribution. Code-license selection remains the owner's decision; no blanket code license should silently cover third-party marks or fonts.

For each future exact asset, record its official source, retrieval date, asset version, permitted use, and the actual app screen it matches. Keep private reference captures separate from distributable assets. No new third-party asset was downloaded or bundled during this research.

## Syntax-renderer dependency audit — October 8

Claude now pins [HighlighterSwift3.1.0](https://github.com/smittytone/HighlighterSwift/tree/3.1.0) at commit`fe7aae9c9b31d3b296fd3d2dd575e1a207bb29e0`, alongside the pinned Swift Markdown parser. The package uses bundled highlight.js11.11.1 through JavaScriptCore; runtime rendering does not fetch code, themes or assets. This is a third-party lexer, not proof of the vendor app's lexer or exact syntax palette.

Local audit confirmed the full HighlighterSwift MIT notice and highlight.js BSD3-Clause notice are present under `Sources/ClaudeUI/Resources/` and processed as package resources. Retain copyright/permission/disclaimer text when distributing source, and reproduce the BSD notice with binary distributions. The BSD notice also prohibits using contributor names for endorsement without permission. These dependency notices do not license the host project's code or vendor brand marks. Package resolution and bundled resource presence will be checked again in the next independent export.

Fresh light Claude code/table captures now provide actual light references; they still do not identify the original font, lexer or all-language palette. Anthropic Sans/JetBrains Mono preference labels are not evidence those font binaries are bundled or licensed by this project.
