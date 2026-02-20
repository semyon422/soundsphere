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
    *   **Cross-Worker Communication:** For communication between different nginx workers/connections, use shared memory queues (e.g., `aqua/icc/SharedMemoryQueue.lua`). These queues should store messages encoded as strings (using `icc.StringBufferPeer`).
*   **Repository Pattern for Shared Memory:** Follow the repository pattern for shared memory access. Create a dedicated repo class (e.g., `sea.UserConnectionsRepo`) that wraps the `ISharedDict` and provides semantic methods. These repos should be initialized in `sea.Repos` using the `SharedMemory` instance passed from `App`.
*   **ICC / Remotes:** ICC stands for **Inter-Context Communication**. It is used for communication between different contexts, such as between the server and client (via websockets) or between different threads (using `ThreadRemote`). Classes ending in `Remote` (e.g., `ServerRemote`) are the primary interfaces for ICC. They typically have a corresponding `Validation` wrapper (e.g., `ServerRemoteValidation`) and require methods to be whitelisted in `sea/app/remotes/whitelist.lua`.
    *   **Field Tooltips:** `IClientRemoteContext` and `IServerRemoteContext` are used as base classes to provide EmmyLua tooltips for common fields (like `user`, `session`, `ip`, `port`). These specific classes should only contain field definitions, not methods.
    *   **Architecture (Proxies & Remotes):**
        *   **`icc.Remote` (The Proxy):** On the caller's side, a `Remote` object acts as a proxy. Indexing it (`remote.path.to.method`) records the access path. Calling it sends an `icc.Message` containing the path and arguments to the peer.
        *   **Validation Wrappers:** To provide type safety and IDE support, `Remote` objects are usually wrapped in classes like `ClientRemoteValidation`. These wrappers mirror the remote API and forward calls to the underlying `Remote` proxy.
        *   **`icc.RemoteHandler` (The Dispatcher):** On the receiver's side, a `RemoteHandler` receives the message. It traverses its own "real" object (e.g., `ServerRemote`) using the path from the message to find the corresponding function.
        *   **Context Injection:** Before calling the function, `RemoteHandler` injects context (like `ip`, `port`, `user`) into the `self` object of the handler. These fields correspond to those defined in `IServerRemoteContext` and `IClientRemoteContext`.
    *   **Message Encoding:** ICC messages (`icc.Message`) must be encoded using `string.buffer` and compressed (via `icc.StringBufferPeer`) when stored in shared memory, as OpenResty shared dictionaries only support string or number values in lists.
    *   **Asynchronous Delivery:** Use `ngx.thread.spawn` within websocket resources to create background loops that pop messages from shared memory queues and deliver them to clients.
*   **Test Files:** Test files are important and should not be deleted.
*   **EmmyLua Table Notation:** Prefer `{[KeyType]: ValueType}` notation for tables instead of `table<KeyType, ValueType>`.

### Testing

The project uses a custom testing framework. Test files should follow these conventions:

1.  **File Naming:** Test files should be named with a `_test.lua` suffix (e.g., `MyModule_test.lua`).
2.  **Structure:** A test file should return a table containing test functions. Each test function receives a `t` object of type `testing.T`.
3.  **Assertions:** Use the methods provided by the `t` object for assertions:
    *   `t:eq(got, expected, msg?)`: Equality check (`==`).
    *   `t:ne(got, expected, msg?)`: Inequality check (`!=`).
    *   `t:tdeq(got, expected, msg?)`: Deep equality check for tables. Can be used to compare `icc.Message` objects directly.
    *   `t:has_error(func, ...)`: Asserts that calling `func(...)` raises an error.
    *   `t:has_not_error(func, ...)`: Asserts that calling `func(...)` does not raise an error.
    *   `t:assert(cond, err_msg?)`: Basic assertion.

#### Testing Inter-Connection Communication

When testing code that sends messages to other connections (using `getPeers()`):
1. Use `FakeSharedDict` to simulate nginx shared memory.
2. Remember that inter-connection calls via shared memory queues are one-way. Use "no-return" remotes (e.g., `-remote`) to avoid yielding in contexts that don't support it.
3. Assert on the contents of the queue using `t:tdeq(popped, Message(...))`.

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
