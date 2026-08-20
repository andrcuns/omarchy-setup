hl.window_rule({
    name = "floating-term",
    match = { class = "Terminal" },

    float = true,
    stay_focused = true,
    no_initial_focus = true,
    animation = "popin",
})

hl.bind(
    "CTRL + return",
    hl.dsp.exec_cmd("~/.config/hypr/terminal.sh"),
    { description = "Pop-Up Terminal" }
)
