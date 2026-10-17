"""Independent integer FFT reference, same arithmetic as the earlier validated reference."""
import numpy as np

def rshift(a,s):
    a=np.asarray(a,dtype=np.int64)
    return (a+(1<<(s-1)))>>s if s else a

def fixed_reference(x,w,cosine,logn,frac=3,coef_frac=17,width=20):
    n=1<<logn;m=n//2;q=n//4
    v=rshift(x.astype(np.int64)*w,coef_frac-frac)
    packed_r=np.zeros(m,dtype=np.int64);packed_i=np.zeros(m,dtype=np.int64)
    packed_r[:len(v[::2])]=v[::2];packed_i[:len(v[1::2])]=v[1::2]
    k=np.arange(m,dtype=np.int64);rev=np.zeros(m,dtype=np.int64)
    for b in range(logn-1):rev|=((k>>b)&1)<<(logn-2-b)
    re=packed_r[rev].copy();im=packed_i[rev].copy();overflow=False
    low=-(1<<(width-1));high=(1<<(width-1))-1
    def clip(a):
        nonlocal overflow
        overflow|=bool(np.any((a<low)|(a>high)))
        return np.clip(a,low,high)
    def twiddle(phase):
        phase=np.asarray(phase,dtype=np.int64)
        wr=np.where(phase<=q,cosine[np.minimum(phase,m-phase)],-cosine[np.minimum(phase,m-phase)])
        wi=-cosine[abs(q-phase)]
        return wr,wi
    span=2
    while span<=m:
        half=span//2
        rr=re.reshape(-1,span);ii=im.reshape(-1,span)
        ar=rr[:,:half].copy();ai=ii[:,:half].copy();br=rr[:,half:].copy();bi=ii[:,half:].copy()
        wr,wi=twiddle(np.arange(half)*(n//span))
        tr=rshift(br*wr-bi*wi,coef_frac);ti=rshift(br*wi+bi*wr,coef_frac)
        rr[:,:half]=clip(rshift(ar+tr,1));ii[:,:half]=clip(rshift(ai+ti,1))
        rr[:,half:]=clip(rshift(ar-tr,1));ii[:,half:]=clip(rshift(ai-ti,1))
        span*=2
    out_r=np.zeros(m+1,dtype=np.int64);out_i=np.zeros(m+1,dtype=np.int64)
    out_r[0]=clip(rshift(re[0]+im[0],1));out_r[m]=clip(rshift(re[0]-im[0],1))
    k=np.arange(1,q);a=re[k];b=im[k];c=re[m-k];d=im[m-k]
    sr=a+c;si=b-d;dr=a-c;di=b+d
    wr,wi=twiddle(k);tr=rshift(dr*wr-di*wi,coef_frac);ti=rshift(dr*wi+di*wr,coef_frac)
    out_r[k]=clip(rshift(sr+ti,2));out_i[k]=clip(rshift(si-tr,2))
    out_r[m-k]=clip(rshift(sr-ti,2));out_i[m-k]=clip(rshift(-si-tr,2))
    out_r[q]=clip(rshift(re[q],1));out_i[q]=clip(rshift(-im[q],1))
    return out_r,out_i,overflow

