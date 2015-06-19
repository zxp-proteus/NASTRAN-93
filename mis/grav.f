      SUBROUTINE GRAV (NGRAV,GVECT,NLIST,ILIST,NLOOP)        
C        
      INTEGER        NAME(2)        
      DIMENSION      GVECT(1),GL(5),X(3),ILIST(1)        
      COMMON /TRANX/ NSYS,TYSYS,RO(3),TO(3,3)        
      COMMON /LOADX/ LCORE,SLT,N(14),NOBLD        
      EQUIVALENCE    (IGL,GL(2))        
      DATA    NAME / 4HGRAV,4H    /        
C        
C     CONVERTS GRAV CARD TO BASIC AND STORES        
C     GB = G*TON*V        
C        
      CALL READ (*30,*40,SLT,GL(1),5,0,FLAG)        
      GO TO 50        
   20 RETURN        
C        
   30 CONTINUE        
   40 CALL MESAGE (-7,NAME,NAME)        
   50 NGRAV = NGRAV + 1        
      IF (GL(1)) 60,70,60        
   60 CALL FDCSTM (GL(1))        
      CALL MPYL (TO,GL(3),3,3,1,X(1))        
      DO 61 I = 1,3        
      GL(I+2) = X(I)        
   61 CONTINUE        
   70 DO 80 I = 1,3        
      J = (NGRAV-1)*3 + I        
   80 GVECT(J) = GL(I+2)*GL(2)        
      NL1 = NLOOP - NGRAV + 1        
      IF (NL1 .EQ. NLIST) GO TO 20        
      NSAVE  = ILIST(NL1)        
      NLIST1 = NLIST - 1        
      DO 90 I = NL1,NLIST1        
   90 ILIST(I) = ILIST(I+1)        
      ILIST(NLIST) = NSAVE        
      GO TO 20        
      END        
