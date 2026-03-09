---
name: rizu-ui-development
description: Use this skill when you need to create, modify, or understand UI components in the Rizu project. It covers the yi and aqua frameworks, layout rules, and component lifecycles.
---

# UI Development in Rizu

Expert guidance for building and maintaining the UI layer of the Rizu rhythm game.

## Available Resources

- **Core Framework**: `aqua/ui/Node.lua` (Base), `yi/views/View.lua` (Visual/Lifecycle)
- **Screens & Navigation**: `yi/views/Screen.lua`, `yi/views/Screens.lua`
- **Layout Logic**: `yi/h.lua` (Declarative helper), `ui.LayoutEngine`
- **Styling**: `yi/Colors.lua`
- **Transforms**: `yi/Transform.lua`

## Instructions

### 1. Component Architecture & Context
When creating new complex UI components, always extend `yi.views.View` (or `yi.views.Screen`). Follow the project's class extension pattern.

- **Lifecycle**: Override `load()` to instantiate and add children. The view hierarchy should be constructed here.
- **Context Access**: Views have access to global context via built-in methods:
  - `self:getGame()`: Returns the main `sphere.GameController`.
  - `self:getResources()`: Returns `yi.Resources` (for fonts, etc.).
  - `self:getConfig()`: Returns game configuration/settings.
  - `self:getContext()`: Returns the root `yi.Context`.

### 2. View Configuration and Declarative Layouts (`h` function)
Configure views using `View:setup()` and construct UI trees using the `h` helper.

- **`View:setup(params)`**: Applies a table of properties via predefined setters in `View.Setters`. It handles layout (`w`, `h`, `padding`, `gap`, `arrange`), transforms (`x`, `y`, `pivot`), styling (`color`, `background_color`), and input flags (`mouse = true`, `keyboard = true`).
- **`h()` and Setters**: `h(view_instance, {params}, {children})` internally calls `view_instance:setup(params)` and adds the children. The `{params}` table can contain any key supported by `View.Setters`.
- **`h()` vs `self:add()`**: Using `self:add()` is acceptable for simple components or dynamically adding children. However, for complex screens (like `yi/views/select/Select.lua`), constructing the entire view hierarchy declaratively using `h()` is strongly preferred for better readability and maintainability.
- **Structure**: `h(view_instance, {params}, {children})`.
- **Nesting**: Always nest children as the third argument to maintain a clear tree structure.

### 3. Screens and Navigation
Screens are top-level views managed by a `Screens` container.
- **Base Class**: Extend `yi.views.Screen` instead of `View`.
- **Lifecycle Methods**: Implement `enter()` and `exit()` to handle logic when the screen becomes active or inactive.
- **Navigation**: Switch screens by calling `self.parent:set("screen_name")` (e.g., `"gameplay"`, `"select"`, `"menu"`).

### 4. Rendering Strategies & Custom Drawing
Choose the most efficient rendering method based on the use case:
- **Retained Nodes**: Use for standard UI elements (buttons, panels). Add children via `self:add()` or `h()`.
- **Immediate Rendering**: For custom graphics or data-heavy views (e.g., long lists, grids), override `View:draw()` and use `love.graphics` commands directly.
  - When overriding `draw()`, ALWAYS use `self:getCalculatedWidth()` and `self:getCalculatedHeight()` for dynamic sizing, rather than hardcoded dimensions.
- **Colors**: Prefer using the centralized `yi.Colors` module (e.g., `Colors.text`, `Colors.accent`, `Colors.panels`) over hardcoding RGBA arrays whenever possible.

### 5. Layout Rules
- **Flexbox**: Use `arrange = "flex_row"` or `"flex_col"`.
- **Wrapping**: Use `arrange = "wrap_row"` or `"wrap_col"`. Use `gap` for main-axis spacing and `line_gap` for cross-axis spacing.
- **Stacking**: Use `arrange = "stack"` to layer children on top of each other. Use `arrange = "absolute"` to position children using explicit x/y coordinates without affecting layout flow.
- **Sizing**: 
  - Pixels: `100`
  - Percentage: `"50%"`
  - Content-based: `"auto"` or `"fit"`
- **Alignment**: Control children using `justify_content` (main axis) and `align_items` (cross axis).

### 6. Input Handling
Implement event handlers to respond to user input. Ensure input flags are enabled in `setup()` (e.g., `mouse = true`, `keyboard = true`).

- **Mouse Events**: `onMouseDown`, `onMouseUp`, `onMouseClick`, `onHover`, `onHoverLost`
- **Drag & Scroll**: `onDragStart`, `onDrag`, `onDragEnd`, `onScroll` (Useful for lists and sliders)
- **Keyboard Events**: `onKeyDown`, `onKeyUp`, `onTextInput`
- **Bubbling**: Use `e:stopPropagation()` or return `true` from an event handler if the event should not reach underlying nodes.

## Examples

### Retained Button with Layout
```lua
local View = require("yi.views.View")
local Colors = require("yi.Colors")
local Label = require("yi.views.Label")

---@class yi.Button : yi.View
---@overload fun(label_text: string): yi.Button
local MyButton = View + {}

---@param label_text string
function MyButton:new(label_text)
    View.new(self)
    self:setup({
        padding = {8, 8, 8, 8},
        background_color = Colors.button,
        mouse = true,
    })
    self.label_text = label_text
end

function MyButton:load()
    local res = self:getResources()
    self:add(Label(res:getFont("bold", 24), self.label_text))
end

function MyButton:onMouseClick(e)
    print("Clicked " .. self.label_text)
end
```