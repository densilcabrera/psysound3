/*
	ptp2svp
	Conversion of part-tone patterns into spectral-virtual-pitch patterns
	---------------------------------------------------------------------
	Copyright 1990/2004
	Ernst Terhardt, Wengleinstr. 7, D-81477 München/Germany.
	http://www.mmk.e-technik.tu-muenchen.de/persons/ter.html
	terhardt@ei.tum.de
	--------------------------------------------------------
	This program may be freely used and distributed for any
	non-profit purpose. 
*/

#define VERSION "0.4"
#define VERSDATE "20040610"
#define AUTHOR "Ernst Terhardt"

#include <stdio.h>
#include <stdlib.h>
#include <math.h> 
#include <string.h> 
#include <ctype.h> 

#include <fstream> //flatmax

#define MAXNOFPITCHES 8
#define WEIGHTTHRESHOLD 0.1

#define TRUE -1 
#define FALSE 0 
#define DOT '.'
#define EODATA ';'
 
#define PTMAX  60 /* size of part-tone arrays */ 
#define SPMAX  20 /* size of spectral-pitch arrays */ 
#define VPMAX  20 /* size of virtual-pitch arrays */ 
#define CPMAX  20 /* size of combined pitch arrays */ 
 
struct parttonepattern { 
        int count; 
        double freq[PTMAX];   /* frequencies in kHz */ 
        double  spl[PTMAX];   /* sound-pressure-levels in dB */ 
        } ptp; 
 
struct spectralpitchpattern { 
        int count;    
        double freq[SPMAX]; 
        double shift[SPMAX];  
        double weight[SPMAX];  
        } spp; 
 
struct virtualpitchpattern { 
        int count; 
        double nomp[VPMAX]; 
        double trup[VPMAX]; 
        double weight[VPMAX]; 
        } vpp; 
 
struct combinedpitchpattern { 
        int count; 
        double weight[CPMAX]; 
        double nomp[CPMAX];   /* nominal pitch */ 
        double trup[CPMAX];   /* true pitch: trup=nomp(1+v) */ 
        int spflg[CPMAX];     /* spectral-pitch flag */
        } cbp; 
 
int shiftflag=FALSE; 
int nofpitches=MAXNOFPITCHES;
double minweight=WEIGHTTHRESHOLD;
int vplowpass=FALSE; 
int noteflag=FALSE;

#include "mscale.h"

void printnotename(double frq) {
	int i;
	i=(int)floor(12.0*log(frq/STDFREQ)/log(2.0)+0.5)+57;
	printf("%s ",note[i]);
}

void putinfo(void) {
	puts("---------------------------------------");
	printf("ptp2svp %s * %s * %s\n",VERSION,VERSDATE,AUTHOR); 
	puts("---------------------------------------");
	puts("Usage: ptp2svp [<opt> [<arg>]]");
	puts("Input: ptp list is read either from stdin or file. Default is stdin.");
	puts("Output: svp list on stdout.");
	puts("--------");
	puts("Options:");
	puts("--------");
	puts(" -h or --help : This message; no action.");
	puts(" -f <file> : Read ptp list from <file> instead of stdin.");
	puts(" -t : Print true instead of nominal pitches.");
	puts(" -n : Print note names instead of pitch values.");
	puts(" -s : Suppress virtual pitches higher than 800 pu.");
	printf(
" %s%d.\n","-p <n> : Max no of pitches included in svp; default is n=",
		MAXNOFPITCHES);
	printf(
" %s%1.1f.\n","-w <n> : Min weight of pitch included in svp; default is n=",
		WEIGHTTHRESHOLD);
	puts("----------------------------------------------------------------");
	puts("Program exit from stdin console mode: Type ';' <CR>");
	puts("----------------------------------------------------------------");
}

double absthresh(double fkhz) { 
   return(3.64*pow(fkhz,-0.8)-6.5*exp(-0.6*(fkhz-3.3)*(fkhz-3.3)) 
            +1.0E-3*pow(fkhz,4.0));  
} 
 
double criticalbr(double fkhz) { 
   return(13.0*atan(0.76*fkhz)+3.5*atan(fkhz*fkhz/56.25)); 
} 
 
double specweight(double fkhz) { 
   double expr; 
   expr = fkhz/0.7-0.7/fkhz; 
   return(1.0/sqrt(1.0+0.07*expr*expr)); 
} 
 
void clearpitchpatterns(void) { 
   int i; 
   for(i=0; i<SPMAX; i++) { 
      spp.weight[i] = 0.0; 
      spp.freq[i] = 0.0; 
      spp.shift[i] = 0.0; 
   } 
   for(i=0; i<VPMAX; i++) { 
      vpp.weight[i] = 0.0; 
      vpp.nomp[i] = 0.0; 
      vpp.trup[i] = 0.0; 
   } 
   for(i=0; i<CPMAX; i++) { 
      cbp.weight[i] = 0.0; 
      cbp.nomp[i] = 0.0; 
      cbp.trup[i] = 0.0; 
   } 
} 

void createspp(void) { 
   int i, j, is; 
   double Lji, LXi, LXid, LXidd, sumlo, sumhi, s; 
   is=0; /* index of spp arrays */ 
   for(i=0; i<=ptp.count; i++)  {
      sumlo=1.0E-8; /* put in a small number to prevent overflow in log */ 
      j=0; 
      while (j<i) {
         s= -24.0-0.23/ptp.freq[j]+0.2*ptp.spl[j]; 
         Lji = ptp.spl[j]-s*(criticalbr(ptp.freq[j])- criticalbr(ptp.freq[i])); 
         sumlo = sumlo+pow(10.0, Lji/20.0); 
         j++; 
      } 
      sumhi=1.0E-8; 
      j=i+1; 
      while(j<=ptp.count) {
         Lji=ptp.spl[j]-27.0*(criticalbr(ptp.freq[j])-criticalbr(ptp.freq[i])); 
         sumhi=sumhi+pow(10.0, Lji/20.0); 
         j++; 
      } 
      /* Sound pressure level excess of i-th part tone: */ 
      LXi=ptp.spl[i]-10.0*log10((sumlo+sumhi)*(sumlo+sumhi) + 
               pow(10.0, absthresh(ptp.freq[i])/10.0)); 
      if(LXi > 0.0) { 
         if(is >= SPMAX) return;    /* This can happen only if SPMAX < 10 */
         else { 
            spp.weight[is]=(1.0-exp(-LXi/15.0))*specweight(ptp.freq[i]); 
            spp.freq[is]=ptp.freq[i]; 
            /* Pitch shift of i-th part tone:   */ 
            if(shiftflag) { 
               LXid=ptp.spl[i]-20.0*log10(sumlo); 
               LXidd=ptp.spl[i]-20.0*log10(sumhi); 
               spp.shift[is]=2.0E-4*(ptp.spl[i]-60.0)*(ptp.freq[i]-2.0) + 
                  1.5E-2*exp(-LXid/20.0)*(3.0-log(ptp.freq[i]));  
               spp.shift[is]=spp.shift[is]+3.0E-2*exp(-LXidd/20.0)*(0.36 + 
                  log(ptp.freq[i]));  
            } 
            is++; 
         }   
      } 
   } 
   spp.count=is-1; 
} 
 
/*
Evaluation of subharmonic coincidences; creation of the virtual-pitch pattern.
*/ 
int signum(int n) { 
   if(n==0) return(0); 
   if(n>0) return(1); 
   return(-1);
} 
 
double truvp(double nomvp, int i, int m) { 
   double x; 
   if(nomvp > 0.5) return(0.0); /* for >500Hz true v. pitch is undefined */  
   x =1.0E-3*(18.0+2.5*(double)m -(50.0-7.0*(double)m)*nomvp + 0.1/nomvp/nomvp); 
   x= -x*(double)signum(m-1); 
   x=x+1.0+spp.shift[i]; 
   return(nomvp*x); 
}         
 
void wsort(void) 
{ 
   double buff; 
   int r, flg;  
   if(vpp.count > 0) { 
      do { 
         flg=FALSE; 
         for(r=0; r<vpp.count; r++) { 
            if(vpp.weight[r] < vpp.weight[r+1]) {  
               flg=TRUE; 
               buff=vpp.weight[r]; vpp.weight[r] = vpp.weight[r+1]; 
               vpp.weight[r+1]=buff; 
               buff=vpp.nomp[r]; vpp.nomp[r]=vpp.nomp[r+1]; 
               vpp.nomp[r+1]=buff; 
               buff=vpp.trup[r]; vpp.trup[r]=vpp.trup[r+1]; 
               vpp.trup[r+1]=buff; 
            } 
         } 
      } while(flg == TRUE); 
   } 
} 
 
void sortintovp(int i, int m, double vpw) { 
   int iv, pc; 
   double vnom; /* vtru; */ 
   vnom=spp.freq[i]/(double)m; 
   iv=0; pc=FALSE; /* pc = near coincidence of pitches */ 
   do {  
      if(fabs(vpp.nomp[iv]-vnom)<0.03*vnom) {  
         pc=TRUE;     /* yes, near coincidence */ 
         /* if new weight > weight of old coinciding pitch, replace: */ 
         if(vpw > vpp.weight[iv]) { 
            vpp.weight[iv]= vpw; 
            vpp.nomp[iv]= vnom; 
            if(shiftflag) 
               vpp.trup[iv]=truvp(vnom, i, m); 
            wsort(); 
         } 
      } 
      iv++; 
   } while(!(pc || iv > vpp.count)); 
   if(pc) return; /* pitch is already present with a higher weight */ 
   /* here comes another, non-coinciding virtual pitch: */ 
   if(vpp.count == VPMAX-1) {   
      if(vpw > vpp.weight[vpp.count]) { 
         vpp.weight[vpp.count]=vpw; 
         vpp.nomp[vpp.count]=vnom; 
         if(shiftflag) 
            vpp.trup[vpp.count]=truvp(vnom, i, m); 
         wsort(); 
      } 
   } 
   else { vpp.count=vpp.count+1; 
      vpp.weight[vpp.count]=vpw; 
      vpp.nomp[vpp.count]=vnom; 
      if(shiftflag) 
         vpp.trup[vpp.count]=truvp(vnom,i,m); 
      wsort(); 
   } 
} 
 
void subcoincidence(void) { 
   int i, j, m, n; 
   double gam, del, cij, vpw;
   if(spp.count == 0) return;    
   del=0.08; 
   for(i=0; i<=spp.count; i++) { 
      for(m=1; m<13; m++) { 
         vpw = 0.0; 
         for(j=0; j<=spp.count; j++) { 
            if(j != i) { 
               n=floor((double)m*spp.freq[j]/spp.freq[i]+0.5); 
               gam=fabs((double)n*spp.freq[i]/(double)m /spp.freq[j]-1.0); 
               if(gam <= del && n <= 20) { 
                  cij=sqrt(spp.weight[i]*spp.weight[j]/(double)m /(double)n)
                  * (1.0-gam/del); 
               } 
               else cij = 0.0; 
            } 
            else cij=0.0; 
            vpw=vpw+cij; 
         } 
         /* virtual pitch low-pass weighting with 800 Hz cut-off freq.: */
         if(vplowpass)
            vpw=vpw/(1.0+pow(spp.freq[i]/0.8/(double)m, 4.0)); 
         if(vpw>=minweight)  
            sortintovp(i, m, vpw); 
      } 
   } 
} 
 
void sortcombipattern(void) { 
   int i, flg, flb;  
   double buff; 

   if(cbp.count > 0) {
      do { 
		flg=FALSE; 
         for(i=0;i<cbp.count;i++) {
            if(cbp.weight[i]<cbp.weight[i+1]) {
               flg=TRUE; 
               buff=cbp.weight[i]; cbp.weight[i]=cbp.weight[i+1]; 
               cbp.weight[i+1]=buff; 
               buff=cbp.nomp[i]; cbp.nomp[i]=cbp.nomp[i+1]; 
               cbp.nomp[i+1]=buff; 
               buff=cbp.trup[i]; cbp.trup[i]=cbp.trup[i+1]; 
               cbp.trup[i+1]=buff; 
               flb=cbp.spflg[i]; cbp.spflg[i]=cbp.spflg[i+1]; 
               cbp.spflg[i+1]=flb; 
            } 
         } 
      } while(flg); 
   }     
} 
 
void spsintocombipat(void) {                       
   int i, ic; 
   double x; 
   ic=0; 
   for(i=0;i<=spp.count;i++) {
      x=0.5*spp.weight[i]; 
      if(x>=minweight) {
         cbp.weight[ic]=x; 
         cbp.nomp[ic]=spp.freq[i]; 
         if(shiftflag) 
            cbp.trup[ic]=spp.freq[i]*(1.0+spp.shift[i]); 
         else cbp.trup[ic]=0.0; 
         cbp.spflg[ic]=TRUE; 
         ic++; 
      } 
   } 
   cbp.count=ic-1; 
   sortcombipattern(); 
} 
 
void vpsintocombipat(void) 
{ 
   int r, j; 
   int flag; 
   if(vpp.count<0) return;
   j=0; /* j = index of virtual pitch array */ 
   do { 
	/* if near coincidence and greater weight, replace: */ 
      r=0; /* r = index of combipattern array */ 
      flag=FALSE; 
      do { 
         if(fabs(vpp.nomp[j]-cbp.nomp[r])<0.03*cbp.nomp[r]) { 
            flag = TRUE; 
            if(vpp.weight[j]>cbp.weight[r]) { 
               cbp.weight[r]=vpp.weight[j]; 
               cbp.nomp[r]=vpp.nomp[j]; 
               cbp.trup[r]=vpp.trup[j]; 
               cbp.spflg[r]=FALSE; 
               sortcombipattern(); 
            } 
         } 
         r++; 
      } while (!(flag || r>cbp.count)); 
      if(!flag) { 
         if(r == CPMAX-1) { 
            if(vpp.weight[j] > cbp.weight[cbp.count]) { 
               cbp.weight[cbp.count]=vpp.weight[j]; 
               cbp.nomp[cbp.count]=vpp.nomp[j]; 
               cbp.trup[cbp.count]=vpp.trup[j]; 
               cbp.spflg[cbp.count]=FALSE; 
               sortcombipattern(); 
            } 
         } 
         else { 
            cbp.count=cbp.count+1; 
            cbp.weight[cbp.count]=vpp.weight[j]; 
            cbp.nomp[cbp.count]=vpp.nomp[j]; 
            cbp.trup[cbp.count]=vpp.trup[j]; 
            cbp.spflg[cbp.count]=FALSE; 
            sortcombipattern(); 
         } 
      } 
      j++; 
  } while(j <= vpp.count); 
} 
 
void compfreqlimit(void) { 
   int i; 
   if(ptp.count > 0) { 
      i=0; 
      while(i <= ptp.count && ptp.freq[i] <= 5.0) 
         i++; 
      ptp.count=i-1; 
   }    
} 
 
//int readinput(FILE *fi) { //flatmax
int readinput(ifstream *fi) {
	char digit[30];  
	int c, i, j; 
	double fhz, ldb;
	ptp.count= -1; j=0;

	char semicolon; //flatmax
	while ((semicolon=fi->peek())!=';'){
		while ((*fi)>>fhz && (*fi)>>ldb){
			if(fhz < 5.0 || fhz > 16000.0) return(-1);
			ptp.freq[j] = fhz/1000.0; 
			if(ldb > 100.0) return(-1); /* SPL's > 100 dB are not accepted */  
			ptp.spl[j]=ldb; 
			j++;
		}
	}
    if (semicolon==';') c=(int)EODATA;
	else c=EOF;
/*	c=getc(fi);
	while(c != EOF && c != (int)EODATA && j < PTMAX) {
		printf("up to element j=%d",j);
		if(!isdigit(c) && c!=DOT) {c=getc(fi); continue;}
		i=0;  
		while(isdigit(c) || c == DOT) { 
			digit[i]=(char)c; 
			i++; 
			c=getc(fi); 
		} 
		digit[i]='\0'; 
		fhz=atof(digit);
		*/
//		if(fhz < 5.0 || fhz > 16000.0) return(-1);
		/* Frequencies outside this range are not accepted */
/*		ptp.freq[j] = fhz/1000.0; 
		while(c != EOF && c != (int)EODATA && !isdigit(c) && c != DOT)  
			c=getc(fi);
		i=0; 
		while(isdigit(c) || c == DOT) { 
			digit[i] = (char)c;       
			i++; 
			c=getc(fi); 
		} 
		digit[i]='\0'; 
		ldb=atof(digit);*/
		//if(ldb > 100.0) return(-1); /* SPL's > 100 dB are not accepted */  
		//ptp.spl[j]=ldb; 
		//if(i > 0) j++; 
//	} 
	ptp.count=j-1; 
	return(c);
} 
    
void sortptp(void) {
   double buff;
   int r, flg;
   if(ptp.count > 0) {
      do {
         flg=FALSE;
         for(r=0; r<ptp.count;r++) {
            if(ptp.freq[r] > ptp.freq[r+1]) {
               flg=TRUE;
               buff=ptp.freq[r]; ptp.freq[r]=ptp.freq[r+1];
               ptp.freq[r+1]=buff;
               buff=ptp.spl[r]; ptp.spl[r]=ptp.spl[r+1];
               ptp.spl[r+1]=buff;
            }
         }
      } while(flg);
   }
}
   
//int initialise(FILE *fi) {  //flatmax
int initialise(ifstream *fi) { //flatmax
	int c;
	clearpitchpatterns(); 
	vpp.count= -1;
	c=readinput(fi);
	sortptp(); 
	compfreqlimit();
	return(c);
} 
 
//void closefile(FILE *fi) {//flatmax
void closefile(ifstream *fi) { //flatmax
	//if (fi != stdin && fi != NULL) fclose(fi);//flatmax
	fi->close():
}

int main(int argc, char **argv) { 
	int i=1, endc; 
	//FILE *fi=stdin; 	 //flatmax
	ifstream fi=ifstream(stdin); //flatmax
 
	while(i<argc) {
		if(!strcmp("--help",argv[i]) || !strcmp("-h",argv[i])) {
			putinfo(); return(0);
		}
		if(!strcmp("-f",argv[i])) {
			i++;
			if(i>=argc) return(-1);
			//fi=fopen(argv[i],"rb");
			//if(fi == NULL) return(-1);
			fi=ifstream(argv[i]);
			if (!fi) return(-1);
			i++;
			continue;
		}
		if(!strcmp("-t",argv[i])) {
			shiftflag=TRUE;
			i++;
			continue;
		}
		if(!strcmp("-s",argv[i])) {
			vplowpass=TRUE;
			i++;
			continue;
		}
		if(!strcmp("-p",argv[i])) { 
			i++;
			if(i>=argc) { closefile(fi); return(-1); }
			if(atoi(argv[i]) <= CPMAX)
				nofpitches=atoi(argv[i]); 
			else
				nofpitches=CPMAX;
			i++;
			continue;
		}
		if(!strcmp("-w",argv[i])) {
			i++;
			if(i>=argc) { closefile(fi); return(-1); }
			minweight=atof(argv[i]);
			i++;
			continue;
		}
		if(!strcmp("-n",argv[i])) {
			noteflag=TRUE;
			i++;
			continue;
		}
		closefile(&fi);
		return(-1); /* Unknown argument */
	}
//	while((endc=initialise(fi)) == (int)EODATA) { 
	while((endc=initialise(&fi)) == (int)EODATA) {  //flatmax
		if(ptp.count < 0) break;  
		createspp();
		subcoincidence();
		spsintocombipat();
		vpsintocombipat();
		for(i=0;i<=cbp.count && i<nofpitches;i++) {
			if(noteflag) printnotename(cbp.nomp[i]*1000.0);
			else
			{
				if(!shiftflag)
					printf("%4.1f ",cbp.nomp[i]*1000.0); 
				else  
					printf("%4.1f ",cbp.trup[i]*1000.0); 
			}
			printf("%1.2f ",cbp.weight[i]); 
			if(cbp.spflg[i]) putchar('s');
			else putchar('v');
			putchar('\n');
		}
		printf("%c\n",EODATA);
	}
	closefile(fi);
	return(0);
} 
