After watching all point-free navigation series, studying the new NavigationStack API,
searching 3rd party navigation packages, and developing several test projects,
this implementation seems the most reliable one.
There are some inline documentation and explanation.

### iOS15
`NavigationLink` can not detect when NavigationTree is initialized deeper than two-level,
there is no `NavigationLink` workarounds, and it is a well-known bug.
