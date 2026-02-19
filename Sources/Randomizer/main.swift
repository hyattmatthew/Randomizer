import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Hide from Dock (agent app — menu bar only)
app.setActivationPolicy(.accessory)

app.run()
