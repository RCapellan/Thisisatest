#################################################################
#################################################################
#################### RESUME STRUCTURES IN R #####################
#################################################################
#################################################################

# To make comments

 # Assignment of variables
a <- "Testing environment"
b <- 3+3

# Breaking points on R
# browser()

# Prints on R of multiple variables
print(c(a,b))

# To install packages from CRAN
# install.packages("ggplot2")
# install.packages("ggplot2", repos="http://cran.rstudio.com/")


###################################################
############# Vectors - Brief Summary #############
###################################################

# Different ways to declare a vector 
x <- c(10,9,8,7,6)
assign("x", c(10,9,8,7,6))
c(10,9,8,7,6) -> x

# Join two vectors
y <- c(x,0,x)
v <- 2*x + y + 1

# Add all the values from a vector
sum(x)

# Length Mean Min Max Sqrt
# There is not a method to calculate the mode
length(x)
mean(x)
median(x)
min(x)
max(x)
sqrt(x)

# Generating sequence of numbers
seq(-5, 5, by=.2) # From 5 a -5 with an interval of o.2
seq(length=51, from=-5, by=.2) # 51 intervals since -5 with an interval of 0.2

# Repeat the vector 5 times 
rep(x, times=5)

# Repeat each value of the vector 5 times each one
rep(x, each=5)

# How to create masks with conditions
temp <- x < 50 &  x > 37

# Missing values
z <- c(1:3,NA);
ind <- is.na(z) # Mask for na values

# Generate a sequence of vectors X1, Y2 ... X9, Y10
labs <- paste(c("X","Y"), 1:10, sep="")

# Filter NaN values
x[!is.na(x)]
# If it's not NaN and the values is bigger than 0 add 1 to each value
(x+1)[(!is.na(x)) & x>0]

# The vectors start in 1 not in 0 and it does not exist negative values as an index
x[1]
x[-1] # Delete the first element of the array the - exclude elements of the vector

# To take the last element an option could be
# - Reverse the list and take the first element of the list
# - The good part of this is totally independent of the index or if the size of the vector changes
# If not could rise an error by the index of the array
rev(x)[1]
# - Other option will be take the length of the array
x[length(x)]

# Filter an array by index
# - Two first elements
x[1:2]
# - Exclude the first two elements
x[-(1:2)]

# Join two list in a kind of table 
fruit <- c(5, 10, 1, 20)
names(fruit) <- c("orange", "banana", "apple", "peach")
lunch <- fruit[c("apple","orange")]

# Replace NaN values for 0
x[is.na(x)] <- 0
# Replace values by conditions 
x[x==100 | x==0] <- -999
# Take absolute values of a vector
abs(x)


#############################################################
############# Arrays and Matrix - Brief Summary #############
#############################################################
# - Declare a matrix
m <- array(1:20, dim=c(4,5))

# Matrix od zeros
array(0, dim=c(4,5))
# - Other way to declare arrays
array(0, c(3,4,2))

# Access to a value in a matrix
m[1,1]
# Negative index are not allowed for matrix

# Create a matrix from a vector
# -If the size indicated is lower than 3*4*2 the values are recycled from the beginning
h <- seq(length=24, from=0, by=1)
Z <- array(h, dim=c(3,4,2))

# function f(x; y) = cos(y)/(1 + x^2)
# f <- function(x, y) cos(y)/(1 + x^2) # Don't know actually what this do
# z <- outer(x, y, f)

d <- outer(0:9,0:9)
fr <- table(outer(d, d, "-"))
plot(fr, xlab="Determinant", ylab="Frequency")

# Transpose a matrix
t(fr)

# Type of a variable
class(fr)

# To do shape command as in python
dim(fr)

# Multiply matrix (It has to have the same dimensions)
fr*fr

# Well tables are not really well documented!!
# I miss a certain commands for some operations

#################################################
############# Lists - Brief Summary #############
#################################################

# Its more like a dictionary more than a list on python
lst_test <- list(name="Fred", wife="Mary", no.children=3,
              child.ages=c(4,7,9)) 

# Access an element from the list
lst_test$wife
lst_test$child.ages[2]
lst_test[['wife']]

# Introduce in a list a matrix, in one of the elements
lst_test[2] <- list(matrix=m)

# Concatenate lists`
lst_test <- c(lst_test, lst_test)
c(lst_test, lst_test$child.ages)


######################################################
############# Dataframes - Brief Summary #############
######################################################

# Declaration of a dataframe

lst_staf  <- c("This","is", "a", "test")
lst_incme <- c(10, 3, 7, 99)
lentils <- list(bike='Trek', bike='GHost', bike='Lapierre')

df <- data.frame(home=lst_staf, loot=lst_incme, shot=lst_incme)

# Read the first line of a dataframe
df[,1]
# Read the first column of a dataframe
df[1,]
# Read the name of the columns
df['home']
# Number of rows of the dataframes
nrow(df)
# Read the columns of the dataframe
colnames(df)
# Shape of the dataframe
dim(df)
# Filter a dataframe by name of the columns
df[, c('home', 'shot')]

# Loop to go through the different rows of the dataframe
for(i in 1:nrow(df)) {
  # 'i' represents the row index
  row <- df[i, ]
  print(row)
}

######################################################
############# Attributes - Brief Summary #############
######################################################

z <- 0:9
# From a vector of numbers transform it to text values
digits <- as.character(z)
numeric <- as.numeric(digits)
numeric <- as.integer(digits)
# Truncate where the position start to take the range a range of values determined
numeric[2 * 2:4]

# attr(z, "dim") <- c(10,10) # Don't know how this command works, don't even realize how to make it work

# Types of objects in R, or at least the mso important to know:
# - "numeric" 
# - "logical" 
# - "character" 
# - "list" 
# - "matrix"
# - "array"
# - "factor"
# - "data.frame"

 
#####################################################
############# Functions - Brief Summary #############
#####################################################
# Define a function on R
myFunction <- function(y1, y2) {
    suma <- y1+y2
    return (suma)
  }

val_sum <- myFunction(10, 10)

#####################################################
############### Loops - Brief Summary ###############
#####################################################

# Loop for
for (i in 1:5) {
  print(i)
}

# Loop while
x <- 1
while (x <= 5) {
  print(x)
  x <- x + 1
}

# Loop repeat
x <- 1
repeat {
  print(x)
  x <- x + 1
  if (x > 5) {
    break
  }
}

# Foreach loop
# - %do% -> indicate that the loop to be sequentially
# To do it parallel:
# - library(doParallel)
# - registerDoParallel(cores = 5)
# - This lines goes before start the loop
# - %dopar%
# - After the loop it goes the following line
# - stopImplicitCluster()
library(foreach)

foreach(i = 1:5) %do% {
  print(i)
}