# �@�B��ƳB�z

# 1-1 �a�ϸ��
library(sf)
tract <- read_sf("C:/Users/User/Desktop/tract.gpkg")   # 181 obs.

## �i�h�y�a��+Tract_No
plot(tract['geom'], col= "lightblue")
text(st_coordinates(st_centroid(tract['geom'])), labels = tract$NAME10, cex = 0.6)



# 1-2 Y - �Ǹo���
crime <- read.csv("C:/Users/User/Desktop/Crime.csv", header=T)   # �g��:Long, �n��:Lat
crime <- as.data.frame(crime) %>% st_as_sf(coords=c("Long","Lat"), crs=4326, remove=FALSE)   # �ର�Ŷ����

## Spatial Join : points to polygon
tract <- tract %>% st_transform(tract$geom, crs=4326)   # �N�i�h�y�a�Ϫ�crs�]�ন�P�Ǹo�@�P
crime <- st_join(crime, left = FALSE, tract['NAME10'])   # inner_join, ���ѨC��Y���I�b����tract
Y <- as.data.frame(table(crime$NAME10)) ; colnames(Y) <- c("NAME10", "Y")   # �p��C��tract���Ǹo�q
tract <- merge(tract, Y, by="NAME10", all.x=T)   # ��Y�֤J�a�ϸ�Ƥ�
tract$Y[which(is.na(tract$Y))] <- 0   # tract���S���Ǹo��Y�אּ0



# 1-3 X - �H�f�S�x�P���Ҧ]�l(�@29�� + tract�����n)
DG <- read.csv("C:/Users/User/Desktop/variables.csv", header=T)  # 173 obs., ����8�Ӹ�Ưʥ��ϰ�

## �X�֩Ҧ����
boston <- merge(DG, tract, by="NAME10", all.x=T)
boston$Area <- (boston$ALAND10 + boston$AWATER10)/1000000   # �p��C��tract���h�֥��褽��
boston$Y2 <- boston$Y/boston$Area   # �p��C��tract����쭱�n�Ǹo�q: �Ω�ԭz�έp & �Ŷ��۬���



# �s�X���
boston2 <- boston[, -c(31:46, 48)]
write.csv(boston2, "C:/Users/User/Desktop/Boston.csv")



############################################################################################################



# �G�B��Ʊ���

# 2-1 �Ǹo�a�I�b�a�ϤW��������
plot(tract['geom'], col=NA)
plot(crime$geometry, pch=20, cex=0.5, col="red", add=T)

## �U��tract���Ǹo�q�h���
Bsf <- st_sf(boston, geometry = boston$geometry)
plot(Bsf["Y2"], nbreaks = 5, breaks = "quantile")



# 2-2 �s���ܼ�
continuous <- boston[, c(2:24, 50)]   # �s���ܼ� + Y2

## �ԭz�έp
summary(continuous)   # Min, 1st Qu, Median, Mean, 3rd Qu, Max
round(apply(continuous, 2, sd), 2)   # �зǮt
library(moments)
round(apply(continuous, 2, skewness), 2)    # ����
round(apply(continuous, 2, kurtosis), 2)    # �p��

## ���������R: �����Y�� & �˩w
library(GGally)
ggpairs(continuous)



# 2-3 ���O�ܼ�
categorical <- boston[, c(25:30, 50)]   # ���O�ܼ� + Y2

## �U���O�p�ƻP����
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

## ��Ž��
par(mfrow=c(2,3))
boxplot(Y2~X24, data = categorical, main="X24", xlab="", ylab="Y", cex=2)
boxplot(Y2~X25, data = categorical, main="X25", xlab="", ylab="", cex=2)
boxplot(Y2~X26, data = categorical, main="X26", xlab="", ylab="", cex=2)
boxplot(Y2~X27, data = categorical, main="X27", xlab="", ylab="Y", cex=2)
boxplot(Y2~X28, data = categorical, main="X28", xlab="", ylab="", cex=2)
boxplot(Y2~X29, data = categorical, main="X29", xlab="", ylab="", cex=2)

## Normal distribution : �]���D�`�A�����A�G�u��ϥ� Kruskal-Wallis test
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



# �T�BPoisson Regression model

# 3-1 ��l�ҫ�
PR <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
         data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(PR)
1-((sum((PR$fitted.values - boston$Y)^2)/(173-length(PR$coefficients)))/(sum((boston$Y - mean(boston$Y))^2)/172))   # Adjusted R Square : 0.7111642
sum((boston$Y - PR$fitted.values)^2)/173   # MSE : 11195.79

## VIF
library(car)
vif(PR)   # all less than 10, but X5, X6, X10 & X11 > 5
mean(vif(PR))   # 4.730659
## ���Ӥ��ӲŦX�޿誺����ܼ�: X12 beta: 0.257, P: 0.000189, Q: �~��V���Ǹo�v�V�h?



# 3-2 ����}�l

## ���� 1 - �椬�@�� (�g����h�ӻPX12���զX�A�ĪG���Ӳz�Q)
T1 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29+X12*X5,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T1)
### �����u��
b5 <- seq(min(boston$X5), max(boston$X5), length.out = 173)
b12 <- seq(min(boston$X12), max(boston$X12), length.out = 173)
z <- outer(b5, b12, FUN = function(f, g) 0.11*f + 0.62*g -0.48*f*g)
par(mfrow = c(1, 2))
persp(b5, b12, z, theta = 45, phi = 10, shade = 0.75, xlab = "X5", ylab = "X12", zlab = "y", main = "3D")
contour(b5, b12, z, xlab = "X5", ylab = "X12", main = "Expected Y")

## ���� 2 - �h�����j�k (�ĪG�٬O���Ӳz�Q)
T2 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+I(X12^2)+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T2)
### Plot
b12 <- seq(min(boston$X12), max(boston$X12), length.out = 173)
g <- 0.812746*b12 -0.047125*(b12^2)
plot(b12, g, type="l")  # Max ���b 8.x

## ���� 3 - ���q���j�k (�ĪG�٬O���Ӳz�Q)
### �ѦҦh�����j�k�����G�A�]�w�_�I = 8
boston$X12_1 <- boston$X12   # �s�ͤ@���ܼ�X12_1
boston$X12_1[which(boston$X12_1 < 8)] <- 0   # ���_�I�H�U��0
boston$X12_1[which(boston$X12_1 >= 8)] <- boston$X12_1[which(boston$X12_1 >= 8)]-8   # �_�I�H�W��(X12-�_�I)
T3 <- glm(Y ~ X1+X2+X3+X4+X5+X6+X7+X8+X9+X10+X11+X12+X12_1+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29,
          data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(T3)
#### if X12 < 8,  E[Y] = 3.031678 + 0.377836 * X12
#### if X12 >= 8, E[Y] = 3.031678 + 0.377836 * X12 - 0.654295 * (X12 - 8) = 8.266038 - 0.276459 * X12

##  ���� 4 - PCA (�復 - �|�묹�ҫ��t�A�סA���ܼƪ�������X�z)
boston1 <- boston[, c(6, 7, 11, 12, 13)]   # ������Y�ư��� X5, X6, X10, X11, X12 �i��PCA
boston1$X6 <- 1- boston1$X6       # To avoid (-) cor, change X6 to 1-X6
boston1$X11 <- 1- boston1$X11     # To avoid (-) cor, change X11 to 1-X6
pp1 <- prcomp(boston1, center=T, scale=T)
round((pp1$sdev)^2 / sum((pp1$sdev)^2), 2)   # PCA�����ܲ��q: 0.78 0.12 0.08 0.01 0.00
round(-pp1$rotation, 2)   # eigenvalue
####      PC1   PC2   PC3   PC4   PC5
#### X5  0.48 -0.20 -0.35  0.76  0.17
#### X6  0.44 -0.50 -0.44 -0.56 -0.24
#### X10 0.48 -0.03  0.45 -0.25  0.71
#### X11 0.46  0.04  0.59  0.14 -0.64
#### X12 0.37  0.84 -0.36 -0.16 -0.05
round(cor(boston1, -pp1$x), 2)   # �t�� (��l�ܼƻPPCA�������Y��)
####      PC1   PC2   PC3   PC4   PC5
#### X5  0.94 -0.15 -0.23  0.20  0.03
#### X6  0.87 -0.38 -0.28 -0.14 -0.04
#### X10 0.95 -0.02  0.29 -0.07  0.11
#### X11 0.92  0.03  0.38  0.04 -0.10
#### X12 0.73  0.64 -0.23 -0.04 -0.01
### �M�w�s�W���PCA
boston$X30 <- 0 - pp1$x[, 1]   # �R�W: ���|�u�դH�f�]�l
boston$X31 <- 0 - pp1$x[, 2]   # �R�W: ���~�B�¥ձڸǲV�~�ϰ�



# 3-3 �ǤJ�s�ܼƪ�Poisson Regression model
PR2 <- glm(Y ~ X1+X3+X7+X8+X9+X13+X14+X15+X16+X17+X18+X19+X20+X21+X22+X23+X24+X25+X26+X27+X28+X29+X30+X31,
         data = boston, family=quasipoisson(link = "log"), offset = log(Area))
summary(PR2)
1-((sum((PR2$fitted.values - boston$Y)^2)/(173-length(PR2$coefficients)))/(sum((boston$Y - mean(boston$Y))^2)/172))  # Adjusted R Square : 0.6975412
sum((boston$Y - PR2$fitted.values)^2)/173  # MSE: 12145.56
vif(PR2)   # all less than 5
mean(vif(PR2))   # 2.636503



############################################################################################################



# �|�B�Ŷ��v���x�}

# 4-1 ��X�F�~�M��
library(spdep)
queen_w <- poly2nb(boston)
summary(queen_w)



# 4-2 �B�z���q���D
queen_w[[168]]  # 9801.01
queen_w[[171]]  # 9812.02 (�F�~ : 101, 105, 106) 
queen_w[[172]]  # 9813 (�F�~ : 92, 93, 94, 95, 96, 97, 98)

## �����q9801.01�[�J�P���̹�����ӾF�~9812.02/9813
queen_w[[168]] <- c(171, 172)
queen_w[[168]] <- as.integer(queen_w[[168]])
queen_w[[171]] <- c(101, 105, 106, 168)
queen_w[[171]] <- as.integer(queen_w[[171]])
queen_w[[172]] <- c(92, 93, 94, 95, 96, 97, 98, 168)
queen_w[[172]] <- as.integer(queen_w[[172]])
summary(queen_w)



# 4-3 �зǤƪŶ��v��
srdw <- nb2listw(queen_w, style="W", zero.policy=TRUE)
srdw$weights[168]  # check



# 4-4 �إߪŶ��v���x�}
ww <- listw2mat(srdw)



############################################################################################################



# ���B�Ŷ��۬���

# 5-1 ����Ŷ��˩w : Moran's I
moran.plot(boston$Y2, srdw, labels = as.character(boston$NAME10))  # ������
moran(boston$Y2, srdw, length(queen_w), Szero(srdw))[1]            # ��������
moran.test(boston$Y2, srdw, alternative="greater")                 # �����˩w



#5-2 �����Ŷ��˩w : Lisa
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



# ���B�Ŷ��j�k�ҫ� : SAR & CAR
library(hglm)
XXX <- model.matrix(~ boston$X1+boston$X2+boston$X3+boston$X4+boston$X7+boston$X8+boston$X9+boston$X13+boston$X14+boston$X15
                    +boston$X16+boston$X17+boston$X18+boston$X19+boston$X20+boston$X21+boston$X22+boston$X23+boston$X24
                    +boston$X25+boston$X26+boston$X27+boston$X28+boston$X29+boston$X30+boston$X31)

# 6-1 SAR model
bSAR <- hglm(X = XXX, y = boston$Y, Z = diag(173), family = poisson(), rand.family = SAR(D = ww), offset = log(boston$Area), conv = 1e-05)
summary(bSAR)
moran.test(bSAR$resid, srdw, alternative="greater")   # �˩w�ݮt�A�T�w�w���㦳�Ŷ��۬���
sum((boston$Y - bSAR$fv)^2)/173  # MSE: 1021.484



# 6-2 CAR model
bCAR <- hglm(X = XXX, y = boston$Y, Z = diag(173), family = poisson(), rand.family = CAR(D = ww), offset = log(boston$Area), conv = 1e-05)
summary(bCAR)
moran.test(bCAR$resid, srdw, alternative="greater")   # �˩w�ݮt�A�T�w�w���㦳�Ŷ��۬���
sum((boston$Y - bCAR$fv)^2)/173  # MSE: 836.406



################################################################
###   �T�ؼҫ��t�A�u�H: CAR > SAR > Poisson Regression       ###
###   �Ҽ{�Ŷ������ʪ��ҫ��ĪG��S���Ҽ{���n                 ###
###   �Ǹo�ƥ󰣤F���ҫ�������ܼƼv�T�A����F��ϰ쪺�v�T   ###
################################################################