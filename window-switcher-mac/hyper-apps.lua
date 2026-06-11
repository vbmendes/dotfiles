-- Hyper-mode app shortcuts.
-- Each entry: { 'KEY', 'AppName' [, 'WindowCycleId'] }
--
-- AppName       is passed to hs.application.open() — use the exact name shown
--               in Activity Monitor, or the bundle ID (e.g. 'com.tinyspeck.slackmacgap').
-- WindowCycleId (optional) is the name Hammerspoon uses when listing windows of
--               an app whose launch name differs from its window title app name
--               (e.g. VS Code opens as 'Visual Studio Code' but windows belong to 'Code').
--
-- Find a bundle ID: mdls -name kMDItemCFBundleIdentifier /Applications/App.app
-- Find the window app name: hs.window.focusedWindow():application():name()  (run in Hammerspoon console)
return {
  { 'a', 'Google Calendar' },
  { 'b', 'Google Chrome' },
  { 'c', 'Slack' },
  { 'd', 'TickTick' },
  { 'e', 'Visual Studio Code', 'Code' },
  { 'f', 'Finder' },
  { 'i', 'Claude' },
  { 'm', 'Spotify' },
  { 'n', 'Obsidian' },
  { 'p', '1Password' },
  { 'u', 'Cursor' },
  { 'v', 'Google Meet' },
  { 'w', 'WhatsApp Web' },
  { 't', 'Warp' },
}
