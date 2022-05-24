# Scripts to create a Configuration Baseline for AD

## Prerequisites

1) Create a repository on the machine running the baseline (ex: c:\scripts)
2) Review content of Export-Var.ps1 and update the following variables:
 - scriptspath
 - logpath
 - sendemail
 - smtpserver
 - SendToAddress
 - FromAddress

3) Run Export-Var.ps1. A file called Export-var.xml should have been generated in the script folder.
4) Permissions:
- Enterprise Admin account (if multiple domains in the forest)


## Run baseline

1) run each config file individually to review the current config. 
2) Evaluate if the current config matches the expected configuration
3) If you identify a deviation between the current config and the ideal state, update the XML corresponding to the script output (ex: get-domaincontroller_baseline.xml)


## Reccurrence

You can run this baseline as a reccurrence. To do that:
1) Create a scheduled task
- Program/Script: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
- Add parameters: your_script_path\GenerateReport.ps1
- Start in: your_script_path
