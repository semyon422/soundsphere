# GEMINI.md

## Project Overview

This project is an open-source rhythm game called "Rizu". It is built using the [LÖVE](https://love2d.org/) framework and is written primarily in Lua. The game is designed to be cross-platform, with support for Windows and Linux.

The project is structured into several key directories:

*   **`rizu/`**: This directory contains the modern, recently rewritten game code. New development and features are primarily focused here.
*   **`sphere/`**: This folder contains older code with an older structure. It is planned to be fully rewritten and integrated into the `rizu/` folder eventually.
*   **`sea/`**: This directory contains code related to the website, server-side logic, and some shared code components.
*   **`aqua/`**: A general-purpose Lua library with various utility modules.
*   **`3rd-deps/`**: Third-party dependencies.
*   **`chartbase/`**: Contains parsers for various rhythm game chart formats (e.g., bms, osu, stepmania).

## Building and Running

The project can be run directly from the source using the LÖVE engine.

**To run the game:**

The game is distributed with LÖVE bundled. Use the provided `game-*` scripts to start it:
-   `game-linux` for Linux
-   `game-macos` for macOS
-   `game-win64.bat` for Windows

**To run tests:**

The project includes a testing framework. Tests can be run from the command line using the following command structure:

```bash
./test [file_pattern] [method_pattern]
```

*   `file_pattern` (optional): A pattern to filter which test files to run (e.g., `rizu/gameplay/GameplayTimings_test.lua`).
*   `method_pattern` (optional): A pattern to filter specific test methods within a file.

For example, to run all tests in `rizu/gameplay/GameplayTimings_test.lua`:

```bash
./test rizu/gameplay/GameplayTimings_test.lua
```

## Development Conventions

The codebase is written in Lua and follows a modular structure. It uses a custom class implementation and a package loader.

The project uses a custom decorator system (`aqua/deco.lua`) for features like profiling and type checking.

The `.editorconfig` file in the root of the repository specifies the coding style for the project. It is recommended to use an editor with EditorConfig support to ensure consistent coding style.

*   **Indentation:** Tabs should be used for indentation.
*   **Constructors:** Empty `:new()` methods in class definitions should be omitted.
*   **Class Naming:** The preferred class naming convention is `prefix.ClassName`. However, in some rare cases, `prefix1.prefix2.ClassName` is allowed but not recommended. Avoid using nested class definitions like `sea.app.repos.UserConnectionsRepo`, prefer using `sea.UserConnectionsRepo`.
*   **Shared Memory:** Use the `web.SharedMemory` class (`aqua/web/nginx/SharedMemory.lua`) to access OpenResty shared dictionaries. Dictionaries must be defined in `nginx_config.lua` under the `shared_dicts` table to be automatically included in the generated `nginx.conf`.
*   **Repository Pattern for Shared Memory:** Follow the repository pattern for shared memory access. Create a dedicated repo class (e.g., `sea.UserConnectionsRepo`) that wraps the `ISharedDict` and provides semantic methods. These repos should be initialized in `sea.Repos` using the `SharedMemory` instance passed from `App`.
*   **ICC / Remotes:** Classes ending in `Remote` (e.g., `ServerRemote`) are used for websocket-based communication (ICC). They typically have a corresponding `Validation` wrapper (e.g., `ServerRemoteValidation`) and require methods to be whitelisted in `sea/app/remotes/whitelist.lua`.
*   **Test Files:** Test files are important and should not be deleted.
*   **EmmyLua Table Notation:** Prefer `{[KeyType]: ValueType}` notation for tables instead of `table<KeyType, ValueType>`.

### Testing

The project uses a custom testing framework. Test files should follow these conventions:

1.  **File Naming:** Test files should be named with a `_test.lua` suffix (e.g., `MyModule_test.lua`).
2.  **Structure:** A test file should return a table containing test functions. Each test function receives a `t` object of type `testing.T`.
3.  **Assertions:** Use the methods provided by the `t` object for assertions:
    *   `t:eq(got, expected, msg?)`: Equality check (`==`).
    *   `t:ne(got, expected, msg?)`: Inequality check (`!=`).
    *   `t:tdeq(got, expected, msg?)`: Deep equality check for tables.
    *   `t:has_error(func, ...)`: Asserts that calling `func(...)` raises an error.
    *   `t:has_not_error(func, ...)`: Asserts that calling `func(...)` does not raise an error.
    *   `t:assert(cond, err_msg?)`: Basic assertion.

Example:

```lua
local MyModule = require("MyModule")
local test = {}

---@param t testing.T
function test.my_feature(t)
    t:eq(MyModule.add(1, 1), 2)
end

return test
```

### Web Development

The website is built with a custom Lua-based framework.

*   **Routing:** The `sea/` directory contains the web-related code. Routing is handled by "Resource" classes (e.g., `sea/shared/http/IndexResource.lua`). New routes can be added by creating a new resource and adding it to `sea/app/Resources.lua`.
*   **Templating:** The frontend uses `etlua` for templating, allowing Lua code to be embedded in HTML files.
*   **HTMX:** The frontend uses HTMX. For links that need to perform a full page navigation (like external links or redirects), you must add `hx-boost="false"` to the `<a>` tag to prevent HTMX from intercepting the click. For external links, using the full URL is sufficient.
*   **Markdown:** Wiki pages (`sea/wiki/`) are written in a Markdown dialect that is processed by `etlua`. This allows embedding Lua code, for example, to get configuration from `brand.lua`: `[link](<%= brand.url %>/some/path)`.
*   **Class Annotations:** EmmyLua annotations are used for classes. Web resources should have a class annotation following the pattern `---@class sea.MyResource: web.IResource`.
