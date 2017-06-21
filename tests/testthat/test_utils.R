context("test bowerbird utilities")

test_that("check_method_is works",{
    expect_true(check_method_is("aadc_eds_get",aadc_eds_get)) ## function name as string
    expect_true(check_method_is(aadc_eds_get,aadc_eds_get)) ## function
    expect_true(check_method_is(enquote(aadc_eds_get),aadc_eds_get))
    expect_true(check_method_is(quote(aadc_eds_get()),aadc_eds_get))
    expect_true(check_method_is(quote(aadc_eds_get),aadc_eds_get)) ## symbol
})

test_that("method dispatch code works",{
    mycat <- function(data_source,...) cat(data_source,...)
    ## as function
    myarg <- "oui oui"
    mth <- mycat
    expect_true(is.function(mth))
    expect_error(expect_output(do.call(mth,list()),"argument \"data_source\" is missing"))
    expect_output(do.call(mth,list(data_source=myarg)),myarg)
    expect_output(do.call(mth,list(myarg)),myarg)
    expect_error(do.call(mth,list(blah=myarg)))
    
    ## as symbol
    mth <- quote(mycat)
    expect_true(is.name(mth))
    expect_error(expect_output(do.call(eval(mth),list()),"argument \"data_source\" is missing"))
    expect_output(do.call(eval(mth),list(data_source=myarg)),myarg)
    expect_output(do.call(eval(mth),list(myarg)),myarg)

    ## call constructed by e.g. enquote(fun)
    mth <- enquote(mycat)
    expect_true(is.call(mth))
    expect_identical(all.names(mth)[1],"quote")
    expect_error(expect_output(do.call(eval(mth)[1],list()),"argument \"data_source\" is missing"))
    expect_output(do.call(eval(mth),list(data_source=myarg)),myarg)
    expect_output(do.call(eval(mth),list(myarg)),myarg)


    ## test arg injection nonsense
    expect_identical(inject_args(quote(cat(z=3)),list(a=0,b=1)),list(a=0,b=1,3))
    expect_identical(inject_args(quote(cat(z=3)),list(a=0,b=1),extras_first=FALSE),list(3,a=0,b=1))
    
    ## call constructed as e.g. quote(fun())
    mth <- quote(mycat())
    expect_true(is.call(mth))
    expect_false(all.names(mth)[1]=="quote")
    expect_identical(all.names(mth)[1],"mycat")
    expect_error(expect_output(do.call(all.names(mth)[1],list()),"argument \"data_source\" is missing"))
    expect_output(do.call(all.names(mth)[1],list(data_source=myarg)),myarg)
    expect_output(do.call(all.names(mth)[1],list(myarg)),myarg)
    ## inject named arg alongside the ones already provided
    arglist <- inject_args(mth,list(data_source=myarg))
    expect_output(do.call(all.names(mth)[1],arglist),myarg)    
    ## can have extra args in this form
    mth <- quote(mycat("last_var"))
    expect_true(is.call(mth))
    expect_false(all.names(mth)[1]=="quote")
    expect_identical(all.names(mth)[1],"mycat")
    ## call with no args
    expect_error(expect_output(do.call(all.names(mth)[1],list()),"argument \"data_source\" is missing"))
    ## call with one arg (ignore the already-provided one)
    expect_output(do.call(all.names(mth)[1],list(data_source=myarg)),myarg)    
    ## inject named arg alongside the ones already provided
    arglist <- inject_args(mth,list(data_source=myarg))
    expect_output(do.call(all.names(mth)[1],arglist),paste(myarg,"last_var"))
})

    