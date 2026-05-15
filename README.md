# Abyssal Descent
Run on `forge 47.4.10`

Join the [Discord](https://discord.gg/S43xbbHAe2) for more information  

> **Note:**  
> This project is still in development, read [Known Issues](KNOWN-ISSUES.md)

PR's and Issues welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md)

## Building
**Dependencies:** `zip`, `curl`, `awk`, JDK 17
```bash
git clone --recursive https://github.com/abyssal-descent/abyssal-descent
cd abyssal-descent
./build.sh curse  # curseforge zip
./build.sh export # manual install zip
```

**Additional Instructions:**

<details>
<summary><b>For Windows 11:</b></summary>

1. Install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)  
   **TLDR:** Open PowerShell as admin and run `wsl --install`. This will likely require a reboot.
2. Open WSL by running `wsl` in the shell, then install `curl`, `git`, `zip`, and `openjdk-17-jdk`:
    ```bash
    sudo apt update && sudo apt upgrade && sudo apt install curl git zip openjdk-17-jdk
    ```
4. Run one of the build commands from above.

</details>

<details>
<summary><b>For Windows 10:</b></summary>

1. Install [Cygwin](https://cygwin.com/)
2. Select `Install from Internet`, choosing the install location.
   Pick where you want the `Local Package Direcotry` to be,
   then select `Use System Proxy Settings` and choose a download site.
   (I don't think it matters which one you choose.)
3. Change `Pending` to `Full` and search for `git`, `gawk`, and `curl`.
   For each package change `Skip` to the latest version.
   Hit next, next, then finish.
   Be sure to make a shortcut when it asks you to, unless you're already familiar with Cygwin.
4. Download the MSI Installer for the [JDK 17](https://www.oracle.com/java/technologies/downloads/) and skip through the wizard.
5. Open `Cygwin64 Terminal`, then run the build commands listed above.

</details>

> **Tip:**  
> When rebuilding run the following to grab the newest changes.
> ```bash
> git fetch && git reset --hard origin/master
> ```
