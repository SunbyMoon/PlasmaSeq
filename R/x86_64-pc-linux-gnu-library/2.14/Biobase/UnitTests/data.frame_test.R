checkDataFramesEqual <- function(obj1, obj2) {
    checkTrue(identical(row.names(obj1), row.names(obj2)))
    checkTrue(identical(colnames(obj1), colnames(obj2)))
    checkTrue(all(sapply(colnames(obj1), function(nm) identical(obj1[[nm]], obj2[[nm]]))))
}

testCombineDf <- function() {
    ## no warnings
    x <- data.frame(x=1:5,y=letters[1:5], row.names=letters[1:5])
    y <- data.frame(z=3:7,y=letters[c(3:5,1:2)], row.names=letters[3:7])
    z <- combine(x,y)
    checkDataFramesEqual(x, z[1:5, colnames(x)])
    checkDataFramesEqual(y, z[3:7, colnames(y)])

    ## an error -- content mismatch
    x <- data.frame(x=1:3, y=letters[1:3], row.names=letters[1:3])
    y <- data.frame(z=2:4, y=letters[1:3], row.names=letters[2:4])
    checkException(suppressWarnings(combine(x,y)), silent=TRUE)

    ## a warning -- level coercion
    oldw <- options("warn")
    options(warn=2)
    on.exit(options(oldw))
    x <- data.frame(x=1:2, y=letters[1:2], row.names=letters[1:2])
    y <- data.frame(z=2:3, y=letters[2:3], row.names=letters[2:3])
    checkException(combine(x,y), silent=TRUE)
    options(oldw)
    checkDataFramesEqual(suppressWarnings(combine(x,y)),
                         data.frame(x=c(1:2, NA),
                                    y=letters[1:3],
                                    z=c(NA, 2:3),
                                    row.names=letters[1:3]))
}

testCombineDfPreserveNumericRows <- function() {
    dfA <- data.frame(label=rep("x", 2), row.names=1:2)
    dfB <- data.frame(label=rep("x", 3), row.names=3:5)
    dfAB <- combine(dfA, dfB)
    ## preserve integer row names if possible
    checkEquals(1:5, attr(dfAB, "row.names"))

    ## silently coerce row.names to character
    dfC <- data.frame(label=rep("x", 2), row.names=as.character(3:4))
    dfAC <- combine(dfA, dfC)
    checkEquals(as.character(1:4), attr(dfAC, "row.names"))
}

testNoRow <- function() {
    x <- data.frame(x=1,y=letters[1])[FALSE,]
    y <- data.frame(z=1,y=letters[1])[FALSE,]
    z <- combine(x,x)
    checkTrue(identical(dim(z), as.integer(c(0,2))))
    x <- data.frame(x=1,y=letters[1])[FALSE,]
    y <- data.frame(z=1,y=letters[1])
    z <- combine(x,y)
    checkTrue(identical(dim(z), as.integer(c(1,3))))
    checkTrue(is.na(z$x))
    z <- combine(y,x)
    checkTrue(identical(dim(z), as.integer(c(1,3))))
    checkTrue(is.na(z$x))
}

testOneRow <- function() {
    x <- data.frame(x=1,y=letters[1], row.names=letters[1])
    y <- data.frame(z=3,y=letters[1], row.names=letters[2])
    z <- combine(x,y)
    checkTrue(identical(dim(z), as.integer(c(2,3))))
    checkTrue(z$x[[1]]==1)
    checkTrue(all(is.na(z$x[[2]]), is.na(z$z[[1]])))
    z <- combine(x,data.frame())
    checkTrue(identical(dim(z), as.integer(c(1,2))))
    checkTrue(all(z[,1:2]==x[,1:2]))
    z <- combine(data.frame(),x)
    checkTrue(identical(dim(z), as.integer(c(1,2))))
    checkTrue(all(z[,1:2]==x[,1:2]))
}

testNoCol <- function() {
    ## row.names
    obj1 <- data.frame(numeric(20), row.names=letters[1:20])[,FALSE]
    obj <- combine(obj1, obj1)
    checkTrue(identical(obj, obj1))
    ## no row.names -- fails because row.names not recoverable from data.frame?
    obj1 <- data.frame(numeric(20))[,FALSE]
    obj <- combine(obj1, obj1)
    checkTrue(all(dim(obj)==dim(obj1)))
}

testNoCommonCols <- function() {
    x <- data.frame(x=1:5, row.names=letters[1:5])
    y <- data.frame(y=3:7, row.names=letters[3:7])
    z <- combine(x,y)
    checkTrue(all(dim(z)==as.integer(c(7,2))))
    checkTrue(all(z[1:5,"x"]==x[,"x"]))
    checkTrue(all(z[3:7,"y"]==y[,"y"]))
    checkTrue(all(which(is.na(z))==6:9))
}

testEmpty <- function() {
    z <- combine(data.frame(), data.frame())
    checkTrue(identical(dim(z), as.integer(c(0,0))))
    x <- data.frame(x=1,y=letters[1], row.names=letters[1])
    z <- combine(x,data.frame())
    checkTrue(identical(dim(z), as.integer(c(1,2))))
    checkTrue(identical(z["a",1:2], x["a",1:2]))
    z <- combine(data.frame(), x)
    checkTrue(identical(dim(z), as.integer(c(1,2))))
    checkTrue(identical(z["a",1:2], x["a",1:2]))
}

testAsIs <- function() {
    x <- data.frame(x=I(1:5),y=I(letters[1:5]), row.names=letters[1:5])
    y <- data.frame(z=I(3:7),y=I(letters[3:7]), row.names=letters[3:7])
    z <- combine(x,y)
    checkTrue(all(sapply(z, class)=="AsIs"))
}

testColNamesSuffix <- function() {
    obj1 <- data.frame(a=1:5, a.x=letters[1:5])
    obj2 <- data.frame(a=1:5, a.y=LETTERS[1:5], b=5:1)
    obj <- combine(obj1, obj2)
    checkDataFramesEqual(obj,
                         data.frame(a=1:5, a.x=letters[1:5], a.y=LETTERS[1:5], b=5:1))
}
