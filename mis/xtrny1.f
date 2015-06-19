      SUBROUTINE X TRN  Y1(X,Y,ALPHA1)
C     SUBROUTINE X TRNS Y (X,Y,ALPHA)
C*******
C     X TRNS Y  FORMS THE DOT PRODUCT X TRANSPOSE * Y = ALPHA
C*******
C     DOUBLE PRECISION   X(1)      ,Y(1)     ,ALPHA
      DOUBLE PRECISION ALPHA1
      REAL X(1) , Y(1)
      COMMON   /INVPWX/  AAA       ,NCOL
C     ALPHA = 0.D0
      ALPHA = 0.0
      DO 10 I=1,NCOL
   10 ALPHA = ALPHA + X(I)*Y(I)
      ALPHA1 = ALPHA
      RETURN
      END
