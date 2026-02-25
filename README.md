# Hey You!

An Arma 3 mod that lets players silently get a teammate's attention using subtle sound signals — tongue clicks, twig throws, and lizard squeaks — through the ACE self-interaction menu or CBA keybinds.

## Features

- **ACE Self-Interaction Menu** — Open the "Hey You!" menu to pick a nearby group member and choose a signal type.
- **General Signal** — Play a sound without targeting anyone specific. Useful for ambient "heads up" alerts.
- **CBA Keybinds** — Signal the group member you're looking at instantly:
  | Keybind | Signal |
  |---|---|
  | `Left Ctrl + L` | Tongue Click |
  | `Left Ctrl + ;` | Throw a Twig |
  | `Left Ctrl + '` | Lizard Squeak |
- **3D Floating Text** — The receiver sees a fading yellow message above the sender's head.
- **Hint Notification** — A standard hint also appears on the receiver's screen.
- **3D Sound** — Each signal plays a positional sound audible within 50m.

## CBA Settings

All settings are server-synced and configurable through CBA's addon options menu:

| Setting | Default | Range |
|---|---|---|
| Max Signal Distance | 12m | 2–15m |
| 3D Text Duration | 5s | 1–15s |
| Hint Duration | 10s | 1–30s |
| 3D Text Size | 0.025 | 0.01–0.05 |
| Enable 3D Text | On | On/Off |
| Enable Hints | On | On/Off |

## Requirements

- [ACE3](https://ace3.acemod.org/)
- [CBA_A3](https://github.com/CBATeam/CBA_A3)

## Installation

1. Download or clone this repository.
2. Copy the `Hey_You` folder into your Arma 3 mods directory (or symlink it).
3. Build the PBO from `addons/hey_you` using your preferred tool (e.g. Addon Builder, HEMTT).
4. Enable the mod alongside ACE3 and CBA_A3 in the Arma 3 launcher.

## How It Works

1. Player opens ACE self-interaction and selects **Hey You!**
2. A list of nearby group members (within max distance) appears, along with a **General Signal** option.
3. Selecting a teammate reveals the signal choices: *Click Tongue*, *Throw a Twig*, or *Lizard Squeak*.
4. The chosen signal plays a 3D sound at the sender's position and sends a notification to the receiver via `remoteExec`.
5. The receiver sees floating 3D text above the sender and/or a hint, depending on server settings.

Keybinds skip the menu entirely — just look at a teammate and press the bound key.

## Multiplayer

- Signal logic runs on the sender's client; notifications are delivered to the receiver via `remoteExec`.
- All CBA settings are server-authoritative and synced to clients.
- Compatible with dedicated servers (the mod's init exits early on headless/dedicated machines).

## License

See repository for license details.
