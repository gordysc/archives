# ⚡ Electron Modern Features Reference

> Covers Electron v35–v40 (2025–2026). Current stable: **Electron 40** (Chromium 144, Node 24, V8 14.4).

---

## 🔐 Security

### ASAR Integrity (Stable in v39+)

Runtime validation of `app.asar` against a build-time hash. If no hash is present or there's a mismatch, the app force-terminates. No longer experimental.

### Clipboard API Migration (v40)

Direct clipboard access from renderer processes is **deprecated**. Move all clipboard calls to preload scripts and expose via `contextBridge`:

```ts
// preload.ts
contextBridge.exposeInMainWorld("clipboard", {
  readText: () => clipboard.readText(),
  writeText: (text: string) => clipboard.writeText(text)
});
```

### Web Serial & WebUSB Blocklists (v37+)

Spec-defined blocklists are now enforced. Disable with `--disable-usb-blocklist` or `--disable-serial-blocklist` if needed for custom hardware.

### File System API Permission Persistence (v40+)

File System Access API permissions can now be persisted within sessions, avoiding repeated permission prompts.

---

## 🖼️ Window Management

### `BrowserWindow.isSnapped()` (v36+)

Detect whether a window has been arranged via OS Snap (Windows Snap Layouts, etc.).

### `win.isContentProtected()` (v37+)

Check whether content protection (screen capture prevention) is currently active on a window.

### `roundedCorners` on Windows (v36+)

The `roundedCorners` BrowserWindow constructor option is now supported on Windows in addition to macOS.

### `-electron-corner-smoothing` CSS Property (v36+)

Apply Apple-style squircle rounded corners in CSS:

```css
.card {
  border-radius: 16px;
  -electron-corner-smoothing: 60%;
}
```

Smoothly transitions curves into squircle shapes matching macOS design language.

### `window.open` Always Resizable (v39+)

Per WHATWG spec, popup windows created via `window.open` are always resizable. Use `setWindowOpenHandler` to customize behavior.

---

## 🌉 IPC & Context Bridge

### `contextBridge.executeInMainWorld()` (v35+)

Safely execute code across world boundaries without going through IPC:

```ts
contextBridge.executeInMainWorld(fn, ...args);
```

### Modern Preload APIs (v35+)

New preload registration system replacing the deprecated `setPreloads()`/`getPreloads()`:

```ts
session.defaultSession.registerPreloadScript({
  type: "frame",
  filePath: "/path/to/preload.js"
});
session.defaultSession.unregisterPreloadScript({ id });
session.defaultSession.getPreloadScripts();
```

Supports additional preload targets beyond just frames.

---

## 👷 Service Workers (v35+)

### `ServiceWorkerMain` Class

Interact with service workers directly from the main process:

```ts
const worker = session.serviceWorkers.getInfoFromVersionID(versionId);
```

### Events & Lifecycle

- `running-status-changed` event for monitoring worker status
- `startWorkerForScope()` to restart previously stopped workers
- `scriptURL` property on ServiceWorkerMain instances (v37+)
- Service worker preload script support

> Note: `session.serviceWorkers.fromVersionID()` is deprecated — use `getInfoFromVersionID()`.

---

## 🎨 Native UI & Theming

### System vs App Theme Detection (v36+)

```ts
nativeTheme.shouldUseDarkColorsForSystemIntegratedUI;
```

Distinguishes between the system theme and the app's configured theme — useful when the app overrides the system dark mode setting.

### System Accent Color on Linux (v40+)

```ts
const accent = systemPreferences.getAccentColor(); // works on macOS, Windows, and now Linux
```

### Reset Window Accent Color (v40+)

```ts
win.setAccentColor(null); // revert to system default
```

### macOS Menu Integration (v36+)

Native macOS menu items for **Writing Tools** (grammar/spelling), **Autofill**, and **Services** are available via the `frame` option in `menu.popup()`.

### Menu Sublabels & Roles (v37+, macOS 14.4+)

- Sublabel support for menu items
- New menu item roles: `palette` and `header`

### SF Symbols (v40+)

```ts
const icon = nativeImage.createFromNamedImage("star.fill"); // SF Symbol names supported
```

---

## 🚀 Rendering & Performance

### HDR Offscreen Rendering (v40+)

RGBAF16 output format with scRGB HDR color space support for offscreen rendering.

### Uncapped Offscreen FPS (v36+)

The 240 FPS limit for shared texture offscreen rendering has been removed.

### Hardware Acceleration Check (v40+)

```ts
if (app.isHardwareAccelerationEnabled()) {
  // GPU compositing is active
}
```

### Improved `desktopCapturer` Performance (v36+)

`desktopCapturer.getSources()` is significantly faster on macOS when thumbnail size is set to `{ width: 0, height: 0 }`.

---

## 🌐 Networking

### Request Priority (v37+)

```ts
const request = net.request({
  url: "https://example.com/api",
  priority: "low",
  priorityIncremental: true
});
```

### Bypass Custom Protocol Handlers (v40+)

```ts
const request = net.request({
  url: "https://example.com",
  bypassCustomProtocolHandlers: true
});
```

---

## ⌨️ Input Events

### `before-mouse-event` (v37+)

Intercept and optionally prevent mouse events in WebContents before they reach the page.

---

## 🖥️ Frame & WebContents

### `WebContents.focusedFrame` (v36+)

Retrieve the currently focused frame from any WebContents instance.

### Navigation History Restoration (v36+)

```ts
webContents.navigationHistory.restore(index, entries);
```

Programmatically restore navigation history — useful for session persistence.

### `webFrame.frameToken` (v38+)

Replaces the deprecated `webFrame.routingId`. Use `webFrame.findFrameByToken(token)` instead of `findFrameByRoutingId()`.

### DevTools Auto-Focus (v40+)

DevTools now automatically receive focus when inspecting elements or triggering breakpoints.

---

## 🐧 Linux Platform Updates

### Wayland Native by Default (v38+)

`--ozone-platform` defaults to `auto`, meaning apps run natively on Wayland. Force X11 with `--ozone-platform=x11`.

### GTK 4 Default on GNOME (v36+)

GTK 4 is the default toolkit on GNOME desktops. Override with `--gtk-version=3` if needed.

### System Context Menu (v36+)

`system-context-menu` event support on Linux.

### DIP/Screen Coordinate Conversion (v37+, X11)

```ts
screen.dipToScreenPoint(point);
screen.screenToDipPoint(point);
```

---

## 🔧 Utility Processes

### Graceful Unhandled Rejections (v37+)

Utility processes now emit warnings on unhandled rejections instead of crashing. Restore crash behavior:

```ts
process.on("unhandledRejection", () => {
  process.exit(1);
});
```

### Synchronous `process.exit()` (v37+)

`process.exit()` in utility processes now terminates immediately (matching Node.js behavior). Side effects like pending I/O may not complete.

### Memory Eviction Exit Reason (v40+)

`"memory-eviction"` is now available as a child process exit reason.

---

## 🪦 Removed & Deprecated APIs

| API                                       | Status     | Version | Replacement                                                    |
| ----------------------------------------- | ---------- | ------- | -------------------------------------------------------------- |
| `systemPreferences.isAeroGlassEnabled()`  | Removed    | v36     | None (always true since Win 10)                                |
| `NativeImage.getBitmap()`                 | Deprecated | v36     | `NativeImage.toBitmap()`                                       |
| `session.setPreloads()` / `getPreloads()` | Deprecated | v35     | `registerPreloadScript()` / `getPreloadScripts()`              |
| `ELECTRON_OZONE_PLATFORM_HINT`            | Removed    | v38     | `--ozone-platform` flag                                        |
| `webFrame.routingId`                      | Deprecated | v38     | `webFrame.frameToken`                                          |
| `webFrame.findFrameByRoutingId()`         | Deprecated | v38     | `webFrame.findFrameByToken()`                                  |
| `ProtocolResponse.session = null`         | Removed    | v37     | `session.fromPartition()`                                      |
| `plugin-crashed` event                    | Removed    | v38     | None                                                           |
| Clipboard in renderer                     | Deprecated | v40     | Preload + `contextBridge`                                      |
| `--host-rules` flag                       | Deprecated | v39     | `--host-resolver-rules`                                        |
| macOS 11 (Big Sur) support                | Removed    | v38     | Requires macOS 12+                                             |
| `PrinterInfo.isDefault` / `.status`       | Removed    | v36     | None                                                           |
| `console-message` positional args         | Deprecated | v35     | Object-style `{ level, message, lineNumber, sourceId, frame }` |
| `session.serviceWorkers.fromVersionID()`  | Deprecated | v35     | `getInfoFromVersionID()`                                       |
| Session extension methods on `session`    | Deprecated | v36     | `session.extensions.*`                                         |
| `WebRequestFilter.urls = []` matching all | Changed    | v35     | Use `'<all_urls>'` pattern                                     |

---

## 📅 Version Timeline

| Version | Chromium | Node  | V8   | Released |
| ------- | -------- | ----- | ---- | -------- |
| 35      | 134      | 22.14 | 13.5 | 2025     |
| 36      | 136      | 22.x  | 13.6 | 2025     |
| 37      | 138      | 22.x  | 13.8 | 2025     |
| 38      | 140      | 22.16 | 14.0 | 2025     |
| 39      | 142      | 22.20 | 14.2 | 2025     |
| 40      | 144      | 24.11 | 14.4 | 2026     |

New major stable versions ship every **8 weeks**, synced with every other Chromium release.
