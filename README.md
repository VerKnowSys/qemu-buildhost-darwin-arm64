# Wham am I looking at?

The goal of this project is to have an all-in-one repository,
that will contain all the necessary info and scripts on how to:

* Run modern Qemu version (6.1) with HVF acceleration on M1 / M2 CPUs on macOS 12+

* Use bridged networking by default (which is not supported by Qemu 6.1 while HVF is not supported on the latest Qemu 8+)


# Qemu installation

Prebuilt Qemu is available via the [Sofin](https://github.com/VerKnowSys/sofin) (which is supported on modern macOS versions since version 1.10).
Installation of all the software here requires *NO* root access.

```zsh
# install Qemu-m1 build using Sofin:
s i Qemu-m1
```

The build contains required entitlements (to allow access to the Apple Hypervisor Framework)
for all the qemu-system* binaries.


# Enable Qemu bridging via the vmnet trick

To make a long story short, you have to follow the instructions from the https://github.com/lima-vm/socket_vmnet/tree/master#qemu

While the instruction is quite precise, it lacks a couple of important things.
My full instruction as a shell script is below:

```zsh
sudo mkdir -p /opt/socket_vmnet
cd /tmp

# fetch prebuilt archive
curl -OLs "https://github.com/lima-vm/socket_vmnet/releases/download/v1.1.2/socket_vmnet-1.1.2-arm64.tar.gz"

# Unpack is tricky for archive that path starts with "."
mkdir opt
tar xf socket_vmnet-1.1.2-arm64.tar.gz --directory=./opt/
cd opt

# Install files to the destination path under /opt
sudo cp -R opt/socket_vmnet/ /opt/socket_vmnet

# Remove quarantine flag. Otherwise macOS will refuse to run the binaries
sudo xattr -d com.apple.quarantine /opt/socket_vmnet/bin/socket_vmnet
sudo xattr -d com.apple.quarantine /opt/socket_vmnet/bin/socket_vmnet_client

# Set sudo exception for our daemon
cat <<EOF | sudo tee /etc/sudoers.d/socket_vmnet
# Entries for bridged mode (en0)
%staff ALL=(root:root) NOPASSWD:NOSETENV: /opt/socket_vmnet/bin/socket_vmnet --vmnet-mode=bridged --vmnet-interface=en0 /var/run/socket_vmnet.bridged.en0
EOF

# Setup our bridge launch daemon
cat <<EOF | sudo tee /Library/LaunchDaemons/io.github.lima-vm.socket_vmnet.bridged.en0.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- make install: no by default -->
<plist version="1.0">
        <dict>
                <key>Label</key>
                <string>io.github.lima-vm.socket_vmnet.bridged.en0</string>
                <key>Program</key>
                <string>/opt/socket_vmnet/bin/socket_vmnet</string>
                <key>ProgramArguments</key>
                <array>
                        <string>/opt/socket_vmnet/bin/socket_vmnet</string>
                        <string>--vmnet-mode=bridged</string>
                        <string>--vmnet-interface=en0</string>
                        <string>/var/run/socket_vmnet.bridged.en0</string>
                </array>
                <key>StandardErrorPath</key>
                <string>/var/log/socket_vmnet/bridged.en0.stderr</string>
                <key>StandardOutPath</key>
                <string>/var/log/socket_vmnet/bridged.en0.stdout</string>
                <key>RunAtLoad</key>
                <true />
                <key>UserName</key>
                <string>root</string>
        </dict>
</plist>
EOF

# start the daemons
sudo launchctl bootstrap system /Library/LaunchDaemons/io.github.lima-vm.socket_vmnet.bridged.en0.plist
sudo launchctl enable system/io.github.lima-vm.socket_vmnet.bridged.en0
sudo launchctl kickstart -kp system/io.github.lima-vm.socket_vmnet.bridged.en0

```

Note, that "by design", vmnet operations on Darwin require root-level access, (for the socket_vmnet launch daemon).
