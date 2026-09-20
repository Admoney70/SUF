# Shadowed Unit Frames (Classic)

Shadowed Unit Frames for the Classic clients, based on the `classic` branch of
[Nevcairiel/ShadowedUnitFrames](https://github.com/Nevcairiel/ShadowedUnitFrames),
updated for the current Classic Era, Anniversary and MoP Classic builds.

## Installing

The addon is **two** folders, and they have to come from the same build:

* `ShadowedUnitFrames` - the addon itself
* `ShadowedUF_Options` - the configuration UI, which is the `options` folder of
  this repository renamed

Mixing a new `ShadowedUnitFrames` with an older `ShadowedUF_Options` from a
previous install produces errors in `config.lua` when opening the options, as the
two halves expect different internals of each other. Always replace both.

This repository does not contain the libraries the addon depends on (LibStub,
Ace3, LibSharedMedia and so on), they are pulled in when the addon is packaged.
So rather than copying the repository into your AddOns folder by hand:

1. Open the [Build workflow](../../actions/workflows/build.yml) and pick the most
   recent run.
2. Download the `ShadowedUnitFrames` artifact and unzip it.
3. Delete any existing `ShadowedUnitFrames` and `ShadowedUF_Options` folders from
   `World of Warcraft/<flavor>/Interface/AddOns`, then copy both folders from the
   zip in their place.

## Development

`luacheck .` runs the same lint the CI does, and must be clean.
