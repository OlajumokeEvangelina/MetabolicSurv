#' The cvmv Class.
#'
#' Class of object returned by function \code{\link[Biosurvmet]{CVMajorityvotes}}.
#'
#' @name cvmv-class
#' @rdname cvmv-class
#' @exportClass cvmv
#' @param x	 A cvmv class object
#' @param y	 missing
#' @param  object A cvmv class object
#' @param ...	 The usual extra arguments to generic functions — see \code{\link[graphics]{plot}}, \code{\link[graphics]{plot.default}}
#' @slot HRTrain A matrix of survival information for the training dataset. It has three columns representing the estimated HR, the 95\% lower confidence interval and the 95\% upper confidence interval.
#' @slot HRTest A matrix of survival information for the test dataset. It has three columns representing the estimated HR, the 95\% lower confidence interval and the 95\% upper confidence interval.
#' @slot Ncv The number of cross validation used
#' @slot Mdata The Metabolite data matrix that was used for the analysis either same as Mdata or a reduced version.
#' @slot Progfact The names of prognostic factors used
#'
#' @author Olajumoke Evangelina Owokotomo, \email{olajumoke.owokotomo@@uhasselt.be}
#' @author Ziv Shkedy
#' @seealso \code{\link[Biosurvmet]{CVPcaPls}}, \code{\link[Biosurvmet]{SurvPcaClass}}, \code{\link[Biosurvmet]{SurvPlsClass}}
#' @examples
#' ## GENERATE SOME METABOLIC SURVIVAL DATA WITH PROGNOSTIC FACTORS
#' Data<-MSData(nPatients=100,nMet=150,Prop=0.5)
#'
#' ## USING THE FUNCTION
#' Result = CVMajorityvotes(Survival=Data$Survival,Censor=Data$Censor,
#' Prognostic=Data$Prognostic, Mdata=t(Data$Mdata), Reduce=FALSE,
#' Select=15, Fold=3, Ncv=10)
#'
#' ## GET THE CLASS OF THE OBJECT
#' class(Result)     # A "cvmv" Class
#'
#' ##  METHOD THAT CAN BE USED FOR THE RESULT
#' show(Result)
#' summary(Result)
#' plot(Result)

setClass("cvmv",representation(HRTrain="matrix",HRTest="matrix",Ncv="numeric",Mdata="matrix",Progfact="vector"),
         prototype=list(HRTrain=matrix(1,1,1),HRTest=matrix(1,1,1),Ncv=100,Mdata=matrix(1,1,1),Progfact=c(NA))
)
#' Method show.
#' @name cvmv
#' @rdname cvmv-class
#' @exportMethod show
#setGeneric("show", function(object) standardGeneric("show"))

#' @rdname cvmv-class
#' @aliases show,cvmv-method
setMethod("show",signature="cvmv"
          , function(object){
            cat("Cross validation for Majority Votes Based Classification Analysis\n")
            cat("Number of cross valdiations used: ", object@Ncv, "\n")
            if (!is.na(object@Progfact)) cat("Prognostic factors used: ",object@Progfact,"\n")
          })





#' Method summary.
#' @name cvmv-class
#' @rdname cvmv-class
#' @exportMethod summary
#setGeneric("summary", function(object,...) standardGeneric("summary"))

#' @rdname cvmv-class
#' @aliases summary,cvmv-method
setMethod("summary",signature="cvmv", function(object){
  cat("Summary of majority votes cross validation analysis\n")
  cat("Number of prognostic factor used :",length(object@Progfact),"\n")
  cat("Number of cross validation: ", object@Ncv, "\n")
  cat("Estimated  quantiles of the HR in the train dataset \n")
  print(quantile(object@HRTrain[,1],probs=c(0.05,0.25,0.5,0.75,0.95)))
  cat("\n")
  cat("Estimated  quantiles of the HR in the test dataset \n")
  print(quantile(object@HRTest[,1],probs=c(0.05,0.25,0.5,0.75,0.95)))
})


#' Method plot.
#' @name cvmv-class
#' @rdname cvmv-class
#' @exportMethod plot

#' @rdname cvmv-class
#' @aliases plot,cvmv-method
setMethod("plot", signature(x="cvmv", y="missing"),
          function(x,  y, ...) {
            if (class(x)!="cvmv") stop("Invalid class object")
            HRTest<-x@HRTest
            HRTrain<-x@HRTrain
            nCV<-x@Ncv
            dotsCall <- substitute(list(...))
            ll <- eval(dotsCall)
            if(!hasArg("xlab")) ll$xlab <- "Cross Validation index"
            if(!hasArg("ylab")) ll$ylab <- "HR"
            ll$main <- "Estimated HR on Test Data \n for low risk group"
            if(!hasArg("cex.lab")) ll$cex.lab <- 1.2
            if(!hasArg("cex.main")) ll$cex.main <- 1.3
            if(!hasArg("col")) ll$col <- 2

            ll$x<-HRTest[,1]
            if(!hasArg("ylim")) ll$ylim <- c(0,max(x@HRTrain,x@HRTest))


            par(mfrow=c(1,2))
            t1 <- which(HRTest[,1]<1)
            do.call(plot,args=ll)
            #plot(HRp.test[,1],ylim=c(0,2),ylab="HR",main="")
            for(i in 1:nCV){
              lines(c(i,i),HRTest[i,2:3])
            }
            for(i in t1){
              lines(c(i,i),HRTest[i,2:3],col=2)
            }
            abline(h=1)


            Results<-data.frame(HRTrain=HRTrain[,1],HRTest=as.numeric(HRTest[,1]))
            ll$x<-Results
            ll$names<-c("Train ","Test ")
            ll$main <- "Estimated HR on Train and Test Data \n for low risk group"
            if(!hasArg("col")) ll$col <- 2:3
            do.call(boxplot,args=ll)
          })