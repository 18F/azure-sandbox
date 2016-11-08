# Don't do any of this...

... without verifying the hardcoded values in all the scripts and commands

## Set up workstation

- Clone this repo to, say, ~/Projects/dsc
- Get RDP access to remote jumpbox
- Connect to jumpbox while redirecting the ~/Projects directory

## Set up Jumpbox

Place `../jumpbox/profile.ps` in your $profile

Then ```
sync-from-home
$remote = remote_mach_name
sync-to-remote
```

# Connect to tfs-app-box

## Fix missing NuGet package step

- Get the install media and copy to remote

*Fix the FIPS issues*

See https://github.com/OneGet/oneget/issues/195.  Solving involves the
steps at the end of that issue (or maybe resolved by now)

The script `strong.ps1` sets the necessary registry settings per that issue.

## Then start automated install bits

Install the Prerequisites:

```
./prereqs.ps1
```

Do the automatable stuff w/ DSC:

```
./dsc_configuration.ps1
```

## Do manual config

TFS now you can do a manual configuration with 
