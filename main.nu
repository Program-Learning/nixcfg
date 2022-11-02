#!/usr/bin/env nu

let-env CACHIX_CACHE = (
  if "CACHIX_CACHE" in ($env | transpose | get column0) { $env.CACHIX_CACHE }
  else "colemickens"
)
def header [ color: string text: string spacer=" ": string ] {
  let text = $"($text) "
  let header = $" ($text | str rpad -c $spacer -l 80)"
  print -e $"(ansi $color)($header)(ansi reset)"
}

def buildDrv [ drvRef: string ] {
  print -e (header yellow_reverse $"eval [($drvRef)]")
  let evalJobs = (
    ^nix-eval-jobs
      --flake $"~/code/nixcfg#($drvRef)"
      --check-cache-status
        | each { |it| ( $it | from json ) }
  )
  print -e $evalJobs
  
  print -e (header blue_reverse $"build [($drvRef)]")
  print -e ($evalJobs
    | where isCached == false
    | select name drvPath outputs)

  $evalJobs
    | where isCached == false
    | each { |drv|
      ^nix build $drv.drvPath
      null
    }

  print -e (header green_reverse $"cache [($drvRef)]")
  $evalJobs | each { |drv|
    $drv.outputs | each { |outPath|
      if ($outPath.out | path exists) {
        ($outPath.out | ^cachix push $env.CACHIX_CACHE)
        null
      }
    }
  }

  let output = ($evalJobs | select name outputs)
  print -e ($output | flatten)
  
  $output
}

def deployHost [ host: string ] {
  let jobs = buildDrv $"toplevels.($host)" 
  let topout = ($jobs | flatten | first)
  let toplevel = ($topout | get out)
  let target = (tailscale ip --6 $host | str trim)
  
  print -e (header purple_reverse $"activate [($host)]")
  print -e $topout
  ^ssh $"cole@($target)" $"sudo nix build --profile /nix/var/nix/profiles/system \"($toplevel)\""
  ^ssh $"cole@($target)" $"sudo \"($toplevel)/bin/switch-to-configuration\" switch"
}

def "main deploy" [ host = "_pc": string ] {
  print -e (header light_yellow_reverse $"deploy_list [($host)]")

  let hosts = (if ($host | str starts-with "_") {
    let host_class = ($host | str trim --char "_")
    (^nix eval --json $".#nixosConfigs.($host_class)" --apply "x: builtins.attrNames x" | from json)
  } else {
    [ $host ]
  })
  
  print -e $hosts
  
  $hosts | each { |host| 
    print -e ""
    print -e (header dark_gray_reverse $" ")
    print -e (header dark_gray_reverse $" ")
    print -e ""
    deployHost $host
    null
  }
}

def "main inputup" [] {
  print -e (header yellow_reverse "inputup")
  let srcdirs = [
    $"($env.HOME)/code/nixpkgs/master"
    $"($env.HOME)/code/nixpkgs/cmpkgs"
    $"($env.HOME)/code/nixpkgs/cmpkgs-cross-riscv64"
    $"($env.HOME)/code/nixpkgs/cmpkgs-cross-armv6l"
    $"($env.HOME)/code/home-manager/master"
    $"($env.HOME)/code/home-manager/cmhm"
    $"($env.HOME)/code/tow-boot/development"
    $"($env.HOME)/code/tow-boot/rpi"
    $"($env.HOME)/code/tow-boot/radxa-zero"
    $"($env.HOME)/code/tow-boot/visionfive"
    $"($env.HOME)/code/nixpkgs-wayland/master"
    $"($env.HOME)/code/flake-firefox-nightly"
    $"($env.HOME)/code/mobile-nixos/master"
    $"($env.HOME)/code/mobile-nixos/blueline-mainline-only--2022-08"
    $"($env.HOME)/code/mobile-nixos/openstick"
    $"($env.HOME)/code/linux/master"
  ]

  $srcdirs | each { |s|
    if ($s | path exists) {
      print -e (header yellow $"inputup: ($s)" "-")
      # again, I have to put parens here to get it to work
      (do -i {
        print -e (header yellow $"inputup: ($s) [rebase --abort]" "-")
        ^git -C $"($s)" rebase --abort
      })
      (do -c {
        print -e (header yellow $"inputup: ($s) [pull --rebase]" "-")
        ^git -C $"($s)" pull --rebase
      })
      (do -c {
        print -e (header yellow $"inputup: ($s) [push origin HEAD -f]" "-")
        ^git -C $"($s)" push origin HEAD -f
      })
      null
    } else {
      print -e $"skipping ($s)"
      null
    }
  }
}

def "main pkgup" [] {
  print -e (header yellow_reverse "pkgup")
  do -c { ./pkgs/pkgs-update.nu }
}

def "main rpiup" [] {
  print -e (header yellow_reverse "rpiup")
  do -c { ./misc/rpi/rpi-update.nu }
}
def "main lockup" [] {
  print -e (header yellow_reverse "lockup")
  do -c { ^nix flake lock --recreate-lock-file --commit-lock-file }
}

def "main up" [] {
  print -e (header red_reverse "loopup" "▒")

  main inputup
  main pkgup
  main rpiup
  main lockup

  main deploy _pc
}

def "main loopup" [] { main up; sleep 3sec; main loopup }

def main [] {
  print -e "commands: [loopup, up]"
}
