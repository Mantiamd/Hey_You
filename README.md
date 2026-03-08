# Hey You!

An Arma 3 mod that provides a simple, effective way to get the attention of a *specific* player using subtle sound signals — tongue clicks, twig throws, and lizard squeaks — through the ACE self-interaction menu or CBA keybinds.

> **Note:** This can be run clientside but requires all clients who want the notification to also be running the mod. It is required on the server if you want to adjust the settings.

## Why This Mod?

Arma already has signal sounds, hand-and-arm gestures, and voice communication — so why another communication tool?

If you've ever been a real-life team or squad leader and then stepped into Arma, you'll quickly notice something ironic: **leading an element can actually be harder in-game than it is in real life.**

In reality, you can:

- Make eye contact
- Physically point or turn someone
- Recognize teammates by face, size, or mannerisms
- Use subtle noises or gestures to cue one specific person

In Arma, many of those small but critical leadership tools are missing or unreliable. It's harder to identify individuals, harder to non-verbally direct someone, and harder to discreetly get one player's attention without broadcasting over comms.

This mod is designed to help bridge that gap. It allows you to **target a specific player and get their attention** using subtle, situational cues — helping simulate the kind of small, direct communication that happens naturally in real-life small-unit leadership.

The goal is not to replace voice comms, but to **supplement them**, especially in moments where talking isn't ideal or breaks immersion.

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

## Inspiration

The idea for this mod came from a Discord discussion where players were sharing mod suggestions and concepts. **Miller** *(aka Miller's Marauders, aka that one of many Millers snooping around)* suggested a mechanic where you could get a teammate's attention by throwing a small object, like a twig, at them.

After discussing the idea with him directly, he also pointed me toward an interview with former **MACV-SOG LTC Ed Wolcoff (RT New York)**. In that interview, Wolcoff describes the use of a subtle attention-getting noise known as a **"lizard squeak"** — a concept that is also represented in this mod.

## Support

Want to help keep me off the overtime list at work and spending more time on Arma 3 modding? [Buy me a coffee or Baja Blast on Patreon!](https://patreon.com/GoonSix)

## License

See repository for license details.
