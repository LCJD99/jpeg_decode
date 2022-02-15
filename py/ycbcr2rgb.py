yf = open('y', 'r')
crf = open('cr', 'r')
cbf = open('cb', 'r')


y = yf.read().replace(' ','').replace('\n','')
cr = crf.read().replace(' ','').replace('\n','')
cb = cbf.read().replace(' ','').replace('\n','')

o = open('o.pgm','w')

y_ = []
cr_ = []
cb_ = []

for i in range(int(len(y)/4)):
    y_.append(y[4*i:i*4 + 4])

for i in range(int(len(cr)/4)):
    cr_.append(cr[4*i:4*i + 4])
    cb_.append(cb[4*i:4*i + 4])

o.write('P3\n')
o.write('1024 666\n')
o.write('#spicec dump\n')
o.write('255\n')


for i in range(len(y_)):
    x = int(i % 1024)
    y = int(i / 1024)
    x_c = int(x / 2)
    y_c = int(y / 2)
    m = y_c * 512 + x_c


    y__ = int(y_[i], 16) 


   

    if y__ > 255:   
        y__ = y__ - 65536


    cr__ = int(cr_[m], 16) 
    if cr__ > 255:
        cr__ = cr__ - 65536

    cb__ = int(cb_[m], 16) 
    if cb__ > 255:
        cb__ = cb__ - 65536


    r = 128 + y__ + cb__ * 1.402


    if r < 0:
        r = 0
    elif r > 255:
        r = 255

    g = 128 + y__ - cr__* 0.34414 - cb__ * 0.71414;


    if g < 0:
        g = 0
    elif g > 255:
        g = 255
    


    b = 128 + y__ + cr__ * 1.772;


    if b < 0:
        b = 0
    elif b > 255:
        b = 255
    

    o.write(str(int(r)) + '\n')
    o.write(str(int(g)) + '\n')
    o.write(str(int(b)) + '\n')
    
o.close()
yf.close()
crf.close()
cbf.close()
