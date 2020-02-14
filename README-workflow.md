
# Workflow

## 1. Product owner adds new feature card to "Intake"

## 2. Developer Alpha takes card and moves to "Under development"

### 2.0 Development!

- Alpha checks out code to work station
- Alpha writes new test for feature
- Alpha verifies test failure
- Alpha writes and saves new code
- Alpha verifies tests pass
- Alpha commits code and pushes to TFS/Git

### 2.1 Push to TFS triggers Jenkins

### 2.2 Jenkins runs build and, if it builds, kicks off tests

- Jenkins runs Lint tools (local)
- Jenkins runs Unit tests (local
- Jenkins kicks of static code analysis (remote)
- Jenkins aggregates tests results, notifies Alpha

### 2.3 Alpha reviews results, if fail, return to 2.0, else...

### Tools needed for step 2

- Workstation with development tools (Vss, Git, etc.)
- TFS/Git
- Jenkins/Automate
- Fortify SCA
- Nexus
- Build system (MsBuild, Gradle, on Jenkins nodes)
- Unit test framework (on Jenkins nodes)

## 3. Developer Alpha submits Pull Request to Master, moves card to "Needs Review"

## 4. Developer Beta takes card and moves to "Developer Review"

- Developer Beta reads code carefully, discusses with Alpha (or others)
- If anything needs changes, return to 2.0
- Otherwise, Beta merges PR into Master on TFS
  - If there are merge conflicts, return to 2.0

### Tooling for step 4:

- TFS/Git

## 5.  Developer Beta moves card to "Acceptance Testing"

### 5.1 Functional testing with Jenkins (or Chef Automate)

- On merge to master, TFS kicks off Jenkins Acceptance build
- Jenkins builds _artifacts_ and stores to Nexus
- Jenkins job kicks off ephemeral test environment:
  - Uses Azure API to instantiate systems with metadata indicating
    what build to install
  - Azure systems use Chef to converge to desired state, checkout the build from
    Nexus, and launch application
- Jenkins detects new environment, runs smoke test, if passess, then
  - Kick off Appscan
  - Kick off Nessus scan
  - Kick off Fortify webinspect
- If tests pass, then Jenkins promotes artifact to Nexus "deployment
  candidate"
  - Jenkins tears down the acceptance env

### 5.2 Developer moves card to "Ready for Owner Review"

### Tooling for step 5

- Jenkins/Automate
- Appscan
- Nessus
- Fortify Webinspect
- Appscan
- Azure
- Chef

## 6 Product owner review - Moves card to "Owner Review"

- If product owner is satisfied, then moves issue to "Integration Testing"

### 6.1 Integration testing

- All the steps up to this point have been for a single software component or
  project. If there are multiple projects comprising an application, or a
  site, then they share a common environment for each of
  - Integration
  - Preproduction
  - Production

- Product Owner kicks off integration build:
  - Jenkins instantiates new app in azure
    - New nodes come up
    - Attaches to load balancer
    - Old nodes are destroyed
    - Database migrations run
  - Smoke tests run
  - Functional tests run
  - Human testing takes place.

### 6.2 Product owner moves card to "Ready for Release"

### Tooling for step 6

- Jenkins/Automate
- Chef
- Nexus artifact repository
- Possibly a deployment tool like Octopus to orchestrate blue/green release with migrations


## 7. Release to Production, Move card to "Releasing"

- Product Owner kicks off release job
  - Same process as integration build, but in Pre-production environment
  - Smoke and functional tests run
  - If they pass, then same artifacts are __automatically__ released to
    Production
    - This is important! If you don't release the code to production at this
      point, then your pre-production environment is no longer preprod, but a
      randomized mutant.
  - If they fail, then all work stops to code a fix through the prior parts of
    the pipeline

### Tooling for step 7

- Same as for step 6

## 8. High Fives. Move card to "Released"


## References

- http://www.jamesshore.com/Blog/Continuous-Integration-on-a-Dollar-a-Day.html
- https://docs.chef.io/workflow.html
- Continuous Delivery
