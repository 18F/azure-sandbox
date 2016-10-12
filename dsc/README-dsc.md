N.B. This is a work-in-progress regarding our early work with DSC. As this has _not_ been published as blog post is should not
be considered a fixed opinion of any sort, and certainly not an endorsement of any technology by the GSA or 18F. AND we would love your help! Please engage with @pburkholder on twitter or open an issue.  

Context: 18F is working with an agency on some process modernization, and they are a 100% Windows shop moving into Azure. I'm trying to make some technology choices to provide them a usable app and infra pipeline in the next months.
And that not daunting for us to introduce others to and train them on. While I can reasonably questioned about making technology choices on behalf of end-users, that is the context I find myself in.

This README summarize some of my experiences, and some of those in the community, with using DSC/Azure Automation, with an end goal making a recommendation on what tools to use for infrastructure-as-code.

## Powershell.org postings

###  Read [Chef v. DSC implementation](https://powershell.org/forums/topic/chef-vs-dsc-implementation/) from April 2016.
Key points, with my editorializing in *ital* and/or \[brackets\]
- https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/ (May 2014)
- https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/ (Sept 2014)
- Chef has reporting. Chef has a library of resources
  - \[*DSC in AzureAutomation seems to have good reporting, but haven't seen it yet myself*\]
- DSC doesn't have subscribe/notifies
- DSC doesn't have:
  - Password management \[probably fixed with Azure KV store\]
  - Code delivery \[possibly fixed with Azure Automation w/ source code repo\]
  - LCM Agent Management \[No idea - help?\]
  - DSC doesn't have test-kitchen \[but it does now\]

###  May 2014: [Why Puppet vs DSC isn't even a thing]https://powershell.org/2014/05/14/why-puppet-vs-dsc-isnt-even-a-thing/

Rich Siegel has some great comments:
> At the heart of a good puppet or chef or ansible implementation, is something that is not part of any of them. This is version control.

> The pipeline is how do people work. How do they submit changes into the pipeline, how are they reviewed, tested and subsequently deployed. The vision with DSC is lost because it feels like Microsoft isn't sure how you should do this, or doesn't want to enter this space. \[_This seems to have changed w/ AA_\]

>  It isn't clear how you write tests around powershell DSC code, and know its good before pushing to 100s or 1000s of nodes . How do you lint it? How do you unwind a bad push/pull. Ruby has a strong TDD community spirit, and Powershell has Pester (which I have improved) but it has not received a nod as "the go to framework". We do use it for chocolatey. Phabricator and Gerrit have become key tools for peer review and create "safety stops" to prevent bad code from moving into prod. Testing is the second most important part of config management after the version control and people need to be engaged in how testing is conducted.

> Ruby is a cross platform language, powershell is not...

- DSC doesn't support callback to the node or server for configuration context (but the underlying Powershell resources could)

Darren Mar-Elia:
> I think the DSC integration work that Chef showed almost a year ago could provide the best of both worlds

### [WHY CHEF + DSC? (REVISITED)](https://blog.chef.io/2014/09/03/why-chef-dsc-revisited/)

Steve Murawski's notable differences, as I see them today
- Linting - Chef has lots of options; DSC has xDSCResourceDesigner \[See also from May 2016: https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourcemofdesigner and included links...\]
- Inventory tool. Chef has Ohia \[Puppet has Facter\], DSC ecosystem seems not to use this. Each provider needs it's own Get-/Test- function.


###

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




## Some reflections on DSC after two weeks: 9/29/2016

I’ve coming around to thinking that DSC is too immature to even use as a stopgap. I’d like to research using Chef in local-mode with kitchen-azurerm to provision each system until we get a real ChefServer in (and Oracle Linux). That will let us write re-usable Chef code starting now. I was hoping DSC would work better so that our federal compatriots didn’t have to learn Chef on top of everything else, but try as I might to like DSC, it’s not happening for me

### What's likable about DSC

- Fewer languages and moving parts is better. If our customers are taking more a code-first, ui-clicky last
approach, then they'll probably be doing more stuff in Windows w/ Powershell than they did
in the past. I'd prefer to do more in Posh, then having to throw Ruby and the Chef DSL in the mix too.
- DSC is support is by MS
- Azure has some good support for DSC pull service w/ AzureAutomation
- The DSC 'scripts' don't allow for node introspection at run time, since everything is compiled to MOF, then
execute on the target system. This could be a good thing, cause then you're by design writing DSC resources properly
instead of jamming a lot of logic in the script (which should be a highlevel description of your nodes' state)
  - A lot of Chef ugliness comes from long recipes where users should have written _custom resources_ instead
  - Notion of _Testers_ _Getters_ _Setters_ not a bad one.

### What's hard to like:

- Testing feedback is really slow.
- Error tracking is awful. E.g. a MOF with a dozen File resources may have on that lacks a DestinationPath, but the error doesn't help at all.  
- Very few available resources.
- Very few High Quality resources (see the DSCResource repo)
- Mysterious hangs and locked runs - e.g. my experience w/ xSQLServerSetup resource.
- Code requires lots of boiler plate and copy-pasa. See e.g. the SharePoint HQ resource.
- ConfigurationData seems tied to notion of long-lived named nodes (pets), _although I may just be poorly informed here_.
- Authoring/publishing is certainly no better than Chef/Puppet, and quite possibly worse
- Composition and modularity not well-structured
- Resource extension (instead of forking and adapting) not supported.
- Chicken-egg problem of getting required resource modules to target no better than the hell of the Chef-Gem process, and possibly worse.

### Possible approaches

- Use AzureAutomation to manage the chef-clients and loading of cookbooks (crazy, potentially cool)
- Use local development and kitchen to test, then `kitchen-azurerm` to push to select nodes until we have a Chef Server
