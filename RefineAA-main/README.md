
Build Timestamp: 2025-04-12_14-32-21
![Refined Edge Filtering Logo](logo.png)


# Refined Edge Filtering with Integrated Nodal Enhancement

🎮 High-performance, adaptive anti-aliasing shader with integrated nodal enhancement.

## Features
✅ Single-pass architecture  
✅ Dynamic sample scaling based on target framerate (default: 120 FPS)  
✅ Tenths precision floating point math for performance  
✅ OSD Debug tools: Sample Count, Edge Strength  
✅ Steam Deck OLED / PC ready  
✅ No external includes or dependencies (.fx only)  
✅ GitHub-ready build pipeline

## Installation
1. Place `RefinedEdgeFiltering.fx` into your injectSMAA or ReShade shaders folder.
2. Enable the shader in your injector UI.
3. (Optional) Use the included `.ini` or configure manually.

## Controls
- 🎯 **Target FPS:** Prioritize desired framerate (default: 120 FPS).
- 🖍️ **Edge Detection Threshold:** Control edge sensitivity.
- 🧩 **Debug Views:** Edge detection, Sample count, OSD metrics.

## Roadmap
- [ ] OLED panel subpixel layout optimization
- [ ] Adaptive framerate smoothing
- [ ] Advanced OSD with live FPS counter

## Screenshots
See `/screenshots/` for comparisons.

---

> Built with precision. Enjoy!
