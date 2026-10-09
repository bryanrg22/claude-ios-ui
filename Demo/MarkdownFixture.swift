import Foundation
/// Synthetic content; all formatting fixtures stay in the demo target.
enum MarkdownFixture {
    static let source = """
        # A small garden

        Good design begins with **clear structure**, *careful details*, and **bold with *emphasis***. Here is `inline code` and ~~an old idea~~.

        > Leave room for people to gather.
        >
        > A second paragraph keeps the quote connected.

        ---

        ## Plan for the weekend

        3. Bring a notebook.
           - Sketch the beds.
           - Keep a path clear.
        4. Share the plan.

        - [x] Choose a place
        - [ ] Invite neighbors

        ```python
        def greet(name: str) -> str:
            return f"Hello, {name}!"
        ```

        | Plant | Count | Season |
        | :--- | ---: | :---: |
        | Mint | `2` | Spring |
        | Basil | 4 | Summer |

        | Long project name | Detailed status | Responsible team | Last updated |
        | --- | --- | --- | --- |
        | Community garden | Ready for review | Garden volunteers | Yesterday |

        [Read the guide](https://example.com/garden) or inspect ![Garden sketch](https://example.com/sketch.png "Synthetic placeholder").

        ### Literal extensions

        Math $x^2$ and a footnote[^note] stay literal until a host provides an extension.

        [^note]: Example footnote source.
        """
}
