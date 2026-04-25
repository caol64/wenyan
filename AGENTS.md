# AGENTS.md

## Build and validation commands

Use `pnpm ui:init` after pulling `wenyan-ui` changes; it updates the submodule, installs its dependencies, and runs `svelte-kit sync`.

Use `pnpm web:install` in the repo root to install the root web dependencies and run `svelte-kit sync`.

Use `pnpm exec svelte-check` in the repo root to type-check the macOS host Svelte app in `src/`.

Use `pnpm --dir wenyan-ui exec svelte-check` to type-check the shared `@wenyan-md/ui` package.

Use `pnpm web:build` to build the Svelte app and copy the generated files from `build/` into `WenYan/Resources.bundle` with `scripts/copy_web_assets.sh`.

Use `pnpm --dir wenyan-ui build` to build the reusable UI package itself (`vite build && svelte-package`).

Use `pnpm build` to build the macOS app with Xcode:

```bash
xcodebuild -scheme WenYan -configuration Release -destination 'platform=macOS,arch=arm64' SYMROOT=target build
```

If you changed web UI code, run `pnpm web:build` before `pnpm build`; the Xcode build consumes the prebuilt assets already copied into `WenYan/Resources.bundle`.

There is no configured automated test suite or single-test runner in this repository right now. The Xcode project currently contains only the `WenYan` app target.

## High-level architecture

This repository is a native macOS app that wraps a Svelte UI. `WenYan/WenYanApp.swift`, `WenYan/Views/ContentView.swift`, and `WenYan/Views/MainUI.swift` create the SwiftUI shell and host a `WKWebView`.

The web UI that ships inside the app lives in the repo-root SvelteKit app under `src/`. It is bundled into static files, then copied into `WenYan/Resources.bundle`, and loaded inside the WebView through the custom `app://` scheme implemented by `WenYan/Common/LocalSchemeHandler.swift`.

Reusable editor/layout/state code lives in the `wenyan-ui/` submodule-like package and is imported as `@wenyan-md/ui`. The root app does not consume the packaged build during local development; `vite.config.ts` and `svelte.config.js` alias `@wenyan-md/ui` directly to `wenyan-ui/src/lib`, so shared UI changes should usually be made in `wenyan-ui/`, not duplicated in the root `src/` app.

The repo-root `src/` layer is the macOS-specific integration layer. It wires `@wenyan-md/ui` stores to Swift persistence via adapters in `src/lib/adapters/`, registers app-specific hooks in `src/lib/setHooks.ts`, and communicates with Swift through `src/lib/bridge.ts` and `src/lib/action.ts`.

The Swift side of the bridge is centered in `WenYan/Views/MainViewModel.swift`, which receives `wenyanBridge` messages from JavaScript, performs native work, and calls back into `window.__WENYAN_BRIDGE__`. JS-to-Swift calls are request/response actions; Swift-to-JS updates are emitted events handled in `src/lib/listeners.svelte.ts`.

Persistence is split by concern. Article content, settings, credentials, and security-scoped bookmarks are stored in `UserDefaults` (`WenYan/Stores/*.swift`), while custom themes and upload cache entries are stored in Core Data (`WenYan/CoreData/DBHandler.swift` and related models).

Rendering and platform-specific HTML generation come from `@wenyan-md/core`; the shared UI layer only manages state, hooks, and presentation. The main renderer/copier state lives in `wenyan-ui/src/lib/wenyan.svelte.ts`.

## Key conventions

Stateful non-component Svelte modules use Svelte 5 runes in `.svelte.ts` files (`$state`, `$effect`) instead of classic `writable` stores. Follow the existing `.svelte.ts` pattern when extending global state, stores, or reactive helpers.

Keep reusable UI logic in `wenyan-ui/`. Keep macOS-only behavior in the root `src/` integration layer and Swift files. If a change needs filesystem access, native dialogs, credential storage, or WebView messaging, it probably belongs in the root app layer rather than the shared UI package.

Bridge features must be implemented on both sides. A new native capability usually requires matching edits in `src/lib/action.ts`, the `switch` in `MainViewModel.userContentController`, a native handler method in Swift, and sometimes `src/lib/listeners.svelte.ts`, `src/lib/setHooks.ts`, or `src/lib/storeRegister.ts`.

Do not hand-edit `build/` output or `WenYan/Resources.bundle` contents. They are generated artifacts produced by `pnpm web:build`.

Theme IDs have repo-specific prefixes. Temporary unsaved themes use `0:` IDs in the UI state, selected persisted custom themes use `custom:` IDs in the shared UI, and the macOS persistence layer stores custom themes by Core Data object URI string. Preserve those conversions when changing theme flows.
