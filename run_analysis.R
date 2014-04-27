# Read the necessary compoents of the training dataset into temporary dataframes
train1<-read.table("train/X_train.txt")
train2<-read.table("train/y_train.txt")
train3<-read.table("train/subject_train.txt")

# Read the necessary compoents of the test dataset into temporary variables
test1<-read.table("test/X_test.txt")
test2<-read.table("test/Y_test.txt")
test3<-read.table("test/subject_test.txt")

# Read the names of the coloumns into a feature dataset 
features<-read.table("features.txt")

# Assign the appropriate coloumn names to the temporary dataframes
names(train1)<-features[,2]
names(train2)<-"Activity"
names(train3)<-"Subject"
names(test1)<-features[,2]
names(test2)<-"Activity"
names(test3)<-"Subject"

#Create the test and train dataset by merging the temporary dataframes
train_full<-cbind(train1,train2,train3)
test_full<-cbind(test1,test2,test3)

#Combine the test and train dataframes to create a full dataframe
full_dataset<-rbind(train_full,test_full)

# Filter the names of coloums corresponding to mean and Standard Deviation from the features dataframe
regex <- c(".*mean\\().*", ".*std\\().*")
filter <- unique(grep(paste(regex, collapse= "|"), features$V2, value=TRUE))

# Apply the filter to the full dataframe to get only those coloumns that correspond to mean and standard deviation 
refined_dataset <- full_dataset[, c(filter,"Activity", "Subject")]
head(refined_dataset)

# Reads the activity_labels
activity_labels <- read.table("activity_labels.txt")
names(activity_labels)<- c("Activity", "ActivityDescription")


# Merges the activity_labels with the refined dataset to add a coloumn which describes the activity
refined_dataset_withdisc <- merge(refined_dataset,activity_labels, all=TRUE)


# Loads the reshape2 package.
library(reshape2)

# Melts the refined data frame into ID and measure variables
dataset_melt <- melt(refined_dataset_withdisc, id.vars=c("ActivityDescription","Subject","Activity"))

# Casts the melt and calulates the average of each measure variable for each activity and subject 
dataset_cast <-  dcast(dataset_melt, Subject + Activity + ActivityDescription  ~ variable, mean)

# The Activity coulumn is removed as it is unnecessary
clean_data<-dataset_cast[,-2]



# Modifies the coloumn names by eliminating intermittent hyphen and paranthesis symbols
names(clean_data)<-gsub("-","",names(clean_data))
names(clean_data)<-gsub("\\()","",names(clean_data))

# Writes the cleaned data to a text file in a tab separated format
write.table(clean_data, "clean_dataset.txt", sep="\t", row.names=FALSE)

