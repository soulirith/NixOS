{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ryzenadj
    linuxPackages.cpupower

    (writeShellScriptBin "mode-quiet" ''
      echo "Activating Quiet Profile..."
      doas ${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=65 --fast-limit=15000 --slow-limit=12000
      doas ${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g powersave
      doas sh -c "echo 0 > /sys/devices/system/cpu/cpufreq/boost"
      echo "System locked to silent baseline (65°C Cap | No Boost | 15W TDP)."
    '')

    (writeShellScriptBin "mode-perf" ''
      echo "Activating Performance Profile..."
      doas sh -c "echo 1 > /sys/devices/system/cpu/cpufreq/boost"
      doas ${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g performance
      doas ${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=85 --fast-limit=45000 --slow-limit=35000
      echo "Full performance unlocked (85°C Cap | Boost Enabled | 45W TDP)."
    '')
  ];
}
