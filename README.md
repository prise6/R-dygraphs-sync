## Proof of concept

Quick goal: use `Dygraph` R library with extra `synchronized.plugin.js` to make something lihe [this](http://dygraphs.com/tests/synchronize.html)

I didn't check if someone have already done this, but no refs in [official doc](https://rstudio.github.io/dygraphs/gallery-synchronization.html)


### synchronized.plugin.js

This script can be found [there](https://github.com/danvk/dygraphs/blob/master/src/extras/synchronizer.js)

Actually, the version of dygraph used in the R package is 1.1.1. So i tried to download the `synchronizer.js` of the 1.1.1 version.
For some reasons it's very slow and creates bugs. 
To finish, i downloaded the last version (master) and updates one line :

```js
// comment this line 
// var idx = gs[i].getRowForX(x);
// and use this one :
var idx = gs[i].findClosestRow(gs[i].toDomXCoord(x));
```

Infos can be found [on SO](https://stackoverflow.com/questions/32909738/dygraphs-synchronization-error).


To use the `Dygraph.synchronize()` function you have to access the Dygraph object, like this :

```js
var g1 = new Dygraph(...),
    g2 = new Dygraph(...),
    ...;
var sync = Dygraph.synchronize(g1, g2, ...);
// charts are now synchronized
sync.detach();
// charts are no longer synchronized
```


### Dygraph

In the current version of dygraph [package](https://github.com/rstudio/dygraphs) (master version), it seems there is no way to acces the dygraph js object for client. See [this issue](https://github.com/rstudio/dygraphs/issues/196).
With `htmlwidget`, you should have an acces with this following functions :

* `HTMLWidgets.getInstance()`
* `HTMLWidgets.find()`
* `HTMLWidgets.findAll()`

[See refs](https://github.com/ramnathv/htmlwidgets/pull/171)

There is a [pull request](https://github.com/rstudio/dygraphs/pull/197) that fixes this issue.
I tried to test with it.

#### install package from pull request

My way (get new commit and merge with PR)

```bash
cd ~
mkdir Dygraphs
git clone https://github.com/rstudio/dygraphs.git Dygraphs
cd  Dygraphs
git branch fix
git checkout fix
git pull origin pull/197/head:master
```

And then in R:

```R
lib.tmp = "~/tmp_lib"
withr::with_libpaths(new  = lib.tmp, devtools::install_git("~/Dygraphs/", branch = "fix"))
```


Another way from R:

```R
lib.tmp = "~/tmp_lib"
withr::with_libpaths(new  = lib.tmp, devtools::install_github("timelyportfolio/dygraphs_htmlwidget"))
```

Notice that the library is installed in another lib path ("~/tmp_lib").



### Code

An exemple:

```R
lib.tmp = "~/tmp_lib"
library(dygraphs, lib.loc = lib.tmp)
library(htmlwidgets)
library(htmltools)


browsable(
  tagList(
    dygraph(fdeaths, elementId = "dy_fdeath"),
    dygraph(mdeaths, elementId = "dy_mdeath"),
    
    htmlDependency(name = "synchronizeDygraph", src = file.path(getwd(), "www"), script = "synchronized.plugin.js", version = "1.1.1"),
    tags$script(
      "
      var dygraphsCollection;
      var dygraphSync;
      
      setTimeout(
        function() {
          dygraphsCollection = HTMLWidgets.findAll('.dygraphs').map(function(o){return(o.dygraph)});
          dygraphSync = Dygraph.synchronize(dygraphsCollection, {selection : true});
        }, 50
      )
      "
    )
  )
)

```


### Go futher

This repo is just a test of course. So feel free to develop this idea further.







