**Posited**: In a heterogenous computing environment where dev and ops are comfortable with both Linux and Windows, and with various high-level languages like Ruby or Powershell, then Chef/Puppet is a better choice than DSC for Windows automation.

However, even in a monoculture of Windows and Powershell, DSC is still not mature enough for lifecycle management of a wide variety of systems, and it's better to bite the bullet and introduce Linux servers to host Chef or Puppet and introduce those systems to nascent DevOps teams.

**Conclusion: Sep 29: True**

**Conclusion: Oct 13: Merits further study**

### _Nota Bene_

This is a work-in-progress regarding our early work with DSC. As this has _not_ been formally published  it should not
be considered a fixed opinion of any sort, and certainly not an endorsement of any technology by the GSA or 18F. AND we would love your help! Please open an issue if you have further information or opinions to add.

This README summarize our experiences, and some of those in the community, with using DSC/Azure Automation, with an end goal of making a recommendation on which tools to experiment with first for larger-scale infrastructure-as-code.

### Context

18F is working with an agency on some process modernization, and they are a 100% Windows shop moving into Azure. I'm trying to make some technology choices to provide them a usable app and infra pipeline in the next months. The systems in the initial pipeline environment include:

- TFS
- Jenkins leader and build nodes
- HP Fortify
- IMB AppScan

and some initial core infra for logging and monitoring.

I would like to consider all these systems as crops, not houseplants (or cattle, not pets), and automate their lifecycles for (all the reasons). As for that automation, the choices are:
- Chef (not an endorsement of Chef over Puppet. Simply, the differences between them matter less than the fact that I can build out infra quickly w/ Chef, instead re-re-releaning Puppet)
- DSC w/ AzureAutomation
- SCCM: I have no experience with SCCM and will let the folks at partner agency w/ SCCM experience help determine what role it should play.


### Chef or DSC?

I would really like DSC to work out because:
- eventual users and owners are more comfortable with Windows and Powershell than they are with Ruby, Linux and open-source in general
- there is greater trust afforded a COTS Microsoft system than an open-source based system like Chef (yes, I know DSC is OSS, but it has Micrsoft's imprimatur)
- reducing the number to tool & technology hurdles we have to clear helps conserve organizational capital for taking on other changes, like granting developers commit bits on the IAC code repositories. This concern has already come up, as [I've addressed in this draft on IAC and admin rights](https://gist.github.com/pburkholder/9c397c36fb966bd54be7c39ff1501776)

I've been using declarative configuration management systems since 2004, with CfEngine2, then Puppet, then Chef, and with a smattering of Ansible. With that background, I thought in mid-September 2016 that two weeks would be sufficient to get a handle on the basis of DSC.

However, my initial foray into DSC-land was rather frustrating, and my initial write-up was [gently mocked at Powershell.org](https://powershell.org/2016/10/12/no-easy-button-for-configuration-management/) (see the ['Initial Post' below for my original commentary](#initial-post)). While I never expected DSC (or any CF system) to be "easy," my initial poor impression stemmed from a few things not related to DSC itself:

* My initial impressions may have been somewhat tainted by my relative inexperience in Windows and PowerShell, irrespective of DSC itself.
* Further, I did not have access to a Windows workstation or local virtualization, so relying on RDP to remote VMS probably tainted my overall experience.
* I used DSC push, instead of DSC pull, which, as Don Jones says: "DSC push mode is basically scratching the surface. You didn’t really explore it if you didn’t get into how Pull affects the architecture"

## Powershell.org postings and related reading

Summaries of key DSC literature, with dates as this space is moving pretty fast.

###  April 2016: [Chef v. DSC implementation](https://powershell.org/forums/topic/chef-vs-dsc-implementation/)
Key points, with my editorializing in *ital* and/or \[brackets\]
- Link: https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/ (May 2014)
- Link: https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/ (Sept 2014)
- Chef has reporting. Chef has a library of resources
  - \[*DSC in AzureAutomation seems to have good reporting, but haven't seen it yet myself*\]
- DSC doesn't have subscribe/notifies
- DSC doesn't have:
  - Password management \[probably fixed with Azure KV store\]
  - Code delivery \[possibly fixed with Azure Automation w/ source code repo\]
  - LCM Agent Management \[No idea - help?\]
  - DSC doesn't have test-kitchen \[but it does now\]

###  May 2014: [Why Puppet vs DSC isn't even a thing](https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/)

Rich Siegel has some great comments:
> At the heart of a good puppet or chef or ansible implementation, is something that is not part of any of them. This is version control.

> The pipeline is how do people work. How do they submit changes into the pipeline, how are they reviewed, tested and subsequently deployed. The vision with DSC is lost because it feels like Microsoft isn't sure how you should do this, or doesn't want to enter this space. \[_This seems to have changed w/ AA_\]

>  It isn't clear how you write tests around powershell DSC code, and know its good before pushing to 100s or 1000s of nodes . How do you lint it? How do you unwind a bad push/pull. Ruby has a strong TDD community spirit, and Powershell has Pester (which I have improved) but it has not received a nod as "the go to framework". We do use it for chocolatey. Phabricator and Gerrit have become key tools for peer review and create "safety stops" to prevent bad code from moving into prod. Testing is the second most important part of config management after the version control and people need to be engaged in how testing is conducted.

> Ruby is a cross platform language, powershell is not...

- DSC doesn't support callback to the node or server for configuration context (but the underlying Powershell resources could)

Darren Mar-Elia:
> I think the DSC integration work that Chef showed almost a year ago could provide the best of both worlds

### Sept 2014: [WHY CHEF + DSC? (REVISITED)](https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/)

Steve Murawski's notable differences, as I see them today
- Linting - Chef has lots of options; DSC has xDSCResourceDesigner \[See also from May 2016: https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcemofdesigner and included links...\]
- Inventory tool. Chef has Ohia \[Puppet has Facter\], DSC ecosystem seems not to use this. Each provider needs it's own Get-/Test- function.


### Oct 2016: [DSC ConfigurationData Blocks in a World of Cattle](https://powershell.org/2016/10/11/dsc-configurationdata-blocks-in-a-world-of-cattle/)

It's not been clear with the MOF generation processing being linked to `NodeName` how to apply DSC as roles
to nodes that don't exist yet. Key point here is that node name reported from node to pull server need not be unique. Nothing at https://msdn.microsoft.com/en-us/powershell/dsc/configdata implies uniqueness constraints.

>  "NodeName" is a misleading setting, but if you think of it as a role, which could be applied to multiple actual machines, then it makes a lot more sense that way.

It's not clear to me where the nodename comes from, possibly from LCM config as in:

```
Set-DscLocalConfigurationManager -Path ./localhost.meta.mof -ComputerName NODE1
```

TODO: Dig into how this works


### Pricing

* Chef: OpenSource- Free, Chef Automate: $137/node/annum (includes Workflow, Compliance, Visibility)
* DSC Pull Server: Free
* DSC Azure Automation: $72/node/annum (no analog to Chef Compliance or Workflow)

## Update 12 Oct 2016

(Sorry for reverse chronological order, but I think the update is more interesting than the original content)

I managed to engage the redoubtable Don Jones on this topic, as we were conversing about some corrections
to [his DSC book](https://leanpub.com/the-dsc-book). Some comments from him include:

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

- Fewer languages and moving parts is better. If our customers are taking more a code-first, ui-clicky last
approach, then they'll probably be doing more stuff in Windows w/ Powershell than they did
in the past. I'd prefer to do more in Posh, than having to throw Ruby and the Chef DSL in the mix too.
- DSC is supported is by Microsoft
- Azure has some good support for DSC pull service w/ AzureAutomation
- The DSC 'scripts' don't allow for node introspection at run time, since everything is compiled to MOF, then
execute on the target system. This could be a good thing, cause then you're by design writing DSC resources properly
instead of jamming a lot of logic in the script (which should be a high-level description of your node's state)
  - A lot of Chef ugliness comes from long recipes where users should have written _custom resources_ instead
  - Notion of _Testers_ _Getters_ _Setters_ not a bad one, but the testers/setters are to some extent reflective of the missing inventory systems _a la_ `Facter` or `Ohai`

### What's hard to like:

- Testing feedback is really slow.
  - _Update 13 Oct_: Only tested vs. Win2012R2 Azure VMs, possibly faster w/ 2016 (and certainly w/ Nano), and possibly with other virtualization approaches.
- Error tracking is awful. E.g. a MOF with a dozen File resources may have one that lacks a DestinationPath, but the error emitted only says there's a missing DestinationPath, not which resource is the problematic one. Chef and Puppet provide much finer-grained error messages for locating issues (_updated_).
- Very few available resources - only 190 in the PowerShell gallery
- Very few High Quality resources (see the DSCResource repo)
  - _Update 13 Oct_: This is an unfair comment on my part. Chef/Puppet/Ansible all have the same risk of low-quality
- Mysterious hangs and locked runs - e.g. my experience w/ xSQLServerSetup resource.
- Code requires lots of boiler plate and copy-pasa. See e.g. the SharePoint HQ resource.
  - _Update from orginal post_: As just one example from the SharePoint resource, these three codeblocks are _identical_, so for a 240-line module, fully 66 lines are the same param block repeated three times.:
    - https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L5-L27
    - https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L68-L90
    - https://github.com/PowerShell/SharePointDsc/blob/master/Modules/SharePointDsc/DSCResources/MSFT_SPInstall/MSFT_SPInstall.psm1#L199-L221
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
