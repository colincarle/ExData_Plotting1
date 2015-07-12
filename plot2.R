# Check to see if the file exists. If not, download the file and flag for
# deletion at the completion of the script
temp.f            <- "./exdata-data-household_power_consumption.zip"
flag.delete       <- FALSE
if (!file.exists(temp.f))
{
    fileURL       <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
    download.file(fileURL, destfile = temp.f, method = "curl", quiet = FALSE)
    flag.delete   <- TRUE
}

# get the archive contents, read the first 5 lines of the data set to acquire:
# 1) column classes
# 2) header information
# 3) starting date/time of the dataset
archive.contents  <- unzip(temp.f, list = TRUE)[[1]]
first.5           <- read.table(unz(temp.f, archive.contents), header = TRUE,
                                sep = ';', na.strings = "?", nrows = 5,
                                stringsAsFactors = FALSE)
classes           <- sapply(first.5, class)
header            <- names(first.5)
data.time.start   <- strptime(paste(as.character(first.5$Date[1]),
                                    as.character(first.5$Time[1])),
                              format = "%d/%m/%Y %H:%M:%S")

# We are looking for observations on February 1st and 2nd, 2007. Use the dataset
# starting date/time and the target starting/end date/time to calculate:
# 1) number of lines to skip in the dataset i.e. table.read skip parameter
# 2) number of lines to read in the dataset i.e. table.read nrows parameter
target.time.start <- strptime("2007-02-01 00:00", format = "%Y-%m-%d %H:%M")
target.time.end   <- strptime("2007-02-03 00:00", format = "%Y-%m-%d %H:%M")
sample.size       <- as.numeric(difftime(target.time.end, target.time.start,
                                         units = "mins"))
skip.lines        <- as.numeric(difftime(target.time.start, data.time.start,
                                         units = "mins"))

# read the desired content into a new data frame, assign the previously stored
# header, convert the date/time columns to POSIXlt and store in a new column.
power.data        <- read.table(unz(temp.f, archive.contents), header = TRUE,
                                sep = ";", na.strings = "?", skip = skip.lines,
                                nrows = sample.size, stringsAsFactors = FALSE)
names(power.data) <- header
power.data$time   <- strptime(paste(power.data$Date, power.data$Time),
                              format = "%d/%m/%Y %H:%M")

# if the file was downloaded (vs. local), delete it.
if (flag.delete) unlink(temp.f)

# open the png device and construct a line plot
png(filename = "plot2.png", width = 480, height = 480)
with(power.data, {
    plot(time, Global_active_power, type = "l",
         xlab = "",
         ylab = "Global Active Power (kilowatts)")
})
dev.off()

# clean up the workspace
rm(list=ls())
