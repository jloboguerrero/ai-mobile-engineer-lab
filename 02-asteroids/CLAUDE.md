# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **classic Asteroids arcade game** clone built with vanilla HTML5 Canvas and JavaScript (ES6+). No build tools, no dependencies, no frameworks — it's a pure client-side game that runs directly in the browser.

The game is in Spanish (README and code comments are in Spanish). Three lives, score-based progression, toroidal space wrapping, collision detection, and explosion particles.

## How to Run

### Direct in browser
Double-click `index.html` to open it directly in any browser.

### With a local server
```bash
npx serve .
# or
python -m http.server 8000
```
Then navigate to `http://localhost:3000` (or `http://localhost:8000` for Python).

## Architecture

### Single-File Game Loop
The entire game logic lives in `game.js` (~424 lines). The structure is:

1. **Input System** (lines 8–24): Key tracking (`keys` dict) and one-shot input detection (`justPressed`). Uses `preventDefault()` for arrow keys and space to avoid browser defaults.

2. **Utility Functions** (lines 26–30):
   - `wrap()`: Toroidal space wrapping (edges connect; objects disappear on one side and reappear on the other)
   - `dist()`: Euclidean distance between two objects
   - `rand(min, max)`: Float random in range
   - `randInt(min, max)`: Integer random in range

3. **Entity Classes** (lines 32–236):
   - **Bullet**: Fast projectiles with TTL (1.1s). Speed 520 px/s. Wraps at edges.
   - **Asteroid**: Irregular polygons in 3 sizes. Each size has fixed radius, base speed, and point value. Spin randomly. Split into two smaller asteroids when destroyed (size 1 asteroids don't split).
   - **Ship**: Player-controlled. Rotation ±3.5 rad/s. Thrust adds acceleration. Drag (0.987 per frame). 3-second invincibility on spawn with flickering. Shoot cooldown 0.2s.
   - **Particle**: Explosion fragments. Random velocity burst. Alpha fade. TTL 0.4–1.1s.

4. **Game State** (lines 238–290): Global `ship`, `bullets`, `asteroids`, `particles` arrays. Score, lives, level. State machine: `'playing'` → `'dead'` (2-second respawn timer) → back to `'playing'`, or → `'gameover'`. Death from asteroid collision kills the ship, spawns explosion, decrements lives.

5. **Update Loop** (lines 292–351): Conditional logic per state. In `'playing'`, handle input, update all entities, check collisions (bullets vs asteroids, ship vs asteroids), spawn new asteroids when level is cleared.

6. **Rendering** (lines 353–409): Clear canvas, draw particles/asteroids/bullets/ship in z-order, draw HUD (score, level, life count). Overlay text for game over.

7. **Main Loop** (lines 411–423): `requestAnimationFrame` with delta-time capping at 50ms per frame.

### Constants
- **Canvas**: 800×600 px
- **Asteroid sizes**: 1 (small, radius 16), 2 (medium, 30), 3 (large, 50)
- **Asteroid speeds**: size 3 = 32 px/s, size 2 = 55 px/s, size 1 = 85 px/s (smaller = faster)
- **Points**: size 1 = 100, size 2 = 50, size 3 = 20 (inverted order)
- **Ship radius**: 12 px. Invincibility: 3 seconds on spawn. Shoot cooldown: 0.2s.
- **Safe spawn zone**: 130 px radius from center (prevents instant death on respawn)

## Common Development Tasks

### Add a New Game Feature
1. Create a new entity class with `constructor()`, `update(dt)`, and `draw()` methods.
2. Add an array for instances (e.g., `let powerUps = []`) in the game state section.
3. Spawn instances in relevant places (e.g., when asteroid destroyed).
4. Update each instance in the update loop: `powerUps.forEach(p => p.update(dt))`.
5. Draw each instance in the draw loop: `powerUps.forEach(p => p.draw())`.
6. Add collision detection in the update loop if needed.
7. Clean up dead instances: `powerUps = powerUps.filter(p => !p.dead)`.

### Modify Game Difficulty
- **More asteroids**: Increase `count` in `spawnAsteroids()` call (line 265 for initial spawn, line 273 for next level).
- **Faster asteroids**: Increase values in `SPEEDS` array (line 62).
- **Bigger asteroids**: Increase values in `RADII` array (line 61).
- **Higher bullet damage**: Decrease `SPEED` in `Bullet.constructor()` (line 37) so bullets live longer or travel slower.
- **Harder ship**: Decrease `THRUST` (line 144), increase `DRAG` (line 145), or increase `invincible` cooldown (line 133).

### Adjust Visuals
- **Canvas size**: Edit `width` and `height` in `index.html` line 23, then update `W` and `H` in `game.js` lines 5–6.
- **Ship silhouette**: Modify the draw path in `Ship.draw()` (lines 184–189).
- **Asteroid polygon**: Change `randInt(8, 13)` to control vertex count (line 81).
- **Colors**: Search `ctx.strokeStyle` and `ctx.fillStyle` to swap from white (`#fff`) to other colors.
- **HUD font/size**: Modify `ctx.font` statements (lines 373, 379, 389, 391).

### Change Input Bindings
Edit the keyboard handlers starting at line 12. Replace `'ArrowLeft'`, `'ArrowRight'`, `'ArrowUp'`, `'Space'` with other key codes. List of key codes: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code

### Fix Physics Issues
- **Wrapping doesn't look right**: Check the `wrap()` function (line 27). It assumes `max > 0` and that positions are always positive.
- **Collisions feel off**: Collision uses `dist()` and compares to sum of radii. Check radius values in entity constructors.
- **Movement feels jerky**: Frame delta capping (line 415) is set to 50ms max. Reduce to 16ms for 60 FPS feel; increase to allow faster frames on slower devices.

### Test Changes
Since there's no build step, just save `game.js`, refresh the browser, and play. Changes take effect immediately.

## Code Style & Conventions

- **Semicolons**: Enforced (`'use strict'` at line 1).
- **Variable naming**: camelCase for variables and methods, SCREAMING_SNAKE_CASE for constants.
- **Comments**: Grouped by section with ASCII decorative lines (e.g., line 8: `// ── Input ──…──`). No docstrings.
- **Indentation**: 2 spaces.
- **Arrow functions**: Used for event listeners and array methods.
- **Canvas context state**: Saved/restored with `ctx.save()` and `ctx.restore()` before transforms.

## Spanish Language Note

The README, comments, and overlay text (e.g., "GAME OVER", "PUNTAJE", "NIVEL") are in Spanish. If you change gameplay text, keep it in Spanish for consistency, or update all strings together.

## Performance Considerations

- **Particle pool**: Dead particles are filtered out each frame, not pre-allocated. For 1000s of simultaneous particles, consider object pooling.
- **Collision checks**: O(bullets × asteroids) per frame. At 10 bullets and 20 asteroids, that's 200 checks/frame. Fine for this scale.
- **Canvas rendering**: Redraw entire screen each frame. No dirty-rect optimization.

## Files

- `index.html` — Entry point. Minimal styling, loads `game.js`.
- `game.js` — The entire game. All classes, state, logic, and rendering.
- `favicon.svg` — Browser tab icon.
- `README.md` — User-facing game description and controls (in Spanish).
