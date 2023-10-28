
%% =========================== Firdt part notes===========================
% For color image, color video
% Reference paper: A Low-rank Tensor Decomposition Model with Factors Prior and Total Variation for Impulsive Noise Removal 
% by Xin Tian
% Email: tianxin1307@hnu.edu.cn


function [doubleX] = FTDTV_eye4D(Nmsi,lambda_1,lambda_2,lambda_3, alpha, beta, tsize, N, factor, myInitial_v, r1, r2, rho)
    Q=cell(N,1);
    F=cell(N,1);
    R=cell(N,1);
    U=cell(N,1);
    V=cell(N,1);
    myV=cell(N,1);
    
    G=cell(N,1);
    X=cell(N,1);
    W=cell(N,1);
    S=cell(N,1);        %%+
    K=cell(N,1);        %%+ 
    
    Lambda=cell(N,1);
    Gamma=cell(N,1);
    Phi=cell(N,1);
 
    
   % clean_psnr = 0;
    
    epsilon=1.0e-6;
    for i=1:N
        l=1;
        for j=[1:i-1,i+1:N]
            l=l*tsize(j);
        end
        rand('seed',1)
        U{i}=rand(tsize(i),tsize(i));   %%rand
        rand('seed',2)
        V{i}=rand(tsize(i),tsize(i));   %%rand
       % V{i}=V{i}/norm(V{i});
        if(beta(i)==1)
            Q{i}=rand(tsize(i)-1, l);
            R{i}=rand(tsize(i),l);
        else
            Q{i}=[];
            R{i}=[];
        end
       
        F{i}=zeros(tsize(i)-1,tsize(i));
        for j=1:tsize(i)-1
            F{i}(j,j)=1;
            F{i}(j,j+1)=-1;
        end

    end
    
    for i=1:N
       if(beta(i)==1)
           Lambda{i}=sign(Q{i})/max([norm(Q{i}), norm(Q{i},Inf), epsilon]);
           Phi{i}=sign(R{i})/max([norm(R{i}), norm(R{i},Inf), epsilon]);
       else
           Lambda{i}=[];
           Phi{i}=[];
       end    
       Gamma{i}=sign(U{i})/max([norm(U{i}), norm(U{i},Inf), epsilon]);     
       
    end
    
    tensor_X=tenzeros(tsize);
    tensor_G=tensor_X;
    tensor_S=tensor_X;          %%+ S
    tensor_W=tenzeros(tsize);
    tensor_K=tenzeros(tsize);   %%+ 乘子K
    
  %% ----------------------------------------------------------------------
    
    iteration=1;
    
%   myInitial_v=1.0e-1;
    rho_1=myInitial_v;
    rho_2=myInitial_v;
    rho_3=myInitial_v;
    rho_4=myInitial_v;
    rho_5=myInitial_v;  %%+
    
%     factor=1.1;
    
    while(true)
        tensor_X_pre=tensor_X;
        for n=1:N
            X{n}=double(tenmat(tensor_X,n));
            W{n}=double(tenmat(tensor_W,n));   %% X的乘子
            
        end
        
        %update Q 
        for n=1:N
            if(beta(n)==1)
                Q{n}=myshrinkage(F{n}*R{n} - 1/rho_1 *Lambda{n}, lambda_1/rho_1);
            end
        end
        
        %update R 
        for n=1:N
            if(beta(n)==1)
                R{n}= (rho_1*F{n}'*F{n} + rho_2 * eye((tsize(n))))\(F{n}'* Lambda{n}+ rho_1* F{n}'* Q{n} + rho_2 * X{n} - Phi{n});
            end
        end
        
        %update U 
        for n=1:N
            U{n}=SVT(V{n} + Gamma{n}/rho_3,alpha(n)/rho_3,0);
        end
        
        %update V 
        for n=1:N
            tmp=ttm(tensor_G,V,-n);
            tmp=tenmat(tmp,n);
            tmp=double(tmp);
            V{n}=(- Gamma{n} + rho_3 * U{n} + W{n} * tmp' + rho_4 * X{n}* tmp')/((rho_3*eye(tsize(n)) + rho_4*(tmp*tmp'))); 
        end
        
        %update X(Z) 
        tmp=0;
        for n=1:N
            if(beta(n)==1)
               currZ = Phi{n} + rho_2 * R{n};
               myX=tenmat(tensor_X,n);
               myX=tenmat(currZ,myX.rdims, myX.cdims,myX.tsize);
               tmp=tmp + tensor(myX);
             end
        end
%         tmp = tmp - tensor_W + rho_4* ttm(tensor_G,V,1:N);
        tmp = tmp - tensor_W + rho_4* ttm(tensor_G,V,1:N) + rho_5*Nmsi - rho_5*tensor_S + tensor_K;
        
        NN=numel(find(beta==1));
        tensor_X = tmp/(NN*rho_2 + rho_4 + rho_5);

        
        %update G 

        for n=1:N
            myV{n}=V{n}';
        end
         myG = optimize_Z(myV,double(tensor_X),double(tensor_W),rho_4,lambda_2);
         tensor_G = tensor(myG);
         
         
        
       %update S 
%% --------------------- norm 1 -------------------------------       
%         Ten = Nmsi-tensor_X + tensor_K/rho_5;
%         DoubleTen = double(Ten);
%         tensor_S = myshrinkage(DoubleTen, lambda_3/rho_5);  
%% --------------------- MCP ----------------------------------
       Sk = tensor_S;
       H  = correcH(Sk,r1,r2);         %% double
       Stemp = (lambda_3*H + rho*Sk + tensor_K + rho_5*Nmsi - rho_5*tensor_X)/(rho_5 + rho);  %% rho是可调参数
       DoubleStemp = double(Stemp);
       tensor_S   = myshrinkage(DoubleStemp, lambda_3/(rho_5 + rho));

 %% -----------------------------sGS---------------------------------
%        %update G 不变
% 
%        for n=1:N
%             myV{n}=V{n}';
%        end
%        myG = optimize_Z(myV,double(tensor_X),double(tensor_W),rho_4,lambda_2);
%        tensor_G = tensor(myG);  
       
        %update X(Z) 
        tmp=0;
        for n=1:N
            if(beta(n)==1)
               currZ = Phi{n} + rho_2 * R{n};
               myX=tenmat(tensor_X,n);
               myX=tenmat(currZ,myX.rdims, myX.cdims,myX.tsize);
               tmp=tmp + tensor(myX);
             end
        end
%         tmp = tmp - tensor_W + rho_4* ttm(tensor_G,V,1:N);
        tmp = tmp - tensor_W + rho_4* ttm(tensor_G,V,1:N) + rho_5*Nmsi - rho_5*tensor_S + tensor_K;
        
        NN=numel(find(beta==1));
        tensor_X = tmp/(NN*rho_2 + rho_4 + rho_5);
       
        %update V 
        for n=1:N
            tmp=ttm(tensor_G,V,-n);
            tmp=tenmat(tmp,n);
            tmp=double(tmp);
            V{n}=(- Gamma{n} + rho_3 * U{n} + W{n} * tmp' + rho_4 * X{n}* tmp')/((rho_3*eye(tsize(n)) + rho_4*(tmp*tmp'))); 
        end
        
        %update U 
        for n=1:N
            U{n}=SVT(V{n} + Gamma{n}/rho_3,alpha(n)/rho_3,0);
        end
        
        %update R 
        for n=1:N
            if(beta(n)==1)
                R{n}= (rho_1*F{n}'*F{n} + rho_2 * eye((tsize(n))))\(F{n}'* Lambda{n}+ rho_1* F{n}'* Q{n} + rho_2 * X{n} - Phi{n});
            end
        end
       
%         %update Q 不变
%         for n=1:N
%             if(beta(n)==1)
%                 Q{n}=myshrinkage(F{n}*R{n} - 1/rho_1 *Lambda{n}, lambda_1/rho_1);
%             end
%         end
        
     
       
%       %update multiplers
        for n=1:N
            if(beta(n)==1)
                Lambda{n}=Lambda{n} + rho_1 * (Q{n}- F{n}*R{n});
                Phi{n}= Phi{n}+ rho_2*(R{n} - double(tenmat(tensor_X,n)));
            end
            Gamma{n}=Gamma{n}+ rho_3*(V{n}-U{n});
        end
        tensor_W = tensor_W + rho_4*(tensor_X - ttm(tensor_G, V,1:N));
        tensor_K = tensor_K + rho_5*(Nmsi - tensor_X - tensor_S);
        diff=norm(tensor_X-tensor_X_pre)/norm(tensor_X);
        
        
        rho_1=rho_1*factor;
        rho_2=rho_2*factor;
        rho_3=rho_3*factor;
        rho_4=rho_4*factor;
        rho_5=rho_5*factor;
        
        fprintf('iter=%d,diff=%f\n',iteration,diff);
       
        if(iteration>5)||diff<1e-5
           break;
        end
        
        doubleX = double(tensor_X);
         
        
        %% RGB图像
 
              
        iteration = iteration + 1; 
        
  

                
    end
%     tensor_X=double(tensor_X);
 

end

