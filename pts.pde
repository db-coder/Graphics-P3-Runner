
class pts // class for manipulaitng and displaying pointclouds or polyloops in 3D 
  { 
    int maxnv = 16000;                 //  max number of vertices
    pt[] G = new pt [maxnv];           // geometry table (vertices)
    char[] L = new char [maxnv];             // labels of points
    vec [] LL = new vec[ maxnv];  // displacement vectors
    int alt = 0;
    float lx, ly;
    int j = 0;
    pt Left, Right;
    float[] vx;
    float[] vy;
    Boolean loop=true;          // used to indicate closed loop 3D control polygons
    int pv =0,     // picked vertex index,
        iv=0,      //  insertion vertex index
        dv = 0,   // dancer support foot index
        nv = 0,    // number of vertices currently used in P
        pp=1; // index of picked vertex

  pts() {}
  pts declare() 
    {
    for (int i=0; i<maxnv; i++) G[i]=P(); 
    for (int i=0; i<maxnv; i++) LL[i]=V(); 
    return this;
    }     // init all point objects
  pts empty() {nv=0; pv=0; return this;}                                 // resets P so that we can start adding points
  pts addPt(pt P, char c) { G[nv].setTo(P); pv=nv; L[nv]=c; nv++;  return this;}          // appends a new point at the end
  pts addPt(pt P) { G[nv].setTo(P); pv=nv; L[nv]='f'; nv++;  return this;}          // appends a new point at the end
  pts addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; return this;} // same byt from coordinates
  pts copyFrom(pts Q) {empty(); nv=Q.nv; for (int v=0; v<nv; v++) G[v]=P(Q.G[v]); return this;} // set THIS as a clone of Q

  pts resetOnCircle(int k, float r)  // sets THIS to a polyloop with k points on a circle of radius r around origin
    {
    empty(); // resert P
    pt C = P(); // center of circle
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-r,0)),2.*PI*i/k,C)); // points on z=0 plane
    pv=0; // picked vertex ID is set to 0
    return this;
    } 
  // ********* PICK AND PROJECTIONS *******  
  int SETppToIDofVertexWithClosestScreenProjectionTo(pt M)  // sets pp to the index of the vertex that projects closest to the mouse 
    {
    pp=0; 
    for (int i=1; i<nv; i++) if (d(M,ToScreen(G[i]))<=d(M,ToScreen(G[pp]))) pp=i; 
    return pp;
    }
  pts showPicked() {show(G[pv],23); return this;}
  pt closestProjectionOf(pt M)    // Returns 3D point that is the closest to the projection but also CHANGES iv !!!!
    {
    pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<=d) {iv=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) { 
       pt A = G[i], B = G[j];
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); iv=i; C=projectionOnLine(M,A,B);}
       } 
    return C;    
    }

  // ********* MOVE, INSERT, DELETE *******  
  pts insertPt(pt P) { // inserts new vertex after vertex with ID iv
    for(int v=nv-1; v>iv; v--) {G[v+1].setTo(G[v]);  L[v+1]=L[v];}
     iv++; 
     G[iv].setTo(P);
     L[iv]='f';
     nv++; // increments vertex count
     return this;
     }
  pts insertClosestProjection(pt M) {  
    pt P = closestProjectionOf(M); // also sets iv
    insertPt(P);
    return this;
    }
  pts deletePicked() 
    {
    for(int i=pv; i<nv; i++) 
      {
      G[i].setTo(G[i+1]); 
      L[i]=L[i+1]; 
      }
    pv=max(0,pv-1); 
    nv--;  
    return this;
    }
  pts setPt(pt P, int i) { G[i].setTo(P); return this;}
  
  pts drawBalls(float r) {for (int v=0; v<nv; v++) show(G[v],r); return this;}
  pts showPicked(float r) {show(G[pv],r); return this;}
  pts drawClosedCurve(float r) 
    {
    fill(dgreen);
    for (int v=0; v<nv; v++) show(G[v],r*3);    
    fill(magenta);
    for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
    stub(G[nv-1],V(G[nv-1],G[0]),r,r);
    pushMatrix(); //translate(0,0,1); 
    scale(1,1,0.03);  
    fill(grey);
    for (int v=0; v<nv; v++) show(G[v],r*3);    
    for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
    stub(G[nv-1],V(G[nv-1],G[0]),r,r);
    popMatrix();
    return this;
    }
  pts set_pv_to_pp() {pv=pp; return this;}
  pts movePicked(vec V) { G[pv].add(V); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts setPickedTo(pt Q) { G[pv].setTo(Q); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts moveAll(vec V) {for (int i=0; i<nv; i++) G[i].add(V); return this;};   
  pt Picked() {return G[pv];} 
  pt Pt(int i) {if(0<=i && i<nv) return G[i]; else return G[0];} 

  // ********* I/O FILE *******  
 void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y)+","+str(G[i].z)+","+L[i];}
    saveStrings(fn,inppts);
    };
  
  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) 
      {
      int i=k+s; 
      //float [] xy = float(split(ss[i],",")); 
      String [] SS = split(ss[i],","); 
      G[k].setTo(float(SS[0]),float(SS[1]),float(SS[2]));
      L[k]=SS[3].charAt(0);
      }
    pv=0;
    };
 
  // Dancer
  void setPicekdLabel(char c) {L[pp]=c;}
  


  void setFifo() 
    {
    _LookAtPt.reset(G[dv],60);
    }              


  void next() {dv=n(dv);}
  int n(int v) {return (v+1)%nv;}
  int p(int v) {if(v==0) return nv-1; else return v-1;}
  
  pts subdivideDemoInto(pts Q) 
    {
    Q.empty();
    for(int i=0; i<nv; i++)
      {
      Q.addPt(P(G[i])); 
      Q.addPt(P(G[i],G[n(i)])); 
      //...
      }
    return this;
    }
    
    void make()
    { 
      j=0;
      for (int i=0; i<nv; i++)
      {   // for each span, send 6 consecutive control points: A, B, C, D, E, F
          rs(G[i].x,G[i].y,G[n(i)].x,G[n(i)].y,G[n(n(i))].x,G[n(n(i))].y,G[n(n(n(i)))].x,G[n(n(n(i)))].y,G[n(n(n(n(i))))].x,G[n(n(n(n(i))))].y,G[n(n(n(n(n(i)))))].x,G[n(n(n(n(n(i)))))].y,level);     
      }
    }
    
    void rs(float ax,float ay,float bx,float by,float cx,float cy,float dx,float dy,float ex,float ey,float fx,float fy, int r)
    {
       float t=-0.5;                              // sets Jarek's parameter for this subdivision level (0=Bspline, 1=4-point, 0.5=Jarek 
       if (r==0)
       {
          vx[j]=cx; vy[j]=cy;
          j++; lx=dx; ly=dy;
       } 
       else 
       {
         float jx=(bx+cx)/2;  float jy=(by+cy)/2;
         float kx=(cx+dx)/2;  float ky=(cy+dy)/2;
         float mx=(dx+ex)/2;  float my=(dy+ey)/2;
         float blx=((ax+cx)/2-bx)/4;    float bly=((ay+cy)/2-by)/4; 
         float clx=((bx+dx)/2-cx)/4;    float cly=((by+dy)/2-cy)/4; 
         float dlx=((cx+ex)/2-dx)/4;    float dly=((cy+ey)/2-dy)/4; 
         float elx=((dx+fx)/2-ex)/4;    float ely=((dy+fy)/2-ey)/4; 
         bx=bx+(1-t)*blx; by=by+(1-t)*bly;
         cx=cx+(1-t)*clx; cy=cy+(1-t)*cly;
         dx=dx+(1-t)*dlx; dy=dy+(1-t)*dly;
         ex=ex+(1-t)*elx; ey=ey+(1-t)*ely;
         jx=jx-t*(blx+clx)/2; jy=jy-t*(bly+cly)/2;
         kx=kx-t*(clx+dlx)/2; ky=ky-t*(cly+dly)/2;
         mx=mx-t*(dlx+elx)/2; my=my-t*(dly+ely)/2;
         rs(bx,by,jx,jy,cx,cy,kx,ky,dx,dy,mx,my,r-1); 
         rs(jx,jy,cx,cy,kx,ky,dx,dy,mx,my,ex,ey,r-1);
       }
   }
    
    pts subdivideQuinticInto(pts Q) 
    {
      Q.empty();
      vx = new float [nv*round(pow(2,level))];
      vy = new float [nv*round(pow(2,level))];
      make();
      for(int i=0; i<nv*round(pow(2,level)); i++)
      {
        Q.addPt(P(vx[i],vy[i])); 
      }
      return this;
    }
  
  void displaySkater() 
      {
      pt[] G1 = new pt [nv];           // geometry table (vertices)
      for (int j=0; j<nv; j++)
      {
        G1[j]=P(G[j],V(0,0,200));
      }
      if(showCurve) {fill(lime); for (int j=0; j<nv; j++) caplet(G1[j],6,G1[n(j)],6); }
      pt[] B = new pt [nv];           // geometry table (vertices)
      for (int j=0; j<nv; j++)
      {
        float theta = j*2*PI/(nv-1);
        if(P.nv > 3)
          B[j]=P(G[j],V(50*cos(theta),50*sin(theta),0));
        else
          B[j]=P(G[j],V(-50*cos(theta),-50*sin(theta),0));
      }
      if(showPath) {fill(yellow); for (int j=0; j<nv; j++) caplet(G[j],6,G[n(j)],6);} 
      if(showKeys) {fill(cyan); for (int j=0; j<nv; j+=4) arrow(G1[j],G[j],3);}
      
      if(animating) f=n(f);
      if(showSkater) 
      {
        // Footprints shown as reg, green, blue disks on the floor 
        if(alt%2 == 0)
        {
          Left = B[n(n(n(n(f))))];
          Right = B[f];
        }
        else
        {
          Left = B[f];
          Right = B[n(n(n(n(f))))];
        }
        alt++;
        float s = 0;
        fill(grey);  showShadow(Left,8);  showShadow(Right,8);// showShadow(C,8); 
        vec Direction = V(B[f],B[n(f)]);
        pt Bottom = B[n(f)];
        pt Top = G1[f];
        showDancer(Right, s, Left, U(Direction), Top, Bottom);  // THIS CALLS YOUR CODE IN TAB "Dancer"
      }
      else {fill(red); arrow(G1[f],B[f],20);} //
      }

        

} // end of pts class