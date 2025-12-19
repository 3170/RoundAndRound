# RoundAndRound

A lightweight macOS menu bar app that adds rounded corners to your screen edges, bringing the smooth aesthetic of macOS Tahoe to any display.

![macOS](https://img.shields.io/badge/macOS-15.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Adds customizable rounded corners to all screen edges
- Supports multiple displays
- Adjustable corner radius (4-32 pixels)
- Lives in the menu bar - no dock icon clutter
- Launch at login option
- Minimal resource usage

## Screenshots

*Click the rainbow icon in the menu bar to access settings*

## Requirements

- macOS 15.0 (Tahoe) or later

## Installation

### Download

Download the latest release from the [Releases](../../releases) page.

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/3170/RoundAndRound.git
   ```

2. Open `RoundAndRound.xcodeproj` in Xcode

3. Build and run (⌘R)

## Usage

1. Launch the app - a rainbow icon appears in your menu bar
2. Click the icon to open the settings panel
3. Adjust the corner radius using the slider
4. Toggle "Launch at Login" to start automatically

## How It Works

RoundAndRound creates small overlay windows at each corner of every connected display. These windows are:

- Always on top
- Click-through (non-interactive)
- Present on all Spaces
- Automatically adapt when displays are connected/disconnected

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
