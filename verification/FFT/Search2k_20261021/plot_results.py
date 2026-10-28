from pathlib import Path
import csv
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
D=Path(__file__).resolve().parent
rows=list(csv.DictReader((D/'distance_results.csv').open(encoding='utf-8')))
x=np.array([float(r['distance_cm']) for r in rows]);y=np.array([float(r['signed_error_mm']) for r in rows])
plt.rcParams.update({'font.family':'Arial','font.size':15,'axes.spines.top':False,'axes.spines.right':False,'savefig.dpi':220})
fig,ax=plt.subplots(figsize=(12,6.75));fig.subplots_adjust(left=.105,right=.975,bottom=.16,top=.86)
ax.set_title('Distance Error: 10–75 cm',fontsize=25,fontweight='bold',color='#193A51',pad=22)
ax.axhline(0,color='#889BA8',lw=1);ax.plot(x,y,'o-',color='#126F9D',lw=2,ms=6)
ax.set(xlabel='Reflector distance (cm)',ylabel='Distance error (mm)',xticks=x,xlim=(9,76),ylim=(-.55,.55))
ax.xaxis.set_major_formatter(FuncFormatter(lambda value,_:f'{value:g}'));ax.tick_params(axis='x',labelsize=10);ax.grid(alpha=.2)
fig.savefig(D/'distance_error_10_75cm_EN.png');plt.close(fig)
