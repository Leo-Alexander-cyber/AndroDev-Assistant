<#
.SYNOPSIS
ADB Wireless Manager Release Generator Script
.DESCRIPTION
Generates release files and documentation for ADB Wireless Manager
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Version = "1.0.0",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "$PSScriptRoot\release\$Version"
)

$ErrorActionPreference = "Stop"

Write-Host "=== ADB Wireless Manager Release Generator ==="
Write-Host "Version: $Version"
Write-Host "Output Directory: $OutputDir"
Write-Host "======================================="

# Set project root
$PROJECT_ROOT = $PSScriptRoot

# Create output directories
$BIN_DIR = Join-Path -Path $OutputDir -ChildPath "bin"
$INCLUDE_DIR = Join-Path -Path $OutputDir -ChildPath "include"
$DOCS_DIR = Join-Path -Path $OutputDir -ChildPath "docs"
$EXAMPLES_DIR = Join-Path -Path $OutputDir -ChildPath "examples"
$RESOURCES_DIR = Join-Path -Path $OutputDir -ChildPath "resources"

# Create directories
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
New-Item -Path $BIN_DIR -ItemType Directory -Force | Out-Null
New-Item -Path $INCLUDE_DIR -ItemType Directory -Force | Out-Null
New-Item -Path $DOCS_DIR -ItemType Directory -Force | Out-Null
New-Item -Path $EXAMPLES_DIR -ItemType Directory -Force | Out-Null
New-Item -Path $RESOURCES_DIR -ItemType Directory -Force | Out-Null

Write-Host "Creating release structure..."

# Copy include files
Write-Host "Copying include files..."
Copy-Item -Path "$PROJECT_ROOT\include\*" -Destination $INCLUDE_DIR -Recurse -Force

# Copy resource files
Write-Host "Copying resource files..."
Copy-Item -Path "$PROJECT_ROOT\resources\*" -Destination $RESOURCES_DIR -Recurse -Force

# Copy example files (if they exist)
if (Test-Path -Path "$PROJECT_ROOT\examples") {
    Write-Host "Copying example files..."
    Copy-Item -Path "$PROJECT_ROOT\examples\*" -Destination $EXAMPLES_DIR -Recurse -Force
}

# Generate documentation
Write-Host "Generating documentation..."

# Create README.md
$README_CONTENT = @"
# ADB Wireless Manager

Production-grade ADB Wireless Connection Manager for Android devices.

## Features

- Device discovery via UDP broadcast and mDNS
- Secure device pairing mechanism
- Connection maintenance with auto-reconnect
- Priority-based command scheduling
- Async non-blocking IO for large file transfers
- Security mechanisms including encryption and certificate management
- State persistence
- USB support

## Requirements

- Qt 6.5+
- libusb-1.0
- C++17 compiler

## Installation

### Windows

1. Download the latest release from [GitHub Releases](https://github.com/TraeAI/ADBWirelessManager/releases)
2. Run the installer executable
3. Follow the installation wizard

### Linux

```bash
sudo apt-get install libqt6core6 libqt6network6 libusb-1.0-0
sudo dpkg -i adbwirelessmanager_${VERSION}_amd64.deb
```

### macOS

```bash
brew install qt@6 libusb
brew install --cask adbwirelessmanager
```

## Usage

```cpp
#include <adbwireless/adbwirelessmanager.h>

using namespace AdbWireless;

int main() {
    // Initialize the manager
    AdbWirelessManager* manager = AdbWirelessManager::instance();
    if (!manager->initialize()) {
        return 1;
    }
    
    // Start scanning for devices
    manager->startScan();
    
    // Connect to a device
    // ...
    
    // Execute a command
    // ...
    
    // Deinitialize
    manager->deinitialize();
    
    return 0;
}
```

## Documentation

- [API Reference](docs/api_reference.md)
- [User Manual](docs/user_manual.md)
- [Development Guide](docs/development_guide.md)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete history of changes.

## License

MIT License
"@

$README_CONTENT | Out-File -FilePath "$OutputDir\README.md" -Encoding UTF8

# Create CHANGELOG.md
$CHANGELOG_CONTENT = @"
# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - $(Get-Date -Format "yyyy-MM-dd")

### Added
- Initial release
- Device discovery via UDP broadcast and mDNS
- Secure device pairing mechanism
- Connection maintenance with auto-reconnect
- Priority-based command scheduling
- Async non-blocking IO for large file transfers
- Security mechanisms including encryption and certificate management
- State persistence
- USB support

### Changed
- None

### Fixed
- None
"@

$CHANGELOG_CONTENT | Out-File -FilePath "$OutputDir\CHANGELOG.md" -Encoding UTF8

# Create LICENSE.md
$LICENSE_CONTENT = @"
MIT License

Copyright (c) $(Get-Date -Format "yyyy") TraeAI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@

$LICENSE_CONTENT | Out-File -FilePath "$OutputDir\LICENSE.md" -Encoding UTF8

# Create release notes
$RELEASE_NOTES_CONTENT = @"
# ADB Wireless Manager $Version Release Notes

## Overview

ADB Wireless Manager is a production-grade wireless connection manager for Android devices, providing a robust and secure way to connect and manage Android devices over WiFi.

## Key Features

- **Device Discovery**: Automatically discovers nearby Android devices via UDP broadcast and mDNS
- **Secure Pairing**: Uses strong encryption and pairing codes to ensure secure connections
- **Reliable Connection**: Maintains connections with auto-reconnect using exponential backoff
- **Efficient Command Execution**: Priority-based command scheduling with queue management
- **Fast File Transfer**: Async non-blocking IO for large file transfers (1GB+)
- **Comprehensive Security**: Device verification, optional encryption, and permission checks
- **Persistent State**: Remembers device connections and settings across sessions
- **USB Support**: Optional USB connection handling for devices without wireless capabilities

## System Requirements

- Windows 10/11, macOS 10.15+, or Linux
- Qt 6.5+ runtime libraries
- libusb-1.0 (for USB support)
- Android 10+ on target devices

## Installation

### Windows

1. Download the installer executable
2. Run the installer and follow the wizard
3. Launch ADB Wireless Manager from the Start menu

### Linux

```bash
sudo dpkg -i adbwirelessmanager_${VERSION}_amd64.deb
# or
sudo rpm -i adbwirelessmanager-${VERSION}-1.x86_64.rpm
```

### macOS

```bash
brew install --cask adbwirelessmanager
```

## Getting Started

1. Ensure your Android device is connected to the same network as your computer
2. Enable "Wireless debugging" in Developer options on your Android device
3. Launch ADB Wireless Manager
4. Click "Scan" to discover devices
5. Select a device and click "Pair"
6. Enter the pairing code displayed on your Android device
7. Once paired, click "Connect"
8. Start executing commands or transferring files

## Documentation

- [API Reference](docs/api_reference.md)
- [User Manual](docs/user_manual.md)
- [Development Guide](docs/development_guide.md)

## Support

For issues, questions, or contributions, please visit:
- GitHub: https://github.com/TraeAI/ADBWirelessManager
- Issues: https://github.com/TraeAI/ADBWirelessManager/issues
- Discussions: https://github.com/TraeAI/ADBWirelessManager/discussions

## License

MIT License
"@

$RELEASE_NOTES_CONTENT | Out-File -FilePath "$OutputDir\RELEASE_NOTES.md" -Encoding UTF8

# Create installation instructions
$INSTALL_INSTRUCTIONS_CONTENT = @"
# Installation Instructions

## Windows

1. Download the installer executable: `ADBWirelessManager-$Version-Setup.exe`
2. Double-click the installer to launch the installation wizard
3. Follow the on-screen instructions:
   - Choose installation directory (default: `C:\Program Files\ADBWirelessManager`)
   - Select components to install
   - Create desktop shortcut (optional)
4. Click "Install" to begin installation
5. Once installation is complete, click "Finish" to exit the wizard

## Linux

### Debian/Ubuntu

```bash
sudo dpkg -i adbwirelessmanager_${VERSION}_amd64.deb
sudo apt-get install -f  # Install dependencies
```

### Fedora/RHEL

```bash
sudo rpm -i adbwirelessmanager-${VERSION}-1.x86_64.rpm
```

### Arch Linux

```bash
sudo pacman -U adbwirelessmanager-${VERSION}-x86_64.pkg.tar.zst
```

## macOS

### Homebrew

```bash
brew install --cask adbwirelessmanager
```

### DMG Installation

1. Download the DMG file: `ADBWirelessManager-$Version.dmg`
2. Double-click the DMG file to mount it
3. Drag the ADBWirelessManager icon to the Applications folder
4. Eject the DMG file
5. Launch ADBWirelessManager from Launchpad or Spotlight

## Building from Source

### Prerequisites

- CMake 3.16+
- C++17 compiler
- Qt 6.5+ (Core, Network modules)
- libusb-1.0 (for USB support)

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/TraeAI/ADBWirelessManager.git
   cd ADBWirelessManager
   ```

2. Create build directory:
   ```bash
   mkdir build && cd build
   ```

3. Configure with CMake:
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Release
   ```

4. Build:
   ```bash
   make -j$(nproc)
   ```

5. Install:
   ```bash
   sudo make install
   ```

## Verification

To verify the installation was successful:

1. Launch ADB Wireless Manager
2. Click "Scan" to discover devices
3. You should see a list of nearby Android devices

## Troubleshooting

### Windows

- **Missing DLL errors**: Install the Visual C++ Redistributable for Visual Studio 2022
- **USB not working**: Install the latest USB drivers for your device
- **Firewall blocking**: Add ADBWirelessManager to the Windows Firewall exceptions

### Linux

- **Permission denied**: Run with sudo or add your user to the `plugdev` group
- **Missing dependencies**: Install required packages using your package manager
- **SELinux issues**: Adjust SELinux policies or temporarily disable it

### macOS

- **Security warnings**: Go to System Preferences > Security & Privacy > General and click "Open Anyway"
- **USB not recognized**: Install HoRNDIS or other USB drivers if needed

## Uninstallation

### Windows

1. Open Control Panel > Programs > Programs and Features
2. Select "ADBWirelessManager"
3. Click "Uninstall" and follow the prompts

### Linux

```bash
sudo apt-get remove adbwirelessmanager  # Debian/Ubuntu
sudo dnf remove adbwirelessmanager  # Fedora/RHEL
sudo pacman -R adbwirelessmanager  # Arch Linux
```

### macOS

1. Drag ADBWirelessManager from Applications folder to Trash
2. Empty Trash
"@

$INSTALL_INSTRUCTIONS_CONTENT | Out-File -FilePath "$OutputDir\INSTALL.md" -Encoding UTF8

# Create simple example
$EXAMPLE_CONTENT = @"
#include <adbwireless/adbwirelessmanager.h>
#include <QCoreApplication>
#include <QDebug>

using namespace AdbWireless;

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    // Initialize the ADB Wireless Manager
    AdbWirelessManager* manager = AdbWirelessManager::instance();
    if (!manager->initialize()) {
        qCritical() << "Failed to initialize ADB Wireless Manager";
        return 1;
    }
    
    qInfo() << "ADB Wireless Manager initialized successfully";
    
    // Connect to signals
    QObject::connect(manager, &AdbWirelessManager::deviceDiscovered, [](AdbDevice* device) {
        qInfo() << "Device discovered:" << device->serial() << "(" << device->model() << ")";
        qInfo() << "IP Address:" << device->ipAddress().toString();
        qInfo() << "Port:" << device->port();
        qInfo() << "Connected:" << (device->connectionState() == ConnectionState::Connected ? "Yes" : "No");
        qInfo() << "Paired:" << (device->isPaired() ? "Yes" : "No");
    });
    
    QObject::connect(manager, &AdbWirelessManager::deviceConnected, [](AdbDevice* device) {
        qInfo() << "Device connected:" << device->serial();
        
        // Example: Execute a command
        AdbCommand* command = manager->executeCommand(device, "shell getprop ro.build.version.release");
        if (command) {
            QObject::connect(command, &AdbCommand::completed, [](AdbCommand* cmd) {
                qInfo() << "Command completed:" << cmd->command();
                qInfo() << "Result:" << cmd->result();
            });
            
            QObject::connect(command, &AdbCommand::failed, [](AdbCommand* cmd) {
                qWarning() << "Command failed:" << cmd->command();
                qWarning() << "Error:" << cmd->error().message();
            });
        }
    });
    
    QObject::connect(manager, &AdbWirelessManager::deviceDisconnected, [](AdbDevice* device, const AdbErrorInfo& error) {
        qInfo() << "Device disconnected:" << device->serial();
        if (error.errorCode() != AdbError::NoError) {
            qWarning() << "Disconnect reason:" << error.message();
        }
    });
    
    // Start scanning for devices
    qInfo() << "Starting device scan...";
    manager->startScan();
    
    // Run for 10 seconds
    QTimer::singleShot(10000, [&app, manager]() {
        qInfo() << "Stopping device scan...";
        manager->stopScan();
        
        qInfo() << "Deinitializing ADB Wireless Manager...";
        manager->deinitialize();
        
        app.quit();
    });
    
    return app.exec();
}
"@

New-Item -Path "$EXAMPLES_DIR\simple_example.cpp" -ItemType File -Force | Out-Null
$EXAMPLE_CONTENT | Out-File -FilePath "$EXAMPLES_DIR\simple_example.cpp" -Encoding UTF8

# Create CMakeLists.txt for example
$EXAMPLE_CMAKE_CONTENT = @"
cmake_minimum_required(VERSION 3.16)

project(SimpleExample)

find_package(Qt6 REQUIRED COMPONENTS Core Network)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${Qt6Core_INCLUDE_DIRS}
    ${Qt6Network_INCLUDE_DIRS}
)

add_executable(${PROJECT_NAME} simple_example.cpp)

target_link_libraries(${PROJECT_NAME}
    Qt6::Core
    Qt6::Network
    ADBWirelessManager
)
"@

$EXAMPLE_CMAKE_CONTENT | Out-File -FilePath "$EXAMPLES_DIR\CMakeLists.txt" -Encoding UTF8

# Create API reference placeholder
$API_REF_CONTENT = @"
# API Reference

## AdbWirelessManager

### Overview

The `AdbWirelessManager` class is the main entry point for the ADB Wireless Manager library.

### Methods

#### initialize()
```cpp
bool initialize();
```
Initializes the ADB Wireless Manager. Returns `true` if successful, `false` otherwise.

#### deinitialize()
```cpp
void deinitialize();
```
Deinitializes the ADB Wireless Manager, freeing all resources.

#### startScan()
```cpp
void startScan();
```
Starts scanning for nearby Android devices.

#### stopScan()
```cpp
void stopScan();
```
Stops scanning for devices.

#### connectDevice(AdbDevice* device)
```cpp
void connectDevice(AdbDevice* device);
```
Connects to the specified device.

#### disconnectDevice(AdbDevice* device)
```cpp
void disconnectDevice(AdbDevice* device);
```
Disconnects from the specified device.

#### executeCommand(AdbDevice* device, const QString& command, CommandPriority priority = CommandPriority::Normal, int timeoutMs = 30000)
```cpp
AdbCommand* executeCommand(AdbDevice* device, const QString& command, CommandPriority priority = CommandPriority::Normal, int timeoutMs = 30000);
```
Executes a command on the specified device.

#### pairDevice(AdbDevice* device, const QString& pairingCode)
```cpp
void pairDevice(AdbDevice* device, const QString& pairingCode);
```
Pairs with the specified device using the given pairing code.

### Signals

#### deviceDiscovered(AdbDevice* device)
```cpp
void deviceDiscovered(AdbDevice* device);
```
Emitted when a new device is discovered.

#### deviceConnected(AdbDevice* device)
```cpp
void deviceConnected(AdbDevice* device);
```
Emitted when a device is successfully connected.

#### deviceDisconnected(AdbDevice* device, const AdbErrorInfo& error = AdbErrorInfo())
```cpp
void deviceDisconnected(AdbDevice* device, const AdbErrorInfo& error = AdbErrorInfo());
```
Emitted when a device is disconnected.

#### commandCompleted(AdbCommand* command)
```cpp
void commandCompleted(AdbCommand* command);
```
Emitted when a command is completed successfully.

#### commandFailed(AdbCommand* command, const AdbErrorInfo& error)
```cpp
void commandFailed(AdbCommand* command, const AdbErrorInfo& error);
```
Emitted when a command fails.

## AdbDevice

### Overview

The `AdbDevice` class represents a single Android device.

### Properties

- `serial`: Device serial number
- `model`: Device model name
- `manufacturer`: Device manufacturer
- `product`: Device product name
- `version`: Android version
- `type`: Device type (Phone, Tablet, TV, etc.)
- `connectionType`: Connection type (USB or Wireless)
- `connectionState`: Connection state (Disconnected, Connecting, Connected, Error)
- `ipAddress`: Device IP address
- `port`: ADB port
- `isPaired`: Whether the device is paired
- `isAuthorized`: Whether the device is authorized
- `lastSeen`: Last time the device was seen

### Methods

#### toString()
```cpp
QString toString() const;
```
Returns a string representation of the device.

#### toJson()
```cpp
QJsonObject toJson() const;
```
Converts the device to a JSON object.

#### updateFrom(const AdbDevice& other)
```cpp
void updateFrom(const AdbDevice& other);
```
Updates the device from another device object.

## AdbCommand

### Overview

The `AdbCommand` class represents a single ADB command.

### Properties

- `command`: Command string
- `device`: Target device
- `priority`: Command priority
- `timeoutMs`: Command timeout
- `state`: Command state
- `result`: Command result
- `error`: Command error information
- `attempts`: Number of attempts made

### Methods

#### execute()
```cpp
void execute();
```
Executes the command.

#### cancel()
```cpp
void cancel();
```
Cancels the command.

#### retry()
```cpp
void retry();
```
Retries the command.

## ConnectionState

### Values

- `Disconnected`: Device is not connected
- `Connecting`: Device is connecting
- `Connected`: Device is connected
- `Error`: Connection error occurred

## CommandPriority

### Values

- `Low`: Low priority command
- `Normal`: Normal priority command
- `High`: High priority command
- `Critical`: Critical priority command

## AdbError

### Values

- `NoError`: No error
- `InvalidArgument`: Invalid argument
- `NotInitialized`: Not initialized
- `NotConnected`: Not connected
- `NotPaired`: Not paired
- `ConnectionFailed`: Connection failed
- `CommandFailed`: Command failed
- `Timeout`: Operation timed out
- `InternalError`: Internal error
- `PermissionDenied`: Permission denied
- `DeviceNotFound`: Device not found
- `UsbError`: USB error
- `NetworkError`: Network error
- `EncryptionError`: Encryption error

## AdbErrorInfo

### Overview

The `AdbErrorInfo` class contains detailed error information.

### Properties

- `errorCode`: Error code
- `message`: Error message
- `detail`: Detailed error information

### Methods

#### toString()
```cpp
QString toString() const;
```
Returns a string representation of the error.
"@

New-Item -Path "$DOCS_DIR\api_reference.md" -ItemType File -Force | Out-Null
$API_REF_CONTENT | Out-File -FilePath "$DOCS_DIR\api_reference.md" -Encoding UTF8

# Create user manual placeholder
$USER_MANUAL_CONTENT = @"
# User Manual

## Introduction

ADB Wireless Manager is a powerful tool for managing Android devices wirelessly. This manual will guide you through the installation, setup, and usage of the software.

## Installation

### Windows

1. Download the installer executable from the official website
2. Double-click the installer to launch it
3. Follow the on-screen instructions to complete the installation
4. Launch ADB Wireless Manager from the Start menu

### macOS

1. Download the DMG file from the official website
2. Double-click the DMG file to mount it
3. Drag the ADB Wireless Manager icon to the Applications folder
4. Eject the DMG file
5. Launch ADB Wireless Manager from Launchpad or Spotlight

### Linux

1. Download the appropriate package for your distribution
2. Install using your package manager
3. Launch ADB Wireless Manager from the application menu

## Setup

### Android Device Preparation

1. Enable Developer Options on your Android device:
   - Go to Settings > About Phone
   - Tap Build Number 7 times
   - Developer Options will now be available in Settings

2. Enable Wireless Debugging:
   - Go to Settings > Developer Options
   - Enable "Wireless debugging"
   - Tap "Allow wireless debugging on this network"
   - You may be prompted to allow access, tap "Allow"

### Computer Setup

1. Ensure your computer is connected to the same network as your Android device
2. Launch ADB Wireless Manager
3. Click the "Scan" button to discover nearby devices

## Usage

### Device Discovery

1. Click the "Scan" button to start scanning for devices
2. Wait for devices to appear in the list
3. Devices will be displayed with their serial number, model, IP address, and connection status

### Device Pairing

1. Select a device from the list
2. Click the "Pair" button
3. Enter the pairing code displayed on your Android device
4. Click "OK" to complete pairing
5. The device will now show as "Paired"

### Connecting to Devices

1. Select a paired device from the list
2. Click the "Connect" button
3. Wait for the connection to be established
4. The device will now show as "Connected"

### Executing Commands

1. Select a connected device from the list
2. Enter a command in the command input field
3. Select the command priority (Low, Normal, High, Critical)
4. Click "Execute" to run the command
5. The command result will be displayed in the output area

### File Transfer

1. Select a connected device from the list
2. Click the "File Transfer" button
3. Select "Push" to send files to the device, or "Pull" to receive files from the device
4. Select the local file (for Push) or remote file (for Pull)
5. Enter the destination path
6. Click "Transfer" to start the transfer
7. Monitor the transfer progress in the progress bar

### Managing Devices

1. **Refresh**: Click the "Refresh" button to update the device list
2. **Disconnect**: Click "Disconnect" to disconnect from a device
3. **Forget**: Click "Forget" to remove a device from the list and clear pairing information
4. **Auto-reconnect**: Enable auto-reconnect to automatically reconnect to devices when they become available

## Troubleshooting

### Device Not Found

- Ensure your device is connected to the same network as your computer
- Check that "Wireless debugging" is enabled on your device
- Ensure your firewall is not blocking ADB Wireless Manager
- Try restarting both your device and computer

### Pairing Failed

- Ensure you entered the correct pairing code
- Check that your device is still in pairing mode
- Try restarting wireless debugging on your device
- Ensure your computer and device are on the same network

### Connection Dropping

- Check your network connection stability
- Ensure your device is not in power saving mode
- Try increasing the auto-reconnect interval
- Check for firmware updates on your device

### Command Execution Failed

- Ensure the device is still connected
- Check that the command is valid for your device
- Verify that the device has the necessary permissions
- Try running the command with higher privileges

## Advanced Settings

### Connection Settings

- **Reconnect Delay**: Adjust the initial delay before attempting to reconnect
- **Max Reconnect Attempts**: Set the maximum number of reconnect attempts
- **Command Timeout**: Set the default timeout for commands
- **Auto-reconnect**: Enable/disable auto-reconnect

### Security Settings

- **Encryption**: Enable/disable connection encryption
- **Pairing Code Length**: Adjust the length of pairing codes
- **Certificate Validation**: Enable/disable certificate validation
- **Permission Prompt**: Enable/disable permission prompts

### Performance Settings

- **Max Concurrent Commands**: Set the maximum number of concurrent commands
- **Block Size**: Adjust the file transfer block size
- **Transfer Timeout**: Set the timeout for file transfers
- **Scan Interval**: Adjust the device scan interval

## Keyboard Shortcuts

- `Ctrl+S`: Start scan
- `Ctrl+D`: Stop scan
- `Ctrl+C`: Cancel current operation
- `Ctrl+E`: Execute command
- `Ctrl+P`: Pair device
- `Ctrl+O`: Connect device
- `Ctrl+F`: Disconnect device
- `Ctrl+T`: Start file transfer
- `Ctrl+L`: Clear output

## Frequently Asked Questions

### Q: Can I use ADB Wireless Manager with multiple devices?
A: Yes, ADB Wireless Manager supports managing multiple devices simultaneously.

### Q: Does ADB Wireless Manager require root access?
A: No, ADB Wireless Manager does not require root access on either your computer or Android device.

### Q: What Android versions are supported?
A: ADB Wireless Manager supports Android 10 and above.

### Q: Can I use ADB Wireless Manager with USB devices?
A: Yes, ADB Wireless Manager supports both wireless and USB connections.

### Q: Is ADB Wireless Manager open source?
A: Yes, ADB Wireless Manager is open source under the MIT License.

## Support

### Contact

- Website: https://github.com/TraeAI/ADBWirelessManager
- Email: support@adbwirelessmanager.com
- GitHub Issues: https://github.com/TraeAI/ADBWirelessManager/issues

### Reporting Issues

When reporting issues, please include:
- Your operating system and version
- ADB Wireless Manager version
- Android device model and version
- Steps to reproduce the issue
- Any error messages or logs

### Contributing

Contributions are welcome! Please visit the GitHub repository for more information on how to contribute.

## License

ADB Wireless Manager is licensed under the MIT License.
"@

New-Item -Path "$DOCS_DIR\user_manual.md" -ItemType File -Force | Out-Null
$USER_MANUAL_CONTENT | Out-File -FilePath "$DOCS_DIR\user_manual.md" -Encoding UTF8

# Create development guide placeholder
$DEV_GUIDE_CONTENT = @"
# Development Guide

## Overview

This guide provides information for developers who want to contribute to the ADB Wireless Manager project or integrate it into their own applications.

## Project Structure

```
ADBWirelessManager/
├── include/
│   └── adbwireless/       # Public header files
├── src/
│   └── adbwireless/       # Source files
├── resources/            # Resource files
├── examples/             # Example applications
├── tests/                # Unit tests
├── docs/                 # Documentation
├── CMakeLists.txt        # CMake build configuration
├── README.md             # Project README
├── LICENSE.md            # License file
└── CHANGELOG.md          # Changelog
```

## Building the Project

### Prerequisites

- CMake 3.16+
- C++17 compiler (GCC 9+, Clang 10+, MSVC 2019+)
- Qt 6.5+ with Core and Network modules
- libusb-1.0 (for USB support)

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/TraeAI/ADBWirelessManager.git
   cd ADBWirelessManager
   ```

2. Create build directory:
   ```bash
   mkdir build && cd build
   ```

3. Configure with CMake:
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Release
   ```

   For a debug build:
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Debug
   ```

   With USB support disabled:
   ```bash
   cmake .. -DENABLE_USB_SUPPORT=OFF
   ```

4. Build the project:
   ```bash
   make -j$(nproc)  # Linux/macOS
   # or
   cmake --build . --config Release --parallel $(nproc)  # Windows
   ```

5. Run tests (optional):
   ```bash
   make test
   # or
   ctest
   ```

6. Install (optional):
   ```bash
   sudo make install
   ```

## Running Tests

### Unit Tests

The project includes comprehensive unit tests. To run the tests:

```bash
cd build
test/unit_tests
```

### Integration Tests

Integration tests require one or more Android devices connected to the network:

```bash
cd build
test/integration_tests
```

### Coverage

To generate test coverage reports:

```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON
make -j$(nproc)
make test
make coverage_report
```

## Code Style

The project follows the Qt Coding Style with some modifications. Please ensure your code adheres to this style when contributing.

### C++ Style Guidelines

- Use 4 spaces for indentation
- Use camelCase for variables and functions
- Use PascalCase for classes and enums
- Use UPPER_CASE for constants
- Prefer `auto` for complex types
- Use `nullptr` instead of `NULL` or `0`
- Use smart pointers (`std::unique_ptr`, `std::shared_ptr`) instead of raw pointers when appropriate
- Follow RAII principles
- Avoid global variables
- Use `const` whenever possible
- Add Doxygen comments for all public API

### CMake Style Guidelines

- Use lowercase for CMake commands
- Use `target_*` commands instead of global commands
- Use `CMAKE_<LANG>_STANDARD` instead of `add_compile_options` for language standards
- Use `target_compile_features` instead of `add_definitions` for compiler features
- Use `find_package` instead of hardcoding paths
- Use `PROJECT_NAME` instead of hardcoded project name
- Use `CMAKE_INSTALL_*` variables for install paths

## Contributing

### Getting Started

1. Fork the repository on GitHub
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Run the tests to ensure they pass
5. Commit your changes with descriptive commit messages
6. Push your changes to your fork
7. Create a pull request

### Pull Request Guidelines

- Keep pull requests focused on a single feature or bug fix
- Include tests for new functionality
- Update documentation for changes to the API
- Follow the project code style
- Write clear commit messages
- Include a changelog entry if appropriate

### Issue Guidelines

When reporting issues:

- Use a clear and descriptive title
- Describe the expected behavior
- Describe the actual behavior
- Include steps to reproduce
- Include your operating system and ADB Wireless Manager version
- Include Android device model and version if relevant
- Include any error messages or logs

## API Design

### Overview

The ADB Wireless Manager API follows a modular design with clear separation of concerns:

- `AdbWirelessManager`: Main entry point and coordinator
- `DeviceDiscovery`: Device discovery via UDP/mDNS
- `PairingManager`: Device pairing management
- `ConnectionManager`: Connection establishment and maintenance
- `CommandEngine`: Command execution with queue and priority
- `DataStreamHandler`: File transfer handling
- `SecurityManager`: Security mechanisms
- `StateManager`: State persistence
- `UsbHandler`: USB connection handling

### Threading Model

The API is thread-safe and uses Qt's signal-slot mechanism for asynchronous communication. All signals are emitted from the main thread.

### Error Handling

The API uses a centralized error handling mechanism with `AdbError` and `AdbErrorInfo` classes. Errors are propagated through signals and return values.

### Memory Management

The API uses RAII principles and smart pointers to manage memory. Public API methods either return smart pointers or transfer ownership to the caller.

## Integration

### Adding ADB Wireless Manager to Your Project

#### Using CMake

1. Add the ADB Wireless Manager repository as a submodule:
   ```bash
   git submodule add https://github.com/TraeAI/ADBWirelessManager.git
   ```

2. Add the following to your CMakeLists.txt:
   ```cmake
   add_subdirectory(ADBWirelessManager)
   target_link_libraries(your_target ADBWirelessManager)
   ```

#### Using vcpkg

1. Install the package:
   ```bash
   vcpkg install adbwirelessmanager
   ```

2. Add the following to your CMakeLists.txt:
   ```cmake
   find_package(ADBWirelessManager REQUIRED)
   target_link_libraries(your_target ADBWirelessManager::ADBWirelessManager)
   ```

#### Using Conan

1. Add the package to your conanfile.txt:
   ```
   [requires]
   adbwirelessmanager/1.0.0
   ```

2. Add the following to your CMakeLists.txt:
   ```cmake
   find_package(ADBWirelessManager REQUIRED)
   target_link_libraries(your_target ADBWirelessManager::ADBWirelessManager)
   ```

### Basic Usage

```cpp
#include <adbwireless/adbwirelessmanager.h>

using namespace AdbWireless;

int main() {
    // Initialize the manager
    AdbWirelessManager* manager = AdbWirelessManager::instance();
    if (!manager->initialize()) {
        return 1;
    }
    
    // Connect to signals
    connect(manager, &AdbWirelessManager::deviceDiscovered, [](AdbDevice* device) {
        qDebug() << "Device discovered:" << device->serial();
    });
    
    connect(manager, &AdbWirelessManager::deviceConnected, [manager](AdbDevice* device) {
        qDebug() << "Device connected:" << device->serial();
        
        // Execute a command
        AdbCommand* command = manager->executeCommand(device, "shell getprop ro.build.version.release");
        connect(command, &AdbCommand::completed, [](AdbCommand* cmd) {
            qDebug() << "Command result:" << cmd->result();
        });
    });
    
    // Start scanning
    manager->startScan();
    
    // ...
    
    // Deinitialize
    manager->deinitialize();
    
    return 0;
}
```

## Performance Considerations

- Use appropriate command priorities to ensure critical commands execute quickly
- Limit the number of concurrent commands to avoid overloading the device
- Use large block sizes for file transfers to maximize throughput
- Avoid frequent scanning when not necessary
- Use auto-reconnect instead of manual reconnect attempts
- Close connections when not in use to free resources

## Security Best Practices

- Always use pairing codes for initial connection
- Enable encryption for sensitive operations
- Validate certificates when connecting to new devices
- Grant only necessary permissions to devices
- Revoke permissions when no longer needed
- Keep the ADB Wireless Manager updated to the latest version

## Debugging

### Enabling Debug Logs

To enable debug logs, set the `ADB_WIRELESS_DEBUG` environment variable:

```bash
export ADB_WIRELESS_DEBUG=1
./adbwirelessmanager
```

### Log Levels

- 0: No logs
- 1: Error logs only
- 2: Warning and error logs
- 3: Info, warning, and error logs
- 4: Debug, info, warning, and error logs
- 5: Trace, debug, info, warning, and error logs

### Network Debugging

To debug network issues, use tools like Wireshark or tcpdump:

```bash
tcpdump -i eth0 port 5555 or port 5556
```

### USB Debugging

For USB-related issues, use libusb's debug mode:

```bash
export LIBUSB_DEBUG=3
./adbwirelessmanager
```

## Release Process

### Versioning

The project follows Semantic Versioning (SemVer):

- MAJOR version when you make incompatible API changes
- MINOR version when you add functionality in a backwards compatible manner
- PATCH version when you make backwards compatible bug fixes

### Release Checklist

1. Update the version in `CMakeLists.txt`
2. Update `CHANGELOG.md` with release notes
3. Run all tests to ensure they pass
4. Generate documentation
5. Build for all supported platforms
6. Create release packages
7. Test packages on each platform
8. Tag the release in git
9. Create a GitHub release
10. Upload release packages
11. Update the website
12. Announce the release

### Building for Multiple Platforms

#### Windows

```bash
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

#### macOS

```bash
cmake .. -G "Xcode"
cmake --build . --config Release
```

#### Linux

```bash
cmake .. -G "Unix Makefiles"
make -j$(nproc)
```

### Creating Release Packages

The project includes scripts for creating release packages:

```bash
./scripts/create_release_packages.sh 1.0.0
```

## Future Development

### Planned Features

- Android Auto support
- Web interface for remote management
- Mobile app for iOS and Android
- Integration with CI/CD systems
- Support for Android Debug Bridge (ADB) over TCP/IP
- Enhanced device management features
- Improved performance monitoring
- Support for more device types

### Roadmap

- Version 1.0.0: Initial release with core functionality
- Version 1.1.0: Enhanced file transfer and performance
- Version 1.2.0: Web interface and mobile app
- Version 2.0.0: API redesign and Android Auto support

## Community

### Discord

Join the Discord server for discussions and support:
https://discord.gg/adbwirelessmanager

### Twitter

Follow us on Twitter for updates:
https://twitter.com/adbwireless

### Reddit

Join the Reddit community:
https://www.reddit.com/r/adbwirelessmanager

## License

The ADB Wireless Manager project is licensed under the MIT License.

## Acknowledgments

- Qt Framework for cross-platform support
- libusb for USB device handling
- Android Open Source Project for ADB protocol
- All contributors and community members
"@

New-Item -Path "$DOCS_DIR\development_guide.md" -ItemType File -Force | Out-Null
$DEV_GUIDE_CONTENT | Out-File -FilePath "$DOCS_DIR\development_guide.md" -Encoding UTF8

# Create user manual placeholder
$USER_MANUAL_CONTENT | Out-File -FilePath "$DOCS_DIR\user_manual.md" -Encoding UTF8

Write-Host "Release generation completed!"
Write-Host "Release files generated in: $OutputDir"
Write-Host "======================================="
Write-Host "Files generated:"
Write-Host "- README.md: Project overview"
Write-Host "- CHANGELOG.md: Changelog"
Write-Host "- LICENSE.md: License information"
Write-Host "- RELEASE_NOTES.md: Release notes"
Write-Host "- INSTALL.md: Installation instructions"
Write-Host "- Examples: Simple usage example"
Write-Host "- Documentation: API reference, user manual, and development guide"
Write-Host "- Include files: Public headers for development"
Write-Host "- Resource files: Icons, styles, and translations"
Write-Host "======================================="
Write-Host "To build the project, run:"
Write-Host "    mkdir build && cd build"
Write-Host "    cmake .. -DCMAKE_BUILD_TYPE=Release"
Write-Host "    make -j$(nproc)"
Write-Host "    sudo make install"
Write-Host "======================================="
