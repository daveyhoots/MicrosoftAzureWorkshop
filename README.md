# MicrosoftAzureWorkshop
Supplemental Azure scripts and files to enhance your workshop experience.

## Exercise - Setup Az PowerShell Module

### Launch PowerShell

1.  Right Click on **Windows PowerShell** from either the Desktop or the
    Start Menu

2.  Select **Run as Administrator**

### Set PowerShell Execution Policy

1.  Run the following PowerShell Command to set your execution policy to
    Unrestricted:

```powershell
Set-ExecutionPolicy Unrestricted
```

2.  Select Yes if prompted. Execution policies determine whether you can
    load configuration files, such as your PowerShell profile, or run
    scripts and whether scripts must be digitally signed before they are
    run. More information on this topic can be found here:
    <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6#parameters>

### Install Az Module

1.  Run the following PowerShell Command:

```powershell
Install-Module -Name 'Az'
```

2.  If not already installed, you may be prompted to install the NuGet
    provider. Select **Yes** if this is the case.

3.  You may receive a warning message stating you are installing modules
    from an untrusted repository. Select **Yes** if this is the case.
    This process may take several minutes.

4.  Run the following PowerShell Command to verify the module has
    installed correctly:

```powershell
Get-Module -Name '*Az*' -ListAvailable
```
5.  If installed, Az should be returned

<div style="page-break-after: always;"></div>

## Setup Visual Studio Code

### Download Visual Studio Code

1.  In a web browser, navigate to <https://code.visualstudio.com>

2.  Click **Download for Windows**

3.  Note the location of the installation files

### Install Visual Studio Code

1.  Run the **VSCodeUserSetup** installation file

2.  If you are prompted with a message \"This User Installer is not
    meant to be run as an Administrator\" Click **OK**

3.  Accept the EULA and click **Next**

4.  Accept the default installation location and click **Next**

5.  Accept the default Start Menu Folder and click **Next**

6.  Select all additional tasks and click **Next** (Optional)

7.  Click **Install**

8.  Uncheck "Launch Visual Studio Code" and click **Finish**

<div style="page-break-after: always;"></div>
