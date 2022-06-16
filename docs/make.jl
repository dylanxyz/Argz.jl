using Documenter
using Argz

makedocs(
    sitename = "Argz",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "Usage" => "usage.md",
        "Example" => "example.md",
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/dylanxyz/Argz.jl.git"
)
