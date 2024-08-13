# documentation
damage log lib inspired by a skeet lua

## preview
<img src="https://airstrike.school/%F0%9F%93%91%F0%9F%92%9F%F0%9F%9A%91%F0%9F%92%AD%F0%9F%8D%9D" />

## functions

### adding library to ur script
```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rippeed/Roblox/main/universalDamageLog"))()
```

#### &lt;void&gt; NewNotification(&lt;string&gt; name, &lt;string&gt; part, <string, number> damage)
creates a new notification

```lua
library:NewNotification("Baconboy123", "UpperTorso", 69)
```

#### &lt;void&gt; SetPosition(<UDim2, string> position)
sets the position of the frame that holds the notifications

```lua
library:SetPosition(UDim2.new(0.5, 0, 0.5, 0))
```

or

```lua
library:SetPosition("LeftCoRnEr")
library:SetPosition("center")
```
##### these are the supported built-in types (NOT case sensitive)

#### &lt;void&gt; ClearNotifications()
clears all current notifications on the screen

```lua
library:ClearNotifications()
```
