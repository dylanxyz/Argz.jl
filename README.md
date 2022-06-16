# Argz.jl

[![Docs][docs-badge]][docs-url] [![Tests][tests-badge]][tests-url]

**Argz** is a simple command-line argument parser for julia.

## Installation

Argz is not yet in the julia public registry, but you can 
install directly from this repo:

- From the command line

```shell
julia -e 'import Pkg; Pkg.pkg"add https://github.com/dylanxyz/Argz.jl"'
```

- From the julia REPL

```julia
julia> ]
pkg> add https://github.com/dylanxyz/Argz.jl
```

## Documentation

To learn how to use this package, see the [documentation][docs-url].

[tests-badge]: https://github.com/dylanxyz/Argz.jl/actions/workflows/RunTests.yaml/badge.svg
[tests-url]: https://github.com/dylanxyz/Argz.jl/actions/workflows/RunTests.yaml
[docs-badge]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-url]: https://dylanxyz.github.io/Argz.jl/latest/
