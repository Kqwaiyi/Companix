# Technical Documentation: LaptopUI Architecture

This document serves as a technical reference for the `LaptopUI` module. It provides context on the design patterns, responsibilities, and specific implementations of this system in the Emberborne Godot project.

---

## 1. System Overview

The `LaptopUI` acts as a diegetic interface in the main story world. It serves as a sandboxed environment where separate game mechanics (e.g., the Snake Tower minigame) can run independently without conflicting with the main game's physics, camera, or input mappings.

---

## 2. Component Structure
*   **Script Location**: `res://scripts/ui/LaptopUI.gd`
*   **Scene Location**: `res://scenes/ui/LaptopUI.tscn`
*   **Node Tree**:
	*   `CanvasLayer` (Layer 90 - Renders below SceneManager but above main game)
		*   `BackgroundTint` (`ColorRect` to obscure the paused main game)
		*   `CenterContainer` -> `Panel` (The physical laptop bezel constraint)
			*   `SubViewportContainer` (Stretch = true, `texture_filter = 1`)
				*   `SubViewport` (`canvas_item_default_texture_filter = 1`)
			*   `TransitionRect` (`ColorRect` overlaid on the container to handle local subviewport transitions)
			*   `CloseButton` (Z-indexed above the viewport to capture clicks)

---

## 3. Key Design Patterns & Behaviors

### Process Mode Isolation
When `open_laptop()` is called, it executes `get_tree().paused = true`. This globally freezes the main game's physics and `_process` loops. The `LaptopUI` circumvents this because its `process_mode` is explicitly set to `Node.PROCESS_MODE_ALWAYS`. Therefore, the `SubViewport` and any minigame instanced inside it continue to run normally.

### Pixel-Perfect Viewport Rendering
To maintain a crisp, pixel-art aesthetic inside the minigame, the `LaptopUI` overrides Godot's default viewport filtering behaviors:
*   The `SubViewportContainer` enforces `texture_filter = 1` (Nearest) so the buffer is rendered to the screen sharply.
*   The `SubViewport` enforces `canvas_item_default_texture_filter = 1` so that internal 2D nodes draw with Nearest Neighbor filtering. This isolates the minigame's aesthetic from any global project settings that might interfere.

### Integration with SceneManager
Instead of manually instantiating packed scenes, `LaptopUI.gd` delegates its loading to `SceneManager.change_scene_in_viewport(path, viewport, transition_rect, fade_duration)`. By passing its own `TransitionRect` to the SceneManager, advancing levels inside a minigame triggers a localized visual fade-to-black within the laptop screen, without affecting the main game view. If `fade_duration` is set to `0.0`, the transition is instantaneous.

### Lifecycle Cleanup & Group Notifications
When `close_laptop()` is triggered (via the X button):
1.  The main game is unpaused (`get_tree().paused = false`).
2.  The viewport's children are destroyed via `queue_free()` to prevent memory leaks.
3.  A global group call `get_tree().call_group("minigame_time_trackers", "pause_time")` is issued. This acts as a broadcast to any lingering or persistent minigame systems (e.g., external timers) to halt their logic, ensuring background systems don't desync when the laptop is closed.

---

## 4. Usage Rules for Future Development

When extending this system, adhere to the following rules:

1.  **Keep LaptopUI Modular**: `LaptopUI` is designed to be a "dumb" container. It does not track player progress or minigame state. If a minigame needs to remember the player's last level, the caller (e.g., an interactable node) must query the minigame's specific state manager before calling `LaptopUI.open_laptop(path)`.
2.  **Respect the Pause State**: If adding new global UI overlays, ensure you evaluate whether their `process_mode` needs to be `ALWAYS` or `INHERIT`. If a UI needs to animate while the game is paused, it must be `ALWAYS`.
