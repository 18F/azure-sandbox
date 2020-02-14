# Microsoft Desired State Configuration(DSC)
**Conclusion: Sep 29: DSC not ready for our use**

**Conclusion: Oct 13: Merits further study**

**Conclusion: Oct 25: DSC as a technology is ready, but the Microsoft tooling/framework
around it is not**

## Overview

We intend to make use of _DSC resources_ (i.e. DSC technology, not tooling/framework) as much as possible. The number and quality of DSC resources
has improved over the last couple of years, and using DSC leverages existing Powershell skills. *We will use Chef server-client as the tooling/framework* for composing and distributing system configurations for the following reasons

- **Resource distribution**: Module management with DSC pull server is significantly more complicated than the process for Chef Cookbook management, particularly since we may not be able to use the Azure Automation DSC pull services (and associated reporting and VCS repository linking). Faced with running our own DSC Pull Server with its minimal reporting facilities, or running Chef Server with analytics/reporting and the years of code management tools that Chef has developed, gives the edge to Chef.
- **Dependency managment**: Chef has `Berksfile`, `metadata.rb` dependency specifications, and `Policyfile` to manage specific groupings of dependent resources, to which DSC has no equivalent.
  - **Unversionable class resources**: WMF4-style resources can be versioned by manually incrementing the name of a distributed .Zip file. WMF5 introduced class-based DSC resources, which alleviates many of the code reuse problems with functional resources. However, class-based resources are unversionable so can't be used with an automated build pipeline (Ref: _The DSC Book_, 'Custom Resources' chapter)
- **Bootstrapping**: Associating new Azure nodes to use either a DSC pull server or Chef server are roughly comparable via AzureResourceManager(ARM) extensions. However, the provisioning process in our Azure deployment is still in flux, and we may not be able to count on use of ARM extensions. When a system is provisioned w/o these extensions, associating a node with pull server is still an open problem. (Ref: [https://powershell.org/forums/topic/bootstrap-windows-using-dsc/](https://powershell.org/forums/topic/bootstrap-windows-using-dsc/))
  - **Certificates and secrets**: This problem seems particularly acute around secrets management. As the sample script at [https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3](https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3) shows, to encrypt credentials into a MOF file one needs the target systems' public keys at build time. Otherwise you need to commit clear-text credentials into the MOF, a bad practice. Since chef-client compiles code at run time we can inject secrets dynamically from ChefVault, EncryptedDataBags, or third-party secrets management systems like Azure KeyVault or Conjur or Hashicorp Vault.  This problem is also acknowledged in the _The DSC Book_, section on 'Self-Modifying Configurations'. Note that ChefVault is not without its scaling problems (ref: [http://www.pburkholder.com/blog/2015/12/04/why-chef-vault-and-autoscaling-dont-mix/](http://www.pburkholder.com/blog/2015/12/04/why-chef-vault-and-autoscaling-dont-mix/)) but there are at least ways to integrate Chef with 3rd party systems.
- **Future flexibility**: Chef can manage Windows systems with DSC resources, and Linux/Solaris systems with existing Chef cookbooks. A DSC-based system would not suffice to manage non-Windows systems at this time.
- **Culture**: We need to instill a mindset of 'Best tool for the job' and 'Yes! We can learn this' and that includes choosing an Infrastructure Automation platform running on Linux and built around Ruby. Modern development, security and operations teams should approach all tasks intent on continuous improvement and continuous learning. For decades, Microsoft Windows products tried to minimize professionalism in system operations.
To quote Michael Hedgepeth:

> "Microsoft is a fantastic platform for enterprise-level development and they have an excellent cloud solution for enterprises. But they also have a long legacy and entire culture centered around the message that you can do IT with little training and a few button clicks."

Counter to this culture, the 2016 server stack is built around a different approach (no GUIs, automation via CLI, etc.) that we should embrace. Ref: [https://www.youtube.com/watch?v=3Uvq38XOark](https://www.youtube.com/watch?v=3Uvq38XOark) - Jeffrey Snover's "The Cultural Battle to Remove Windows from Window Server".


## _Nota Bene_

This is a work-in-progress regarding our early work with DSC. As this has _not_ been formally published  it should not
be considered a fixed opinion of any sort, and certainly not an endorsement of any technology by the GSA or 18F. AND we would love your help! Please open an issue if you have further information or opinions to add.

This README summarize our experiences, and some of those in the community, with using DSC/Azure Automation, with an end goal of making a recommendation on which tools to experiment with first for larger-scale infrastructure-as-code.

## Context

18F is working with an agency on some process modernization, and they are a 100% Windows shop moving into Azure. We're trying to make some technology choices to provide them a usable app and infra pipeline in the coming months. The systems in the initial pipeline environment include:

- TFS
- Jenkins leader and build nodes
- HP Fortify
- IMB AppScan

and some initial core infra for logging and monitoring.

We would like to consider all these systems as crops, not houseplants (or cattle, not pets), and automate their lifecycles for (all the reasons). As for that automation, the choices are:
- Chef (not an endorsement of Chef over Puppet. Simply, the differences between them matter less than the fact we have more in-house experience with Chef, and would prefer not to relearn Puppet)
- DSC w/ AzureAutomation
- SCCM: I have no experience with SCCM and will let the folks at partner agency w/ SCCM experience help determine what role it should play.

After an initial assessment of DSC in September 2016, we made the following conclusion, which we then re-examined in October 2016 after some useful feedback from the Powershell community:

> **Posited**: In a heterogenous computing environment where dev and ops are comfortable with both Linux and Windows, and with various high-level languages like Ruby or Powershell, then Chef/Puppet is a better choice than DSC for Windows automation.  However, even in a monoculture of Windows and Powershell, DSC is still not mature enough for lifecycle management of a wide variety of systems, and it's better to bite the bullet and introduce Linux servers to host Chef or Puppet and introduce those systems to nascent DevOps teams.

In addition to doing a deeper dive into the technology, we also reached out to the community, over Twitter and mailing lists, to ascertain the scale and scope of Windows automation in different environments.


## How do Chef and DSC compare? Executive Summary

Chef and DSC both extend an existing language (Ruby, Powershell) to express system state in a declarative manner, and a client (Chef-Client, LocalConfigManager) to idempotently converge a system to that desired state.

Chef-Client exists in the context of mature framework to write, share, package, test and apply the configuration.  DSC is much more of a building-block technology that can work in multiple frameworks. Some frameworks include:

- Chef itself, with the `dsc_resource`
- DSC Push over CIM connections
- DSC Pull services with either Azure Automation or with a standalone DSC Pull Server
- DSC Resources within MS Service Center (we have not examined this option yet)

Since DSC is _not_ a framework, when we speak of "Using DSC" we mean using a **test and release pipeline of version-controlled system artifacts, written in the DSC language, and using a DSC Pull Server such as Azure Automation.**

DSC Adoption: Risks & Benefits:

- Risks:
  - We would need to write or research more tooling ourselves, e.g. test processes and some resources.
    - The DSC community has not settled on as many standard-practices as Chef has. So we would need to sort through what other folks are doing and decide what will work for us.  
    - We are already building community connection to help with process determination
  - We would have a hard time extending DSC into any future Linux-based servers.
  - We would see a slower start to automation as our team hones our Powershell skills and learns DSC.
- Benefits:
  - We might get significant support from Microsoft since they need more DSC case studies within the Fed space
  - We win over agency skeptics reluctant to adopt Ruby-based app
  - We win over agency skeptics reluctant to adopt Linux servers
  - We can build upon the existing Powershell expertise within the agency
  - Should we decide to replace DSC Pull, we can re-use DSC resources as components of any future Chef implementation
    - For example: Suppose we have `Agency_My_App` which comprises DSC resources for `Agency_IIS_DSC` and `Agency_dotNet_DSC` and `Agency_SQLServer_DSC`. If the DSC pull model is not working for us, we can build a Chef cookbook `Agency_My_App_cookbook` and re-use the DSC for `Agency_IIS_DSC` and `Agency_SQLServer_DSC`, etc., without having to rewrite all the lower-level code.

## Pricing

- Chef OpenSource: Free
- Chef Automate: $137/node/annum (includes Workflow, Compliance, Visibility)
- DSC Pull Server: Free
- DSC Azure Automation: $72/node/annum (no analog to Chef Compliance or Workflow)


## Chef or DSC? \[Notes from early October 2016\]


We would really like DSC to work out because:

- eventual users and owners are more comfortable with Windows and Powershell than they are with Ruby, Linux and open-source in general
- there is greater trust afforded a COTS Microsoft system than an open-source based system like Chef (yes, I know DSC is OSS, but it has Micrsoft's imprimatur)
- reducing the number of tool & technology hurdles we have to clear helps conserve organizational capital for taking on other challenges, like granting developers commit bits on the IAC code repositories. This concern has already come up, as [I've addressed in this draft on IAC and admin rights](https://gist.github.com/pburkholder/9c397c36fb966bd54be7c39ff1501776)

I've been using declarative configuration management systems since 2004, with CfEngine2, then Puppet, then Chef, and with a smattering of Ansible. With that background, I thought in mid-September 2016 that two weeks would be sufficient to get a handle on the basis of DSC.

However, my initial foray into DSC-land was rather frustrating, and [my initial write-up](https://github.com/18F/azure-sandbox/blob/748b42bf8f2315c91e042b3db2527815b5064f73/dsc/README-dsc.md) was [gently mocked at Powershell.org](https://powershell.org/2016/10/12/no-easy-button-for-configuration-management/) (see the ['Initial Post' below for my original commentary](#initial-post)). While I never expected DSC (or any CF system) to be "easy," my initial poor impression stemmed from a few things not related to DSC itself:

- My initial impressions may have been somewhat tainted by my relative inexperience in Windows and PowerShell, irrespective of DSC itself.
- Further, I did not have access to a Windows workstation or local virtualization, so relying on RDP to remote VMS probably tainted my overall experience.
- I used DSC push, instead of DSC pull, which, as Don Jones says: "DSC push mode is basically scratching the surface. You didn’t really explore it if you didn’t get into how Pull affects the architecture"


### Other Players

Other players in this space I know nothing about:

- Indeo Otter: [http://inedo.com/otter](http://inedo.com/otter)
- Upguard: [https://www.upguard.com/blog/powershell-dsc-with-upguard](https://www.upguard.com/blog/powershell-dsc-with-upguard)

## Is anyone using DSC 'for real'?

Google 'Who uses DSC in production?' or 'Powershell DSC in production' and you don't get much:

[https://www.reddit.com/r/sysadmin/comments/50huqd/how_many_of_you_actually_use_powershell_dsc_in/](https://www.reddit.com/r/sysadmin/comments/50huqd/how_many_of_you_actually_use_powershell_dsc_in/)

Answer: no one? (August 2016)

So, I went on a Tweet-spam storm on 14 October 2016 to try to scare up more real examples: <br>
[https://twitter.com/pburkholder/status/786968790819074048](https://twitter.com/pburkholder/status/786968790819074048)<br>
[https://twitter.com/pburkholder/status/786965389964091392](https://twitter.com/pburkholder/status/786965389964091392)<br>
[https://twitter.com/pburkholder/status/786965952969793536](https://twitter.com/pburkholder/status/786965952969793536)<br>
[https://twitter.com/pburkholder/status/786967131422396417](https://twitter.com/pburkholder/status/786967131422396417)<br>
[https://twitter.com/pburkholder/status/786967362213974017](https://twitter.com/pburkholder/status/786967362213974017)<br>
[https://twitter.com/pburkholder/status/786967643907579905](https://twitter.com/pburkholder/status/786967643907579905)<br>
[https://twitter.com/pburkholder/status/786967643907579905](https://twitter.com/pburkholder/status/786967643907579905)<br>


And found at least these shops that are running at modest scale w/ DSC:

- Flynn Bundy @bundyfx, 100 nodes, 15 roles: [https://twitter.com/Bundyfx/status/787201763501801473](https://twitter.com/Bundyfx/status/787201763501801473)
- Chris Hunt, @logicaldiagram, 1000 nodes @ ticketmaster [https://twitter.com/LogicalDiagram/status/786971759501160448](https://twitter.com/LogicalDiagram/status/786971759501160448))
- DevOps Trawler @dtrawler, 140 nodes, [https://twitter.com/DTrawler/status/786970813475934209](https://twitter.com/DTrawler/status/786970813475934209)
- Cory Woods @netgainhosting, 300 nodes, [https://twitter.com/CoryDWood/status/786968517203619840](https://twitter.com/CoryDWood/status/786968517203619840)

One detailed description that came back:

> &nbsp;&nbsp;&nbsp;&nbsp;Hey mate,
So we use DSC to manage around 100 nodes with about 15 roles.

> &nbsp;&nbsp;&nbsp;&nbsp;All Windows Server 2012 R2 Core, Basically we do it all from Github.
We have a central repository that holds the Configuration Data which outlines the roles and the nodes attached to those roles.
Then we have a Generation folder that holds the LCM configuration files and another folder for the main configuration script.

> &nbsp;&nbsp;&nbsp;&nbsp;Essentially taking the three main components of DSC (config data, meta mof generation and mof generation) and giving them their own section in the repo.

> &nbsp;&nbsp;&nbsp;&nbsp;We make all changes in Pull Requests to the Repo which trigger our CI/CD pipeline in Appveyor.

> &nbsp;&nbsp;&nbsp;&nbsp;Appveyor will take the repo and run through a list of Pester tests that our DSC Configuration data file should follow (no duplicates, valid names, roles etc) then if the tests pass it (Appveyor) will run the main .ps1 file which will create all the meta.mof files and the .mof files for all the roles.

> &nbsp;&nbsp;&nbsp;&nbsp;After it (Appveyor) has created all the files required for DSC to function it will zip them up and put the zip file (as a nuget package) into our private appveyor nuget feed.

> &nbsp;&nbsp;&nbsp;&nbsp;We then have our Pull Server (with its own DSC config) to look at the feed and check for any new version of the DSC nuget package.
If it finds a new version (checks every 30 mins) it will pull it down and unzip all the meta mofs and mof files into the location on disk that all nodes will look for new .mof files.
But this leaves us with the issue of: How do nodes get told where to look for their config? (aka LCM config)

> &nbsp;&nbsp;&nbsp;&nbsp;We have another configuration on the pull server that checks through the meta.mof files once they get pulled down and does a check against all nodes to ensure they are pulling the correct config (role).

> &nbsp;&nbsp;&nbsp;&nbsp;Essentially what this does is allows us to alter any of the LCM config in github and ensure us that the pull server will connect with those nodes and make sure they pulling what it says they should be.

> &nbsp;&nbsp;&nbsp;&nbsp;If they're not pulling what we said or we have updated any of the config in the meta.mof generation in github the pull server will make sure its updates the LCM on those nodes then report its changes into out Slack Channel.

> &nbsp;&nbsp;&nbsp;&nbsp;Hopefully, this makes sense, feel free to hit me back with any questions. But I must say it works perfectly. We've built a fair few custom in-house modules that all fall into the same appveyor style deployment pipeline - works great.

## Can Chef work in a Windows monoculture?

As a corollary to the above question, we also reached out to the Chef community to find examples of whether Chef has worked out in Windows shops -- not as a matter of whether the technology works, but whether the potential cultural barriers are too high.

Getting feedback involved Discourse postings:

- [https://discourse.chef.io/t/chef-in-a-windows-monoculture-success-examples/9733](https://discourse.chef.io/t/chef-in-a-windows-monoculture-success-examples/9733)

And Twitter outreach:

- [https://twitter.com/pburkholder/status/789180324009816064](https://twitter.com/pburkholder/status/789180324009816064)

In the end I only found two shops that have adopted Chef that are more than 90% windows: NCR and MSN. There are lots of shops that are Windows-dominant: Nordstrom and Alaska Air, to name two.


## SCCM and the Config Management space

Ref: [https://donjones.com/2014/06/11/why-i-think-sccm-will-probably-not-survive/](https://donjones.com/2014/06/11/why-i-think-sccm-will-probably-not-survive/). From the comments:
>  I see Microsoft BEGINNING to line up the functional replacements for SCCM’s existing features. Those first steps, combined with SCCM’s non-cloud-focus, is what makes me think Microsoft is indeed walking down a path to replace SCCM.

Ref: [https://redmondmag.com/articles/2015/02/01/predicting-the-future-of-system-center.aspx](https://redmondmag.com/articles/2015/02/01/predicting-the-future-of-system-center.aspx):

- Configuration Manager
  - (already compiles MOFs?)
- Orchestator
  - Opalis gone in favor of SMA = Service Management Automation

GA announced 12 Oct 2016: [https://blogs.technet.microsoft.com/hybridcloud/2016/10/12/managing-the-software-defined-datacenter-with-system-center-2016/](https://blogs.technet.microsoft.com/hybridcloud/2016/10/12/managing-the-software-defined-datacenter-with-system-center-2016/)

Home page: [https://www.microsoft.com/en-us/cloud-platform/operations-management-suite](https://www.microsoft.com/en-us/cloud-platform/operations-management-suite)

## Resources

Summaries of key DSC literature, with dates as this space is moving pretty fast.

### Presentations

[The Devopsification of Windows Server](https://www.youtube.com/watch?v=6Mn10BiaVaw) - Jeff Snover, WinOps 2016.  **Recommend to understand vision, direction**

[Gain insight into a Release Pipeline Model](https://myignite.microsoft.com/videos/22116) - This video from MS Ignite, Sept 2016, should be titled, **Transform your organization with Powershell DSC** 1h25m w/ Michael Greene, Mark Gray. **Need to watch**.

- comments
  - Environmental configs should be build with PSake
  - Need slides...
  - TFS or jenkins for Build
  - "Integration and Acceptance tests done after release" ... to each pre-prod env as well as after release.
  - Patch management: at least five ways, no standard best practice
  - Getting Started (Slide):
    - Use source controls
    - Don't expect to cut over instantly
    - Require tests
    - Keep options open (use the tools that work for you, demo happened to be TFS...)
    - Old and New tools can be integrated (not sure I agree)
  - Use JEA (Just Enough Administration) to prevent "Heroes" from changing server settings randomly.
- Related resources:
  - [Whitepaper: The release pipeline model](https://msdn.microsoft.com/en-us/powershell/dsc/whitepapers#the-release-pipeline-model)
  - [Interview MSDN channel 9 DevOps-Dimension](https://channel9.msdn.com/Shows/DevOps-Dimension/13--The-Release-Pipeline-Model-Transform-IT-Ops-with-DevOps-Practices)
  - [Also from DevOps-Dimension - Octopus Deployment Devops Best Practices](https://channel9.msdn.com/Shows/DevOps-Dimension/9--DevOps--Deployment-Automation-Best-Practices)
  - [Build and operate a software-defined datacenter](https://myignite.microsoft.com/videos/20645)
    - TODO - watch this

[Configuration management with Azure Automation, DSC, Cloud]( https://channel9.msdn.com/Events/WinOps/WinOps-Conf-2016/Configuration-Management-with-Azure-Automation-DSC-Cloud--On-Prem-Windows--Linux) - Ed Wilson (Scripting Guy) - WinOps Conference, June 2016. **OK overview**

[DSC acceptance testing w/ Test-Kitchen](http://mspsug.com/2016/05/17/video-acceptance-testing-powershell-desired-state-configuration-with-test-kitchen/) - Steven Murawski, Spring 2016.

### Books

[The DSC Book](https://leanpub.com/the-dsc-book) - Don Jones, Oct 2016, Leanpub: Up-to-date, usefully opinionated. Doesn't cover Pester testing.

[Learning Powershell DSC](https://www.packtpub.com/networking-and-servers/learning-powershell-dsc) - James Pogran, Oct 2015, Pakt Pub: WMF5 was still rough around the edges on publication. Seems to have better debugging sections than Jones's book.

### Posts

####  April 2016: [Chef v. DSC implementation](https://powershell.org/forums/topic/chef-vs-dsc-implementation/)
Key points, with editorializing in *ital* and/or \[brackets\]

- Link: [https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/](https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/) (May 2014)
- Link: [https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/](https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/) (Sept 2014)
- Chef has reporting. Chef has a library of resources
  - \[*DSC in AzureAutomation seems to have good reporting, but haven't seen it yet myself*\]
- DSC doesn't have subscribe/notifies
- DSC doesn't have:
  - Password management \[probably fixed with Azure KV store\]
  - Code delivery \[possibly fixed with Azure Automation w/ source code repo\]
  - LCM Agent Management \[No idea - help?\]
  - DSC doesn't have test-kitchen \[but it does now\]
  
#### Feb 2016: [Question: Why Should I Use DSC Rather than SCCM?](http://stevenmurawski.com/powershell/2016/02/what-direction-should-we-go/)

An essential blog post by Steven Murawski. READ IT.



####  May 2014: [Why Puppet vs DSC isn't even a thing](https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/)

Rich Siegel has some great comments:
> At the heart of a good puppet or chef or ansible implementation, is something that is not part of any of them. This is version control.
<div></div>

> The pipeline is how do people work. How do they submit changes into the pipeline, how are they reviewed, tested and subsequently deployed. The vision with DSC is lost because it feels like Microsoft isn't sure how you should do this, or doesn't want to enter this space. \[_This seems to have changed w/ AA_\]
<div></div>

> It isn't clear how you write tests around powershell DSC code, and know its good before pushing to 100s or 1000s of nodes . How do you lint it? How do you unwind a bad push/pull. Ruby has a strong TDD community spirit, and Powershell has Pester (which I have improved) but it has not received a nod as "the go to framework". We do use it for chocolatey. Phabricator and Gerrit have become key tools for peer review and create "safety stops" to prevent bad code from moving into prod. Testing is the second most important part of config management after the version control and people need to be engaged in how testing is conducted.
<div></div>

> Ruby is a cross platform language, powershell is not...

- DSC doesn't support callback to the node or server for configuration context (but the underlying Powershell resources could)

Darren Mar-Elia:
> I think the DSC integration work that Chef showed almost a year ago could provide the best of both worlds

#### Sept 2014: [WHY CHEF + DSC? (REVISITED)](https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/)

Steve Murawski's notable differences, as I see them today

- Linting - Chef has lots of options; DSC has xDSCResourceDesigner \[See also from May 2016: [https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcemofdesigner](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcemofdesigner) and included links...\]
- Inventory tool. Chef has Ohia \[Puppet has Facter\], DSC ecosystem seems not to use this. Each provider needs it's own Get-/Test- function.


#### Oct 2016: [DSC ConfigurationData Blocks in a World of Cattle](https://powershell.org/2016/10/11/dsc-configurationdata-blocks-in-a-world-of-cattle/)

It's not been clear with the MOF generation processing being linked to `NodeName` how to apply DSC as roles to nodes that don't exist yet. Key point here is that node name reported from node to pull server need not be unique. Nothing at [https://msdn.microsoft.com/en-us/powershell/dsc/configdata](https://msdn.microsoft.com/en-us/powershell/dsc/configdata) implies uniqueness constraints.

>  "NodeName" is a misleading setting, but if you think of it as a role, which could be applied to multiple actual machines, then it makes a lot more sense that way.

It's not clear to me where the nodename comes from, possibly from LCM config as in:

```
Set-DscLocalConfigurationManager -Path ./localhost.meta.mof -ComputerName NODE1
```
TODO: Dig into how this works


#### Flynn Bundy's blog

See [https://flynnbundy.com/category/dsc-2/](https://flynnbundy.com/category/dsc-2/), I like his intro to WMF5 class-based resources, but note that Don Jones warns in The DSC Book:

> there’s a downside to class-based modules at this time, which is that they don’t support filename-based versioning. This makes them a little problematic in real-world applications, because you can’t have two versions of a class-based module living side-by-side on nodes or on a pull server.


### Useful resources at https://github.com/PowerShellOrg

- StackExchange DSC resources: Evidently Murawski got that going, not sure if it's a real thing, only three commits since 21 No 2014
- SMurawski's POSH-driven DSC tutorial: [https://github.com/PowerShellOrg/dsc-summit-precon](https://github.com/PowerShellOrg/dsc-summit-precon)

### Useful comments by Galen Emery:

> Patching:  Chef vs. SCCM vs. WSUS(?)

Our stance on Windows patching is best managed via Chef+WSUS.  Use Chef to ensure that WSUS is setup on the node, and that it's part of the correct update group.  The wsus-client cookbook follows this pattern: https://github.com/criteo-cookbooks/wsus-client
WSUS is *the* way to manage patches coming into your environment.  Chef is *the* way to ensure that your systems are configured accurately.

> What does SC-Orchestrator do in comparison to Chef?

SCOM uses the concept of a runbook.  As a tool, it's very very UI driven.  Click and drag, creating groups, etc.  It's designed for server management, like Chef.  But approaches it without the test-driven development process, or tooling.

From a future perspective, Microsoft is putting a lot of investment into Powershell DSC, which SCOM can consume as part of a runbook, but again it is not designed to handle the testing and pipeline functionality that Chef does.

It is also built for Windows.  It has expanded it's capabilities past it, but anything non-windows is still very new.

> What does SCCM do in comparison to Chef?

I'm going to let Steven handle this: http://stevenmurawski.com/powershell/2016/02/what-direction-should-we-go/

> What have been the most significant improvements in Chef Windows support in the last 10 month? (From working with XXXX, I know of some of the weird hoops they jumped through for managing chef-client as admin, not sure if that's been solved in the general case. Also the client as schtask vs. service issue).

Schtask vs service:  https://getchef.zendesk.com/hc/en-us/articles/205233360-Should-I-run-chef-client-on-Windows-as-a-service-or-a-scheduled-task-
The short answer here is that scheduled task is more resilient than service.

I'm not aware of any outstanding issues getting chef-client to work as admin.  Particularly in the context of scheduled tasks.

In terms of changes in Windows, the changelog has a number of bugfixes.  There's a few new features, but really Chef-client is very stable on Windows, there's not a lot of pressing backlog for it right now.  And we're really focused on increasing the compliance and patching stories, to really drive home the value of using inspec and compliance.


## Update 12 Oct 2016 conversation w/ Don Jones:

(Sorry for reverse chronological order, but I think the update is more interesting than the original content)

I managed to engage the redoubtable Don Jones on this topic, as we were conversing about some corrections to [his DSC book](https://leanpub.com/the-dsc-book). Some comments from him include:

With respect to DSC development pipelines:
> Yeah, we had folks at \[DSC\] Camp run through a couple of complete stacks they’re using. One was TFS-based, and the other was Git and TeamCity, I believe.

With respect to my Chicken-egg experiences with DSC push:
> But DSC push mode is basically scratching the surface. You didn’t really explore it if you didn’t get into how Pull affects the architecture.

Other comments with respect to the above \[emphasis mine where I strongly agree\]
> While I acknowledge some of the testing/debugging weaknesses, you’re also missing out on a lot of the dev practices the community has adopted, which largely mitigate those weaknesses. And **a lot of your direction seems to be, “Chef is hard, but DSC wasn’t easy, so I’m not using DSC.” DSC isn’t easy, correct. None of this stuff is**. The ConfigurationData stuff, for example - all the examples you see are hard-bound to a host name, yeah, but that’s not how people are evolving. Again at Camp, we looked at a couple of approaches for decoupling. The Camp alumni maintain very close contact, and as we start to nail down practices and approaches, we tend to publish them. Matt Hitchcock and Derek Ardolf, for example, are working on an ebook around some of this stuff.

Also:
> And the whole Tug project, as one more example, is to create a smarter pull server that can dynamically generate MOFs based on run-time criteria. Again, the magic is all on the pull server side. DSC’s strength is that it’s more or less entirely open, so what it lacks natively in tooling or whatever, you can make up for.

Lastly:
> Why not post some of this to the Forums at PowerShell.org? There’s a lot of people who could offer some perspective, not just me.

## Initial post: Some reflections on DSC after two weeks: 9/29/2016 <a id="initial-post"></a>

I’ve coming around to thinking that DSC is too immature to even use as a stopgap. I’d like to research using Chef in local-mode with kitchen-azurerm or with `test-kitchen` to provision each system until we get a real ChefServer in (and Oracle Linux). That will let us write re-usable Chef code starting now. I was hoping DSC would work better so that our federal compatriots didn’t have to learn Chef on top of everything else, but try as I might to like DSC, it’s not happening for me.

### What's likable about DSC

- Fewer languages and moving parts is better. If our customers are taking a code-first, ui-clicky last approach, then they'll probably be doing more stuff in Windows w/ Powershell than they did
in the past. I'd prefer to do more in Posh, than having to throw Ruby and the Chef DSL in the mix too.
- DSC is supported is by Microsoft
- Azure has some good support for DSC pull service w/ AzureAutomation
- The DSC 'scripts' don't allow for node introspection at run time, since everything is compiled to MOF, then execute on the target system. This could be a good thing, cause then you're by design writing DSC resources properly instead of jamming a lot of logic in the script (which should be a high-level description of your node's state)
  - A lot of Chef ugliness comes from long recipes where users should have written _custom resources_ instead
  - Notion of _Testers_ _Getters_ _Setters_ not a bad one, but the testers/setters are to some extent reflective of the missing inventory systems _a la_ `Facter` or `Ohai`

### What's hard to like:

- Testing feedback is really slow.
  - _Update 13 Oct_: Only tested vs. Win2012R2 Azure VMs, possibly faster w/ 2016 (and certainly w/ Nano), and possibly with other virtualization approaches.
- Error tracking is awful. E.g. a MOF with a dozen File resources may have one that lacks a DestinationPath, but the error emitted only says there's a missing DestinationPath, not which resource is the problematic one. Chef and Puppet provide much finer-grained error messages for locating issues (_updated_).
- Very few available resources - only 190 in the PowerShell gallery
- Very few High Quality resources (see the DSCResource repo)
  - _Update 13 Oct_: This is an unfair comment on my part. Chef/Puppet/Ansible all have the same risk of low-quality
- Mysterious hangs and locked runs - e.g. experiences w/ xSQLServerSetup resource.
- Code requires lots of boiler plate and copy-pasa. See e.g. the SharePoint HQ resource.
  - _Update 13 Oct_: As just one example from the SharePoint resource, these three codeblocks are _identical_, so for a 240-line module, fully 66 lines are the same param block repeated three times.:
    - [https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L5-L27](https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L5-L27)
    - [https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L68-L90](https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L68-L90)
    - [https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L199-L221](https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L199-L221)
  - _Update 14 Oct_: Class-based resources seem to alleviate this issue. See e.g. [https://flynnbundy.com/2016/05/16/getting-started-with-class-based-dsc-resources/](https://flynnbundy.com/2016/05/16/getting-started-with-class-based-dsc-resources/)
- ConfigurationData seems tied to notion of long-lived named nodes (pets), _although I may just be poorly informed here_.
  - _Update 13 Oct_: See correction above.
- Authoring/publishing is certainly no better than Chef/Puppet, and quite possibly worse
  - _Update 13 Oct_: The Chef cookbook TDD workflow of local dev and test with unit and integration tests, then push to code repo for CI system to test and handle PRs, then publish to a ChefServer is what I expect form and inf-as-code system. I've not seen that yet for DSC
- Composition and modularity not well-structured
  - _Update 13 Oct_: When I wrote this I may have conflated Partials (evil) with Composite configs. I think I need to categorize as 'toss-up' until I've worked more with it.
- Resource extension (instead of forking and adapting) not supported.
- Chicken-egg problem of getting required resource modules to target no better than the hell of the Chef-Gem process, and possibly worse.
  - _Update 13 Oct_:  Don Jones strongly encourages DSC pull for this.

### Possible approaches with Chef pending Chef Server

- Use AzureAutomation to manage the chef-clients and loading of cookbooks (crazy, potentially cool)
- Use local development and kitchen to test, then `kitchen-azurerm` to push to select nodes until we have a Chef Server
