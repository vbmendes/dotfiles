-- Hyper-mode focus-or-launch with MRU window cycling.
--
-- Modifier: Shift+Ctrl+Alt+Cmd ("hyper").
-- First press: focuses the most-recently-used window of the app, or launches it.
-- Repeated presses within 2 s: cycles through all visible windows in MRU order.
-- After 2 s of inactivity the snapshot resets, so the next press re-sorts by MRU.

local log = hs.logger.new('hyper', 'info')

-- ── MRU tracking ─────────────────────────────────────────────────────────────
-- mruList[1] = most recently focused window ID
local mruList = {}

local allWindowsFilter = hs.window.filter.new(true)
allWindowsFilter:subscribe(hs.window.filter.windowFocused, function(win)
  local id = win:id()
  for i, v in ipairs(mruList) do
    if v == id then table.remove(mruList, i); break end
  end
  table.insert(mruList, 1, id)
end)

-- ── Cycle state ───────────────────────────────────────────────────────────────
-- Keyed by stateKey (windowCycleId or appId).
-- { time = os.time(), windowIds = {...}, lastId = id }
local cycleState = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function visibleWindows(app)
  local wins = {}
  for _, w in ipairs(app:allWindows()) do
    if not w:isMinimized() then wins[#wins + 1] = w end
  end
  return wins
end

local function sortByMRU(wins)
  local pos = {}
  for i, id in ipairs(mruList) do pos[id] = i end
  table.sort(wins, function(a, b)
    return (pos[a:id()] or math.huge) < (pos[b:id()] or math.huge)
  end)
  return wins
end

-- ── Core logic ────────────────────────────────────────────────────────────────

local function openApplication(appId, windowCycleId)
  if type(appId) ~= 'string' then
    log:e('invalid appId', appId)
    return
  end

  local app = windowCycleId and hs.application.get(windowCycleId)
  if app == nil then app = hs.application.get(appId) end

  if app == nil or not app:isFrontmost() then
    log:i('launching / focusing', appId)
    hs.application.open(appId)
    return
  end

  local wins = visibleWindows(app)
  if #wins <= 1 then
    log:i('single window, nothing to cycle for', appId)
    return
  end

  local stateKey = windowCycleId or appId
  local now = os.time()
  local state = cycleState[stateKey]
  local ordered

  if state and (now - state.time) < 2 then
    -- Rebuild from snapshot, filtering out windows that have since closed
    local byId = {}
    for _, w in ipairs(wins) do byId[w:id()] = w end
    ordered = {}
    for _, id in ipairs(state.windowIds) do
      if byId[id] then ordered[#ordered + 1] = byId[id] end
    end
    -- Append any new windows not yet in the snapshot
    for _, w in ipairs(wins) do
      local seen = false
      for _, o in ipairs(ordered) do
        if o == w then seen = true; break end
      end
      if not seen then ordered[#ordered + 1] = w end
    end
  else
    ordered = sortByMRU(wins)
  end

  -- Find the next window after the one we last cycled to
  local nextWin = nil
  local lastId = state and state.lastId

  if lastId then
    local found = false
    for _, w in ipairs(ordered) do
      if found then nextWin = w; break end
      if w:id() == lastId then found = true end
    end
  end

  -- Wrap around or pick first non-focused window
  if not nextWin then
    local focused = app:focusedWindow()
    for _, w in ipairs(ordered) do
      if not focused or w ~= focused then nextWin = w; break end
    end
  end

  if not nextWin then return end

  log:i('cycling to window', nextWin:id(), 'of', appId)
  nextWin:focus()

  local ids = {}
  for _, w in ipairs(ordered) do ids[#ids + 1] = w:id() end
  cycleState[stateKey] = { time = now, windowIds = ids, lastId = nextWin:id() }
end

-- ── Keybindings ───────────────────────────────────────────────────────────────

local ok, mappings = pcall(require, 'hyper-apps')
if not ok then
  log:e('hyper-apps.lua not found — no shortcuts registered')
  return
end

local modifier = { 'shift', 'ctrl', 'alt', 'cmd' }

for _, mapping in ipairs(mappings) do
  local key           = mapping[1]
  local appId         = mapping[2]
  local windowCycleId = mapping[3]
  hs.hotkey.bind(modifier, key, function()
    openApplication(appId, windowCycleId)
  end)
end

return { openApplication = openApplication }
