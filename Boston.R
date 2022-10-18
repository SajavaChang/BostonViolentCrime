# 一、資料處理

# 1-1 地圖資料
library(sf)
tract <- read_sf("C:/Users/User/Desktop/tract.gpkg")   # 181 obs.

## 波士頓地圖+Tract_No
plot(tract['geom'], col= "lightblue")
text(st_coordinates(st_centroid(tract['geom'])), labels = tract$NAME10, cex = 0.6)



# 1-2 Y - 犯罪資料
crime <- read.csv("C:/Users/User/Desktop/Crime.csv", header=T)   # 經度:Long, 緯度:Lat
crime <- as.data.frame(crime) %>% st_as_sf(coords=c("Long","Lat"), crs=4326, remove=FALSE)   # 轉為空間資料

## Spatial Join : points to polygon
tract <- tract %>% st_transform(tract$geom, crs=4326)   # 將波士頓地圖的crs也轉成與犯罪一致
crime <- st_join(crime, left = FALSE, tract['NAME10'])   # inner_join, 辨識每個Y落點在哪個tract
Y <- as.data.frame(table(crime$NAME10)) ; colnames(Y) <- c("NAME10", "Y")   # 計算每個tract的犯罪量
tract <- merge(tract, Y, by="NAME10", all.x=T)   # 把Y併入地圖資料中
tract$Y[which(is.na(tract$Y))] <- 0   # tract中沒有犯罪的Y改為0



# 1-3 X - 人口特徵與環境因子(共29個 + tract的面積)
DG <- read.csv("C:/Users/User/Desktop/variables.csv", header=T)  # 173 obs., 移除8個資料缺失區域

## 合併所有資料
boston <- merge(DG, tract, by="NAME10", all.x=T)
boston$Area <- (boston$ALAND10 + boston$AWATER10)/1000000   # 計算每個tract為多少平方公里
boston$Y2 <- boston$Y/boston$Area   # 計算每個tract的單位面積犯罪量: 用於敘述統計 & 空間自相關



# 存出資料
boston2 <- boston[, -c(31:46, 48)]
write.csv(boston2, "C:/Users/User/Desktop/Boston.csv")



############################################################################################################



# 二、資料探索

# 2-1 犯罪地點在地圖上的分布圖
plot(tract['geom'], col=NA)
plot(crime$geometry, pch=20, cex=0.5, col="red", add=T)

## 各個tract的犯罪量多寡圖
Bsf <- st_sf(boston, geometry = boston$geometry)
plot(Bsf["Y2"], nbreaks = 5, breaks = "quantile")



# 2-2 連續變數
continuous <- boston[, c(2:24, 50)]   # 連續變數 + Y2

## 敘述統計
summary(continuous)   # Min, 1st Qu, Median, Mean, 3rd Qu, Max
round(apply(continuous, 2, sd), 2)   # 標準差
library(moments)
round(apply(continuous, 2, skewness), 2)    # 偏度
round(apply(continuous, 2, kurtosis), 2)    # 峰度

## 兩兩相關分析: 相關係數 & 檢定
library(GGally)
ggpairs(continuous)



# 2-3 類別變數
categorical <- boston[, c(25:30, 50)]   # 類別變數 + Y2

## 各類別計數與佔比
x24 <- table(categorical$X24)
x25 <- table(categorical$X25)
x26 <- table(categorical$X26)
x27 <- table(categorical$X27)
x28 <- table(categorical$X28)
x29 <- table(categorical$X29)
x24; x25; x26; x27; x28; x29
round(prop.table(x24), 2)
round(prop.table(x25), 2)
round(prop.table(x26), 2)
round(prop.table(x27), 2)
round(prop.table(x28), 2)
round(prop.table(x29), 2)

## 盒鬚圖
par(mfrow=c(2,3))
boxplot(Y2~X24, data = categorical, main="X24", xlab="", ylab="Y", cex=2)
boxplot(Y2~X25, data = categorical, main="X25", xlab="", ylab="", cex=2)
boxplot(Y2~X26, data = categorical, main="X26", xlab="", ylab="", cex=2)
boxplot(Y2~X27, data = categorical, main="X27", xlab="", ylab="Y", cex=2)
boxplot(Y2~X28, data = categorical, main="X28", xlab="", ylab="", cex=2)
boxplot(Y2~X29, data = categorical, main="X29", xlab="", ylab="", cex=2)

## Normal distribution : 因為非常態分布，故只能使用 Kruskal-Wallis test
shapiro.test(CC$Y2[which(CC$X24 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X24 == 'b')])   # no
shapiro.test(CC$Y2[which(CC$X24 == 'c')])   # no
shapiro.test(CC$Y2[which(CC$X25 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X25 == 'b')])   # no
shapiro.test(CC$Y2[which(CC$X25 == 'c')])   # no
shapiro.test(CC$Y2[which(CC$X26 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X26 == 'b')])   # no
shapiro.test(CC$Y2[which(CC$X27 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X27 == 'b')])   # Yes
shapiro.test(CC$Y2[which(CC$X28 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X28 == 'b')])   # no
shapiro.test(CC$Y2[which(CC$X28 == 'c')])   # Yes
shapiro.test(CC$Y2[which(CC$X29 == 'a')])   # no
shapiro.test(CC$Y2[which(CC$X29 == 'b')])   # no
shapiro.test(CC$Y2[which(CC$X29 == 'c')])   # no

## Kruskal-Wallis
kruskal.test(Y2~X24, data = categorical)    # P > 0.05 
kruskal.test(Y2~X25, data = categorical)    # P > 0.05
kruskal.test(Y2~X26, data = categorical)    # P > 0.05
kruskal.test(Y2~X27, data = categorical)    # P > 0.05
kruskal.test(Y2~X28, data = categorical)    # P < 0.05
kruskal.test(Y2~X29, data = categorical)    # P < 0.05



############################################################################################################



# 三、Poisson Regression model

# 3-1 初始模型
PR <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
         data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(PR)
1-((sum((PR$fitted.values - boston$Y)^2)/(173-length(PR$coefficients)))/(sum((boston$Y - mean(boston$Y))^2)/172))   # Adjusted R Square : 0.7111642
sum((boston$Y - PR$fitted.values)^2)/173   # MSE : 11195.79

## VIF
library(car)
vif(PR)   # all less than 10, but X5, X6, X10 & X11 > 5
mean(vif(PR))   # 4.730659
## 有個不太符合邏輯的顯著變數: X12 beta: 0.257, P: 0.000189, Q: 薪資越高犯罪率越多?



# 3-2 試驗開始

## 探索 1 - 交互作用 (經試驗多個與X12的組合，效果不太理想)
T1 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29+X12*X5,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T1)
### 等高線圖
b5 <- seq(min(boston$X5), max(boston$X5), length.out = 173)
b12 <- seq(min(boston$X12), max(boston$X12), length.out = 173)
z <- outer(b5, b12, FUN = function(f, g) 0.11*f + 0.62*g -0.48*f*g)
par(mfrow = c(1, 2))
persp(b5, b12, z, theta = 45, phi = 10, shade = 0.75, xlab = "X5", ylab = "X12", zlab = "y", main = "3D")
contour(b5, b12, z, xlab = "X5", ylab = "X12", main = "Expected Y")

## 探索 2 - 多項式迴歸 (效果還是不太理想)
T2 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+I(X12^2)+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T2)
### Plot
b12 <- seq(min(boston$X12), max(boston$X12), length.out = 173)
g <- 0.812746*b12 -0.047125*(b12^2)
plot(b12, g, type="l")  # Max 落在 8.x

## 探索 3 - 分段式迴歸 (效果還是不太理想)
### 參考多項式迴歸的結果，設定斷點 = 8
boston$X12_1 <- boston$X12   # 新生一個變數X12_1
boston$X12_1[which(boston$X12_1 < 8)] <- 0   # 把斷點以下放0
boston$X12_1[which(boston$X12_1 >= 8)] <- boston$X12_1[which(boston$X12_1 >= 8)]-8   # 斷點以上放(X12-斷點)
T3 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X12_1+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T3)
#### if X12 < 8,  E[Y] = 3.031678 + 0.377836 * X12
#### if X12 >= 8, E[Y] = 3.031678 + 0.377836 * X12 - 0.654295 * (X12 - 8) = 8.266038 - 0.276459 * X12

##  探索 4 - PCA (選它 - 會犧牲模型配適度，但變數的解釋更合理)
boston1 <- boston[, c(6, 7, 11, 12, 13)]   # 對相關係數高的 X5, X6, X10, X11, X12 進行PCA
boston1$X6 <- 1- boston1$X6       # To avoid (-) cor, change X6 to 1-X6
boston1$X11 <- 1- boston1$X11     # To avoid (-) cor, change X11 to 1-X6
pp1 <- prcomp(boston1, center=T, scale=T)
round((pp1$sdev)^2 / sum((pp1$sdev)^2), 2)   # PCA解釋變異量: 0.78 0.12 0.08 0.01 0.00
round(-pp1$rotation, 2)   # eigenvalue
####      PC1   PC2   PC3   PC4   PC5
#### X5  0.48 -0.20 -0.35  0.76  0.17
#### X6  0.44 -0.50 -0.44 -0.56 -0.24
#### X10 0.48 -0.03  0.45 -0.25  0.71
#### X11 0.46  0.04  0.59  0.14 -0.64
#### X12 0.37  0.84 -0.36 -0.16 -0.05
round(cor(boston1, -pp1$x), 2)   # 負荷 (原始變數與PCA的相關係數)
####      PC1   PC2   PC3   PC4   PC5
#### X5  0.94 -0.15 -0.23  0.20  0.03
#### X6  0.87 -0.38 -0.28 -0.14 -0.04
#### X10 0.95 -0.02  0.29 -0.07  0.11
#### X11 0.92  0.03  0.38  0.04 -0.10
#### X12 0.73  0.64 -0.23 -0.04 -0.01
### 決定新增兩個PCA
boston$X30 <- 0 - pp1$x[, 1]   # 命名: 社會優勢人口因子
boston$X31 <- 0 - pp1$x[, 2]   # 命名: 高薪且黑白族裔混居區域



# 3-3 納入新變數的Poisson Regression model
PR2 <- glm(Y ~ X1+X3+X7+X8+X9+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29+X30+X31,
         data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(PR2)
1-((sum((PR2$fitted.values - boston$Y)^2)/(173-length(PR2$coefficients)))/(sum((boston$Y - mean(boston$Y))^2)/172))  # Adjusted R Square : 0.6975412
sum((boston$Y - PR2$fitted.values)^2)/173  # MSE: 12145.56
vif(PR2)   # all less than 5
mean(vif(PR2))   # 2.636503



############################################################################################################



# 四、空間權重矩陣

# 4-1 找出鄰居清單
library(spdep)
queen_w <- poly2nb(boston)
summary(queen_w)



# 4-2 處理離島問題
queen_w[[168]]  # 9801.01
queen_w[[171]]  # 9812.02 (鄰居 : 101, 105, 106) 
queen_w[[172]]  # 9813 (鄰居 : 92, 93, 94, 95, 96, 97, 98)

## 為離島9801.01加入與它最像的兩個鄰居9812.02/9813
queen_w[[168]] <- c(171, 172)
queen_w[[168]] <- as.integer(queen_w[[168]])
queen_w[[171]] <- c(101, 105, 106, 168)
queen_w[[171]] <- as.integer(queen_w[[171]])
queen_w[[172]] <- c(92, 93, 94, 95, 96, 97, 98, 168)
queen_w[[172]] <- as.integer(queen_w[[172]])
summary(queen_w)



# 4-3 標準化空間權重
srdw <- nb2listw(queen_w, style="W", zero.policy=TRUE)
srdw$weights[168]  # check



# 4-4 建立空間權重矩陣
ww <- listw2mat(srdw)



############################################################################################################



# 五、空間自相關

# 5-1 全域空間檢定 : Moran's I
moran.plot(boston$Y2, srdw, labels = as.character(boston$NAME10))  # 莫蘭圖
moran(boston$Y2, srdw, length(queen_w), Szero(srdw))[1]            # 莫蘭指數
moran.test(boston$Y2, srdw, alternative="greater")                 # 莫蘭檢定



#5-2 局部空間檢定 : Lisa
localY2 <- localmoran(x=boston$Y2, srdw)  

## LISA Cluster Map
boston$Y2sc <- scale(boston$Y2)
boston$Y2lg <- lag.listw(srdw, boston$Y2sc)
boston$quad_sig2 <- NA
boston$quad_sig2[(boston$Y2sc >= 0 & boston$Y2lg >= 0) & (localY2[, 5] <= 0.05)] <- 1
boston$quad_sig2[(boston$Y2sc <= 0 & boston$Y2lg <= 0) & (localY2[, 5] <= 0.05)] <- 2
boston$quad_sig2[(boston$Y2sc >= 0 & boston$Y2lg <= 0) & (localY2[, 5] <= 0.05)] <- 3
boston$quad_sig2[(boston$Y2sc >= 0 & boston$Y2lg <= 0) & (localY2[, 5] <= 0.05)] <- 4
boston$quad_sig2[(boston$Y2sc <= 0 & boston$Y2lg >= 0) & (localY2[, 5] <= 0.05)] <- 5
breaks <- seq(1, 5, 1)
labels <- c("high-High", "low-Low", "High-Low", "Low-High", "Not Signif.")
np <- findInterval(boston$quad_sig2, breaks)
colors <- c("red", "blue", "lightpink", "skyblue2", "white")
plot(boston["NAME10"], col = colors[np], main="Local Moran's I")
legend("bottomright", legend = labels, fill = colors, bty = "n")



############################################################################################################



# 六、空間迴歸模型 : SAR & CAR
library(hglm)
XXX <- model.matrix(~ boston$X1+boston$X2+boston$X3+boston$X4+boston$X7+boston$X8+boston$X9+boston$X13+boston$X14+boston$X15
                    +boston$X16+boston$X17+boston$X18+boston$X19+boston$X20+boston$X21+boston$X22+boston$X23+boston$X24
                    +boston$X25+boston$X26+boston$X27+boston$X28+boston$X29+boston$X30+boston$X31)

# 6-1 SAR model
bSAR <- hglm(X = XXX, y = boston$Y, Z = diag(173), family = poisson(), rand.family = SAR(D = ww), offset = log(boston$Area), conv = 1e-05)
summary(bSAR)
moran.test(bSAR$resid, srdw, alternative="greater")   # 檢定殘差，確定已不具有空間自相關
sum((boston$Y - bSAR$fv)^2)/173  # MSE: 1021.484



# 6-2 CAR model
bCAR <- hglm(X = XXX, y = boston$Y, Z = diag(173), family = poisson(), rand.family = CAR(D = ww), offset = log(boston$Area), conv = 1e-05)
summary(bCAR)
moran.test(bCAR$resid, srdw, alternative="greater")   # 檢定殘差，確定已不具有空間自相關
sum((boston$Y - bCAR$fv)^2)/173  # MSE: 836.406



################################################################
###   三種模型配適優劣: CAR > SAR > Poisson Regression       ###
###   考慮空間相關性的模型效果比沒有考慮的好                 ###
###   犯罪事件除了受模型中顯著變數影響，亦受鄰近區域的影響   ###
################################################################
