function ShapeMeasure()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Code for measuring bottle shapes
%
%    Author: Carlos Alberto Arce Lopera
%    Email: caarce@icesi.edu.co
%     Date: 25-04-2013
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  pkg load image;
 fid = fopen('BottleShapeInfo.csv', 'a');
 fprintf(fid,'%s','Name, Mean,Variance, Skewness, Kurtosis, Centroid X, Centroid Y, Body Height, Body Width, Area, Lid Height, Lid Width');
 fprintf(fid,'%s\n','');
 fclose(fid);
 %load the directory
 D = dir('*.JPG');

for i = 1:numel(D)
    I = imread(D(i).name);
    GI = im2bw(I);    
    
    %rotation to align all images
    bb1 = regionprops(GI,'BoundingBox','Centroid','Orientation','FilledArea');
    % Corrects: if several boundingBoxes are found, picks the last one
    [l,~]=size(bb1);
    if(l>1)
        max=0;
        ind=0;
        for k=1:1:l
            if(bb1(k).FilledArea>max)
                ind=k;
                max=bb1(k).FilledArea;
            end
        end
        bb1=bb1(ind);
    end
    l=0;
    %   uncomment to check the bounding box defined
    %   figure, imshow(GI), hold on, rectangle('Position', bb1.BoundingBox,'EdgeColor','r', 'LineWidth', 1)
    angle=bb1.Orientation;
    A=imrotate(GI,(-90+abs(angle)));
    bb2 = regionprops(A,'BoundingBox','Centroid','Orientation','FilledArea');
    % Corrects: if several boundingBoxes are found, picks the last one
    [l,~]=size(bb2);
    if(l>1)
        max=0;
        ind=0;
        for k=1:1:l
            if(bb2(k).FilledArea>max)
                ind=k;
                max=bb2(k).FilledArea;
            end
        end
        bb2=bb2(ind);
    end
    l=0;
    %   uncomment to check the bounding box defined
    %   figure, imshow(A), hold on, rectangle('Position', bb2.BoundingBox,'EdgeColor','r', 'LineWidth', 1)

    % Global measures of bottles
    
    bbox=vertcat(bb1.BoundingBox);
    bboxA=vertcat(bb2.BoundingBox);
    cen=bb2.Centroid;
    farea=bb2.FilledArea;
    xwidth=bboxA(1,3);
    ywidth=bboxA(1,4);
    

    info=imfinfo(D(i).name);
    ancho=info.Width;
    alto=info.Height;
    
    % Lid and Body separation
    xinicio=uint32(bbox(1,2));
    xfin=uint32(bbox(1,2)+bbox(1,4));
    minimo=ancho;
    xminimo=0;
    acc=0;
    
    for x=xinicio+100:xfin-100
        for y=1:ancho
            if GI(x,y)==1
                acc=acc+1;
            end
        end
        if minimo>acc
            minimo=acc;
            xminimo=x;
        end
        acc=0;
    end
    
    lid=GI(1:xminimo,:);
%     uncomment to see the lid 
%     figure, imshow(lid);
    body=GI(xminimo:alto,:);
%     uncomment to see the body
%     figure, imshow(body);

    % Measure Body
    bb3 = regionprops(body,'BoundingBox','Centroid','Orientation','FilledArea');
    % Corrects: if several boundingBoxes are found, picks the last one
    [l,~]=size(bb3);
    if(l>1)
        max=0;
        ind=0;
        for k=1:1:l
            if(bb3(k).FilledArea>max)
                ind=k;
                max=bb3(k).FilledArea;
            end
        end
        bb3=bb3(ind);
    end
    l=0;
%      uncomment to see the bounding box of the body
%      figure, imshow(body), hold on, rectangle('Position', bb3.BoundingBox,'EdgeColor','r', 'LineWidth', 1)
    
    bbox1=vertcat(bb3.BoundingBox);
    xwidthB=bbox1(1,3);
    ywidthB=bbox1(1,4);
    xi=uint32(bbox(1,1));
    
    % Body transform to distribution
    values=zeros(1,ywidthB);
    for j=1:ywidthB
        A3 = body(j:j, xi:xi+round(xwidthB/2), :);
        bb4 = regionprops(A3,'BoundingBox');
        bbox2=vertcat(bb4.BoundingBox);
        try
        values(j)=bbox2(1,3);
        catch err
        end
    end
    
%      uncomment to see the region on which the moments are calculated    
%      imshow(body(1:ywidthB,xi:xi+round(xwidthB/2),:));
    
    % Measure Height and Width of Lid
    bb5 = regionprops(lid,'BoundingBox');
    bbox3=vertcat(bb5.BoundingBox);
    xwidth_Lid=bbox3(1,3);
    ywidth_Lid=bbox3(1,4);
  
    [p,n,e] = fileparts(D(i).name);
    C{i,1}= n;
    fileName = strcat(p,n);
    moment1=mean(values);
    moment2=var(values);
    moment3=skewness(values);
    moment4=kurtosis(values);

      
    fid = fopen('BottleShapeInfo.csv', 'a');
    fprintf(fid,'%s,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%d,%d',fileName, moment1,moment2,moment3,moment4, cen(1), cen(2),xwidth,ywidth,farea,ywidth_Lid,xwidth_Lid);
    fprintf(fid,'%s\n','');
    fclose(fid);
 
end
