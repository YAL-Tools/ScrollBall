# ScrollBall
**Quick links:** [blog post](https://yal.cc/scrollball) · [documentation](https://yal-tools.github.io/ScrollBall/)

This is an AutoHotKey (v2) script that can turn motions from pointing devices (mice, trackballs, trackpads, etc.) into custom actions.

Thus you can program your mouse to have "gestures" or do general input conversions
(e.g. moving the mouse to scroll, change volume, press keys, and so on)
regardless of driver/manufacturer.

A little video:

https://github.com/YAL-Tools/ScrollBall/assets/731492/4f1722fb-e8b5-432a-a6d8-fbdfbf59e3a7

## How does this work?
The script uses Raw Input API to track motions from individual pointing devices
and briefly locks the cursor when conditions are satisfied.

This approach allows the script to do its work without the cursor drifting around the screen
([further reading](https://yal.cc/scrollball#Research)).

## Setting up
1. Download [AutoHotKey](https://www.autohotkey.com/) (v2) if you don't have it yet.
2. Checkout (or just [download](https://github.com/YAL-Tools/ScrollBall/archive/refs/heads/main.zip)) this repository.
3. Create a script with your own configuration (see documentation) or have a look at examples.
4. Run your script by dragging it onto AutoHotKey64.exe or through a context menu (if using AHK installer)

For a convenient AHK script editing experience, I recommend VS Code
with [AHKv2 plugin](https://marketplace.visualstudio.com/items?itemName=thqby.vscode-autohotkey2-lsp).

## Mac/Linux<em>?</em>
Personally I'm primarily proficient in doing funny things with Windows.

Someone else might know how to carry over the idea to other platforms.

Or perhaps it'll run under WINE? I bet that WINE simulates at least a single mouse for Raw Input API.

## Credits/license
A script by Vadym "[YellowAfterlife](https://yal.cc)" Diachenko  
Licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.
