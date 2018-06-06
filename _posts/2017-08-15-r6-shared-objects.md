---
title: "R6 and shared objects"

post_date: 2017-08-15
layout: single
permalink: /r6-shared-objects/
categories : r-blog-en
tags: [R6]
excerpt_separator: #----#
---

A short tutorial about how to share objects between all instances of an R6 class.

#----#

When you create a new object which is an instance of an R6 class, it contains its own data fields — i.e. one change in an object is not reflected inside all the instances of the class. If you made a mistake in the class definition, you can't just change something in the parent and expect the change to be reflected in the children who inherited from your parent class. Or maybe you need to work with the same dataframe all along, and whenever you change something in it, you want the dataframe to be updated for everyone.

## Share elements across all instances of a class

Well, that was partially true: this is the default behavior of R6 objects, and in fact you can make objects shareable inside all the instances of a class, i.e. a change in one class instance will be reflected in all the instances of this class. For this, you'll need to create an environment in the `shared` element, which is to be put inside your `private` field. 

Let's compare a class which doesn't share its object:

```r
library(R6)
GrandParentClassic <- R6Class("GrandParent", 
                   public = list(
                     name = "Grandparent"
                   ))

grand_pa_classic <- GrandParentClassic$new()
grand_ma_classic <- GrandParentClassic$new()

grand_pa_classic$name == grand_ma_classic$name
[1] TRUE

grand_pa_classic$name <- "Grand Pa"
grand_pa_classic$name == grand_ma_classic$name
[1] FALSE
```

As you can see, a change in one of the instances is not reflected inside the others — changing the name of the `grand_pa_classic` object does not change the name of `grand_ma_classic`. That's usually the behavior you want your objects to have — but sometime you don't. And for that, you need to create the objects to be shared in an environment inside the `shared` method in your `private` field. You can then access it with active binding. 

```r
GrandParentShared <- R6Class("GrandParent",
                       private = list(
                         shared = {
                        env <- new.env()
                        env$name <- "Grand Parent"
                        env
                         }
                       ),
                       active = list(
                         name = function(value){
                           if(missing(value)) return(private$shared$name)
                           else private$shared$name <- value
                         }
                       )
)

grand_pa_shared <- GrandParentShared$new()
grand_ma_shared <- GrandParentShared$new()

grand_pa_shared$name == grand_ma_shared$name
[1] TRUE

grand_pa_shared$name <- "Grand Pa"
grand_pa_shared$name == grand_ma_shared$name
[1] TRUE
```

Here, changes in one instance are reflected in other instances. That's because {R6} does not copy by value environments: they are always copied by reference, so point to the same slot in memory. 

The same can goes if you want to pass shared objects along the inheritance tree:

```r
# Without Shared field
PapaClassic <- R6Class("PapaClassic", 
                inherit = GrandParentClassic)
ChildClassic <- R6Class("ChildClassic", 
                 inherit = PapaClassic)
                 
grand_pa_classic <- GrandParentClassic$new()
papa_classic <- PapaClassic$new()
child_classic <- ChildClassic$new()

grand_pa_classic$name == papa_classic$name
[1] TRUE
papa_classic$name == child_classic$name
[1]TRUE 

papa_classic$name <- "Papa"
grand_pa_classic$name == papa_classic$name
[1] FALSE
papa_classic$name == child_classic$name
[1] FALSE

# With Shared field
PapaShared <- R6Class("PapaShared", 
                inherit = GrandParentShared)
ChildShared <- R6Class("ChildShared", 
                 inherit = PapaShared)

grand_pa_shared <- GrandParentShared$new()
papa_shared <- PapaShared$new()
child_shared <- ChildShared$new()

grand_pa_shared$name == papa_shared$name
[1] TRUE
papa_shared$name == child_shared$name
[1] TRUE

papa_shared$name <- "Papa"
grand_pa_shared$name == papa_shared$name
[1] TRUE
papa_shared$name == child_shared$name
[1] TRUE
```
As you can seen, changes flow all along the family tree! 



