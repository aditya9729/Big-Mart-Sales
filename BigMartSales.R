setwd("C:/Users/Lenovo/Desktop/analytics_vidhya_projects/BIG_MART)SALES_3")
library(tidyverse)
library(data.table)
library(caret)
library(corrplot)
library(cowplot)

train=fread('Train_UWu5bXk.txt')
test=fread('Test_u94Q5KV.txt')

head(train)
str(train)
summary(train)
dim(train)

names(train)

test[,"Item_Outlet_Sales"]=NA

data<-rbind(train,test)
dim(data)

#cat-barcharts, cont-histograms

ggplot(train,aes(train$Item_Outlet_Sales)) +
  geom_histogram(binwidth = 100, fill = "red",color='black') +  
  xlab("Item_Outlet_Sales")


p1 = ggplot(data) +
  geom_histogram(aes(Item_Weight), binwidth = 0.5, fill = "blue",color='black')
p2 = ggplot(data) + 
  geom_histogram(aes(Item_Visibility), binwidth = 0.005, fill = "green",color='black') 
p3 = ggplot(data) + geom_histogram(aes(Item_MRP), binwidth = 1, fill = "yellow",color='black')
plot_grid(p1, p2, p3, nrow = 1)

ggplot(data %>% group_by(Item_Fat_Content) %>% summarise(Count = n())) + 
  geom_bar(aes(Item_Fat_Content, Count), stat = "identity", fill = "coral1")

data$Item_Fat_Content[data$Item_Fat_Content == "LF"] = "Low Fat" 
data$Item_Fat_Content[data$Item_Fat_Content == "low fat"] = "Low Fat" 
data$Item_Fat_Content[data$Item_Fat_Content == "reg"] = "Regular"

ggplot(data %>% group_by(Item_Fat_Content) %>% summarise(Count = n())) + 
  geom_bar(aes(Item_Fat_Content, Count), stat = "identity", fill = "coral1")



p4 = ggplot(data %>% group_by(Item_Type) %>% summarise(Count = n())) +
  geom_bar(aes(Item_Type, Count), stat = "identity", fill = "coral1") +  xlab("") +
  geom_label(aes(Item_Type, Count, label = Count), vjust = 0.5)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ggtitle("Item_Type")

p5 = ggplot(data %>% group_by(Outlet_Identifier) %>% summarise(Count = n()))+ 
  geom_bar(aes(Outlet_Identifier, Count), stat = "identity", fill = "coral1")+
  geom_label(aes(Outlet_Identifier, Count, label = Count), vjust = 0.5)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
p6 = ggplot(data %>% group_by(Outlet_Size) %>% summarise(Count = n())) +
  geom_bar(aes(Outlet_Size, Count), stat = "identity", fill = "coral1")+
  geom_label(aes(Outlet_Size, Count, label = Count), vjust = 0.5) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
second_row = plot_grid(p5, p6, nrow = 1)
plot_grid(p4, second_row, ncol = 1)

p7 = ggplot(data %>% group_by(Outlet_Establishment_Year) %>% summarise(Count = n())) +
  geom_bar(aes(factor(Outlet_Establishment_Year), Count), stat = "identity", fill = "coral1") + 
  geom_label(aes(factor(Outlet_Establishment_Year), Count, label = Count), vjust = 0.5) +
  xlab("Outlet_Establishment_Year") +
  theme(axis.text.x = element_text(size = 8.5))


p8 = ggplot(data %>% group_by(Outlet_Type) %>% summarise(Count = n())) +
  geom_bar(aes(Outlet_Type, Count), stat = "identity", fill = "coral1") +
  geom_label(aes(factor(Outlet_Type), Count, label = Count), vjust = 0.5) +
  theme(axis.text.x = element_text(size = 8.5))

plot_grid(p7,p8,ncol=1)


#bivariate analysis scatter->cont,violin-> cat

train = data[1:nrow(train)]

p9 = ggplot(train) +
  geom_point(aes(Item_Weight, Item_Outlet_Sales), colour = "violet", alpha = 0.3) +
  theme(axis.title = element_text(size = 8.5))

p10 = ggplot(train) + 
  geom_point(aes(Item_Visibility, Item_Outlet_Sales), colour = "violet", alpha = 0.3) + 
  theme(axis.title = element_text(size = 8.5))

p11 = ggplot(train) +
  geom_point(aes(Item_MRP, Item_Outlet_Sales), colour = "violet", alpha = 0.3) + 
  theme(axis.title = element_text(size = 8.5))

second_row_2 = plot_grid(p10, p11, ncol = 2)
plot_grid(p9, second_row_2, nrow = 2)



p12 = ggplot(train) +
  geom_violin(aes(Item_Type, Item_Outlet_Sales), fill = "magenta") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),axis.text = element_text(size = 6),axis.title = element_text(size = 8.5))

p13 = ggplot(train) +
  geom_violin(aes(Item_Fat_Content, Item_Outlet_Sales), fill = "magenta") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),axis.text = element_text(size = 8), axis.title = element_text(size = 8.5))
p14 = ggplot(train) +
  geom_violin(aes(Outlet_Identifier, Item_Outlet_Sales), fill = "magenta") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),axis.text = element_text(size = 8), axis.title = element_text(size = 8.5))
second_row_3 = plot_grid(p13, p14, ncol = 2)
plot_grid(p12, second_row_3, ncol = 1)


ggplot(train) + geom_violin(aes(Outlet_Size, Item_Outlet_Sales), fill = "magenta")

p15 = ggplot(train) +
  geom_violin(aes(Outlet_Location_Type, Item_Outlet_Sales), fill = "magenta")

p16 = ggplot(train) +
  geom_violin(aes(Outlet_Type, Item_Outlet_Sales), fill = "magenta") 

plot_grid(p15, p16, ncol = 1)

sum(is.na(data$Item_Weight))


missing_index = which(is.na(data$Item_Weight))
for(i in missing_index){ 
  item = data$Item_Identifier[i] 
  data$Item_Weight[i] = mean(data$Item_Weight[data$Item_Identifier == item], na.rm = T)
}

sum(is.na(data$Item_Weight))

ggplot(data) + geom_histogram(aes(Item_Visibility), bins = 100)

missing_index = which(data$Item_Visibility==0)
for(i in missing_index){ 
  item = data$Item_Identifier[i] 
  data$Item_Visibility[i] = mean(data$Item_Visibility[data$Item_Identifier == item], na.rm = T)
}

perishable = c("Breads", "Breakfast", "Dairy", "Fruits and Vegetables", "Meat", "Seafood")
non_perishable = c("Baking Goods", "Canned", "Frozen Foods", "Hard Drinks", "Health and Hygiene", "Household", "Soft Drinks")


data[,Item_Type_new:= ifelse(Item_Type %in% perishable, "perishable", ifelse(Item_Type %in% non_perishable, "non_perishable", "not_sure"))]

table(data$Item_Type, substr(data$Item_Identifier, 1, 2))

data[,Item_category := substr(data$Item_Identifier, 1, 2)]

data$Item_Fat_Content[data$Item_category == "NC"] = "Non-Edible" 

data[,Outlet_Years := 2013 - Outlet_Establishment_Year]

data[,price_per_unit_wt := Item_MRP/Item_Weight]

data[,Item_MRP_clusters := ifelse(Item_MRP < 69, "1st",ifelse(Item_MRP >= 69 & Item_MRP < 136, "2nd",ifelse(Item_MRP >= 136 & Item_MRP < 203, "3rd", "4th")))]


data[,Outlet_Size_num := ifelse(Outlet_Size == "Small", 0,ifelse(Outlet_Size == "Medium", 1, 2))] 

data[,Outlet_Location_Type_num := ifelse(Outlet_Location_Type == "Tier 3", 0,ifelse(Outlet_Location_Type == "Tier 2", 1, 2))] 

# removing categorical variables after label encoding 

data[, c("Outlet_Size", "Outlet_Location_Type") := NULL]


ohe =dummyVars("~.", data = data[,-c("Item_Identifier", "Outlet_Establishment_Year", "Item_Type")], fullRank = T) 
ohe_df = data.table(predict(ohe, data[,-c("Item_Identifier", "Outlet_Establishment_Year", "Item_Type")])) 
data = cbind(data[,"Item_Identifier"], ohe_df)



data[,Item_Visibility := log(Item_Visibility + 1)] 
data[,price_per_unit_wt := log(price_per_unit_wt + 1)]


num_vars = which(sapply(data, is.numeric)) # index of numeric features
num_vars_names = names(num_vars)
combi_numeric = data[,setdiff(num_vars_names, "Item_Outlet_Sales"), with = F] 
prep_num = preProcess(combi_numeric, method=c("center", "scale"))
combi_numeric_norm = predict(prep_num, combi_numeric)
data[,setdiff(num_vars_names, "Item_Outlet_Sales") := NULL] # removing numeric independent variables 
combi = cbind(data, combi_numeric_norm)


train = combi[1:nrow(train)] 
test = combi[(nrow(train) + 1):nrow(combi)]
test[,Item_Outlet_Sales := NULL]

cor_train = cor(train[,-c("Item_Identifier")]) 
corrplot(cor_train, method = "pie", type = "lower", tl.cex = 0.9)
# removing Item_Outlet_Sales as it contains only NA for test dataset



linear_reg_mod = lm(Item_Outlet_Sales ~ ., data = train[,-c("Item_Identifier")])



set.seed(1235)
my_control = trainControl(method="cv", number=5)
Grid = expand.grid(alpha = 1, lambda = seq(0.001,0.1,by = 0.0002)) 
lasso_linear_reg_mod = train(x = train[, -c("Item_Identifier", "Item_Outlet_Sales")], y = train$Item_Outlet_Sales,method='glmnet', trControl= my_control, tuneGrid = Grid)


set.seed(1236)
my_control = trainControl(method="cv", number=5)
Grid = expand.grid(alpha = 0, lambda = seq(0.001,0.1,by = 0.0002)) 
ridge_linear_reg_mod = train(x = train[, -c("Item_Identifier", "Item_Outlet_Sales")], y = train$Item_Outlet_Sales, method='glmnet', trControl= my_control, tuneGrid = Grid)


predict(ridge_linear_reg_mod, test[,-c("Item_Identifier")]) 



set.seed(1237) 
my_control = trainControl(method="cv", number=5) # 5-fold CV 
tgrid = expand.grid(
  .mtry = c(3:10),
  .splitrule = "variance",
  .min.node.size = c(10,15,20)
)

rf_mod = train(x = train[, -c("Item_Identifier", "Item_Outlet_Sales")],
               y = train$Item_Outlet_Sales,
               method='ranger',
               trControl= my_control,
               tuneGrid = tgrid,
               num.trees = 400,
               importance = "permutation")

plot(rf_mod)

plot(varImp(rf_mod))

library(xgboost)
param_list = list(objective = "reg:linear",eta=0.01,gamma = 1,max_depth=6,subsample=0.8,colsample_bytree=0.5)
dtrain = xgb.DMatrix(data = as.matrix(train[,-c("Item_Identifier", "Item_Outlet_Sales")]), label= train$Item_Outlet_Sales) 
dtest = xgb.DMatrix(data = as.matrix(test[,-c("Item_Identifier")]))


set.seed(112)
xgbcv = xgb.cv(params = param_list,data = dtrain,nrounds = 1000, nfold = 5,print_every_n = 10,early_stopping_rounds = 30,maximize = F)
xgb_model = xgb.train(data = dtrain, params = param_list, nrounds = 432)

var_imp = xgb.importance(feature_names = setdiff(names(train), c("Item_Identifier", "Item_Outlet_Sales")), model = xgb_model)
xgb.plot.importance(var_imp)
