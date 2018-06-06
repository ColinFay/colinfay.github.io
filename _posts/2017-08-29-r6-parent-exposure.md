---
title: "R6 and parent exposure"

post_date: 2017-08-28
layout: single
permalink: /r6-parent-exposure/
categories : r-blog-en
tags: [R6]
excerpt_separator: #----#
---

About R6 and parent exposure. 

#----#

## Default inheritance

By default, R6 objects can only herit from their direct parent. But you may need to create an inheritance which goes along the family tree. 

For example, we need to create a grand-child class `PersonGrandChild`, which inherits from a child class `PersonChild`, which inherits from the parent `Person`. The idea is to have a grand-child class with predifined and fixed `first_name`, `last_name`, and use with `initialize` the method from its grand-parent. The naive approach would be to use `$super$super`

``` r
library(R6)
Person <- R6Class("Person", 
                    public = list(
                      first_name = NULL, 
                      last_name = NULL, 
                      initialize = function(first, last){
                        self$first_name <- first
                        self$last_name <- last
                      }
                    )
)
PersonChild <- R6Class("PersonChild", 
                       inherit = Person)
PersonGrandChild <- R6Class("PersonGrandChild",
                            inherit = PersonChild, 
                            public = list(
                              initialize = function(){
                                super$super$initialize(first_name = "Colin", last_name = "Fay", age = 37, job = "R developper")
                              }  
                            )
)
try(PersonGrandChild$new())
Error in .subset2(public_bind_env, "initialize")(...) : 
  tentative d'appliquer un objet qui n'est pas une fonction
```

But that throws an error, because you can't use `$super$super`: an R6 object doesn't, by defaut, expose his parents to his children. A way to get around this feature is to use active binding. For that, you can create a method `super_` inside a class, which simply returns `super`. Then, use `$super$super_` inside the child class : 

``` r
PersonChild$set("active", "super_", function() super)
PersonGrandChildExposed <- R6Class("PersonGrandChildExposed",
                                   inherit = PersonChild, 
                                   public = list(
                                     initialize = function(){
                                       super$super_$initialize(first = "Colin", last = "Fay")
                                     }  
                                   )
)

PersonGrandChildExposed$new()
<PersonGrandChildExposed>
  Inherits from: <PersonChild>
  Public:
    clone: function (deep = FALSE) 
    first_name: Colin
    initialize: function () 
    last_name: Fay
    super_: active binding
```

Works like a charm ;)




