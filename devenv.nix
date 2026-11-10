{ pkgs, lib, config, inputs, ... }:

{
	# https://devenv.sh/packages/
	packages = [ pkgs.git ];

	# https://devenv.sh/languages/
	languages.zig = {
		enable = true;
		version = "0.15.2";
	};
	languages.c.enable = true;
}
