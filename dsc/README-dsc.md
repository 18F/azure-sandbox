## Some reflections on DSC after two weeks

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
