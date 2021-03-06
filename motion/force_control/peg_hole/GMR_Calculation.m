function Output = GMR_Calculation(Force,Torque,GMRpar_Priors ,GMRpar_Mu, GMRpar_Sigma, GMRpar_inv_SigmaIn,GMRpar_det_SigmaIn )

% GMRpar = {Priors [1*15], Mu [4*15], Sigma [4*4*15], inv_SigmaIn [ 2*2*15], det_SigmaIn [1*15] }

% persistent Mu  Mu_w Mu_q  Prior Sigma_w_row  Sigma_w    Sigma_qw   inv_Sigma_w_row   inv_Sigma_w  Sigma_det  ;
%
% if isempty(Mu)
%     Mu = [0.138,0.0580,0.552,0.998,-5.742,0.536,0.979,0.303,7.586,-1.11,-4.931,-0.213,2.577,-6.949,0.557;
%         -2.263,-8.649,-3.464,-0.891,-0.251,7.073,-3.363,0.187,-0.771,-1.477,4.623,-0.156,-1.64,-1.896,6.363;
%         -6.092,-0.872,3.632,1.875,-5.656,0.520,1.614,0.681,-1.219,8.428,5.952,-0.517,-8.19,0.0780,-0.205;
%         -4.54,0.131,-1.524,-0.763,-0.0590,1.281,0.833,-8.299,7.405,1.098,-1.62,0.135,1.082,6.733,0.199;
%         -0.130,1.484,-6.861,-0.959,-7.343,-3.218,3.059,-0.609,1.515,-0.875,-0.866,8.988,-1.461,-0.0290,5.828;
%         -5.874,5.44,-0.0780,-7.837,-0.0590,-0.135,-0.603,2.209,0.212,7.065,-0.124,0.123,1.625,-0.976,-0.678;
%         0.079,-0.002,0.027,0.013,0.001,-0.0220,-0.0150,0.145,-0.129,-0.0190,0.0280,-0.00200,-0.0190,-0.118,-0.003];
%
%     Mu_w = Mu(1:6,:);
%     Mu_q = Mu(7,:);
%
%
%     Prior = [0.049,0.048,0.087,0.055,0.038,0.094,0.1090,0.094,0.055,0.033,0.043,0.067,0.073,0.072,0.083];
%
%     Sigma_qw = [0.038,0.0020,-0.0080,-0.1220,-0.026,0.0050;
%         0.058,0.021,-0.1280,-0.4520,-0.020,0.0060;
%         0.068,-0.023,0.047,-0.3840,0.011,-0.1010;
%         -0.1050,0.064,0.2090,-0.5080,0.4220,-0.0080;
%         -0.14,0.048,0.039,-0.4140,0.037,-0.099;
%         0.0040,0.033,0.049,-0.4740,0.012,-0.027;
%         0.021,0.025,0.011,-0.3610,0.077,0.1210;
%         -0.0040,-0.010,0.012,-0.018,-0.0060,-0.0060;
%         -0.0060,-0.0060,0.014,-0.035,-0.023,-0.018;
%         -0.1680,-0.056,-0.013,-0.5020,-0.1070,0.064;
%         0.020,-0.089,-0.065,-0.3150,0.014,-0.080;
%         -0.1270,0.026,-0.0050,-0.4790,0.010,-0.077;
%         0.036,0.023,0,-0.4320,-0.0020,0.044;
%         -0.0070,0.0070,0.031,-0.079,-0.024,-0.023;
%         -0.058,0.027,-0.093,-0.4580,0.014,0.1380];
%
%     inv_Sigma_w_row = [0.048,0.028,0.026,0.010,0.014,-0.0080,0.028,0.079,0.084,-0.0010,0.024,-0.0090,0.026,0.084,0.302,-0.022,0.043,-0.041,0.010,-0.0010,-0.022,0.15,-0.010,0.0050,0.014,0.024,0.043,-0.010,0.056,0.0010,-0.0080,-0.0090,-0.041,0.0050,0.0010,0.135;
%         0.047,0.032,0.0050,0.0060,-0.0030,-0.019,0.032,2.563,0.062,0.105,-0.032,-0.309,0.0050,0.062,0.041,-0.0080,-0.0040,-0.019,0.0060,0.105,-0.0080,0.047,-0.0020,-0.010,-0.0030,-0.032,-0.0040,-0.0020,0.041,0.014,-0.019,-0.309,-0.019,-0.010,0.014,0.155;
%         0.034,-0.0020,0.0010,0.0060,0.016,0.0010,-0.0020,0.066,0.0090,-0.0040,0.027,0.0060,0.0010,0.0090,0.080,0.0060,-0.0080,0.012,0.0060,-0.0040,0.0060,0.050,0.0090,-0.0090,0.016,0.027,-0.0080,0.0090,0.282,-0.0020,0.0010,0.0060,0.012,-0.0090,-0.0020,0.037;
%         0.059,0.017,0.0070,-0.036,-0.037,-0.080,0.017,0.048,0.010,0.023,0.020,-0.0030,0.0070,0.010,0.052,0.0040,-0.021,-0.040,-0.036,0.023,0.0040,0.167,0.147,0.081,-0.037,0.020,-0.021,0.147,0.177,0.111,-0.080,-0.0030,-0.040,0.081,0.111,0.70;
%         0.244,0.010,-0.0010,-0.096,-0.038,0.048,0.010,0.045,0.023,0.0090,0.028,-0.012,-0.0010,0.023,0.201,0.011,-0.018,0.039,-0.096,0.0090,0.011,0.090,0.059,-0.034,-0.038,0.028,-0.018,0.059,0.358,-0.053,0.048,-0.012,0.039,-0.034,-0.053,0.063;
%         0.040,0.022,-0.0070,0.0010,0.014,0.0040,0.022,0.357,0.025,0.028,0.056,0.025,-0.0070,0.025,0.056,0.0080,0.023,0.0020,0.0010,0.028,0.0080,0.040,0.0090,0,0.014,0.056,0.023,0.0090,0.093,0.0010,0.0040,0.025,0.0020,0,0.0010,0.035;
%         0.043,-0.0070,-0.015,-0.0020,-0.0030,-0.0090,-0.0070,0.108,0.043,0.010,0.0090,-0.0010,-0.015,0.043,0.069,0.0090,0.0010,0.014,-0.0020,0.010,0.0090,0.059,0.021,0.016,-0.0030,0.0090,0.0010,0.021,0.091,0.0040,-0.0090,-0.0010,0.014,0.016,0.0040,0.046;
%         0.037,0.0010,-0.0060,-0.012,-0.0070,0.0030,0.0010,0.039,-0.0010,-0.023,0.0020,0.0020,-0.0060,-0.0010,0.038,0.024,-0.0010,0.0080,-0.012,-0.023,0.024,0.997,-0.013,-0.010,-0.0070,0.0020,-0.0010,-0.013,0.045,-0.0010,0.0030,0.0020,0.0080,-0.010,-0.0010,0.045;
%         0.485,-0.013,-0.0020,-0.057,-0.024,-0.0050,-0.013,0.033,0.0040,-0.0010,-0.0030,0.0010,-0.0020,0.0040,0.041,0.025,-0.012,-0.0010,-0.057,-0.0010,0.025,0.545,-0.033,-0.022,-0.024,-0.0030,-0.012,-0.033,0.043,0.0080,-0.0050,0.0010,-0.0010,-0.022,0.0080,0.032;
%         0.058,-0.011,-0.111,-0.024,0.023,-0.032,-0.011,0.094,-0.054,0.0040,-0.049,-0.0080,-0.111,-0.054,1.326,0.036,0,0.221,-0.024,0.0040,0.036,0.052,-0.020,0.048,0.023,-0.049,0,-0.020,0.065,-0.031,-0.032,-0.0080,0.221,0.048,-0.031,0.281;
%         0.215,-0.015,-0.089,0.045,0.0040,-0.034,-0.015,0.256,-0.070,-0.077,0.050,0.080,-0.089,-0.070,0.247,-0.044,-0.018,0.027,0.045,-0.077,-0.044,0.101,-0.015,-0.049,0.0040,0.050,-0.018,-0.015,0.059,0.030,-0.034,0.080,0.027,-0.049,0.030,0.078;
%         0.036,-0.0060,0.0060,-0.011,-0.021,0.0020,-0.0060,0.056,0.0070,0.0030,-0.115,-0.0050,0.0060,0.0070,0.046,-0.0070,-0.165,0.0090,-0.011,0.0030,-0.0070,0.042,0.074,-0.0080,-0.021,-0.115,-0.165,0.074,3.05,-0.070,0.0020,-0.0050,0.0090,-0.0080,-0.070,0.036;
%         0.068,-0.0020,-0.028,0.0060,0.029,0.0060,-0.0020,0.041,-0.027,0.0010,0.0040,-0.0070,-0.028,-0.027,0.823,-0.0060,0.027,-0.017,0.0060,0.0010,-0.0060,0.041,0.0020,0.0050,0.029,0.0040,0.027,0.0020,0.055,-0.0010,0.0060,-0.0070,-0.017,0.0050,-0.0010,0.045;
%         0.304,-0.024,-0.0060,-0.030,-0.0040,-0.0040,-0.024,0.050,-0.0060,0.0090,-0.0040,-0.012,-0.0060,-0.0060,0.036,0.013,0,0.0040,-0.030,0.0090,0.013,0.237,-0.013,-0.010,-0.0040,-0.0040,0,-0.013,0.039,0.0020,-0.0040,-0.012,0.0040,-0.010,0.0020,0.036;
%         0.047,0.011,-0.010,-0.0040,0.026,-0.0040,0.011,0.221,-0.0010,0.0080,0.014,-0.012,-0.010,-0.0010,0.040,-0.0070,0.014,-0.0020,-0.0040,0.0080,-0.0070,0.044,0.0010,0.013,0.026,0.014,0.014,0.0010,0.234,-0.0030,-0.0040,-0.012,-0.0020,0.013,-0.0030,0.043];
%
%     inv_Sigma_w = zeros(6,6,15);
%     for i = 1:15
%         inv_Sigma_w(:,:,i) = reshape(inv_Sigma_w_row(i,:),6,6);
%     end
%
%     Sigma_det = [1856047.659,1254845.33,13625537.337,3402731.668,996022.352,15650542.497,25431754.48,10459390.963,2760216.861,682547.510,973055.328,4190680.398,6457968.566,7017051.75,7694577.351];
%
% end
%
% if size(Wrench,2) > size(Wrench,1)   % row
%     Wrench = Wrench';
% end
Input = [norm(Force);norm(Torque)];
if isrow(Input)
    Input = Input';
end
In = numel(Input);

% GMRpar_Priors ,GMRpar_Mu, GMRpar_Sigma, GMRpar_inv_SigmaIn,GMRpar_det_SigmaIn
% In: Dimension of input    On: Dimension of output
temp2 = zeros(2,1);
N = numel(GMRpar_Priors);
for i = 1:N
    %disp(size(Wrench));disp(size(Mu_w(:,i)));disp(size(Sigma_w(:,:,i)));
    num1 = GMRpar_Priors(i)* GMR_MND(Input,GMRpar_Mu(1:In,i),GMRpar_inv_SigmaIn(:,:,i),GMRpar_det_SigmaIn(i));
    num2 = GMRpar_Mu(In+1:end,i) + GMRpar_Sigma(In+1:end, 1:In,i)*GMRpar_inv_SigmaIn(:,:,i)*(Input - GMRpar_Mu(1:In,i));
    temp1 = 0;
    for j = 1:N
        temp1 =  temp1 + GMRpar_Priors(j)* GMR_MND(Input,GMRpar_Mu(1:In,j),GMRpar_inv_SigmaIn(:,:,j),GMRpar_det_SigmaIn(j));
    end
    den = temp1;    
    temp2 = temp2 + num1*num2/den;
end
Output = temp2;


% temp2 = 0;
% N = size(GMRpar{1},2);
% for i = 1:N
%     %disp(size(Wrench));disp(size(Mu_w(:,i)));disp(size(Sigma_w(:,:,i)));
%     num1 = Prior(i)* GMR_MND(Wrench,Mu_w(:,i),inv_Sigma_w(:,:,i),Sigma_det(i));
%     num2 = Mu_q(i) + Sigma_qw(i,:)*inv_Sigma_w(:,:,i)*(Wrench - Mu_w(:,i));
%
%     temp1 = 0;
%     for j = 1:N
%         temp1 =  temp1 + Prior(j)* GMR_MND(Wrench,Mu_w(:,j),inv_Sigma_w(:,:,j),Sigma_det(j));
%     end
%     den = temp1;
%
%     temp2 = temp2 + num1*num2/den;
% end
% correctiveq = temp2;

