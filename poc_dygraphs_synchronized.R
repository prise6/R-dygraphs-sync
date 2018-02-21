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
