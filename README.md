# SQLRoboFailover

All in one solution to failover AlwaysOn Availability Groups in SQL Server.

Functions to run health checks, failover all availability groups, complete post failover health checks, set AG replicas to sync / async modes. Can be combined with the [Update-DbaInstance](https://docs.dbatools.io/#Update-DbaInstance) function for a fully automated patching solution. 

Requires the `SqlServer` module.
Optional: Install [dbatools](https://dbatools.io/) module for patching functionality.

## Core Functions

This solution is built to be modular to be flexible. Detailed documentation to core functions can be found [here](./docs/CoreFunctions.md). 

## Example Usage

Import the module.

```powershell
Import-Module .\src\Vex -Force
```

The config repository (tests / environments) is seperated by design so it can be source controlled independently. Set the path to the Config repository
```powershell
$ConfigRepoPath = "C:\src\VexConfigRepo"
```

#### Run all tests with default parameters
```powershell
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath
```

#### Run all tests tagged with "Daily" schedule
```powershell
$Schedule = "Daily"
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath -RunType "Schedule" -RunTypeParams $Schedule -OutputTarget "None" -Show All
```

#### Run specific tests
```powershell
$TestList = ("Team1\OneEqualsOne.tests.ps1", "Team2\TwoEqualsTwo.tests.ps1")
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath -RunType "TestList" -RunTypeParams $TestList -Show All
```
## Vex Parameters

#### -ConfigRepoPath
Path to VexConfigRepo. Use the same file names and directory structure as provided in the sample repo (.\VexConfigRepo). 
For more information on the VexConfigRepo, refer to the [the documentation](./docs/VexConfigRepo.md)

#### -RunType
Type of test to run. Supported inputs:

- All (default) - Run tests found in all .config.json files in VexConfigRepo (.\VexConfigRepo\TestConfig)
- Schedule - Run all tests tagged with a specific schedule in VexConfigRepo
- TestList - Pass in a list of tests to run. Tests will only run if configured in ConfigRepo (.\VexConfigRepo\TestConfig)


#### -RunTypeParams
Parameters for RunTypes. Supported Inputs:
- If `-RunType="All"`, this parameter is not required/valid. All tests will be run.
- If `-RunType="Schedule"`, pass in a single value (Weekly / Daily / Hourly / Mon2pm). This can be any value - Vex will check the test config for any tests with the same tagged value
- If `-RunType="TestList"`, pass in a list of tests. Example:
```powershell
$TestList = ("Team1\Team1Test.tests.ps1", "Team2\Team2Test.tests.ps1")
```
	
#### -OutputTarget
Supported Inputs:
- None – Don’t save test results (Default)
- OMS - Save test results to Azure Log Analytics (OMS)
- Database (TBA) - Save test results to SQL Server (Not yet supported)

#### -Show
Different levels of ouput detail to the console (a Pester parameter).
https://github.com/pester/Pester/wiki/Invoke%E2%80%90Pester#show

Supported Inputs:
- All
- None
- Summary(default)
- Failed
