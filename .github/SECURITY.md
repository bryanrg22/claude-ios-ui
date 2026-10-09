# Security

This package draws user interface and keeps presentation state. It makes no network calls, stores no credentials, and
never touches the microphone, camera or photo library, so most security-sensitive behavior lives in the app that embeds
it. Even so, if you find something in this code that could expose data or let content from a conversation do something
it shouldn't (for example through the Markdown renderer), please report it privately rather than in a public issue.

Use GitHub's **Report a vulnerability** button on the Security tab of this repository. You'll get a reply within a week.
