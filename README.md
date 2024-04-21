# radxa-zero3w
Repo with automated image builds for the [Radxa Zero 3W](https://docs.radxa.com/en/zero/zero3)

They may work on the `E` as well but haven't been tested.

## Customizations
Armbian customizations are located in the armbian branch. Currently it just fixes the wifi driver but will have more in the future.

## Usage
If you want to create your own images, you can fork this repo and use the github actions (located in ./github/workflows or the actions tab) to create them.

You'll want to run the armbian_custom action to build and create a release. You can specify kernel, release, and ui type by modifying the matrix [here](https://github.com/SelfhostedPro/radxa-zero3w/blob/d32b9ff85971586f62d26c120cc532d3b5bb3b0f/.github/workflows/armbian_custom.yml#L33-L43)

You can customize images by using the `armbian` branch according to official armbian docs fairly easily.