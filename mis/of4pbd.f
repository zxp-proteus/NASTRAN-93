      BLOCK DATA OF4PBD        
COF4PBD        
C        
C     C ARRAY FOR COMPLEX STRESSES SORT2 FREQUENCY        
C        
      INTEGER        C1,C21,C41,C61,C81        
      COMMON /OFPB4/ C1(240),C21(240),C41(240),C61(240),C81(240)        
C        
C                 IX,L1,L2,L3,L4,L5         , IX,L1,L2,L3,L4,L5        
C                 REAL/IMAG  L3=125         , MAG/PHASE  L3=126        
C                     (L1 IS SET FOR ELEM.ID, ALWAYS = 108)        
C        
      DATA C1  /  846,108,136,125,  0,195   , 856,108,136,126,  0,195   
     2          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     3          , 846,108,144,125,  0,195   , 856,108,144,126,  0,195   
     4          , 846,108,137,125,  0,196   , 856,108,137,126,  0,196   
     5          , 846,108,145,125,  0,196   , 856,108,145,126,  0,196   
     6          , 964,108,139,125,  0,197   , 990,108,139,126,  0,197   
     7          , 964,108,138,125,  0,197   , 990,108,138,126,  0,197   
     8          , 964,108,143,125,  0,197   , 990,108,143,126,  0,197   
     9          ,1016,108,142,125,  0,198   ,1029,108,142,126,  0,198   
     O          , 846,108,131,125,  0,195   , 856,108,131,126,  0,195   
     1          , 897,108,128,125,  0,199   , 908,108,128,126,  0,199   
     2          , 897,108,129,125,  0,199   , 908,108,129,126,  0,199   
     3          , 897,108,130,125,  0,199   , 908,108,130,126,  0,199   
     4          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     5          , 964,108,133,125,  0,197   , 990,108,133,126,  0,197   
     6          ,1016,108,132,125,  0,198   ,1029,108,132,126,  0,198   
     7          , 964,108,140,125,  0,197   , 990,108,140,126,  0,197   
     8          , 964,108,135,125,  0,197   , 990,108,135,126,  0,197   
     9          , 964,108,134,125,  0,197   , 990,108,134,126,  0,197   
     O          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0  /
      DATA C21 /    0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     2          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     3          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     4          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     5          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     6          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     7          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     8          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     9          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     O          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     1          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     2          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     3          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     4          ,1042,108,127,125,  0,200   ,1074,108,127,126,  0,200   
     5          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     6          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     7          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     8          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     9          ,1179,108,222,125,  0,220   ,1214,108,222,126,  0,220   
     O          ,1179,108,224,125,  0,220   ,1214,108,224,126,  0,220  /
      DATA C41 / 1179,108,226,125,  0,220   ,1214,108,226,126,  0,220   
     2          ,1179,108,228,125,  0,220   ,1214,108,228,126,  0,220   
     3          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     4          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     5          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     6          ,   0,  0,  0, -1,  0,  0   ,   0,  0,  0, -1,  0,  0   
     7          ,1435,108,236,125,  0,252   ,1448,108,236,126,  0,252   
     8          ,1298,108,237,125,  0,243   ,1321,108,237,126,  0,243   
     9          ,3042,108,238,125,  0,453   ,3069,108,238,126,  0,453   
     O          , 865,108,239,125,  0,249   , 881,108,239,126,  0,249   
     1          ,1353,108,240,125,  0,246   ,1370,108,240,126,  0,246   
     2          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     3          ,1298,108,266,125,  0,278   ,1321,108,266,126,  0,278   
     4          ,1298,108,267,125,  0,278   ,1321,108,267,126,  0,278   
     5          ,1298,108,268,125,  0,278   ,1321,108,268,126,  0,278   
     6          ,1298,108,269,125,  0,278   ,1321,108,269,126,  0,278   
     7          ,1298,108,270,125,  0,278   ,1321,108,270,126,  0,278   
     8          ,1298,108,288,125,  0,278   ,1321,108,288,126,  0,278   
     9          ,1298,108,289,125,  0,278   ,1321,108,289,126,  0,278   
     O          ,1298,108,290,125,  0,278   ,1321,108,290,126,  0,278  /
      DATA C61 / 1298,108,291,125,  0,278   ,1321,108,291,126,  0,278   
     2          ,1016,108,305,125,  0,198   ,1029,108,305,126,  0,198   
     3          ,1016,108,307,125,  0,326   ,1029,108,307,126,  0,326   
     4          , 964,108,448,125,  0,450   , 990,108,448,126,  0,450   
     5          ,4250,108,331,125,  0,462   ,4250,108,331,126,  0,462   
     6          ,4250,108,331,125,  0,462   ,4250,108,331,126,  0,462   
     7          ,4268,108,331,125,  0,462   ,4268,108,331,126,  0,462   
     8          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     9          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     O          ,2857,108,393,125,  0,399   ,2857,108,393,126,  0,399   
     1          ,2956,108,395,125,  0,399   ,2956,108,395,126,  0,399   
     2          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     3          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     4          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     5          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     6          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     7          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     8          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     9          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     O          ,3447,108,412,125,  0,414   ,3447,108,412,126,  0,414 / 
      DATA C81 / 3799,108,426,125,  0,200   ,3766,108,426,126,  0,200   
     2          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     3          , 964,108,466,125,  0,450   , 990,108,466,126,  0,450   
     4          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     5          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     6          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     7          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     8          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     9          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     O          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     1          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     2          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     3          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     4          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     5          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     6          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     7          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     8          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     9          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0   
     O          ,   0,  0,  0,  0,  0,  0   ,   0,  0,  0,  0,  0,  0 / 
      END        
