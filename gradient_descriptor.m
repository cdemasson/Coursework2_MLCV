function gradHistogram = gradient_descriptor(pic_data, IPts)


rowNb = size(pic_data,1);
colNb = size(pic_data,2);

L = (imgaussfilt(pic_data,1.5));
imshow(L);

m = zeros(rowNb,colNb);
for row = 2:size(L,1)-1
    for col = 2:size(L,2)-1
        m(row,col) = (L(row+1,col) - L(row-1,col)).^2 + (L(row,col+1) - L(row,col-1)).^2;
    end
end
m(end+1,:) = 0;
m(:,end+1)=0;
m=sqrt(double(m));

%%
theta = zeros(rowNb,colNb);
for row = 2:size(L,1)-1
    for col = 2:size(L,2)-1
        theta(row,col) = atand(double((L(row,col+1) - L(row,col-1)) / (L(row+1,col) - L(row-1,col))));
    end
end


%%
dim = 5;
nb_bins = 36;
histo = zeros(length(IPts), nb_bins);
for pt = 1:size(IPts,1)
    for row = IPts(pt,1)-dim : IPts(pt,1)+dim
        for col = IPts(pt,2)-dim : IPts(pt,2)+dim
            if row > 0 && col > 0 && row < rowNb && col < colNb
                bin = round((theta(row,col)+5)/10);
                histo(pt,bin) = histo(pt,bin) + m(row,col);
            end
        end
    end
end


pt = 1;
for des = 1:size(IPts,1)
    [maxi,index] = max(histo(des,:));
    orientAss(pt,:) = [des index];
    pt = pt+1;
    [row, col] = find(histo(des,:) < maxi & histo(des,:) > 0.8*maxi);
    if size(col,2) ~= 0
        for c = 1:size(col,2)
            orientAss(pt,:) = [des col(1,c)];
            pt=pt+1;
        end
    end
end

%%
gaussCol = gausswin(16);
gaussLine = gaussCol';
zoneL = zeros(16);
for i=1:16
    for j = 1:16
        zoneL(i,j) = gaussLine(j) + gaussCol(i);
    end
end


%%
vector128 = zeros(16,8);
gradHistogram = zeros(size(orientAss,1),129);
for keyPt = 1:size(orientAss,1)
    intPt = orientAss(keyPt,1);
    zoneT = theta(IPts(intPt,1)-8:IPts(intPt,1)+7, IPts(intPt,2)-7:IPts(intPt,2)+8);    %-orientAss(keyPt,2)*10;
    zoneM = m(IPts(intPt,1)-8:IPts(intPt,1)+7, IPts(intPt,2)-7:IPts(intPt,2)+8);
    zoneTbin = zoneT;
    for row = 1:16
        for col = 1:16
            zoneTbin(row,col) = round((zoneTbin(row,col)+23)/45); 
            r=round((row+1)/4)-1;
            c=round((col+1)/4)-1;
            rc = base2dec(int2str(c+10*r), 4)+1;
            vector128(rc, zoneTbin(row,col)) = vector128(rc, zoneTbin(row,col)) + zoneM(row,col) * zoneL(row,col);
        end
    end
    for vectorRow=1:16
        histoCol = (vectorRow-1)*8+1;
        gradHistogram(keyPt, histoCol:histoCol+7) = vector128(vectorRow,:);
    end
end
gradHistogram(:,end)=orientAss(:,1);


end