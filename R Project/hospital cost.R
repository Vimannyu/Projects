#Importing Data set into Rstusdio system for the Healthcare cost analysis Project.

setwd("C:/PerfLogs/")
getwd()

library(readxl)
Data <- read_excel("C:/PerfLogs/hospitalcosts.xlsx")
View(Data)

#Cleaning the dataset.

Data <- na.omit(Data)
summary(Data)
str(Data)

# capping the outliers of Variable LOS.

bx = boxplot(Data$LOS)
bx$stats
quantile(Data$LOS, seq(0,1,0.02))
Data$LOS<-ifelse(Data$LOS>=4,4,Data$LOS)
Data$LOS<-ifelse(Data$LOS<=1,1,Data$LOS)

# capping the outliers of Variable TOTCHG.

bx = boxplot(Data$TOTCHG)
bx$stats
quantile(Data$TOTCHG, seq(0,1,0.02))
Data$TOTCHG<-ifelse(Data$TOTCHG>=4412,4412,Data$TOTCHG)
# capping the outliers of Variable APRDRG.

bx = boxplot(Data$APRDRG)
bx$stats
quantile(Data$APRDRG, seq(0,1,0.02))
Data$APRDRG<-ifelse(Data$APRDRG>=911,911,Data$APRDRG)
Data$APRDRG<-ifelse(Data$APRDRG<=560,560,Data$APRDRG)

#1. To record the patient statistics, the agency wants to find the age-
#category of people who frequent the hospital and has the maximum expenditure.

hist(Data$AGE,breaks = 4,col = "grey")

s<-summarise(group_by(Data,AGE),sum(TOTCHG))
View(s)
#2. In order of severity of the diagnosis and treatments and to find out the expensive treatments, the agency wants to find the diagnosis-related group that has maximum hospitalization and expenditure.

sev<-summarise(group_by(Data,APRDRG),sum(TOTCHG),sum(LOS))
View(sev)

#3. To make sure that there is no malpractice, 
#the agency needs to analyze if the race of the patient is related to the hospitalization costs.

malprtc <- aov(RACE ~ TOTCHG,data = Data)
summary(malprtc)

#4. To properly utilize the costs, 
#the agency has to analyze the severity of the hospital costs by age and gender for the proper allocation of resources.

model1<- lm(TOTCHG ~ AGE + FEMALE, data = Data)
summary(model1)
scatterplot(Data$TOTCHG,Data$FEMALE)
scatterplot(Data$TOTCHG,Data$AGE)
#5. Since the length of stay is the crucial factor for inpatients, 
#the agency wants to find if the length of stay can be predicted from age, gender, and race.

set.seed(4234)
t=sample(1:nrow(Data),0.7*nrow(Data))
t_train=Data[t,]
t_test=Data[-t,]


model2<- lm(LOS ~ AGE +FEMALE+RACE, data = t_train)
summary(model2)
names(model2)
plot(model2$model)
final_data = predict(model2,data=t_train,type = "response")
tab1<-confusionMatrix(as.factor(final_data),as.factor(t_train),positive = '1')
summary(tab1)



#6. To perform a complete analysis, 
#the agency wants to find the variable that mainly affects hospital costs.

model3<-lm(TOTCHG ~.,data = Data)
summary(model3)
t = vif(model3)
sort(t, decreasing = T)
model3<-lm(TOTCHG ~ LOS+APRDRG+AGE+FEMALE,data = Data) 

stpmod = step(model3, direction = "both")
formula(stpmod)
summary(stpmod)
scatterplot(Data$TOTCHG,Data$AGE)
scatterplot(Data$TOTCHG,Data$FEMALE)
scatterplot(Data$TOTCHG,Data$LOS)
scatterplot(Data$TOTCHG,Data$APRDRG)
