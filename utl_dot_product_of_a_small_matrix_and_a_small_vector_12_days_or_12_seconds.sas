DOT product of a small matrix and a small vector (12 days or 12 seconds?)

 Actually it took about 2 seconds using Microsoft R

   user  system elapsed
   1.91    0.12    1.03

 Not sure I completely understood your dot product.
 But here is dot ptoduct of a  200,000(row) * 1000(column)  dot  1000 column vector

see
https://goo.gl/Q9Y8th
https://communities.sas.com/t5/Base-SAS-Programming/Sincere-request-for-efficient-code-for-inner-products/m-p/427518

Interface to Microsoft R
https://github.com/rogerjdeangelis/utl_interface_Per_Python_R32_R64_MS_r64_WPS

for a very fast transfer of floats from SAS to R
https://github.com/rogerjdeangelis/utl_load_1_billion_SAS-floats_into_R_in_13_seconds


INPUT
=====

  MATRIX            VECTOR    |    RULES
SD1.HAV1ST        SD1.HAV2ND  |    =====
                              |                  WANT (dataset)
   M1    M2         O         |
                              |    3*1 + 7*1 =     10
    3     7  dot    1         |    1*1 * 8*5 =     41
    1     8         5         |    1*1 + 4*5 =     21
    1     4                   |
                              |

WORKING CODE
============

    want<-as.data.frame(A %*% B)

OUTPUT
======

  WORK.WANT  total obs=1,000

        Obs   hav1st dot hav2nd

          1    4053594
          2    4053895
          3    4067320
          4    4051091
          5    4053839
          6    4049561
          7    4053552
          8    4053088
          9    4054366
         10    4048699
        .....
         997   4049115
         998   4041227
         999   4045125
        1000   4065533

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

%let m=200000;  * number of rows;
%let n=1000;  * number of columns;
%let o=&m; * vector ;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.hav1st;
  call streaminit(5721);
  array m[&m] m1-m&m (1:&m);
  do n=1 to &n;
    do p=1 to dim(m);
      m[p]=int(10*rand('uniform'));
    end;
    output;
  end;
  drop n p;
run;quit;

data sd1.hav2nd;
  call streaminit(5741);
  do i=1 to &o;
    o=int(10*rand('uniform'));
    output;
  end;
  drop i;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

* Microsoft R;
%utl_submit_msr64('
if(require("RevoUtilsMath")){
  setMKLthreads(5)
};
library(haven);
library(SASxport);
A<-as.matrix(read_sas("d:/sd1/hav1st.sas7bdat"));
B<-as.matrix(read_sas("d:/sd1/hav2nd.sas7bdat"));
system.time(want<-as.data.frame(A %*% B));
write.xport(want,file="d:/xpt/want.xpt",autogen.formats = FALSE);
');

libname xpt xport "d:/xpt/want.xpt";
proc print data=xpt.want(obs=10);
run;quit;
libname xpt clear;


