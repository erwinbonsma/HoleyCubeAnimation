//  Persistence of Vision Ray Tracer version 3.5 Include File
//  File: quaternions.inc
//  Description: Quaternion macros (primarily used for rotations)
//  Last updated: 2003.10.5
//  Created by: Alain Ducharme
//
//  Notes:
//    - All angles are in Radians
//    - Might need to normalize quaternions more often if rounding errors creep
//      in because quaternions must be unit lenght for rotation operations to work
//
//  If you expand/fix/enhance, please let me know: Alain_Ducharme@hotmail.com
//

#ifndef(QUATERNIONS_INC_TEMP)
#declare QUATERNIONS_INC_TEMP = version;
#version 3.5;

#macro QToMatrix(q)
  // Convert a quaternion to a Povray transformation matrix (4x3)
  // Use: matrix <M[0].x,M[0].y,M[0].z,M[1].x,M[1].y,M[1].z,M[2].x,M[2].y,M[2].z,M[3].x,M[3].y,M[3].z>
  #local x2 = q.x + q.x;
  #local y2 = q.y + q.y;
  #local z2 = q.z + q.z;
  #local xx = q.x * x2;
  #local xy = q.x * y2;
  #local xz = q.x * z2;
  #local yy = q.y * y2;
  #local yz = q.y * z2;
  #local zz = q.z * z2;
  #local wx = q.t * x2;
  #local wy = q.t * y2;
  #local wz = q.t * z2;
  array[4] {<1.0 - (yy + zz),xy + wz,xz - wy>,<xy - wz,1.0 - (xx + zz),yz + wx>,<xz + wy,yz - wx,1.0 - (xx + yy)>,<0,0,0>}
#end

#macro QFromMatrix(M)
  // Convert a Povray matrix (same array format as above) to a quaternion
  // Note: you should normalize the resulting quaternion if you want to use it for rotation
  #local tr = M[0].x+M[1].y+M[2].z+1;
  #if (tr>0)
    #local s=sqrt(tr)*2;
    #local r = <(M[1].z-M[2].y)/s,(M[2].x-M[0].z)/s,(M[0].y-M[1].x)/s,0.25*s>;
  #else
    #if (M[0].x > M[1].y & M[0].x > M[2].z) // Column 0
      #local s = sqrt(1+M[0].x-M[1].y-M[2].z) * 2;
      #local r = <0.25*s,(M[0].y+M[1].x)/s,(M[2].x+M[0].z)/s,(M[1].z-M[2].y)/s>;
    #else
      #if (M[1].y > M[2].z)                 // Column 1
        #local s = sqrt(1+M[1].y-M[0].x-M[2].z) * 2;
        #local r = <(M[0].y+M[1].x)/s,0.25*S,(M[1].z+M[2].y)/s,(M[2].x-M[0].z)/s>;
      #else                                 // Column 2
        #local s = sqrt(1+M[2].z-M[0].x-M[1].y) * 2;
        #local r = <(M[2].x+M[0].z)/s,(M[1].z+M[2].y)/s,0.25*s,(M[0].y-M[1].x)/s>;
      #end
    #end
  #end
  r
#end

#macro Qsc(q)
  // Square the quaternion components
  q.x*q.x+q.y*q.y+q.z*q.z+q.t*q.t
#end

#macro QMagnitude(q)
  // Magnitude of quaternion
  sqrt(Qsc(q))
#end

#macro QNormalize(q)
  // Normalize quaternion
  #local m = QMagnitude(q);
  <q.x/m,q.y/m,q.z/m,q.t/m>
#end

#macro QInverse(q)
  // q^-1
  <-q.x,-q.y,-q.z,q.t>
#end

#macro QMultiply(qa, qb)
  // qa * qb (can effectively be used to add two rotations)
  <qa.x*qb.t + qa.t*qb.x + qa.y*qb.z - qa.z*qb.y,
   qa.y*qb.t + qa.t*qb.y + qa.z*qb.x - qa.x*qb.z,
   qa.z*qb.t + qa.t*qb.z + qa.x*qb.y - qa.y*qb.x,
   qa.t*qb.t - qa.x*qb.x - qa.y*qb.y - qa.z*qb.z>
#end

#macro QRotate(ax,an)
  // Returns a quaternion that represents a rotation around an axis at specified angle
  // linear interpolation from origin: pass an*i where i is between 0 and 1
  #local ax = vnormalize(ax);
  <ax.x*sin(an/2),ax.y*sin(an/2),ax.z*sin(an/2),cos(an/2)>
#end

#macro QAxAn(q,an)
  // Return the rotation axis and angle (in parameter) of a quaternion
  #declare an = acos(q.t)*2;
  #local sa = sqrt(1-q.t*q.t);
  <q.x/sa,q.y/sa,q.z/sa>
#end

#macro VQRotate(vec,q)
  // Rotate a vector with a quaternion
  #local p = <vec.x,vec.y,vec.z,0>;
  #local r = QMultiply(QMultiply(q,p),QInverse(q));
  <r.x,r.y,r.z>
#end

/* Use Pov's built-in vaxis_rotate(), it's much faster
#macro VQARotate(vec, ax, an)
  // Use quaternion to rotate a vector around an axis at specified angle
  #local q = QRotate(ax,an);
  VRotateQ(vec,q)
#end */

#macro QDiff(qa, qb)
  // In effect returns the quaternion required to go from qa to qb
  #local r = QMultiply(qb,QInverse(qa));
  #if (r.t < 0)  // Make sure we take the shortest route...
    #local r = -r;
  #end
  r
#end

#macro QADiff(qa, qb)
  // Returns the angle difference between two quaternians
  #local an = 0;
  #local ax = QAxAn(QDiff(qa, qb),an);
  an
#end

#macro EulerToQ(a)
  // Rotate three (xyz in a 3D vector) Euler angles into a quaternion
  // Note: Like a regular rotate x,y,z : can suffer from Gimbal Lock
  #local cr = cos(a.x/2);
  #local cp = cos(a.y/2);
  #local cy = cos(a.z/2);
  #local sr = sin(a.x/2);
  #local sp = sin(a.y/2);
  #local sy = sin(a.z/2);
  #local cpcy = cp * cy;
  #local spsy = sp * sy;
  <sr * cpcy - cr * spsy,cr * sp * cy + sr * cp * sy,cr * cp * sy - sr * sp * cy, cr * cpcy + sr * spsy>
#end

#macro Qln(q)
  // ln(q)
  #local r = sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
  #local at = (r>0.00001?atan2(r,q.t)/r:0);
  <at*q.x,at*q.y,at*q.z,0.5*log(Qsc(q))>
#end

#macro QExp(q)
  // e^q
  #local r = sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
  #local et = exp(q.t);
  #local s = (r>=0.00001?et*sin(r)/r:0);
  <s*q.x,s*q.y,s*q.z,et*cos(r)>
#end

#macro QLinear(qa,qb,i)
  // Linear interpolation from qa to qb
  QExp((1-i)*Qln(qa)+i*Qln(qb))
#end

#macro QHermite(qa,qb,qat,qbt,i)
  // Hermite interpolation from qa to qb using tangents qat & qbt
  QExp((+2*i*i*i-3*i*i+1)*Qln(qa)+
       (-2*i*i*i+3*i*i)*Qln(qb)+
       (+1*i*i*i-2*i*i +i)*Qln(qat)+
       (+1*i*i*i-1*i*i)*Qln(qbt))
#end

#macro QBezier(qa,qb,qc,qd,i)
  // Bezier interpolation from qa to qd
  QExp((-1*i*i*i+3*i*i-3*i+1)*Qln(qa)+
       (+3*i*i*i-6*i*i+3*i)*Qln(qb)+
       (-3*i*i*i+3*i*i)*Qln(qc)+
       (+1*i*i*i)*Qln(qd))
#end

#version QUATERNIONS_INC_TEMP;
#end //quaternions.inc