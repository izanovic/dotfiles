# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

# --- Automatic PATH Configuration (Based on Bash's PATH) ---

let bash_path_string = (bash -c "echo $PATH" | str trim)
let inherited_paths_from_bash = ($bash_path_string | split row ":")

let nu_specific_paths = [
    # ($env.HOME | path join ".my_nu_tools_dir") # Example
    # You might not need anything here, but it's good for extensibility.
]

$env.PATH = (
    $inherited_paths_from_bash
    | prepend $nu_specific_paths
    | flatten
    | uniq
)

# --- End Automatic PATH Configuration ---

$env.config.edit_mode = 'vi'
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

$env.config.show_banner = false


mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
