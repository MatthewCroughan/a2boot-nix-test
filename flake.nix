# http://apple2.guidero.us/doku.php/projects/appleshare_boot_blocks
# http://apple2.guidero.us/doku.php/mg_notes/apple_ii_atlk/iigs_netboot
# https://github.com/Netatalk/netatalk/blob/12e30192b85daf653f682e8eee30a73d06bf2611/contrib/a2boot/meson.build#L8-L13
# http://apple2.guidero.us/doku.php/mg_notes/apple_ii_atlk/iigs_netboot
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.netatalk = let

          iigsblocks = pkgs.fetchurl {
            url = "http://apple2.guidero.us/lib/exe/fetch.php/projects/prodos16_image.203.mgfizzy.gz";
            hash = "sha256-zTJqm/RUGfAF9JiuEGWJlp7+Q5U3BHs/q3xSWIU4AKc=";
          };
          iieblocks = pkgs.fetchurl {
            url = "http://apple2.guidero.us/lib/exe/fetch.php/projects/iie.bootblks.242.gz";
            hash = "sha256-nADACCKFSyoIaJzO4UsBDVKpwRsoHd3Zk2j7sP/UsiE=";
          };
          bootBlocks = pkgs.runCommand "bootBlocks" {} ''
            mkdir -p $out/etc/a2boot
            zcat ${iigsblocks} > "$out/etc/a2boot/ProDOS16 Boot Blocks"
            zcat ${iigsblocks} > "$out/etc/a2boot/ProDOS16 Image"
            zcat ${iieblocks} > "$out/etc/a2boot/Apple :2f:2fe Boot Blocks"
          '';
        in pkgs.symlinkJoin {
          name = "netatalk-with-bootblocks";
          paths = [
            pkgs.netatalk
            bootBlocks
          ];
        };
      };
    };
}
