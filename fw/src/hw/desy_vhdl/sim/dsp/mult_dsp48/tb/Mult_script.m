% -------------------------------------------------------------------------------
% --          ____  _____________  __                                          --
% --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
% --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
% --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
% --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
% --                                                                           --
% -------------------------------------------------------------------------------
% --! @copyright Copyright 2021 DESY
% --! SPDX-License-Identifier: CERN-OHL-W-2.0
% -------------------------------------------------------------------------------
% --! @date 2021-12-09
% --! @author Shweta Prasad <shweta.prasad@desy.de>
% -------------------------------------------------------------------------------
% --! @brief
% --! This is a test script for writing A vector , B vector and
%     mult vector on text files.
% -------------------------------------------------------------------------------
F = fimath('OverflowAction','Wrap','RoundingMethod','Floor'); 
DT = 'Double';

a_in_array = [-0.970000741039197;
              -0.742639194189556;
              -0.548774236349738;
              -0.333194393110472;
              -0.135238578155205;
              0.0815821050414609;
               0.152117784743213;
               0.425930206128130;
               0.661371558537172;
               0.993170157646061];

b_in_array = [0.411453983587244;
              0.197949064003456;
             -0.657389040515377;
              0.686037655474030;
             -0.0200091902045514;
              -0.48079558346084;
             -0.591954227180695;
              0.834554990049871;
              0.548149923474970;
              0.601830209222048];
          
a_input = [a_in_array];
b_input = [b_in_array];
a_in_fixed = fi(a_input,1,32,31,F);
b_in_fixed = fi(b_input,1,32,31,F);
mult_output(:,1) = a_in_fixed(:,1).*b_in_fixed(:,1);

a_array =flipud(a_in_fixed);
fi_a = fopen('a_input.txt','w');
for n=1:size(a_array,1)
  fprintf(fi_a,'%s\n',bin(a_array(n)));
end
fclose(fi_a);

b_array =flipud(b_in_fixed);
fi_b = fopen('b_input.txt','w');
for n=1:size(b_array,1)
  fprintf(fi_b,'%s\n',bin(b_array(n)));
end
fclose(fi_b);

mult_array =flipud(mult_output);
fo_mult = fopen('pipelined_mult_out.txt','w');
for n=1:size(mult_array,1)
  fprintf(fo_mult,'%s\n',bin(mult_array(n)));
end
fclose(fo_mult);